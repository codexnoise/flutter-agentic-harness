# devfest_agenda — reglas del proyecto

App Flutter (iOS) con la agenda de un DevFest. Datos locales en `assets/devfest_agenda.json`, sin red.

## Comandos
- Siempre `fvm flutter ...` / `fvm dart ...` (versión fijada en `.fvmrc`). Nunca `flutter` ni `dart` a secas.
- Material se importa desde `package:material_ui/material_ui.dart` (Flutter 3.50).

## Arquitectura
- Sigue el skill `flutter-apply-architecture-best-practices`: capas UI / lógica / datos.
- La UI nunca lee el JSON (ni `rootBundle`) directamente: eso lo hace un repositorio en la capa de datos.

## Layout
- Decide el layout con `LayoutBuilder` y las constraints del espacio disponible.
  No uses `MediaQuery.size` ni el tipo de dispositivo (`Platform`, "es tablet").
- Breakpoints como constantes con nombre, definidas en un solo lugar. Nada de números mágicos en los widgets.

## Calidad
- Toda feature nueva lleva al menos un widget test (skill `flutter-add-widget-test`).
- Antes de dar una tarea por terminada: `analyze_files` sin errores y `run_tests` en verde, vía el MCP `dart`.
- Si la app está corriendo, diagnostica con el MCP (`get_runtime_errors`, `widget_inspector`) antes de adivinar.
