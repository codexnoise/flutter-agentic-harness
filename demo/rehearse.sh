#!/usr/bin/env bash
# Ensaya un momento de la demo sin interfaz (claude -p) y guarda duración,
# tools/skills en orden, hooks y transcripción condensada.
#
# Uso (desde cualquier estado del repo):
#   bash <(git show main:demo/rehearse.sh) <a|c|d> [etiqueta]
#       resetea el momento con reset.sh y lo corre en el repo principal.
#   bash <(git show main:demo/rehearse.sh) <b-sin|b-con> [etiqueta]
#       corre el prompt de B en el worktree <repo>-b-<lado> tal como esté
#       (resetear antes con reset.sh b).
#
# Salida: <git-common-dir>/demo-rehearsals/<momento>-<etiqueta>/
#   (dentro de .git: sobrevive a los cambios de rama y no ensucia el árbol)
#   raw.jsonl, summary.md, transcript.txt (+ setup/ para A, C y D)
#
# Variables: DEMO_MODEL (default claude-opus-5-5).

ALLOWED_TOOLS=(
  Read Edit Write Glob Grep Skill TodoWrite
  mcp__dart
  "Bash(fvm:*)" "Bash(git status:*)" "Bash(git diff:*)" "Bash(git log:*)"
  "Bash(ls:*)" "Bash(cat:*)" "Bash(xcrun simctl:*)"
)

run_session() { # <dir> <out_dir> <prompt1> [prompt2]
  # Un solo proceso de claude para todos los prompts (entrada stream-json): así
  # el MCP server sigue vivo entre el setup y el prompt del momento, y ve la app
  # que lanzó. Cada respuesta se guarda en su propio archivo (setup / raw).
  local dir="$1" out="$2"
  shift 2
  # Sin memoria automática: la del proyecto contiene notas del plan de la demo.
  (cd "$dir" && CLAUDE_CODE_DISABLE_AUTO_MEMORY=1 python3 -I - "$out" "$MODEL" "$@" \
    -- "${ALLOWED_TOOLS[@]}" <<'PY'
import json, subprocess, sys, time
args = sys.argv[1:]
sep = args.index("--")
out, model, prompts, allowed = args[0], args[1], args[2:sep], args[sep + 1:]
names = ["setup", "raw"] if len(prompts) == 2 else ["raw"]
cmd = ["claude", "-p", "--model", model,
       "--input-format", "stream-json", "--output-format", "stream-json",
       "--verbose", "--include-hook-events", "--permission-mode", "acceptEdits",
       "--allowedTools", *allowed]
proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                        stderr=open(f"{out}/claude.err", "w"), text=True)
walls = {}
for name, prompt in zip(names, prompts):
    t0 = time.time()
    proc.stdin.write(json.dumps({"type": "user", "message": {"role": "user", "content": prompt}}) + "\n")
    proc.stdin.flush()
    with open(f"{out}/{name}.jsonl", "w") as f:
        for line in proc.stdout:
            f.write(line)
            try:
                if json.loads(line).get("type") == "result":
                    break
            except Exception:
                pass
    walls[name] = round(time.time() - t0)
proc.stdin.close()
proc.wait(timeout=120)
json.dump(walls, open(f"{out}/walls.json", "w"))
PY
  )
}

wall_of() { python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1])).get(sys.argv[2],"?"))' "$1" "$2"; }

