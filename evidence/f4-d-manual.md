# Momento D — corrida manual en escena (2026-11-25) · 4 min 29 s

Flujo: `demo d` → app ya corriendo (`flutter run`) → Enter → Claude abre con el prompt de D
ya enviado. Opus 5.5, sin memoria automática. Sin intervención manual.

Prompt (tras el texto de estilo):
> Conéctate con el MCP de Dart a la app que está corriendo en el iPhone. Recorre la app como
> un usuario: filtra por el track AI, abre una sesión, márcala como favorita y verifica que
> aparece en Mi agenda. Después convierte ese recorrido en un integration test y córrelo.

## Qué hizo

1. Cargó `flutter-add-integration-test`.
2. Flutter Driver no estaba habilitado: creó un entrypoint con
   `enableFlutterDriverExtension()` y relanzó la app con `launch_app` (reemplaza la app que
   levantó el presentador).
3. Recorrió la app con `flutter_driver_command`: filtro AI → sesión "Creando Agentes IA en
   el navegador usando JavaScript" → favorita → Mi agenda. Varias llamadas fallidas por el
   camino: dos textos "AI" (chip y etiqueta de una card), timeout por frame sync, estrella
   del detalle sin finder fiable.
4. Agregó `ValueKey`s y aplicó con hot reload.
5. Escribió el integration test, lo corrió en el iPhone (verde), y cerró con
   `analyze_files` + `run_tests` (29 tests en verde).

## Qué cambió en el proyecto (lo configuró el skill)

- `test_driver/driver_main.dart`: entrypoint con `enableFlutterDriverExtension()`
  (lo creó en `lib/` y después lo movió a `test_driver/`, porque depende de una dev
  dependency).
- `test_driver/integration_test.dart`: `integrationDriver()`.
- `integration_test/favorite_ai_session_test.dart`: el recorrido como test permanente.
- `pubspec.yaml` / `pubspec.lock`: `flutter_driver` e `integration_test`.
- `ValueKey('filter_chip_<track>')` en el `FilterChip` (`agenda_view.dart`) y
  `ValueKey('detail_favorite_button')` en la estrella de `SessionDetailScreen`.

Usé: flutter-add-integration-test, dtd, flutter_driver_command, widget_inspector,
get_runtime_errors, get_app_logs, hot_reload, launch_app, analyze_files, stop_app, run_tests.

## Observaciones

- 4 min 29 s: pasa del límite de 2.5 min para ir en vivo.
- El agente cierra la app al terminar (`stop_app`): después de D no queda app corriendo.
- Un `timeout` de shell no existe en macOS (`command not found`); el agente siguió sin él.
