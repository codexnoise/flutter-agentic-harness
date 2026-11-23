#!/usr/bin/env bash
# PostToolUse (Edit|Write|MultiEdit): formatea con `fvm dart format` el archivo
# editado si es .dart. Nunca bloquea: si el formato falla (p. ej. el archivo
# aún no compila), lo avisa por stderr y sigue.
set -u

input="$(cat)"
file="$(jq -r '.tool_input.file_path // empty' <<<"$input")"

[[ "$file" == *.dart && -f "$file" ]] || exit 0

cd "${CLAUDE_PROJECT_DIR:-$(jq -r '.cwd' <<<"$input")}" || exit 0

if ! out="$(fvm dart format "$file" 2>&1)"; then
  echo "format.sh: fvm dart format falló en $file:" >&2
  echo "$out" | tail -n 5 >&2
  exit 1 # no bloqueante
fi
exit 0
