#!/usr/bin/env bash
# Stop: antes de que el agente termine, corre `fvm flutter analyze` y
# `fvm flutter test`. Si algo falla, sale con 2 (impide que el agente termine)
# y manda a stderr un resumen corto para que lo corrija y vuelva a intentar.
set -u

input="$(cat)"

# Anti-loop: si ya estamos en un reintento provocado por este hook, no bloquear
# de nuevo (el agente ya recibió el error una vez).
if [[ "$(jq -r '.stop_hook_active // false' <<<"$input")" == "true" ]]; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$(jq -r '.cwd' <<<"$input")}" || exit 0
[[ -f pubspec.yaml ]] || exit 0

# Solo se valida el trabajo del agente: si no hay cambios sin commit en código
# Dart o en la configuración del paquete, no hay nada nuevo que verificar
# (p. ej. un turno que solo lanza la app o solo diagnostica).
if git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
  [[ -z "$(git status --porcelain -- '*.dart' pubspec.yaml pubspec.lock analysis_options.yaml)" ]]; then
  exit 0
fi

failed=0
summary=""

if ! analyze_out="$(fvm flutter analyze 2>&1)"; then
  failed=1
  issues="$(grep -E '^\s*(error|warning|info) •' <<<"$analyze_out" | head -n 15)"
  summary+=$'── fvm flutter analyze FALLÓ ──\n'"${issues:-$(tail -n 15 <<<"$analyze_out")}"$'\n\n'
fi

if ! test_out="$(fvm flutter test --reporter=expanded 2>&1)"; then
  failed=1
  failures="$(grep -E '\[E\]|Expected:|Actual:|Which:|Error:|Exception| line [0-9]+|\.dart [0-9]+:[0-9]+' <<<"$test_out" | head -n 20)"
  summary+=$'── fvm flutter test FALLÓ ──\n'"${failures:-$(tail -n 20 <<<"$test_out")}"$'\n'"$(tail -n 1 <<<"$test_out")"$'\n'
fi

if (( failed )); then
  {
    echo "Stop hook: la tarea NO está terminada. Corrige esto y vuelve a verificar:"
    echo
    echo "$summary"
  } >&2
  exit 2
fi
exit 0
