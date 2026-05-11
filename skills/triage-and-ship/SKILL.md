---
name: triage-and-ship
description: >
  Autonomous PR-factory der triagerer GitHub-backlog, dispatcher
  parallel-pr-workflow på "ready"-issues, auto-fixer kendte CI-failures
  (manifest-drift, lint, styler) inden for retry-budget, og eskalerer kun
  ved final merge-approval. Bygger ovenpå /parallel-pr med tilføjet
  triage-pre-stage og auto-fix-post-stage. Use when user says
  "/triage-and-ship", "triage backlog and ship", "drive ready issues to
  PR", eller backlog skal processeres autonomt.
---

# Triage-and-Ship

Autonomous wrapper omkring `/parallel-pr` der adderer:
1. **Backlog-triage** — automatisk filtrér åbne issues efter "ready"-kriterier
2. **Auto-fix-loop** — kategoriserede fix-rutiner ved CI-fail med retry-budget
3. **Synthesis-rapport** — konsolideret status på tværs af alle dispatched issues

**Forudsætter:** `/parallel-pr` skill installeret og funktionel.

---

## When to use

✅ **Brug triage-and-ship:**
- Bruger siger "/triage-and-ship" eller "drive backlog"
- Backlog har 2-5 åbne issues mærket `ready` eller `priority/high`
- Issues er uafhængige (ingen blocked-by-relations)
- Repo følger develop+master-konvention
- Bruger accepterer auto-fix-iterations på CI-failures

❌ **Skip triage-and-ship:**
- Single issue → brug `/parallel-pr <num>` direkte
- Cross-cutting refactor → brug `/feature-dev` med human guidance
- Backlog uden klare acceptance-kriterier → kør `/opsx:explore` først
- Issues afhænger af unmerged PRs → manuel sequencing nødvendig
- Bruger vil have hands-on review hvert trin → brug normal flow

---

## Hard limits (non-negotiable)

| Limit | Værdi | Begrundelse |
|-------|-------|-------------|
| Max issues per kørsel | 3 | Compounding cost ved fejl-iterations |
| Max retries per issue | 2 | Forhindrer infinite-loop ved struktural fejl |
| Auto-merge | NEVER | Matcher non-negotiable rule |
| Worktree isolation | ALTID | Matcher worktree-rule |
| Same-file conflict-stop | ALTID | Matcher pushback-pattern |
| Timeout per agent | 30 min | Forhindrer stuck-agent |

---

## Workflow (5 phases)

### Phase 1: Backlog-triage

**Default kriterier:**

```bash
# Hent åbne issues med "ready"-signal
gh issue list \
  --state open \
  --label ready \
  --json number,title,body,labels,assignees \
  --limit 20

# Eller alternativ: bug + priority/high
gh issue list --state open \
  --label bug --label "priority/high" \
  --json number,title,body,labels --limit 20
```

**Filter-pipeline (sekventielt for hvert issue):**

1. **Body-completeness:** body indeholder "Expected:", "Acceptance:", "Skal", eller numbered steps
2. **No-blocked-label:** `labels` ej indeholder `blocked` / `needs-design` / `wip`
3. **No-existing-PR:** `gh pr list --search "in:body #<num>"` returnerer tom
4. **No-blocked-by-references:** body matcher ej regex `(blocked by|depends on)\s*#\d+`
5. **Scope-heuristic:** body word-count < 500 (større issues = brug `/feature-dev`)

**Output:** ranked candidate-list med `ready=true`, `reason` per filter-fail.

**Stop-gate:**
```
Triage fundet 5 åbne issues, 3 kvalificerede:

  ✓ #401 fix(parser): handle 90% scale [ready, priority/high]
  ✓ #402 fix(export): svglite fallback [ready]
  ✓ #403 fix(ui): missing label [ready]
  ✗ #404 (skipped: blocked by #200)
  ✗ #405 (skipped: ingen acceptance-kriterier)

Dispatch alle 3? (y/n/select)
```

