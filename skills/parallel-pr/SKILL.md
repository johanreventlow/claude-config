---
name: parallel-pr
description: >
  Dispatch parallel worktree-isolerede agents til multiple GitHub-issues
  i samme repo. Orkestrerer pre-flight, branch-creation, agent-dispatch,
  CI-monitoring og sequential merge med eksplicitte stop+confirm-gates.
  Encoder worktree-isolation-rule + base-branch-rule fra projekt-CLAUDE.md.
  Use when user says "/parallel-pr", "fix issues #X #Y #Z parallelt",
  "dispatch parallel agents for issues", eller flere uafhængige issues
  skal løses samtidigt i samme repo.
---

# Parallel PR Dispatch

Codifyer parallel-worktree-pattern til at løse 2+ uafhængige GitHub-issues
samtidigt med isolerede agents, CI-monitoring og sequential merge. Følger
brugerens non-negotiable rules (worktree-isolation, base-branch develop,
stop+confirm før destruktive ops).

---

## When to use

✅ **Brug parallel-pr:**
- 2+ uafhængige issues kan løses parallelt (ej overlap i filer/funktioner)
- Bruger siger "/parallel-pr <numre>" eller "fix #X #Y parallelt"
- Issues har klare acceptance-kriterier (label `ready` eller komplet beskrivelse)
- Repo har `develop`-branch som default base

❌ **Skip parallel-pr:**
- Issues rør samme funktion → seriel work + ét konsolideret PR
- Cross-cutting refactor der berører mange filer
- Single-issue work (brug normal `/feature-dev` eller direkte impl)
- Repo uden `develop`-branch (først kalibrér base-branch-konvention)
- Issues uden klar scope → kør `/opsx:explore` først

---

## Pre-flight (stop ved fejl)

Kør parallelt:

1. **Working tree clean** (`git status --porcelain` returnerer tomt)
   → Stop hvis ej: "Stash eller commit først."

2. **Current branch = `develop`** (eller projektets default base)
   → Switch hvis nødvendigt: `git switch develop && git pull --ff-only`

3. **Up-to-date med origin** (`git fetch origin develop` + `git rev-list --left-right --count develop...origin/develop` = `0\t0`)
   → Stop hvis bagud: "Pull først."

4. **Ingen worktree-konflikter** (`git worktree list` viser ej `wt-<issue>`-paths)
   → Stop hvis konflikt: "Cleanup eksisterende worktrees først."

5. **Repository-konvention bekræftet:**
   - Læs project-CLAUDE.md for base-branch-rule
   - Default `develop`, fallback `master`/`main` hvis ej develop-branch findes

---

## Workflow (7 trin)

### 1. Issue-resolution

Parse input. Tre formater:

- **Eksplicitte numre:** `parallel-pr 123 124 125`
- **Label-query:** `parallel-pr label:ready-to-fix` → `gh issue list --label ready-to-fix --json number,title`
- **Interaktiv:** `parallel-pr` (ingen args) → list åbne issues, lad bruger vælge via `AskUserQuestion`

For hvert issue:
```bash
gh issue view <num> --json number,title,body,labels
```

Generér slug: `fix/<num>-<short-title-slug>` (max 40 tegn, lowercase, dash-separated).

### 2. Compatibility check

Cross-reference filer der sandsynligvis berøres:

- Parse issue-body efter file-paths, function-names
- Hvis 2+ issues nævner samme fil/funktion: **stop**, anbefal seriel approach
- Bruger kan override med "force parallel" hvis konflikt acceptabel

### 3. Worktree-creation (sekventiel)

Per issue (sekventiel for at undgå git-locking):

```bash
git worktree add ../wt-<num> -b fix/<num>-<slug> develop
```

Verificér worktree oprettet: `git worktree list | grep wt-<num>`.

### 4. Agent-dispatch (parallel)

**Single message med multiple Task-calls** for ægte parallelism.

Per worktree:
```
Task(
  description: "Fix issue #<num>",
  subagent_type: general-purpose,
  isolation: worktree (sæt cwd til wt-<num>),
  model: sonnet,
  prompt: """
    Working dir: <absolute-path-til-wt-<num>>
    Issue: <issue-body>
    Acceptance kriterier: <parsed fra issue>

    Implementér fix. Følg projekt-konventioner i CLAUDE.md.
    Lav fokuserede commits. Skriv tests for kritiske paths.
    Verificér med devtools::test() / lintr / projekt-specifik gate.

    Returnér:
    - Branch-name
    - Liste af commits (sha + message)
    - Test-status
    - Eventuelle blockers
  """
)
```

**Parallelism-regel:** ALTID `isolation: worktree` ved 2+ samtidige Task-calls
(matcher global rule i `~/.claude/rules/WORKFLOW_PREFERENCES.md`).

### 5. PR-creation

Når alle agents complete:

