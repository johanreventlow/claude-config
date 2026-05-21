# Workflow Orchestration

Orkestrerings-mønstre for plan-mode, self-improvement, elegance-check,
autonom bug-fixing. Komplementerer `WORKFLOW_PREFERENCES.md`
(subagents, OpenSpec) + `DEVELOPMENT_PHILOSOPHY.md` (TDD, verification).

---

## 1. Plan-Mode default

**Triggers** (enter plan-mode før kode-edits):
- Non-trivielle opgaver: 3+ trin eller arkitektoniske beslutninger
- Verifikations-flows, ej kun feature-bygning
- Detaljerede specs upfront — reducer ambiguitet før implementation

**Re-plan-trigger:** Noget går sidelæns → STOP + re-plan straks. Ej blind
push videre med oprindelig plan.

**Skip plan-mode for:**
- Trivielle one-liner-fixes
- Bruger har givet eksplicit step-by-step instruktion
- Read-only analyse uden edits

OpenSpec-flow (`/opsx:propose`) bruges når change er behavioral/architectural —
se `WORKFLOW_PREFERENCES.md`.

---

## 2. Self-improvement loop

Bruger-korrektion = obligatorisk memory-update.

| Trin | Handling |
|------|----------|
| 1 | Bruger korrigerer eller bekræfter overraskende valg |
| 2 | Identificér pattern (ej bare instansen) |
| 3 | Skriv/opdatér `feedback_*.md` i memory med **Why:** + **How to apply:** |
| 4 | Link til relateret memory via `[[name]]` |
| 5 | Læs relevante memories ved næste session-start |

**Format:** Auto-memory system (`~/.claude/projects/<repo>/memory/`).
Ej fil-baseret `tasks/lessons.md` — memory-systemet er primær persistens
på tværs af sessions.

**Review-cadence:** Kvartalsvis — arkivér AFSLUTTET/PAUSET entries ud af
`MEMORY.md`-index. Se `feedback_memory_review_cadence`.

---

## 3. Elegance-check (balanceret)

**Pause-trigger** for non-trivielle ændringer:
- "Er der en mere elegant måde?"
- Fix føles hacky → re-implementér med "knowing everything I know now"-mindset
- Challenge eget arbejde før præsentation

**Skip elegance-check for:**
- Simple obvious fixes (typo, navn-ændring, isoleret patch)
- Bug-fix der genopretter existing behavior uden refactor-mulighed
- Tids-kritiske hotfixes (markér eksplicit, fix elegant i opfølgning)

**Anti-pattern:** Over-engineering simple fixes for "elegance" → strider mod
core-princip om minimal impact.

---

## 4. Autonom bug-fixing

Bug-rapport modtaget: fix direkte. Ej hand-holding-spørgsmål.

**Workflow:**
1. Identificér evidens (logs, errors, failing tests)
2. Trace root cause (ej symptom-fix)
3. Implementér fix + test
4. Rapportér: hvad fejlede, hvorfor, hvordan fixed

**Failing CI:** Fix uden at bede bruger om opskrift. Diagnose **alle**
root causes i én pass før næste push — undgå incremental
"push-and-see-what-breaks"-cycles (forurener history, skjuler reelle
årsager, spilder CI-minutter). Lokal repro først (`devtools::check()`,
relevante test-filer, manifest-validering). Følg eksisterende
fix-patterns (`.claude/fix-patterns.jsonl` per repo hvis tilgængelig).

**Eskalér til bruger KUN ved:**
- Ambiguøs intent (flere valide fortolkninger af "korrekt adfærd")
- Destruktive actions kræves (jf. global rule §8)
- Cross-repo breaking change overvejes
- Threat-model-vurdering kræver bruger-kontekst

---

## 5. Issue resolution workflow

GitHub-issue modtaget: disciplineret flow før kode.

1. **Verificér premiss først** — inspicér current code/behavior, tjek
   om sibling-PRs har løst issuet, søg duplikater. Mange issues
   lukkes med evidens (`gh issue comment` + close) frem for kode.
   Spar reviewer-tid + undgå unødvendige PRs.
2. **Worktree før kode** — opret `git worktree add` ved
   issue-resolution (ej kun ved parallel agents). Isolerer fra
   pågående work + tillader trygge eksperimenter uden at forurene
   nuværende branch.
3. **Atomisk PR** — én logisk fix per PR, `--draft` default,
   reference `closes #N` i body. Større issues splittes i flere
   PRs frem for mega-commit.

**Eskalér til bruger ved:** ambiguøs intent, scope-tvivl, destruktive
actions (jf. global rule §8), cross-repo breaking changes.

---

## 6. Core principles

| Princip | Betydning |
|---------|-----------|
| **Simplicity first** | Hver ændring så simpel som muligt. Minimal kode-impact. |
| **No laziness** | Find root causes. Ingen midlertidige fixes uden eksplicit markering. Senior-developer-standard. |
| **Minimal impact** | Ændringer rører kun nødvendigt. Undgå at introducere bugs i urørte områder. |

**Anvendelse:** Trivielle fixes = direkte. Non-trivielle = plan-mode +
elegance-check + verification (jf. `DEVELOPMENT_PHILOSOPHY.md`).

---

## Task-tracking: TodoWrite + memory

Brug **TodoWrite** for in-session task-tracking (ej fil-baseret `tasks/todo.md`).
Bruger ser todo-liste live i UI; memory-system persister på tværs sessions.

**Hvorfor ej fil-baseret:**
- TodoWrite = native Claude Code-tool, integreret med UI
- Memory-system håndterer cross-session persistens via struktureret pattern
- Fil-baseret `tasks/todo.md` introducerer duplikation + drift-risiko

**Undtagelse:** Projekt har eksisterende `tasks/`-konvention → respektér lokal
struktur (project CLAUDE.md overrider global).

---

**Sidst opdateret:** 2026-05-14
**Del af:** ~/.claude/ global configuration system
