#!/usr/bin/env bash
# Deja el repo en el estado de inicio de un momento de la demo. Idempotente.
#
# Uso, desde cualquier estado del repo (también si demo/ no existe en el
# checkout actual, como pasa en los estados de demo):
#   bash <(git show main:demo/reset.sh) <a|b|c|d>
# o, si estás en main:
#   demo/reset.sh <a|b|c|d>
#
#   a, c  -> rama demo-run en demo-a-start (bug de layout en SessionCard)
#   d     -> rama demo-run en demo-d-start (app de stage-3-app)
#   b     -> dos worktrees hermanos desde demo-b-start:
#              <repo>-b-sin  sin CLAUDE.md, .claude/ ni .mcp.json
#              <repo>-b-con  + CLAUDE.md, .claude/ y .mcp.json del harness final
#                            (el de demo-d-start: stage-2-harness + Stop hook ajustado)
#
# No toca el simulador ni la app: el presentador los levanta a mano DESPUÉS del
# reset (fvm flutter run -d "iPhone 17"), para que la app corra el código del momento.
#
# Todo el script vive en funciones y se ejecuta al final: así bash lo lee
# completo antes de que `git switch` cambie (o borre) este mismo archivo.

usage() {
  echo "Uso: bash <(git show main:demo/reset.sh) <a|b|c|d>   (o demo/reset.sh <momento> desde main)" >&2
}

repo_root() {
  # Funciona también desde dentro de un worktree de B.
  dirname "$(git rev-parse --path-format=absolute --git-common-dir)"
}

reset_demo_run() {
  local tag="$1" current
  current="$(git branch --show-current || true)"
  if [[ "$current" != "demo-run" && -n "$(git status --porcelain)" ]]; then
    echo "Hay cambios sin commit en '${current:-HEAD}'. Haz commit o stash antes de resetear." >&2
    exit 1
  fi
  # demo-run es desechable: se descartan sus cambios y archivos nuevos.
  git switch --quiet --force -C demo-run "$tag"
  git clean -fdq
  rm -rf build
  fvm flutter pub get >/dev/null
  echo "Repo: rama demo-run en $tag ($(git rev-parse --short HEAD))."
}

reset_b_worktrees() {
  local root="$1" parent name side wt
  parent="$(dirname "$root")"
  name="$(basename "$root")"
  for side in sin con; do
    wt="$parent/$name-b-$side"
    git worktree remove --force "$wt" 2>/dev/null || true
    rm -rf "$wt"
    git worktree prune
    git worktree add --quiet --detach "$wt" demo-b-start
  done

  # Toma CON harness: las 3 piezas del harness final (el mismo de A, C y D).
  wt="$parent/$name-b-con"
  git archive demo-d-start CLAUDE.md .claude .mcp.json | tar -x -C "$wt"
  # Equivale a aprobar el MCP server del proyecto al abrir `claude`.
  printf '{\n  "enabledMcpjsonServers": ["dart"]\n}\n' >"$wt/.claude/settings.local.json"

  for side in sin con; do
    wt="$parent/$name-b-$side"
    # Crea .fvm/flutter_sdk (lo usa .mcp.json) y resuelve dependencias.
    (cd "$wt" && fvm use --force >/dev/null 2>&1 && fvm flutter pub get >/dev/null)
    echo "Worktree $side: $wt ($(git -C "$wt" rev-parse --short HEAD))"
  done
}

main() {
  set -euo pipefail
  local moment="${1:-}" root
  root="$(repo_root)"
  cd "$root"
  case "$moment" in
    a | c) reset_demo_run demo-a-start ;;
    d) reset_demo_run demo-d-start ;;
    b) reset_b_worktrees "$root" ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "$@"
exit
