---
name: dual-review-cycle
description: >
  Orchestrate Claude+Codex dual-review for non-trivial code-changes.
  Trigger-based: runs Codex when draft contains executable recipes,
  cross-package contracts, CI gates, empirical claims, or repeated
  failure patterns. Auto-applies reconcile rules from biSPCharts
  review-program 2026-05 lessons (impact-bucketing, peer-review-
  laundering anti-pattern, atomic-commits-per-finding, worktree-aware
  branching). Use when user says "review X", "/dual-review", "review
  the diff systematically", or substantive code-area needs systematic
  dual-pass quality-assurance.
---

# Dual-Review Cycle

Orkestrér systematisk Claude+Codex dual-review-pattern for non-trivielle kode-ændringer eller review-cycles. Skill'en encoder lessons fra biSPCharts review-program 2026-05 (8 cycles, 27 PRs, dual-review meta-evaluation).

## When to use

✅ **Brug dual-review-cycle:**
- Bruger siger "review X", "/dual-review", "review systematically"
- Cycle-baseret review af et område (security, observability, AI/RAG, parsing osv.)
- Refactor-PR med executable code-snippets
- Fix der røre cross-package contracts (eksterne API'er)
- CI/security gates
- Repeated failure patterns (memory-dokumenterede)
- Clinical-data semantics

❌ **Skip dual-review-cycle:**
- Trivielle one-line bug-fixes med åbenlyst korrekte tests
- Pure docs-PRs (typo, formatering)
- Stable-pipeline obvious-fixes (1-2 lines, no contracts)
- Empty cycles under kalibreret threat-model
- Skills/scripts der ikke rammer prod-code

---

## Workflow (5 phases)

### Phase 1: Initial Claude review

1. **Spawn Explore agent** for kortlægning hvis område >5 filer eller >1000 LOC
2. **Spawn code-analyzer agent** for focused bug-hunt:
   - Pre-existing findings (verify still-present?)
   - New bugs/gaps
   - File:line refs + 3-5 linje kode-citater per fund
   - Severity baseret på REEL impact (ej theoretical)
3. **Brug min 2-3 minutters mental type-check** af proposed fix-snippets FØR commit til doc:
   - R-quirks: `nchar` chars vs bytes, `startsWith` recycling, length>1 condition-error
   - Function-scope: arg-availability i call-site
   - Cross-package contracts: peer-pakke API-signatures
4. **Skriv draft-rapport** i `docs/reviews/NN-omraade.md` med struktur:
   ```
   ## H1 [HIGH/MEDIUM/LOW] — beskrivelse
   **Lokation:** path:LL-MM
   **Symptom:** ...
   **Verifikation:** kode-citat (3-5 linjer)
   **Konsekvens:** ...
   **Foreslået fix:** ...
   ```

### Phase 2: Trigger-decision (Codex YES/NO)

**Default OFF.** Run Codex KUN hvis ≥1 af:

- [ ] Draft indeholder executable code-snippet (R, bash, YAML)
- [ ] Cross-package contract-claim (peer-pakke API)
- [ ] CI-gate ændring
- [ ] Empirisk claim ("X = Y bytes", "race-condition", "leak")
- [ ] Repeated failure pattern (memory-dokumenteret)
- [ ] Clinical-data semantics
- [ ] Severity-vurdering driver implementation-scope

**Skip Codex hvis:**
- 0 findings (forventet under threat-model)
- Pure docs eller cleanup
- Stable-pipeline med obvious-fixes
- Same review-area kørt <7 dage siden

### Phase 3: Codex adversarial-review (kun hvis Phase 2 = YES)

```bash
node "<plugin-cache>/openai-codex/codex/<version>/scripts/codex-companion.mjs" \
  adversarial-review "Focus narrowly on docs/reviews/NN-omraade.md.
IGNORE all other diff content.

For EACH finding (H1, H2, ..., M1, ...):
- Verify empirisk against actual code (file:line refs)
- Tjek fix-recipe for runtime-correctness
- Distinguish: confirmed | dismissed | recalibrated
- Identify cross-package contract-issues
- Flag any new bugs jeg har misset

Particular focus:
1. [skill-specifik H1-claim]
2. [skill-specifik H2-claim]
3. ..." 2>&1 | tee /tmp/codex-cycle-NN.txt
```

**Pin-pointed focus-text er obligatorisk** — Cycle F off-target lesson: uden eksplicit ekskludering af anden diff, ramte Codex deferred work.

Run i baggrunden hvis review-doc >250 linjer (~5 min Codex-tid).

### Phase 4: Reconcile (med encoded rules)

#### Rule 1: Empirical-reproduction-rule (forhindrer peer-review-laundering)

Hver Codex-claim klassificeres:

| Label | Krav | Brugbar til |
|-------|------|-------------|
| `verified` | Reproduceret empirisk i denne reconcile (R-session, grep, file-inspection) ELLER direct source-evidence (kode-citat fra peer-pakke) | Severity-decisions, ROI-tally |
| `inferred` | Plausibel argument men ej direkte verificeret | Defense-in-depth-noter; IKKE severity-driver |
| `uncertain` | Codex usikker selv ("matcher? — verificer") | Flagged for follow-up; IKKE accept |

**Anti-pattern: peer-review laundering** = accept Codex-objection uden reproduktion → confirmation-bias amplifier.

**Reproduktion-eksempler (fra Cycle E + D + C):**
- Cycle E NEW3: Run `nchar("æ" * 240, type="bytes")` → 480 bytes. Verified.
- Cycle D H1: Run `is_column_numeric(c("12,5","0,73","3,14"))` → FALSE. Verified.
- Cycle C H1: Grep `extract_freeze_position` call-sites + verify `analysis_options` mangler felt. Verified.

#### Rule 2: Impact-bucketing (forhindrer ROI-inflation)

Hver fix-recipe rescue klassificeres:

| Bucket | Eksempler |
|--------|-----------|
| **Hard runtime-crash** | C H2 startsWith pairwise, E NEW1 session$token ej i scope |
| **Silent-corruption / semantic drift** | D M1 point-decimal corruption, C H1 phase_names integer-IDs |
| **False-confidence / process guard** | G H7 enabled-flag mismatch, F M3 silent-skip |
| **Sub-optimal / cleanup** | E NEW3 byte-edge, D H3 too-aggressive threshold |

**Rapportér per-bucket, IKKE flat-tal.** "10 reddede recipes" → "2 hard + 3 semantic + 2 process + 3 cleanup".

#### Rule 3: Reconcile-section template

```markdown
## Codex adversarial-review konsekvens (YYYY-MM-DD)

Verdict: needs-attention | approve | no-ship

**Bekræftet (verified empirisk):**
- H1: [reproduktion-evidens]
- H3: [reproduktion-evidens]

**Inferred (plausibel men ej reproduceret):**
- H2: [Codex's argument; flag som inferred]

**Recalibreret:**
1. [Original fix-strategi] → [Codex-foreslået strategi] — reason

**Læring:** [pattern indfanget for fremtid]
```

### Phase 5: Implementation (atomic + worktree-aware)

#### Pre-flight checks

1. **Worktree confirm:** `cd <worktree> && git branch --show-current` (Cycle G læring — undgå master-edit-trap)
2. **Branch-naming:** `fix/<short-desc>-cycle-X-<finding-id>`
3. **Sync develop:** `git pull origin develop` før branching

#### Atomic commits

- **Én PR per finding** (memory: `feedback_atomic_commits`)
- Commit-message struktur:
  ```
  fix(<area>): <kort beskrivelse> (cycle X <finding-id>)
  
  Cycle X <finding-id> (Codex peer-review YYYY-MM-DD).
  
  Problem: [empirisk-verificeret beskrivelse]
  
  [Codex feedback hvis recalibreret]: [hvad blev rewritten]
  
  Fix: [hvad ændret + hvor]
  
  Tests: tests/testthat/test-<name>.R (N pass, 0 fail)
  - [test-coverage-bullets]
  
  Refs: docs/reviews/NN-omraade.md <finding-id>
  ```

#### Test-coverage

Hver finding-PR skal have:
- Regression-test der ville have fanget pre-fix-bug
- No-regression-tests for eksisterende behavior
- Manifest-entry i `dev/audit-output/test-classification.yaml` (hvis projekt har)

#### Manifest-conflict-pattern (memory: `feedback_post_merge_ci_gotchas`)

Når flere PRs i samme cycle merges, opstår manifest-konflikter (alle adds entry samme sted). Pattern:
1. Første PR merges fint
2. Anden+ PRs får DIRTY-status
3. Resolve: `git fetch origin develop && git merge origin/develop --no-edit` på branch
4. Fix YAML-conflict-markers manuelt (behold begge entries)
5. Push → CI re-runs

### Phase 6: Audit-trail update

1. **Update `docs/reviews/README.md`** tracker-tabel:
   - Markér cycle som ✅ Komplet med dato
   - Liste PR-numre
   - Linke til review-doc
2. **Tilføj læringer** til README's "Læringer" sektion (numbered, akkumulerer)
3. **Cross-cycle-PR for audit-trail** (cherry-pick docs til develop):
   ```bash
   git checkout develop && git pull
   git checkout -b docs/cycle-X-audit-trail
   git checkout review/program-base -- docs/reviews/NN-omraade.md docs/reviews/README.md
   git commit -m "docs(reviews): cycle X audit-trail"
   gh pr create --base develop ...
   ```

### Phase 7: Memory-update (hvis nye patterns)

Tilføj til `~/.claude/projects/<project>/memory/`:

- **feedback_*.md**: Nye process-mønstre (atomic-commits, branch-discipline)
- **project_*.md**: Aktive cycles, pending findings, deferred-work
- **MEMORY.md** index opdateres

Skip hvis: ingen nye patterns; cycle var rutine.

---

## Anti-patterns

❌ **Auto-trust Codex** — off-target hallucination muligt (Cycle F første pass review'ede deferred work). Verify scope FØR accept.

❌ **Skip Codex på "kun kosmetiske ændringer"** — Cycle D M1 så kosmetisk ud, fanget silent corruption-risk.

❌ **Codex som review-replacement** — bør være second-opinion på MIN draft, ej eneste reviewer.

❌ **Bundle multiple cycles til én Codex-pass** — focus dilueres.

❌ **Peer-review laundering** — accept Codex-objection uden reproduktion. Hver `verified`-claim KRÆVER independent verification.

❌ **Default-on Codex hver cycle** — overhead uden ROI-justification. Trigger-based.

❌ **Inflated ROI-tally** — flat "X reddede"-tal uden bucket-distinguishing skaber falske claims.

❌ **Edit i main-repo når worktree etableret** — pre-commit blocker. `git branch --show-current` confirm.

---

## Process-konstanter

| Konstant | Værdi | Kilde |
|----------|-------|-------|
| Tidssbox per cycle | Max 1 arbejdsdag | biSPCharts review-program 2026-05 |
| Codex-budget | 1-2 adversarial-review per cycle | Cost ~$0.20-0.50 per pass |
| Codex-skip threshold | Ingen executable-recipes + ingen contracts | Per Codex meta-review 2026-05-10 |
| Reconcile-doc placering | `docs/reviews/NN-omraade.md` | Konvention etableret cycles A-H |
| Atomic-commit-grænse | Én logisk fix per PR | Memory: `feedback_atomic_commits` |

---

## Output-format

End-of-cycle summary til bruger:

```markdown
## Cycle X — [område] sammenfatning

| ID | Severity | Status | PR |
|----|----------|--------|-----|
| H1 | HIGH | ✅ Implementeret | #NNN |
| H2 | MEDIUM | ✅ Confirmed (verified) | #NNN |
| H3 | LOW | DEFER per [reason] | — |

**Codex impact (verified):**
- Hard runtime-saves: N
- Semantic/silent-corruption-saves: N
- False-confidence/process-saves: N
- Sub-optimal/cleanup: N (excluded fra ROI-tally)

**Læringer:** [1-2 nye patterns indfanget i memory eller README]

**Pending:** [PR-numre afventende CI/merge eller næste cycle-spørgsmål]
```

---

## Reference

- biSPCharts review-program 2026-05: `/Users/johanreventlow/R/biSPCharts/docs/reviews/README.md` (8 cycles, 28 læringer, dokumenteret meta-review)
- Codex meta-review (2026-05-10): identificerede 3 anti-patterns ovenfor (peer-review laundering, ROI-inflation, default-on overhead)
- Memory-baseline: `~/.claude/projects/-Users-johanreventlow-R-biSPCharts/memory/` (feedback_*, project_*)
- Eksisterende skills brugt som komponenter: `/codex:adversarial-review` (Phase 3), Explore + code-analyzer subagents (Phase 1)
