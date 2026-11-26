# Momentos de la demo

## En escena (guía rápida)

Una vez, en `~/.zshrc`:
```bash
alias demo='bash <(git -C ~/Documents/projects/flutter-agentic-harness show main:demo/go.sh)'
```

Flujo por momento (el simulador y la app los levantas tú, siempre después del reset):

| Momento | 1. Terminal A | 2. Terminal B | 3. En Claude |
|---|---|---|---|
| A + C | `demo ac` (resetea y espera) | `fvm flutter run -d "iPhone 17"`; luego Enter en la terminal A | **A:** se abre con el prompt ya enviado. **C:** `demo copy c` → Cmd+V, Enter. |
| D | `q` en la terminal de `flutter run`, luego `demo d` | `fvm flutter run -d "iPhone 17"`; luego Enter en la terminal A | Se abre con el prompt de D ya enviado. |
| B | `demo b` (para grabar: dos ventanas, sin y con harness, con el mismo prompt) | — | Nada: el prompt ya va enviado. |

Los prompts de A y D empiezan con *"Conéctate con el MCP de Dart a la app que está
corriendo en el iPhone"*: el agente la encuentra por el Dart Tooling Daemon que levanta
`flutter run`. Entre momentos hay que cortar `flutter run` (`q`) y volver a lanzarlo
después del reset, para que la app corra el código del nuevo momento.

Claude se abre sin memoria automática, con las tools de la demo preaprobadas (no pide
permisos en escena) y con una instrucción de estilo al inicio del primer mensaje (respuestas de
3 a 5 líneas que terminan con una línea "Usé:" con las tools del MCP y los skills usados).
`demo copy c` agrega un recordatorio corto de ese estilo al prompt de C.

## Detalle

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
| **A** | Contexto (MCP) | `demo-a-start` | `prompts/a.md` (app levantada a mano) | `dtd` connect → `get_runtime_errors` → `widget_inspector`; explica el `RenderFlex overflowed` apuntando al `Row` del título en `SessionCard`. No corrige. | 19 s (manual, 2026-11-25) |
| **B** | Reglas (Rules + Skills) | `demo-b-start` | `prompts/b.md` | Mismo modelo y prompt, con y sin harness; se puntúa con `scorecard.md`. | _pendiente_ |
| **C** | Iteración (Hot Reload) | `demo-a-start` | `prompts/setup.md` + `prompts/c.md` | `flutter-fix-layout-issues` → edita → `hot_reload` → `get_runtime_errors` vacío → árbol de widgets. Sin reiniciar la app. | _pendiente_ |
| **D** | Validación (Hooks + tests) | `demo-d-start` | `prompts/d.md` (app levantada a mano) | `flutter_driver_command` recorre la app → `flutter-add-integration-test` lo convierte en test en `integration_test/` → `run_tests` → Stop hook (analyze + tests). | _pendiente_ |

## La app la levanta el presentador

El MCP puede conectarse a una app que levantaste tú con `fvm flutter run`: la encuentra con
`dtd listDtdUris` y se conecta (probado en la prueba manual de A + C, 2026-11-24).

Historia de este flujo:
- Primeros ensayos sin interfaz, con la app sin lanzar: el agente de A diagnosticó leyendo
  el último commit y corriendo tests, y el de C no pudo hacer hot reload.
- Un setup separado ("lanza la app") tampoco servía: al lanzarla, el agente leía
  `get_runtime_errors` por iniciativa propia y diagnosticaba el bug antes de escena.
- Por eso los prompts de A y D empiezan pidiendo conectarse a la app que ya corre.

`prompts/setup.md` queda solo para los ensayos sin interfaz (`rehearse.sh`), donde no hay
nadie que levante la app.

## Notas por momento

**A — "que lea, no que adivine".** El bug es realista: alguien movió la estrella junto al
título con un `Row(mainAxisAlignment: spaceBetween)` sin `Expanded`/`Flexible`
(commit `feat: show the favorite star next to the session title`). Con títulos largos →
`RenderFlex overflowed`. Los widget tests de layout fallan con ese bug, pero el Stop hook
solo verifica cuando el agente cambió código: en el setup y en A (solo diagnóstico) no
bloquea. En C, cuando el agente edita, sí exige analyze y tests en verde.

**B — el misterio.** `reset.sh b` crea dos worktrees hermanos desde `demo-b-start`:
`<repo>-b-sin` (sin harness) y `<repo>-b-con` (con `CLAUDE.md`, `.claude/` y `.mcp.json`
del harness final, el de `demo-d-start`). Correr `claude` en cada uno con el mismo prompt y puntuar con
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
