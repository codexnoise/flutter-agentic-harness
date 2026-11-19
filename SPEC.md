# SPEC — flutter-agentic-harness

Demo de la charla **"Flutter + IA: No es el modelo, es el harness"** (DevFest Cuenca 2026).

Este documento lo ejecuta **Claude Code en la terminal**, en la Mac del desarrollador,
dentro de `~/Documents/projects/flutter-agentic-harness`. Trabaja **fase por fase** y
detente en cada ⏸ para reportar antes de continuar.

---

## 0. Qué estamos construyendo y por qué

Dos cosas a la vez:

1. **Una app Flutter pequeña**: la agenda de un DevFest (lista/grilla de sesiones,
   filtros, detalle, "Mi agenda" con favoritas). Datos locales en JSON, sin backend,
   sin red.
2. **El harness alrededor de la app**, versionado en el repo, con 4 piezas:

| Pieza | Qué es | Dónde vive en el repo |
|---|---|---|
| **Contexto** | Dart & Flutter MCP server: el agente lee la app viva | `.mcp.json` |
| **Reglas** | Rules del proyecto + Agent Skills oficiales | `CLAUDE.md`, `.claude/skills/` |
| **Iteración** | Agentic Hot Reload vía MCP | (tool del MCP) |
| **Validación** | Hooks + tests + criterios medibles | `.claude/settings.json`, `test/`, `integration_test/`, `demo/scorecard.md` |

Y un tercer entregable: **puntos de control (tags de git)** para que cada momento de
demo de la charla sea reproducible desde cero, las veces que haga falta.

> **Decisión de diseño clave:** todo el harness se instala a **nivel de proyecto**, no
> de usuario. Así (a) el mensaje de la charla es "el harness vive en el repo y lo
> comparte el equipo", y (b) un worktree sin esos archivos = un agente **sin harness**,
> que es justo la comparación que necesitamos.

### Reglas de oro para este SPEC
- Todo comando de Flutter/Dart va con **`fvm`** (`fvm flutter ...`, `fvm dart ...`).
- No improvises versiones ni workarounds silenciosos: si algo falla, reporta el error
  textual y detente.
- Commits atómicos y bien descritos (Conventional Commits). Nada de commits de relleno.
- Toda evidencia (árboles de widgets, salidas de tests, tiempos) va en `evidence/`.

---

## Fase 0 — Entorno (bloqueante)

⏸ Ejecuta y reporta:

```bash
fvm --version
fvm releases | tail -n 5           # para ver la última estable
sw_vers
xcodebuild -version
xcrun simctl list devices available | grep -E "iPhone|iPad"
claude --version
claude plugin list                 # ver si hay plugins a nivel usuario
claude mcp list                    # ver si hay MCP servers a nivel usuario
which jq rg
```

Requisitos:
- Flutter **última estable ≥ 3.47**, fijada en el proyecto con `fvm use <versión>`
  (crea `.fvmrc`). Dart ≥ 3.9 (requisito del MCP server).
- Un simulador **iPhone** (pantalla angosta) y uno **iPad** (pantalla ancha).
- `jq` instalado (lo usan los hooks). `rg` (ripgrep) recomendado (lo usa el MCP).
- **Importante:** si `claude plugin list` muestra el plugin `dart-flutter` a nivel
  usuario, o `claude mcp list` muestra un server `dart` a nivel usuario, **repórtalo**.
  Hay que desactivarlo para que la comparación "sin harness" sea honesta. No lo
  desinstales sin confirmación del desarrollador.

---

## Fase 1 — Scaffold y app base (sin harness todavía)

### 1.1 Crear el proyecto

```bash
fvm use <última-estable> --force
fvm flutter create --project-name devfest_agenda --org dev.codexnoise --platforms ios .
```

`assets/devfest_agenda.json` **ya existe en el repo** (lo dejó el desarrollador). No lo
sobrescribas. Regístralo en `pubspec.yaml` bajo `flutter.assets`.

> La agenda es **de ejemplo** (basada en el DevFest Ecuador 2025; la mayoría de las
> entradas tienen `illustrative: true`). Se reemplazará con la agenda oficial 2026.
> El código no debe asumir cantidades ni nombres concretos.

### 1.2 Modelo de datos

