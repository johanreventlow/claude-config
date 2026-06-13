# Workflow

Arbejdsmetoder + orkestrering. Erstatter WORKFLOW_PREFERENCES.md +
WORKFLOW_ORCHESTRATION.md (merged 2026-06).

---

## OpenSpec

✅ **Projekter med `openspec/`:** Følg OpenSpec-workflow for non-trivielle
ændringer. Foreslå `/opsx:propose` ved nye features, breaking changes,
arkitektur-ændringer. Flow: explore → propose → apply → archive.

🆕 **Uden `openspec/`:** Foreslå `openspec init` kun ved større
arkitektur/API-ændringer.

❌ **Skip for:** bugfixes, typos, dependency-updates, config, tests for
eksisterende adfærd, throwaway-scripts.

---

## Skills

Invoker skills når reelt match — ikke "for sikkerheds skyld". Eksplicit
`/command` invokeres altid.

- **Pre-commit `/simplify`** ved ikke-trivielle kode-ændringer (>10 linjer
  el. ny funktion/modul). Ej nødvendig: docs, config, tests for
  eksisterende adfærd, rene refactors.
- **`/dual-review-cycle`** ved substantielle refactor-PRs (cross-package
  contracts, CI gates, executable snippets, empiriske claims). Skip for
  trivielle fixes og pure docs-PRs.

---

## Subagents

Context-firewalls, ikke default-workhorse. Triggers:
(a) 2+ uafhængige tasks i kø, (b) verbose output (>30k tokens) hvor
detaljer ej skal ind i main-context, (c) isoleret worktree-arbejde.

- **Model:** `sonnet` default. Opus kun ved arkitektur, kompleks debugging,
  nuanceret security-vurdering. Eskalér ved BLOCKED/lavt output.
- **Parallel (2+ samtidig): ALTID `isolation: "worktree"`** — delt working
  directory giver race conditions + forurenet test-state. Sekventielt:
  working directory fint. Review af parallel-PRs: merge server-side
  (`gh pr merge`), undgå lokal checkout mens agents arbejder.
- **Returformat:** koncise findings (10-20% af processeret), ej dumps.

---

## Issue resolution

1. **Verificér premiss først** — inspicér current code, tjek sibling-PRs,
   søg duplikater. Mange issues lukkes med evidens frem for kode.
2. **Worktree før kode** — isolerer fra pågående arbejde.
3. **Atomisk PR** — én logisk fix per PR, `--draft`, `closes #N`.
   Større issues splittes i flere PRs.

---

## Autonom bug-fixing

Bug-rapport: fix direkte, ingen hand-holding-spørgsmål. Evidens → root
cause → fix + test → rapportér.

**Failing CI:** Diagnostér **alle** root causes i én pass før næste push —
ingen incremental "push-and-see"-cycles. Lokal repro først. Følg
`.claude/fix-patterns.jsonl` per repo hvis tilgængelig.

**Eskalér KUN ved:** ambiguøs intent, destruktive actions (global regel §8),
cross-repo breaking change, threat-model kræver bruger-kontekst.

---

## Self-improvement

Bruger-korrektion = memory-update: identificér pattern (ej instansen),
skriv/opdatér feedback-memory med **Why:** + **How to apply:**, link via
`[[name]]`. Kvartalsvis review: arkivér afsluttede entries ud af
MEMORY.md-index.

---

## Core principles

| Princip | Betydning |
|---------|-----------|
| **Simplicity first** | Så simpel som muligt, minimal kode-impact |
| **No laziness** | Root causes, ingen umarkerede midlertidige fixes |
| **Minimal impact** | Rør kun nødvendigt, ingen bugs i urørte områder |

Non-trivielle ændringer: spørg "er der mere elegant måde?" før præsentation.
Over-engineering for "elegance" = anti-pattern.

---

**Sidst opdateret:** 2026-06-12
