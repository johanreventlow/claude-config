# Workflow Preferences

Brugers foretrukne arbejdsmetoder + tools.

---

## OpenSpec (Kontekstuel)

OpenSpec anbefalet change management når projekt allerede bruger det,
eller ændring har behavioral/architectural impact.

### Hvornår OpenSpec bruges

✅ **Projekter med eksisterende `openspec/`:**
- Følg projekts OpenSpec-workflow for non-trivielle ændringer
- Foreslå `/opsx:propose` ved:
  - Nye features/capabilities
  - Breaking changes til public API
  - Arkitektur-ændringer
  - Performance/security ændringer der påvirker behavior
- Brug `openspec list` + `openspec spec list` for kontekst
- Link OpenSpec changes til GitHub Issues

🆕 **Projekter uden `openspec/`:**
- Foreslå `openspec init` **kun** ved større arkitektur/API-ændringer
  eller hvis bruger spørger om change management
- Ej påkrævet for små features eller ad-hoc projekter

❌ **Skip OpenSpec for:**
- Bug fixes der genopretter existing behavior
- Typos, formatering, kommentarer
- Dependency updates (non-breaking)
- Konfigurationsændringer
- Tests for eksisterende behavior
- One-shot scripts eller throwaway-kode

### Workflow
1. **Explore** (valgfri) → `/opsx:explore` → afklar idé før proposal
2. **Proposal** → `/opsx:propose` → godkendelse
3. **Implementation** → `/opsx:apply` → kode
4. **Archival** → `/opsx:archive` → deploy

---

## Skill-invokation

Invoker skills når reelt matcher opgaven — ikke "for sikkerheds skyld".
Brugers eksplicitte `/command` invokeres altid. Ingen skill matcher:
proceed direkte med bedste vurdering.

**Pre-commit `/simplify`** ved ikke-trivielle kode-ændringer (>10 linjer
R-kode el. ny funktion/modul). Reviewer for code reuse, hacky patterns,
efficiency. Ej nødvendig: docs, config, tests for eksisterende adfærd,
rene refactors.

**`/dual-review-cycle`** ved cycle-baseret review eller substantielle
refactor-PRs (cross-package contracts, CI gates, executable code-snippets,
empiriske claims, repeated failure patterns). Encoder lessons fra
biSPCharts review-program 2026-05 (8 cycles, 27 PRs, dual-review meta-
evaluation): trigger-based Codex-invokation, empirical-reproduction-rule
(forhindrer peer-review laundering), impact-bucketing (forhindrer ROI-
inflation), atomic-commits per finding, worktree-aware branching.
Skill-fil: `~/.claude/skills/dual-review-cycle/SKILL.md`. Skip for
trivielle bug-fixes, pure docs-PRs, eller empty cycles under kalibreret
threat-model.

---

## Subagent-orkestrering

### Model-valg: Sonnet som default

Default `model: sonnet` for subagent-dispatches, medmindre opgave er
ren arkitektur, design, eller kompleks review hvor Opus' ekstra
reasoning retfærdiggør prisen.

**Sonnet klarer (høj confidence):**
- Implementation-tasks (mekanisk, TDD med klar spec)
- Salvage/test-fix-tasks
- Analyse/kategorisering med klare regler
- Diverse nit-level code hygiene fixes

**Opus reserveres til:**
- Arkitektur-beslutninger, design-review
- Komplekse debugging-sessioner
- Security-vurderinger med nuanceret threat-model
- Cross-repo API-design

**Eskalering:** Subagent returnerer BLOCKED eller lavvurderet output →
eskalér til Opus.

### Proaktiv foreslåelse

Subagents = context-firewalls, ikke default-workhorse. Foreslå Sonnet-
subagents **når opgave faktisk matcher profilen** — ikke "for sikkerheds
skyld". Konkrete triggers:

- **2+ uafhængige tasks i kø** (parallel-dispatch = reel speedup)
- **Verbose output forventes** (>30k tokens læses/produceres) + detaljer
  skal ej ind i main-context
- **Isoleret worktree-arbejde** hvor agents arbejder parallelt uden
  at se hinandens uncommitted changes

Undgå subagent for single-file edits, simple spørgsmål, eller opgaver
hvor du alligevel skal læse outputtet detaljeret. Nævn eksplicit at
Sonnet valgt + hvorfor opgave passer profilen.

**Returformat:** Subagent returnerer koncise findings (10-20% af
processeret), ikke dumps af fuld output.

### Parallel arbejde: Brug worktrees

2+ subagents dispatches parallelt i samme repo: brug
`isolation: "worktree"` på `Agent`-tool (eller `superpowers:using-git-worktrees`
skill). IKKE delt working directory.

**Hvorfor:** Delt working directory mellem parallelle agents giver:
- Kun én branchs filer "live" på disk ad gangen
- `devtools::load_all()`/tests ser uncommitted ændringer fra andre agents
- Race conditions hvis to agents modificerer samme fil
- Orkestrator kan ej trygt review PRs mens agents arbejder

**Regler:**
- Parallelle agents (2+ samtidig): ALTID `isolation: "worktree"`
- Sekventielle agents (én ad gangen): working directory fint
- Solo arbejde uden subagents: working directory fint
- Review af parallel-work-PR: merge via `gh pr merge` server-side,
  undgå lokal `git checkout` mens andre agents stadig arbejder

---

**Sidst opdateret:** 2026-04-19
**Del af:** ~/.claude/ global configuration system