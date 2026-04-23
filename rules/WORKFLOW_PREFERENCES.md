# Workflow Preferences

Brugerens foretrukne arbejdsmetoder og tools.

---

## OpenSpec (Obligatorisk)

OpenSpec er standard change management for ALLE projekter.

### Proaktiv Enforcement

✅ **Gør automatisk:**
- Foreslå `openspec init` hvis openspec/ ikke findes i projektet
- Foreslå `/openspec:proposal` ved:
  - Nye features/capabilities
  - Breaking changes til public API
  - Arkitektur-ændringer
  - Performance/security ændringer der påvirker behavior
- Brug `openspec list` og `openspec spec list` til at forstå kontekst
- Link OpenSpec changes til GitHub Issues

❌ **Skip OpenSpec for:**
- Bug fixes der genopretter existing behavior
- Typos, formatering, kommentarer
- Dependency updates (non-breaking)
- Konfigurationsændringer
- Tests for eksisterende behavior

### Workflow
1. **Proposal** → `/openspec:proposal` → godkendelse
2. **Implementation** → `/openspec:apply` → kode
3. **Archival** → `/openspec:archive` → deploy

---

## Superpowers Plugin (Kontekstuel)

Superpowers skills er kraftfulde værktøjer — brug dem når de reelt matcher
opgaven. Brug din vurdering baseret på opgavens karakter frem for at
invokere "for sikkerheds skyld".

### Kontekstuelle Skills

| Situation | Skill | Hvornår |
|-----------|-------|---------|
| Ny feature / større designvalg | `brainstorming` | Før implementation (ikke ved små ændringer eller forklaringsspørgsmål) |
| Godkendt plan klar til multi-fil refactor | `writing-plans` | Ved kompleks implementation med edge-cases |
| Ikke-triviel bug / uventet behavior | `systematic-debugging` | Før fixes (ikke ved almindelige syntaksfejl) |
| Færdiggørelse af arbejde | `verification-before-completion` | Før PR eller "færdig"-claim |
| Adfærdsændrende kode | `test-driven-development` | Ved ny funktionalitet eller logik-bugfix |
| Feature branch færdig | `finishing-a-development-branch` | Ved completion |
| Code review modtaget | `receiving-code-review` | Før ændringer implementeres |
| Ikke-triviel kode-commit | `/simplify` | > 10 linjer R-kode eller ny funktion/modul |

### Pre-Commit: /simplify (Kontekstuel)

`/simplify` bør køres før commits med **ikke-trivielle kode-ændringer**
(typisk > 10 linjer R-kode eller ny funktion/modul). Den reviewer ændret
kode for:
- Code reuse (duplikeret funktionalitet)
- Code quality (hacky patterns, leaky abstractions)
- Efficiency (unødvendigt arbejde, memory issues)

Eventuelle findings fixes inden commit udføres.

**Ikke nødvendig for:**
- Docs, typos, kommentarer
- Config-justeringer, dependency-bumps
- Tests for eksisterende adfærd
- Rene refactors uden adfærdsændring

### Skill-invokation: Brug din vurdering

Invoker skills når de reelt matcher opgaven — ikke "for sikkerheds skyld".
Brugerens eksplicitte `/command` invokeres altid. Når ingen skill matcher:
proceed direkte med din bedste vurdering.

---

## Subagent-orkestrering

### Model-valg: Sonnet som default

Default til `model: sonnet` for subagent-dispatches, medmindre opgaven er
ren arkitektur, design, eller kompleks review hvor Opus' ekstra
reasoning-kapacitet retfærdiggør prisen.

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

**Eskalering:** Hvis subagent returnerer BLOCKED eller lavvurderet output,
eskalér til Opus.

### Proaktiv foreslåelse

Foreslå Sonnet-subagents til brugeren så ofte som det er relevant. Når der
er 2+ uafhængige issues eller tasks på queue, default til at foreslå
parallel Sonnet-dispatch — spar Opus-tid til review og orkestrering.
Nævn eksplicit at Sonnet er valgt og hvorfor opgaven passer til profilen.

### Parallel arbejde: Brug worktrees

Når 2+ subagents dispatches parallelt i samme repo, brug
`isolation: "worktree"` på `Agent`-tool (eller `superpowers:using-git-worktrees`
skill). IKKE delt working directory.

**Hvorfor:** Delt working directory mellem parallelle agents giver:
- Kun én branchs filer "live" på disk ad gangen
- `devtools::load_all()`/tests ser uncommitted ændringer fra andre agents
- Race conditions hvis to agents modificerer samme fil
- Orkestrator kan ikke trygt review PRs mens agents arbejder

**Regler:**
- Parallelle agents (2+ samtidig): ALTID `isolation: "worktree"`
- Sekventielle agents (én ad gangen): working directory er fint
- Solo arbejde uden subagents: working directory er fint
- Ved review af parallel-work-PR: merge via `gh pr merge` server-side,
  undgå lokal `git checkout` mens andre agents stadig arbejder

---

**Sidst opdateret:** 2026-04-19
**Del af:** ~/.claude/ global configuration system