Cada entrada del JSON tiene: `id`, `title`, `speaker`, `track`, `time` (`HH:mm`),
`room`, `level` (`Intro` | `Intermedio` | `Avanzado`), `lang`, `illustrative` (bool).
`track` puede ser compuesto (`"Cloud/AI"`, `"Android/AI"`).

### 1.3 Funcionalidad de la app

1. **Agenda**: sesiones ordenadas por hora. Cada sesión es una `SessionCard` con
   hora, título, speaker, sala, track y nivel.
2. **Filtros**: por track (un `"Cloud/AI"` aparece al filtrar por `AI` y por `Cloud`)
   y por nivel. Chips seleccionables arriba de la lista.
3. **Detalle**: al tocar una sesión, pantalla de detalle.
4. **Mi agenda**: marcar/desmarcar favoritas (ícono de estrella en la card y en el
   detalle); una pestaña "Mi agenda" muestra solo las favoritas. Estado en memoria.

Esta fase se construye **de forma normal**, sin requisitos de arquitectura especiales:
es la línea base. Una sola columna (lista) en todos los tamaños de pantalla.

⏸ Reporta: la app corre en el simulador iPhone, `fvm flutter analyze` limpio, captura
de pantalla en `evidence/f1-base.png`. Commit + tag:

```bash
git tag stage-1-base
```

---

## Fase 2 — Instalar el harness (a nivel proyecto)

Una pieza por commit, en este orden.

### 2.1 Contexto — Dart & Flutter MCP server

```bash
claude mcp add --scope project --transport stdio dart -- dart mcp-server
```

Debe crear `.mcp.json` en la raíz. Si `dart` no resuelve al SDK de fvm, usa la ruta
absoluta del dart de fvm (`fvm flutter sdk-path` → `<sdk>/bin/dart`) y documenta la
decisión en el commit.

⏸ Verifica que, con la app corriendo, el agente puede usar: `launch_app`,
`list_running_apps`, `get_runtime_errors`, `widget_inspector`, `hot_reload`,
`flutter_driver_command`, `run_tests`, `analyze_files`. Reporta la lista de tools que
ves disponibles.

### 2.2 Reglas — Agent Skills oficiales

Instala los skills a nivel proyecto para Claude Code:

```bash
npx -y skills add flutter/agent-plugins --skill '*' --agent claude-code
npx -y skills add dart-lang/skills --skill '*' --agent claude-code
```

Deben quedar en `.claude/skills/`. Si los registros de skills muestran nombres viejos
o duplicados (el repo `flutter/skills` fue renombrado a `flutter/agent-plugins`),
quédate con lo que realmente se instaló.

Los que la demo usará obligatoriamente:
- `flutter-apply-architecture-best-practices`
- `flutter-build-responsive-layout`
- `flutter-fix-layout-issues`
- `flutter-add-widget-test`
- `flutter-add-integration-test`
- `dart-add-unit-test`

⏸ Reporta: `find .claude/skills -name SKILL.md | sort`. Si alguno de los 6 no existe con
ese nombre exacto, reporta el nombre equivalente que sí se instaló.

### 2.3 Reglas — `CLAUDE.md` (rules del proyecto)

Crea `CLAUDE.md` en la raíz. **Corto (máx. ~25 líneas), sin contradicciones.**
Contenido mínimo:

- Comandos: siempre `fvm flutter` / `fvm dart`.
- Arquitectura: seguir `flutter-apply-architecture-best-practices` (capas UI / lógica /
  datos). La UI no lee el JSON directamente.
- Layout: decidir con `LayoutBuilder` y el espacio disponible, con **breakpoints con
  nombre** (sin números mágicos). Nunca por tipo de dispositivo.
- Toda feature nueva lleva al menos un widget test.
- Antes de dar una tarea por terminada: `analyze_files` sin errores y `run_tests` en
  verde (vía MCP).
- Si la app está corriendo, diagnosticar con el MCP (`get_runtime_errors`,
  `widget_inspector`) antes de adivinar.

### 2.4 Validación — Hooks de Claude Code

Crea `.claude/settings.json` con dos hooks. **Antes de escribirlos, verifica el
formato actual en la documentación oficial de hooks de Claude Code** (nombres de
eventos, formato del JSON de entrada, semántica de los códigos de salida) y ajusta si
cambió.

1. **PostToolUse** sobre `Edit|Write|MultiEdit`: si el archivo editado termina en
   `.dart`, correr `fvm dart format <archivo>`.
