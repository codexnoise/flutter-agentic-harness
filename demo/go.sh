#!/usr/bin/env bash
# Un comando por momento, pensado para escena.
#
#   demo ac   resetea el código de A/C y espera: levanta la app a mano en otra
#             terminal (fvm flutter run -d "iPhone 17") y pulsa Enter. Se abre
#             Claude con el prompt de A ya enviado.
#   demo d    igual para D.
#   demo b    resetea B y abre dos ventanas de Terminal (sin / con harness)
#             con el mismo prompt ya enviado. Pensado para grabar.
#   demo copy <a|b|c|d>   solo copia ese prompt al portapapeles.
#
# Instalar el alias una vez (en ~/.zshrc):
#   alias demo='bash <(git -C ~/Documents/projects/flutter-agentic-harness show main:demo/go.sh)'

# Estilo de respuesta en escena: se agrega al system prompt (no se ve en pantalla)
# y vale para toda la sesión (A y C, o D).
STAGE_STYLE='Estás en una demo en vivo frente a público. Responde en español, corto y preciso: 3 a 5 líneas como máximo, sin encabezados ni listas largas. Di qué encontraste o qué hiciste y dónde (archivo y widget), nada más. Limítate a esta app y a la tarea pedida: no ofrezcas extras, alternativas ni explicaciones generales. Termina siempre con una última línea que empiece con "Usé:" y liste, en orden, las tools del MCP de Dart (por ejemplo get_runtime_errors, widget_inspector, hot_reload) y los Agent Skills (por ejemplo flutter-fix-layout-issues) que usaste en esa respuesta.'

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
      echo
      echo "▶ Código listo para el momento $(tr a-z A-Z <<<"$next")."
      echo "  En otra terminal (en $repo):  fvm flutter run -d \"iPhone 17\""
      read -r -p "  Cuando la app esté corriendo, pulsa Enter: abro Claude con el prompt de $(tr a-z A-Z <<<"$next")… " _
      [[ $moment == ac ]] && echo "  Para C, después: demo copy c (y Cmd+V, Enter)."
      cd "$repo"
      CLAUDE_CODE_DISABLE_AUTO_MEMORY=1 exec claude --append-system-prompt "$STAGE_STYLE" \
        --allowedTools "${ALLOWED[@]}" -- "$(prompt "$next")"
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
