# Scorecard — Momento B (mismo modelo, mismo prompt, con y sin harness)

Criterios **binarios**, fijados **antes** de correr cualquier toma
(commit de este archivo anterior a las tomas). No se cambian después.

Prompt (idéntico en todas las tomas): `demo/prompts/b.md`
> Agrega la vista de Mi agenda adaptada a tablet: en pantallas anchas muestra la
> agenda y Mi agenda lado a lado.

Punto de partida: `demo-b-start` (= `stage-1-base` sin `SPEC.md`), en dos worktrees
creados por `demo/reset.sh b`. La única diferencia entre ambos es la presencia de
`CLAUDE.md`, `.claude/` y `.mcp.json` copiados de `stage-2-harness`.

## Criterios

| # | Criterio | Pasa si… | Cómo se verifica |
|---|---|---|---|
| 1 | Layout por constraints | La decisión de "lado a lado" usa `LayoutBuilder`/`BoxConstraints`, y el diff **no** agrega `MediaQuery…size`, `Platform.`/`defaultTargetPlatform` ni checks de tipo de dispositivo. | `demo/score-b.sh` (grep sobre el diff) + revisión del diff. |
| 2 | Breakpoints con nombre | El umbral de ancho es una constante con nombre; no hay comparaciones de ancho contra literales numéricos (`maxWidth > 700`). | `demo/score-b.sh` (grep de comparaciones con literales) + revisión del diff. |
| 3 | La UI no lee el JSON | Ningún archivo con widgets (`StatelessWidget`/`StatefulWidget`/`State<`) usa `rootBundle`, `jsonDecode` ni la ruta del JSON. | `demo/score-b.sh` (grep sobre `lib/`). |
| 4 | Widget test nuevo | El diff agrega al menos un `testWidgets(` en `test/`. | `demo/score-b.sh` (grep sobre el diff). |
| 5 | Analyze sin errores | `fvm flutter analyze` termina sin issues de nivel `error`. | `demo/score-b.sh` (salida guardada). |
| 6 | Tests en verde | `fvm flutter test` termina con todos los tests pasando. | `demo/score-b.sh` (salida guardada). |

Notas:
- La app base (`demo-b-start`) **ya incumple el criterio 3**: la lista se carga
  con `rootBundle` dentro de un widget. Para pasarlo, la toma tiene que mover la
  carga a una capa de datos.
- Los criterios 1 y 2 tienen chequeo automático por grep, pero el veredicto final
  sale de leer el diff: el script lo marca como `REVISAR` cuando el grep no basta.

## Condiciones de las tomas

- 3 tomas por lado, todas reportadas (no solo la mejor).
- Mismo modelo y mismas opciones de CLI en todas: `claude -p` con
  `--permission-mode acceptEdits` y la misma lista de tools permitidas.
- Plugins de usuario `superpowers` y `postman` **desactivados** en todas las tomas.
- Evidencia por toma en `evidence/b-sin-harness/<n>/` y `evidence/b-con-harness/<n>/`:
  `diff.patch`, `analyze.txt`, `test.txt`, `score.md`, `transcript.txt`.

## Resultados

_(se completa después de correr las tomas)_