2. **Stop**: correr `fvm flutter analyze` y `fvm flutter test`. Si alguno falla, salir
   con el código que **impide que el agente termine** (exit 2) y mandar a stderr un
   resumen corto del error, para que el agente lo corrija y vuelva a intentar.
   - Cuidar el loop infinito: si la entrada del hook indica que ya está activo un
     reintento por Stop hook (`stop_hook_active`), no bloquear de nuevo.

Pon los scripts en `.claude/hooks/` (`format.sh`, `verify.sh`), ejecutables, y que el
JSON solo los invoque.

⏸ Reporta: los 3 archivos, y una prueba manual: rompe a propósito un test, pídele al
agente una tarea trivial, y confirma que el Stop hook lo obliga a arreglarlo. Guarda la
salida en `evidence/f2-stop-hook.txt`. Revierte el test roto.

Commit + tag:

```bash
git tag stage-2-harness
```

---

## Fase 3 — Evolucionar la app CON el harness

Ahora el agente trabaja como trabajaría un equipo con harness. Cada paso usa
obligatoriamente su skill.

1. **Refactor de arquitectura** con `flutter-apply-architecture-best-practices`:
   separar datos (repositorio que carga el JSON), lógica (filtros, favoritas) y UI.
   Unit tests de la lógica de filtros con `dart-add-unit-test` (incluido el caso de
   tracks compuestos como `"Cloud/AI"`).
2. **Layout responsivo** con `flutter-build-responsive-layout`: lista de una columna
   en pantalla angosta, grilla de 2–3 columnas en pantalla ancha (iPad).
3. **Widget tests** con `flutter-add-widget-test`: angosto → lista; ancho → grilla;
   tocar la estrella marca la favorita.

⏸ Reporta: capturas iPhone e iPad (`evidence/f3-iphone.png`, `evidence/f3-ipad.png`),
árbol de widgets de cada uno vía `widget_inspector` (`evidence/f3-tree-*.txt`), tests
en verde. Commit + tag `stage-3-app`.

---

## Fase 4 — Preparar los 4 momentos de demo

Cada momento arranca desde un **tag** y tiene un **prompt exacto** que el desarrollador
pegará en escena. Escribe todo en `demo/`:

- `demo/README.md`: tabla de momentos (tag de inicio, prompt, qué debe pasar, duración
  medida).
- `demo/reset.sh <momento>`: deja el repo en el estado de inicio del momento
  (`git switch -C demo-run <tag>` + limpiar `build/`). Tiene que ser idempotente.
- `demo/prompts/<momento>.md`: el prompt exacto.

### Momento A — Contexto (MCP): "que lea, no que adivine"

- **Estado inicial (tag `demo-a-start`)**: a partir de `stage-3-app`, introduce un bug
  **realista**: en `SessionCard`, el título va en un `Row` sin `Expanded`/`Flexible`.
  Con títulos largos (hay uno de 52 caracteres) → `RenderFlex overflowed` en iPhone.
  Es el error que comete cualquiera; no lo disfraces como algo exótico. Commit con un
  mensaje neutro (no "bug intencional").
- **Prompt**: algo como *"En el iPhone algo se ve mal en la agenda. Revisa qué pasa."*
  (sin decir qué ni dónde).
- **Lo que debe verse**: el agente lanza la app (`launch_app`), lee
  `get_runtime_errors`, inspecciona el árbol con `widget_inspector` y **explica** la
  causa apuntando al widget exacto. **No corrige todavía** (el prompt lo pide:
  "solo diagnostica").

### Momento B — Reglas (Rules + Skills): el misterio

El momento más importante: **mismo modelo, mismo prompt, con y sin harness.**

- **Estado inicial (tag `demo-b-start`)** = `stage-1-base` + `assets/` (la app base,
  antes del refactor).
- **Toma SIN harness**: en un `git worktree` desde `demo-b-start` **sin** `CLAUDE.md`,
  `.claude/` ni `.mcp.json`. Correr `claude` ahí.
- **Toma CON harness**: worktree desde `demo-b-start` + copiar `CLAUDE.md`, `.claude/`
  y `.mcp.json` del `stage-2-harness`.
- **Prompt idéntico en ambas**: *"Agrega la vista de Mi agenda adaptada a tablet: en
  pantallas anchas muestra la agenda y Mi agenda lado a lado."*
