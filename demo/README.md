# Momentos de la demo

Cada momento arranca desde un **tag** y tiene un **prompt exacto** en `demo/prompts/`.
Para dejar el repo listo (desde cualquier estado):

```bash
bash <(git show main:demo/reset.sh) <a|b|c|d>   # o demo/reset.sh <momento> desde main
```

**En escena, abrir Claude Code sin memoria automática:** `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1 claude`.
La memoria del proyecto (en `~/.claude/projects/…`) guarda notas de la preparación de la
demo y el agente puede leerlas.

Los estados de demo **no incluyen** `SPEC.md` ni `demo/`: ambos describen el bug del
Momento A y los criterios del Momento B, y el agente podría leerlos.

| Momento | Pieza | Tag de inicio | Prompt | Qué debe pasar | Duración medida |
|---|---|---|---|---|---|
| **A** | Contexto (MCP) | `demo-a-start` | `prompts/setup.md` + `prompts/a.md` | `launch_app` → `get_runtime_errors` → `widget_inspector`; explica el `RenderFlex overflowed` apuntando al `Row` del título en `SessionCard`. No corrige. | _pendiente_ |
| **B** | Reglas (Rules + Skills) | `demo-b-start` | `prompts/b.md` | Mismo modelo y prompt, con y sin harness; se puntúa con `scorecard.md`. | _pendiente_ |
| **C** | Iteración (Hot Reload) | `demo-a-start` | `prompts/setup.md` + `prompts/c.md` | `flutter-fix-layout-issues` → edita → `hot_reload` → `get_runtime_errors` vacío → árbol de widgets. Sin reiniciar la app. | _pendiente_ |
| **D** | Validación (Hooks + tests) | `demo-d-start` | `prompts/setup.md` + `prompts/d.md` | `flutter_driver_command` recorre la app → `flutter-add-integration-test` lo convierte en test en `integration_test/` → `run_tests` → Stop hook (analyze + tests). | _pendiente_ |

## Antes de A, C y D: lanzar la app desde la sesión

El MCP solo ve (y solo puede hacer hot reload de) las apps que lanzó **en la misma sesión**
con `launch_app`. Por eso A, C y D empiezan pegando `prompts/setup.md` antes del
cronómetro. En los primeros ensayos, sin este paso, el agente de A diagnosticó leyendo el
último commit y corriendo tests (sin mirar la app), y el de C no pudo hacer hot reload.
En escena A y C van en la misma sesión: setup → A → C.

## Notas por momento

**A — "que lea, no que adivine".** El bug es realista: alguien movió la estrella junto al
título con un `Row(mainAxisAlignment: spaceBetween)` sin `Expanded`/`Flexible`
(commit `feat: show the favorite star next to the session title`). Con títulos largos →
`RenderFlex overflowed`. **El Stop hook va a disparar al final**: los widget tests de
layout fallan con ese bug, así que el hook bloquea al agente aunque el prompt diga "solo
diagnostica" y lo empuja a corregir. Es intencional y se cuenta como parte de la
historia: el hook también vigila.

**B — el misterio.** `reset.sh b` crea dos worktrees hermanos desde `demo-b-start`:
`<repo>-b-sin` (sin harness) y `<repo>-b-con` (con `CLAUDE.md`, `.claude/` y `.mcp.json`
de `stage-2-harness`). Correr `claude` en cada uno con el mismo prompt y puntuar con
`demo/score-b.sh <worktree> <evidencia>`. 3 tomas por lado, todas reportadas.
Plugins de usuario `superpowers` y `postman` desactivados durante las tomas.

**C — la historia continúa.** Mismo estado que A. La app corre durante todo el momento:
el agente edita, dispara `hot_reload` y vuelve a leer errores y árbol.

**D — validación.** Antes del cronómetro se pega `prompts/setup.md` (ver abajo).
Flutter Driver necesita la extensión habilitada: lo configura el skill
`flutter-add-integration-test` durante el momento; lo que cambie queda documentado aquí
después del ensayo.

## Archivos

- `reset.sh` — deja el estado de inicio de cada momento (idempotente).
- `prompts/*.md` — prompts exactos para pegar en escena.
- `scorecard.md` — criterios binarios del Momento B (fijados antes de correr) y resultados.
- `score-b.sh` — evalúa una toma de B y guarda diff, analyze, tests y puntaje.