Bruger bekræfter via AskUserQuestion. Default cap: 3 issues.

### Phase 2: Compatibility check

For udvalgte issues, parallel-analyse:

1. **File-overlap detection:** parse issue-body + linked code-references
2. **Function-overlap heuristic:** søg efter `function_name()` mønstre i body
3. **Diff-conflict prediction:** hvis 2+ issues nævner samme fil → eskalér til bruger

```
⚠️ #401 og #402 nævner begge fct_spc_prepare.R.

Foreslå:
  a) Seriel work (ét issue ad gangen)
  b) Konsolidér til ét PR (én agent for begge)
  c) Force parallel (accepterer merge-konflikt-risiko)
```

### Phase 3: Dispatch via /parallel-pr

Delegér til eksisterende skill med præ-validerede issues:

```
Invoke: /parallel-pr <issue-numbers fra Phase 1>
```

`/parallel-pr` håndterer:
- Worktree-creation
- Agent-dispatch (parallel)
- PR-creation
- CI-monitoring (initial)

### Phase 4: Auto-fix-loop (på CI-fail)

For hvert PR med fejlende CI:

#### 4a. Failure-categorization

Parse `gh run view <run-id> --log` efter mønstre:

| Mønster | Kategori |
|---------|----------|
| `manifest.json.*drift` eller `Connect manifest er ude af sync` | MANIFEST |
| `lint failed` eller `lintr.*errors` | LINT |
| `styler.*formattering` eller `styler-format-changed` | STYLER |
| `testthat.*FAIL` eller `Failure:` | TEST |
| `R CMD check.*WARNING` eller `ERROR` | RCMDCHECK |
| `Error: package.*not available` | DEPS |
| `permission denied` eller `auth failed` | INFRA |

#### 4b. Fix-rutiner (per kategori)

**MANIFEST:**
```bash
cd <worktree-path>
R_LIBS_USER=/tmp/bispcharts-r-lib Rscript dev/publish_prepare.R install
R_LIBS_USER=/tmp/bispcharts-r-lib Rscript dev/publish_prepare.R manifest
Rscript dev/validate_connect_manifest.R manifest.json
git add manifest.json
git commit -m "fix(deploy): regenerér manifest.json"
git push
```

**LINT:**
- Parse log → fil+linje liste
- Dispatch fix-agent (Sonnet) med eksplicit fil-liste i prompt
- Agent kører `lintr::lint()` lokalt → fix → commit → push

**STYLER:**
```bash
cd <worktree-path>
Rscript -e "styler::style_dir('R')"
git add R/
git commit -m "style: apply styler"
git push
```

**TEST:**
- Dispatch debugger-skill (eksisterer som user-command)
- Eskalér til bruger hvis ej fix efter 1 iteration

**RCMDCHECK:**
- Eskalér med det samme — ofte struktural, ej trivielt auto-fixable

**DEPS:**
- Tjek DESCRIPTION-DCF-syntax (CI-fejl ofte = malformed Imports-line)
- Hvis syntax OK: eskalér (mangler dependency er ej-trivielt)

**INFRA:**
- Eskalér straks (ej kode-relateret)

#### 4c. Retry-budget

Per issue: max 2 fix-iterations. Counter persisteres i `~/.claude/skills/triage-and-ship/state.json` (per session).

```
PR #401: CI fejlet (LINT). Auto-fix iteration 1 af 2.
  → Dispatching fix-agent...
  → Push'd. Re-watching CI.

PR #401: CI fejlet (TEST). Auto-fix iteration 2 af 2.
  → Dispatching debugger.
  → Push'd. Re-watching CI.

PR #401: CI fejlet (TEST). Budget opbrugt → ESKALERER til bruger.
```

### Phase 5: Synthesis-rapport

Når alle PRs er enten green eller eskaleret:

