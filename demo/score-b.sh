#!/usr/bin/env bash
# Evalúa una toma del Momento B contra demo/scorecard.md.
# Uso: demo/score-b.sh <worktree> <dir-de-evidencia>
# Escribe diff.patch, analyze.txt, test.txt y score.md en <dir-de-evidencia>.
set -uo pipefail

wt="$(cd "$1" && pwd)"
out="$2"
mkdir -p "$out"
out="$(cd "$out" && pwd)"
cd "$wt"

# Diff completo contra el punto de partida, incluidos archivos nuevos.
git add -A -N . >/dev/null 2>&1
git diff demo-b-start -- . ':(exclude)CLAUDE.md' ':(exclude).claude' ':(exclude).mcp.json' \
  ':(exclude)pubspec.lock' >"$out/diff.patch"
added="$(grep -E '^\+[^+]' "$out/diff.patch" || true)"

fvm flutter analyze >"$out/analyze.txt" 2>&1
fvm flutter test >"$out/test.txt" 2>&1
test_exit=$?

verdict() { [[ "$1" == 0 ]] && echo "✅" || echo "❌"; }

# 1. Constraints, no MediaQuery size / plataforma / tipo de dispositivo.
uses_lb=$(grep -cE 'LayoutBuilder|BoxConstraints|constraints\.maxWidth' <<<"$added")
bad_mq=$(grep -cE 'MediaQuery\.(sizeOf|of\(.*\)\.size)|\.size\.width|Platform\.|defaultTargetPlatform|isTablet|shortestSide' <<<"$added")
c1=1; [[ $uses_lb -gt 0 && $bad_mq -eq 0 ]] && c1=0

# 2. Umbral de ancho con nombre y sin literales en las comparaciones.
#    (Independiente del criterio 1: no importa si el ancho sale de constraints o no.)
magic=$(grep -cE '(maxWidth|width|Width)\s*(>=|<=|>|<)\s*[0-9]' <<<"$added")
named=$(grep -cE 'const (double|int|num) \w*([Bb]reakpoint|[Ww]idth)\w*|Breakpoints?\.' <<<"$added")
c2=1; [[ $magic -eq 0 && $named -gt 0 ]] && c2=0

# 3. Ningún archivo con widgets lee el JSON.
json_in_ui=0
while IFS= read -r f; do
  if grep -qE 'extends (StatelessWidget|StatefulWidget)|extends State<' "$f" &&
    grep -qE 'rootBundle|jsonDecode|devfest_agenda\.json' "$f"; then
    json_in_ui=$((json_in_ui + 1)); echo "    JSON en UI: ${f#./}" >>"$out/.c3"
  fi
done < <(find lib -name '*.dart')
c3=1; [[ $json_in_ui -eq 0 ]] && c3=0

# 4. Al menos un testWidgets nuevo en test/.
new_tests=$(awk '/^\+\+\+ b\/test\//{t=1;next} /^\+\+\+ /{t=0} t && /^\+.*testWidgets\(/' "$out/diff.patch" | wc -l | tr -d ' ')
c4=1; [[ $new_tests -gt 0 ]] && c4=0

# 5. Analyze sin errores.
an_errors=$(grep -cE '^\s*error •' "$out/analyze.txt")
c5=1; [[ $an_errors -eq 0 ]] && c5=0

# 6. Tests en verde.
c6=$test_exit

score=$(( (c1==0) + (c2==0) + (c3==0) + (c4==0) + (c5==0) + (c6==0) ))
{
  echo "# Score — $(basename "$out") ($(basename "$wt"))"
  echo
  echo "| # | Criterio | Resultado | Detalle |"
  echo "|---|---|---|---|"
  echo "| 1 | Layout por constraints | $(verdict $c1) | LayoutBuilder/constraints en el diff: $uses_lb · MediaQuery size/plataforma/dispositivo: $bad_mq |"
  echo "| 2 | Breakpoints con nombre | $(verdict $c2) | umbral con nombre: $named · comparaciones de ancho con literal: $magic (REVISAR el diff) |"
  echo "| 3 | La UI no lee el JSON | $(verdict $c3) | archivos con widgets que leen el JSON: $json_in_ui |"
  echo "| 4 | Widget test nuevo | $(verdict $c4) | testWidgets( agregados: $new_tests |"
  echo "| 5 | Analyze sin errores | $(verdict $c5) | errores: $an_errors · $(tail -n 1 "$out/analyze.txt") |"
  echo "| 6 | Tests en verde | $(verdict $c6) | $(grep -E 'All tests passed|Some tests failed|No tests ran' "$out/test.txt" | tail -n 1 | sed -E 's/^[0-9:]+ //') |"
  echo
  echo "**Puntaje automático: $score / 6**"
  [[ -s "$out/.c3" ]] && { echo; cat "$out/.c3"; }
} >"$out/score.md"
rm -f "$out/.c3"
cat "$out/score.md"