summarize() { # <raw.jsonl> <out_dir> <moment> <label> <wall_seconds>
  python3 -I - "$@" <<'PY'
import json, sys, os, re
raw, out, moment, label, wall = sys.argv[1:6]
home = os.path.expanduser("~")
def clean(s): return s.replace(home, "~")
tools, skills, hooks, lines = [], [], [], []
result = {}
for l in open(raw):
    try: m = json.loads(l)
    except Exception: continue
    t, st = m.get("type"), m.get("subtype", "")
    if t == "system" and st == "hook_response" and m.get("hook_event") != "SessionStart":
        hooks.append(f"{m['hook_name']} exit={m.get('exit_code')}")
        lines.append(f"[HOOK {m['hook_name']}] exit={m.get('exit_code')}")
        if m.get("stderr"): lines.append("    " + clean(m["stderr"].strip()).replace("\n", "\n    "))
    elif t == "assistant":
        for c in m["message"]["content"]:
            if c["type"] == "text" and c["text"].strip():
                lines.append("[AGENTE] " + clean(c["text"].strip()).replace("\n", "\n         "))
            elif c["type"] == "tool_use":
                name = c["name"]
                if name == "ToolSearch": continue
                if name == "Skill":
                    sk = c["input"].get("skill", "?"); skills.append(sk); name = f"Skill({sk})"
                elif name.startswith("mcp__dart__"):
                    cmd = c["input"].get("command")
                    name = name.replace("mcp__dart__", "") + (f"({cmd})" if cmd else "")
                tools.append(name)
                lines.append(f"[TOOL] {name} {clean(json.dumps(c['input'], ensure_ascii=False))[:180]}")
    elif t == "user" and isinstance(m["message"].get("content"), list):
        for c in m["message"]["content"]:
            if c.get("type") == "tool_result":
                txt = c["content"] if isinstance(c["content"], str) else " ".join(x.get("text", "") for x in c["content"] if isinstance(x, dict))
                first = clean(txt.strip()).splitlines()[0][:180] if txt.strip() else ""
                if first: lines.append("  -> " + first)
    elif t == "result":
        result = m
os.makedirs(out, exist_ok=True)
open(os.path.join(out, "transcript.txt"), "w").write("\n".join(lines) + "\n")
dur = result.get("duration_ms")
summary = [
    f"# Ensayo {moment} — {label}", "",
    f"- Duración (claude, de prompt a resultado): {dur/1000:.0f} s" if dur else "- Duración: (sin resultado)",
    f"- Duración de pared: {wall} s",
    f"- Turnos: {result.get('num_turns')} · resultado: {result.get('subtype')} · costo: ${result.get('total_cost_usd', 0):.2f}",
    f"- Skills usados (en orden): {', '.join(skills) or 'ninguno'}",
    f"- Tools (en orden): {' → '.join(tools) or 'ninguna'}",
    f"- Hooks: {', '.join(hooks) or 'ninguno'}",
    "- Intervención manual: ninguna (corrida sin interfaz)",
]
open(os.path.join(out, "summary.md"), "w").write("\n".join(summary) + "\n")
print("\n".join(summary))
PY
}

main() {
  set -euo pipefail
  MODEL="${DEMO_MODEL:-claude-opus-5-5}"
  local moment="${1:-}" label="${2:-$(date +%Y%m%d-%H%M%S)}"
  local common root prompts out
  common="$(git rev-parse --path-format=absolute --git-common-dir)"
  root="$(dirname "$common")"
  out="$common/demo-rehearsals/$moment-$label"
  rm -rf "$out"; mkdir -p "$out"

  # Leer los prompts de main ANTES de resetear (los estados de demo no tienen demo/).
  read_prompt() { git -C "$root" show "main:demo/prompts/$1.md"; }

  local dir="$root" prompt setup="" t0
  case "$moment" in
    # El MCP solo ve las apps que lanzó en la misma sesión. A lanza la app en
    # su propio prompt; C (ensayado solo) y D necesitan setup.md antes.
    a) prompt="$(read_prompt a)" ;;
    c | d) prompt="$(read_prompt "$moment")"; setup="$(read_prompt setup)" ;;
    b-sin | b-con) prompt="$(read_prompt b)"; dir="$(dirname "$root")/$(basename "$root")-${moment}" ;;
    *) echo "Uso: rehearse.sh <a|b-sin|b-con|c|d> [etiqueta]" >&2; exit 1 ;;
  esac

  if [[ "$moment" =~ ^[acd]$ ]]; then
    bash <(git -C "$root" show main:demo/reset.sh) "$moment"
  fi
  [[ -d "$dir" ]] || { echo "No existe $dir (¿corriste reset.sh b?)" >&2; exit 1; }

  echo "Prompt ($moment): $prompt"
  if [[ -n "$setup" ]]; then
    echo "Setup: $setup"
    run_session "$dir" "$out" "$setup" "$prompt" || true
    summarize "$out/setup.jsonl" "$out/setup" "$moment-setup" "$label" "$(wall_of "$out/walls.json" setup)" >/dev/null
  else
    run_session "$dir" "$out" "$prompt" || true
  fi
  summarize "$out/raw.jsonl" "$out" "$moment" "$label" "$(wall_of "$out/walls.json" raw)"
  echo "Salida: $out"
}

main "$@"
exit