Per worktree, fra worktree-root:
```bash
gh pr create \
  --base develop \
  --head fix/<num>-<slug> \
  --title "<commit-type>: <issue-title> (#<num>)" \
  --body "Closes #<num>

  ## Summary
  <agent-rapport bullets>

  ## Test plan
  - [x] Unit tests
  - [x] Lint pass
  - [ ] Manual verification (brugerens ansvar)"
```

Bekræft `--base develop` (matcher CLAUDE.md "PR Base Branch"-rule).

### 6. CI-monitoring

For hvert PR i parallel:
```bash
gh run watch <run-id> --exit-status
```

Kategorisér failures hvis CI fail:
- **Lint:** parse log for `lintr`/`styler` errors → return for fix
- **Test:** parse for `testthat` failures → return for fix
- **Build:** parse for `R CMD check` errors → return for fix
- **Manifest:** parse for manifest-drift → suggest `Rscript dev/publish_prepare.R manifest`

Rapportér til bruger hvilke PRs er grønne, hvilke fejler.

### 7. Sequential merge (STOP + CONFIRM)

⚠️ **Aldrig auto-merge.** Vis bruger merge-rækkefølge + spørg om bekræftelse.

```
PRs klar til merge:
  • #401 fix(parser): handle 90% scale (3 commits, CI green)
  • #402 fix(export): svglite fallback (2 commits, CI green)
  • #403 fix(ui): missing label (1 commit, CI green)

Foreslået rækkefølge: 401 → 402 → 403 (uafhængige, alfabetisk).

Skriv "merge" for at fortsætte sekventielt.
Skriv "merge 403,401,402" for custom rækkefølge.
Skriv "skip" for at lade dig merge manuelt.
```

Når bekræftet, per PR sekventielt:
```bash
gh pr merge <num> --squash --delete-branch
git switch develop && git pull --ff-only origin develop
```

Mellem merges: rebase næste branch hvis develop er bevæget:
```bash
cd ../wt-<næste>
git rebase develop
```

### 8. Cleanup

```bash
# Pr worktree (efter merge)
git worktree remove ../wt-<num> --force
```

Verificér: `git worktree list` viser kun main worktree + eventuelle ikke-merged.

### 9. Final rapport (dansk)

```
✅ Parallel-PR-flow færdig.

Merged til develop:
  • <sha-1> #401 fix(parser): handle 90% scale
  • <sha-2> #402 fix(export): svglite fallback
  • <sha-3> #403 fix(ui): missing label

Worktrees ryddet.
Develop er up-to-date med origin/develop.

💡 Næste: hvis dette er pre-release, kør /publish-to-connect eller /opsx:archive efter behov.
```

---

## Guardrails

| Regel | Begrundelse |
|-------|-------------|
| ALTID `isolation: worktree` på 2+ Task-calls | Forhindrer cross-contamination via main working dir |
| ALDRIG auto-merge | Matcher non-negotiable rule "merge til main = stop+confirm" |
| Stop hvis 2 issues rør samme funktion | Matcher brugerens dokumenterede pushback-pattern |
| Default base = `develop` | Matcher CLAUDE.md "PR Base Branch"-rule |
| Sonnet default per agent | Matcher global rule i WORKFLOW_PREFERENCES.md |
| Eskalér til Opus hvis subagent BLOCKED | Matcher subagent-policy |
| Ingen Claude attribution-footers | Matcher GIT_WORKFLOW.md |
| Validér post-merge: develop op-to-date før næste merge | Forhindrer rebase-konflikter |

---

## Failure-modes

**Agent BLOCKED:**
- Eskalér til Opus + dispatch ny agent i samme worktree
- Hvis stadig BLOCKED: rapportér til bruger, behold worktree som-er

**CI fail efter PR-create:**
- Stop merge-flow for det PR
- Dispatch fix-agent i samme worktree (ingen ny branch)
- Re-push, re-watch CI
- Max 2 retry-iterations før eskalering

**Merge-konflikt mod develop:**
- Stop sekventielt
- Switch til konflikten-branch worktree
- Foreslå bruger gennemgår konflikten manuelt
- Genoptag flow når løst

**Worktree-cleanup fejler:**
- `git worktree remove --force` aborter
- Ofte fordi worktree har uncommitted changes (skulle ej ske post-merge)
- Rapportér og lad bruger inspicere

---

## Eksempel-invocations

**Tre eksplicitte issues:**
```
/parallel-pr 401 402 403
```

**Label-baseret:**
```
/parallel-pr label:ready-to-fix
```

**Interaktiv (lad mig vælge):**
```
/parallel-pr
→ skill lister åbne issues, bruger vælger via AskUserQuestion
```

---

## Referencer

- Global rule: `~/.claude/rules/WORKFLOW_PREFERENCES.md` (worktree-pattern, subagent-orkestrering)
- Global rule: `~/.claude/rules/GIT_WORKFLOW.md` (branches, commits, PRs)
- Project-rule: `<repo>/CLAUDE.md` (base-branch, project-specifikke gates)
- Subagent-policy: `~/.claude/AGENTS.md`
- Memory: `feedback_worktrees_for_parallel_agents.md`, `feedback_pr_target_develop.md`
