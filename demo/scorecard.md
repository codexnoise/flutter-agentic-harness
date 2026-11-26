# Scorecard — Momento B (mismo modelo, mismo prompt, con y sin harness)

Criterios **binarios**, fijados **antes** de correr cualquier toma
(commit de este archivo anterior a las tomas). No se cambian después.

Prompt (idéntico en todas las tomas): `demo/prompts/b.md`
> Agrega la vista de Mi agenda adaptada a tablet: en pantallas anchas muestra la
> agenda y Mi agenda lado a lado.

Punto de partida: `demo-b-start` (= `stage-1-base` sin `SPEC.md`), en dos worktrees
creados por `demo/reset.sh b`. La única diferencia entre ambos es la presencia de
`CLAUDE.md`, `.claude/` y `.mcp.json` del harness final (el de `demo-d-start`:
`stage-2-harness` + el ajuste del Stop hook que solo verifica cuando hay cambios de código,
hecho después de los primeros ensayos de A/C y antes de cualquier toma de B).

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

## Resultados (2026-11-25)

Opus 5.5, `claude -p`, sin memoria automática, plugins de usuario desactivados. Puntaje
automático de `demo/score-b.sh`, confirmado leyendo cada diff (criterios 1 y 2).

| Toma | Lado | 1 Constraints | 2 Breakpoints | 3 Sin JSON en UI | 4 Widget test | 5 Analyze | 6 Tests | Puntaje | Duración | Turnos |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | sin | ❌ `MediaQuery.sizeOf` | ✅ `_wideBreakpoint` | ❌ | ✅ 2 | ✅ | ✅ | **4/6** | 181 s | 34 |
| 1 | con | ✅ `LayoutBuilder` | ✅ `Breakpoints` | ✅ `AgendaRepository` | ✅ 3 | ✅ | ✅ | **6/6** | 125 s | 16 |
| 2 | sin | ❌ `MediaQuery.sizeOf` | ✅ `wideLayoutMinWidth` | ❌ | ✅ 3 | ✅ | ✅ | **4/6** | 151 s | 30 |
| 2 | con | ✅ `LayoutBuilder` | ✅ `Breakpoints` | ✅ `AgendaRepository` | ✅ 3 | ✅ | ✅ | **6/6** | 130 s | 17 |
| 3 | sin | ✅ `LayoutBuilder` | ✅ `wideLayoutMinWidth` | ❌ | ✅ 2 | ✅ | ✅ | **5/6** | 142 s | 21 |
| 3 | con | ✅ `LayoutBuilder` | ✅ `Breakpoints` | ✅ `AgendaRepository` | ✅ 2 | ✅ | ✅ | **6/6** | 94 s | 14 |

**Promedio:** sin harness **4.3/6** (4, 4, 5) · con harness **6/6** (6, 6, 6).
**Duración media:** sin 158 s · con 116 s. **Turnos medios:** sin 28 · con 16.

Lectura honesta:
- El modelo solo, sin harness, ya hace mucho bien: en las 3 tomas puso un breakpoint con
  nombre, agregó widget tests y dejó analyze y tests en verde.
- Lo que el harness cambia de forma consistente es lo que **nadie pidió en el prompt**:
  separar los datos de la UI (sin harness: 0 de 3) y decidir el layout por constraints
  (sin harness: 1 de 3; las otras 2 usaron `MediaQuery.sizeOf`).
- Con harness el resultado es **estable** (6/6 las 3 veces) y además **más rápido y con menos
  turnos**: las reglas le ahorran decisiones al agente.
- Nota: el agente con harness consultó los skills leyendo `.claude/skills/*` directamente
  (no con la tool `Skill`), así que el resumen de cada toma dice "skills: ninguno".

Evidencia por toma: `evidence/b-sin-harness/<n>/` y `evidence/b-con-harness/<n>/`.