```
═══════════════════════════════════════
  Triage-and-Ship: kørsel #1 færdig
═══════════════════════════════════════

✅ Klar til merge (CI green):
  • #402 fix(export): svglite fallback (1 commit, 0 retries)
  • #403 fix(ui): missing label (1 commit, 1 retry [LINT auto-fixed])

⚠️ Eskaleret (kræver din intervention):
  • #401 fix(parser): handle 90% scale
    Failure-kategori: TEST
    Retry-budget opbrugt (2/2)
    Worktree bevaret: ../wt-401
    Suggested next-action: kør /debugger i wt-401

─────────────────────────────────────────
NÆSTE: bruger godkender merge-rækkefølge:

  Skriv "merge" for at merge #402+#403 sekventielt.
  Skriv "skip" for at lade dig merge manuelt.
═══════════════════════════════════════
```

Sekventiel merge **kun** efter eksplicit "merge"-bekræftelse.

---

## Stop+Confirm gates (eksplicit)

Skill stopper og venter på bruger-input ved:

1. **Phase 1 done:** "Dispatch <N> issues? (y/n/select)"
2. **Compatibility-warning:** "Issues overlapper, hvad foretrækker du?"
3. **Auto-fix-budget opbrugt:** "PR #X eskaleret, hvad nu?"
4. **Phase 5 merge-gate:** "Merge <N> PRs sekventielt?"

Aldrig auto-merge. Aldrig auto-close issues. Aldrig auto-deploy.

---

## State persistence

`~/.claude/skills/triage-and-ship/state.json`:

```json
{
  "session_id": "<hash>",
  "started": "2026-05-10T20:30:00Z",
  "issues": {
    "401": {"status": "escalated", "retries": 2, "category": "TEST"},
    "402": {"status": "ready_to_merge", "retries": 0},
    "403": {"status": "ready_to_merge", "retries": 1, "category": "LINT"}
  }
}
```

Tillader resume efter session-end. Cleanup ved successful merge.

---

## Eskalering-protokol

**Når retry-budget opbrugt:**
- Worktree bevares (ej cleanup)
- PR forbliver åben med fejl-context i description
- Bruger får eksplicit næste-skridt-suggestion (specifikt skill / kommando)
- State markeret `escalated` — undgår re-dispatch ved næste kørsel

**Eskalations-targets:**

| Kategori | Target |
|----------|--------|
| TEST | `/debugger` skill |
| RCMDCHECK | manuel investigation, ofte versionering |
| INFRA | check secrets/auth/env |
| Compatibility-stop | bruger vurderer scope |

---

## Eksempel-invocation

```
/triage-and-ship
```

Skill kører Phase 1-5 autonomt med stop-gates ved hver fase-overgang.
Bruger involveret kun ved:
- Triage-godkendelse (Phase 1)
- Compatibility-warning (Phase 2, hvis relevant)
- Eskaleringer (Phase 4, ad-hoc)
- Final merge-godkendelse (Phase 5)

---

## Differentiering fra `/parallel-pr`

| Feature | /parallel-pr | /triage-and-ship |
|---------|--------------|------------------|
| Issue-input | Eksplicit numre eller label-query | Auto-triage backlog |
| CI-fejl handling | Rapportér til bruger | Auto-fix-loop med retry-budget |
| Failure-kategorisering | Nej | Ja (7 kategorier) |
| State persistence | Nej | Ja (resume across sessions) |
| Default issue-cap | Ingen | 3 |

**Brug `/parallel-pr` når:** du har specifikke issues i tankerne.
**Brug `/triage-and-ship` når:** du vil have backlog procesieret autonomt.

---

## Referencer

- Forudsætter: `~/.claude/skills/parallel-pr/SKILL.md`
- Global rule: `~/.claude/rules/WORKFLOW_PREFERENCES.md`
- Subagent-policy: `~/.claude/AGENTS.md`
- Project-CLAUDE.md (per repo) — base-branch + project-specifikke gates
- Memory: `feedback_worktrees_for_parallel_agents.md`, `feedback_atomic_commits.md`