- **Scorecard** (`demo/scorecard.md`), criterios binarios definidos **antes** de correr:
  1. Usa `LayoutBuilder`/constraints (no `MediaQuery.size` ni tipo de dispositivo).
  2. Breakpoints con nombre, sin números mágicos.
  3. La UI no lee el JSON directamente (capa de datos).
  4. Agregó al menos un widget test.
  5. `flutter analyze` sin errores al terminar.
  6. Tests en verde al terminar.
- Guarda el diff, la salida de analyze/test y el scorecard de cada toma en
  `evidence/b-sin-harness/` y `evidence/b-con-harness/`.
- ⚠️ **Honestidad**: reporta el resultado tal como salga. Si la toma sin harness saca
  más de lo esperado, se reporta así. Se corren **3 tomas de cada una** y se reporta
  cada puntaje (no solo la mejor).

### Momento C — Iteración (Agentic Hot Reload)

- **Estado inicial** = `demo-a-start` (el mismo bug del momento A: la historia
  continúa).
- **Prompt**: *"Corrige el problema de la agenda en el iPhone y verifica que quedó
  bien, sin reiniciar la app."*
- **Lo que debe verse**: usa `flutter-fix-layout-issues`, edita, dispara `hot_reload`,
  vuelve a leer `get_runtime_errors` (vacío) y el árbol de widgets. La app nunca se
  reinicia.

### Momento D — Validación (Hooks + tests)

- **Estado inicial (tag `demo-d-start`)** = `stage-3-app` con la app corriendo vía
  `launch_app`.
- **Prompt**: *"Recorre la app como un usuario: filtra por el track AI, abre una
  sesión, márcala como favorita y verifica que aparece en Mi agenda. Después convierte
  ese recorrido en un integration test y córrelo."*
- **Lo que debe verse**:
  1. El agente navega la app con `flutter_driver_command` (taps, navegación).
  2. Con `flutter-add-integration-test` convierte esas acciones en un test permanente
     en `integration_test/`.
  3. Lo corre con `run_tests`.
  4. Al terminar, el **Stop hook** corre analyze + tests. Ideal si en el camino el hook
     atrapa algo (formato, un analyze warning) y obliga a corregir; si no pasa
     naturalmente, **no lo fuerces**: deja documentado que el hook corrió y pasó.
- Requisito técnico: Flutter Driver necesita la extensión habilitada en la app. Deja
  que el skill lo configure y documenta qué cambió (por ejemplo, un `main` alterno para
  driver).

⏸ Reporta cada momento con: duración real (de prompt a resultado), qué tools/skills
usó el agente (en orden) y si hubo intervención manual.

---

## Fase 5 — Ensayo con datos móviles (hotspot del iPhone 17)

En la charla, la Mac estará conectada al **hotspot del iPhone 17 con datos móviles**.

1. Conecta la Mac al hotspot. Corre cada momento (A, C, D) **3 veces** con
   `demo/reset.sh` entre corridas. El B ya queda grabado.
2. Registra en `evidence/latency.md`: duración de cada corrida, y cualquier timeout o
   reintento del agente.
3. Recomienda cuáles momentos pueden ir **en vivo** (duración estable y < 2.5 min) y
   cuáles deben ir **grabados**.

---

## Fase 6 — Grabaciones de respaldo

Para **todos** los momentos (también los que irán en vivo):
- Grabar pantalla completa: simulador + terminal con Claude Code lado a lado.
- Archivos en `demo/recordings/` → **agregar `demo/recordings/` a `.gitignore`** (no
  subir videos al repo).
- Anotar en `demo/README.md` la duración de cada video crudo.

---

## Checklist final

- [ ] Tags: `stage-1-base`, `stage-2-harness`, `stage-3-app`, `demo-a-start`,
      `demo-b-start`, `demo-d-start`.
- [ ] `demo/reset.sh` funciona para A, B, C y D desde cualquier estado.
- [ ] Momento B: 3 tomas por lado, con scorecard y evidencia.
- [ ] `evidence/latency.md` con las corridas por hotspot.
- [ ] Grabaciones de los 4 momentos.
- [ ] El harness completo es visible en el repo: `.mcp.json`, `CLAUDE.md`,
      `.claude/skills/`, `.claude/settings.json`, `.claude/hooks/`.
- [ ] `README.md` del repo: qué es, link a la charla, cómo reproducir cada momento.
