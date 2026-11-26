# Momento A + C — corrida manual en escena (2026-11-25)

Flujo final: `demo ac` → `fvm flutter run -d "iPhone 17"` (a mano) → Enter → Claude abre
con el prompt de A ya enviado → `demo copy c` → Cmd+V, Enter. Opus 5.5, sin memoria
automática, plugins de usuario desactivados. Sin intervención manual aparte de los prompts.

## A — Contexto (MCP) · 19 s

Prompt (tras el texto de estilo):
> Conéctate con el MCP de Dart a la app que está corriendo en el iPhone. Algo se ve mal en
> la agenda: revisa qué pasa. Solo diagnostica, todavía no corrijas nada.

Respuesta: `RenderFlex overflowed by 154 pixels on the right` en el `Row` de
`lib/ui/core/widgets/session_card.dart:69` (`SessionCard`): `Text(session.title)` sin
`Expanded`/`Flexible` junto al `IconButton` de la estrella; el título largo mide 441.9 px y
la fila tiene 336 px. Atribuido al último commit. No corrigió nada.

Usé: get_runtime_errors (más la conexión por `dtd`).

## C — Iteración (Agentic Hot Reload) · 1 min 10 s

Prompt:
> Corrige el problema de la agenda en el iPhone y verifica que quedó bien, sin reiniciar la
> app. Responde corto y preciso (3 a 5 líneas) y termina con la línea "Usé:".

Respuesta: envolvió `Text(session.title)` en `Expanded`; aplicó con hot reload sin reiniciar;
`get_runtime_errors` vacío y `analyze_files` sin errores. Ajustó un test de favoritas
(`ensureVisible` antes del tap, porque las cards ahora son más altas): 29 tests en verde.
El Stop hook corrió al final (había cambios de código) y pasó.

Usé: flutter-fix-layout-issues, hot_reload, get_runtime_errors, analyze_files, run_tests.

## Observaciones

- A no usó `widget_inspector`: el error en tiempo de ejecución ya traía el widget y la
  línea exactos.
- C cargó el skill `flutter-fix-layout-issues` por su cuenta.
