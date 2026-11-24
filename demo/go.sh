#!/usr/bin/env bash
# Un comando por momento, pensado para escena.
#
#   demo ac   resetea el código de A/C y abre Claude. El prompt de A queda en el
#             portapapeles. Antes de pegarlo, levanta la app a mano en otra
#             terminal: fvm flutter run -d "iPhone 17"
#   demo d    igual para D.
#   demo b    resetea B y abre dos ventanas de Terminal (sin / con harness)
#             con el mismo prompt ya enviado. Pensado para grabar.
#   demo copy <a|b|c|d>   solo copia ese prompt al portapapeles.
#
# Instalar el alias una vez (en ~/.zshrc):
#   alias demo='bash <(git -C ~/Documents/projects/flutter-agentic-harness show main:demo/go.sh)'

# Tools permitidas sin preguntar (las mismas que usan los ensayos).
ALLOWED=(Read Edit Write Glob Grep Skill TodoWrite mcp__dart
  'Bash(fvm:*)' 'Bash(git status:*)' 'Bash(git diff:*)' 'Bash(git log:*)'
  'Bash(ls:*)' 'Bash(cat:*)' 'Bash(xcrun simctl:*)')

main() {
  set -euo pipefail
  local repo="${DEMO_REPO:-$HOME/Documents/projects/flutter-agentic-harness}"
  prompt() { git -C "$repo" show "main:demo/prompts/$1.md"; }
  reset() { (cd "$repo" && bash <(git show main:demo/reset.sh) "$1"); }

  case "${1:-}" in
    ac | d)
      local moment="$1" next
      reset "${moment:0:1}"
      next="$( [[ $moment == ac ]] && echo a || echo d )"
      prompt "$next" | pbcopy
      echo
      echo "▶ Prompt de $(tr a-z A-Z <<<"$next") copiado."
      echo "  1. En otra terminal (en $repo):  fvm flutter run -d \"iPhone 17\""
      echo "  2. Cuando la app esté corriendo: Cmd+V y Enter en Claude."
      [[ $moment == ac ]] && echo "  Para C, después: demo copy c"
      cd "$repo"
      CLAUDE_CODE_DISABLE_AUTO_MEMORY=1 exec claude --allowedTools "${ALLOWED[@]}"
      ;;
    b)
      reset b
      local parent side wt tools="" t
      parent="$(dirname "$repo")"
      for t in "${ALLOWED[@]}"; do tools+=" '$t'"; done
      for side in sin con; do
        wt="$parent/$(basename "$repo")-b-$side"
        # Script temporal por ventana: evita pelear con las comillas de AppleScript.
        printf '%s\n' "cd '$wt'" \
          "CLAUDE_CODE_DISABLE_AUTO_MEMORY=1 claude --allowedTools$tools -- \"\$(git -C '$repo' show main:demo/prompts/b.md)\"" \
          >"$TMPDIR/demo-b-$side.sh"
        osascript -e "tell application \"Terminal\" to do script \"bash '$TMPDIR/demo-b-$side.sh'\"" \
          -e 'tell application "Terminal" to activate' >/dev/null
      done
      echo "▶ Abrí dos ventanas de Terminal: b-sin y b-con, con el mismo prompt."
      ;;
    copy)
      prompt "${2:?Uso: demo copy <a|b|c|d>}" | pbcopy
      echo "▶ Prompt de ${2} copiado."
      ;;
    *)
      echo "Uso: demo <ac|d|b|copy a|b|c|d>  (ver git show main:demo/go.sh)" >&2
      exit 1
      ;;
  esac
}

main "$@"
exit
