# flutter-agentic-harness

Demo de la charla **"Flutter + IA: No es el modelo, es el harness"** — DevFest Cuenca 2026.

> Link a la charla: _pendiente_ <!-- TODO: agregar la URL de la charla -->

Una app Flutter pequeña (la agenda de un DevFest) y, alrededor de ella, el **harness** que
hace que un agente de IA trabaje como lo haría el equipo. El harness vive **en el repo**:
lo comparte todo el equipo y un checkout sin esos archivos es un agente sin harness.

## La app

`devfest_agenda` (iOS): agenda de sesiones con filtros por track y nivel, detalle de la
sesión y "Mi agenda" con favoritas. Datos locales en `assets/devfest_agenda.json` (agenda de
ejemplo), sin backend ni red. Lista de una columna en pantalla angosta y grilla de 2–3
columnas en pantalla ancha.

## El harness: 4 piezas

| Pieza | Qué es | Dónde vive |
|---|---|---|
| **Contexto** | Dart & Flutter MCP server: el agente lee la app que está corriendo (errores, árbol de widgets) | `.mcp.json` |
| **Reglas** | Rules del proyecto + Agent Skills oficiales de Flutter y Dart | `CLAUDE.md`, `.claude/skills/` |
| **Iteración** | Agentic Hot Reload: el agente aplica sus cambios sin reiniciar la app | tool `hot_reload` del MCP |
| **Validación** | Hooks (formato al editar; analyze + tests antes de terminar) + tests | `.claude/settings.json`, `.claude/hooks/`, `test/`, `demo/scorecard.md` |

## Requisitos

- [fvm](https://fvm.app) con Flutter **3.50.0** (fijado en `.fvmrc`; todo comando va con `fvm`).
- Xcode con simuladores **iPhone 17** y **iPad Pro 13-inch (M5)**.
- [Claude Code](https://claude.com/claude-code) y `jq` (lo usan los hooks).

```bash
fvm install && fvm flutter pub get
fvm flutter test
fvm flutter run -d "iPhone 17"
```

## Reproducir la demo

Cada momento arranca desde un tag de git y tiene un prompt exacto. La guía completa (flujo en
escena, prompts, notas y duraciones medidas) está en **[`demo/README.md`](demo/README.md)**.

| Momento | Pieza | Tag de inicio | Qué se ve |
|---|---|---|---|
| **A** | Contexto | `demo-a-start` | El agente se conecta a la app corriendo y diagnostica un `RenderFlex overflowed` apuntando al widget exacto. |
| **B** | Reglas | `demo-b-start` | Mismo modelo y mismo prompt, con y sin harness, puntuados con un scorecard. |
| **C** | Iteración | `demo-a-start` | Corrige el bug de A con hot reload, sin reiniciar la app. |
| **D** | Validación | `demo-d-start` | Recorre la app con Flutter Driver y convierte el recorrido en un integration test. |

Atajo para escena (una vez, en `~/.zshrc`):

```bash
alias demo='bash <(git -C ~/Documents/projects/flutter-agentic-harness show main:demo/go.sh)'
```

`demo ac` / `demo d` dejan el código del momento y abren Claude con el prompt; `demo b`
abre las dos sesiones del Momento B lado a lado; `demo/reset.sh <a|b|c|d>` solo resetea.

### Resultado del Momento B

3 tomas por lado, todas reportadas (Opus 5.5, mismo prompt):

| | Puntaje (de 6) | Duración media | Turnos medios |
|---|---|---|---|
| Sin harness | 4, 4, 5 → **4.3** | 158 s | 28 |
| Con harness | 6, 6, 6 → **6.0** | 116 s | 16 |

El modelo solo ya hace mucho bien; el harness agrega, de forma estable, lo que el prompt no
pidió: separar los datos de la UI y decidir el layout por constraints. Detalle en
[`demo/scorecard.md`](demo/scorecard.md).

## Puntos de control (tags)

| Tag | Estado |
|---|---|
| `stage-1-base` | App base, sin harness (una columna, sin capas). |
| `stage-2-harness` | + MCP, skills, `CLAUDE.md` y hooks. |
| `stage-3-app` | App evolucionada con el harness: capas, layout responsivo, tests. |
| `demo-a-start` | Estado de inicio de A y C (bug de layout en `SessionCard`). |
| `demo-b-start` | Estado de inicio de B (app base). |
| `demo-d-start` | Estado de inicio de D. |

Los estados `demo-*` no incluyen `SPEC.md` ni `demo/` (describen el bug y los criterios, y el
agente podría leerlos).

## Estructura

```
lib/            app (data / domain / ui)
test/           unit y widget tests
.mcp.json       MCP server de Dart
CLAUDE.md       reglas del proyecto
.claude/        skills, hooks y settings del harness
demo/           momentos, prompts, scripts y scorecard
evidence/       capturas, árboles de widgets, salidas de tests y ensayos
SPEC.md         plan de trabajo de la demo
```
