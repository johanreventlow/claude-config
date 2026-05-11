# Claude Bootstrap Workflow

Bootstrap-procedure ved projekt-start. Auto-loadet via global CLAUDE.md.

---

## Tier-system

Globale rules organiseret i tre tiers efter relevans-bredde:

### Tier 1: Auto-load (`~/.claude/rules/*.md`)
Universelle for alle R-projekter. Ladet automatisk hver session.

- `CLAUDE_BOOTSTRAP_WORKFLOW.md` — denne fil
- `WORKFLOW_PREFERENCES.md` — OpenSpec, subagent-orkestrering, worktrees
- `DEVELOPMENT_PHILOSOPHY.md` — TDD, ADR, safe_operation, design principles
- `R_STANDARDS.md` — naming, tidyverse, error handling, testing
- `GIT_WORKFLOW.md` — branches, commits, PRs
- `VERSIONING_POLICY.md` — semver, tags, NEWS, cross-repo bump
- `SECURITY_BEST_PRACTICES.md` — secrets, input validation, auth

### Tier 2: Profil-rules (`~/.claude/rules-profiles/<type>/*.md`)
Project-type-specifikke. Project CLAUDE.md @-importerer relevant profil.

- `shiny/` — SHINY_STANDARDS, SHINY_ADVANCED_PATTERNS, ARCHITECTURE_PATTERNS

### Tier 3: On-demand (`~/.claude/rules-ondemand/*.md`)
Sjældent-relevante. Manuel @-import når aktivt brug.

- `TROUBLESHOOTING_GUIDE.md` — kompleks debugging
- `CI_CD_WORKFLOW.md` — GitHub Actions
- `DEPLOYMENT_GUIDE.md` — RConnect, Docker, shinyapps
- `OBSERVABILITY_STANDARDS.md` — production logging, Sentry, alerts
- `QUARTO_STANDARDS.md` — Quarto websites/dokumenter
- `WINDOWS_ENVIRONMENT.md` — Windows R-paths, gh CLI workaround

---

## Bootstrap-procedure

### Trin 1: Identificér projekttype

Læs lokal `CLAUDE.md` → `## Project Overview` → identificér type:
**Shiny** | **R Package** | **Quarto** | **Generic R** (default)

Ingen `CLAUDE.md` eller type: antag **Generic R**.

### Trin 1b: Platform-detektion

Windows (win32):
- Manuel kopi `~/.claude/rules-ondemand/WINDOWS_ENVIRONMENT.md` →
  `~/.claude/rules/` for auto-load på Windows-maskinen
- ALDRIG `gh` CLI — brug `git` + browser
- Altid fuld sti til R/Rscript (ej i PATH)

### Trin 2: Project @-imports (Tier 2)

Project CLAUDE.md tilføjer @-imports for projekt-type-rules:

**Shiny:**
```
@~/.claude/rules-profiles/shiny/SHINY_STANDARDS.md
@~/.claude/rules-profiles/shiny/SHINY_ADVANCED_PATTERNS.md
@~/.claude/rules-profiles/shiny/ARCHITECTURE_PATTERNS.md
```

**R Package:** Tier 1 dækker. Ingen ekstra @-imports default.

**Quarto:**
```
@~/.claude/rules-ondemand/QUARTO_STANDARDS.md
```

### Trin 3: On-demand-imports

Project CLAUDE.md @-importerer Tier 3 hvis aktivt arbejdet med:

```
@~/.claude/rules-ondemand/OBSERVABILITY_STANDARDS.md  # production logging
@~/.claude/rules-ondemand/DEPLOYMENT_GUIDE.md         # ved deploy-arbejde
```

### Trin 4: OpenSpec

`openspec/` findes: læs `openspec/project.md` + `openspec/AGENTS.md`,
brug OpenSpec workflow til non-trivielle ændringer.

`openspec/` findes ej: foreslå `openspec init` kun ved større
arkitektur-ændringer.

---

## Enforcement

✅ **Automatisk:**
- Læs lokal CLAUDE.md + Tier 1 + project @-imports
- Foreslå git branches via konvention (`feat/`, `fix/`, etc.)
- Enforc commit message format
- Flag manglende tests

❌ **Aldrig uden eksplicit godkendelse:**
- Commit/merge til `main`/`master`
- Push til remote
- Force push, branch deletion, release-tagging

Detaljer: `GIT_WORKFLOW.md`.

---

## Checklist

- [ ] Læst lokal CLAUDE.md
- [ ] Identificeret projekttype
- [ ] Platform-detekteret (Windows → kopi WINDOWS_ENVIRONMENT)
- [ ] Tier 2 @-imports verificeret i project CLAUDE.md
- [ ] OpenSpec status tjekket

---

**Sidst opdateret:** 2026-04-28
**Del af:** ~/.claude/ global configuration system
