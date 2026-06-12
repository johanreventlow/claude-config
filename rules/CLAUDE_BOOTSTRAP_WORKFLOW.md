# Claude Bootstrap Workflow

Bootstrap ved projekt-start. Auto-loadet via global CLAUDE.md.

---

## Tier-system

### Tier 1: Auto-load (`~/.claude/rules/*.md`) — hold minimal
- `CLAUDE_BOOTSTRAP_WORKFLOW.md` — denne fil
- `WORKFLOW.md` — OpenSpec, skills, subagents, issue-flow
- `DEVELOPMENT_PHILOSOPHY.md` — TDD, safe_operation, pre-commit checklist
- `GIT_WORKFLOW.md` — branches, commits, PRs
- `VERSIONING_POLICY.md` — semver, tags, NEWS, cross-repo bump

### Tier 2: Profiler (`~/.claude/rules-profiles/<type>/*.md`)
Project CLAUDE.md @-importerer relevant profil:

| Projekttype | @-imports |
|---|---|
| **R** (alle R-projekter) | `rules-profiles/r/R_STANDARDS.md` |
| **Shiny** | + `rules-profiles/shiny/SHINY_STANDARDS.md`, `SHINY_ADVANCED_PATTERNS.md`, `ARCHITECTURE_PATTERNS.md` |
| **TypeScript** | `rules-profiles/typescript/TYPESCRIPT_STANDARDS.md` |
| **Power BI Visual** | + `rules-profiles/typescript/POWERBI_VISUAL_STANDARDS.md` |

### Tier 3: On-demand (`~/.claude/rules-ondemand/*.md`)
Manuel @-import ved aktivt brug: `SECURITY_BEST_PRACTICES`,
`CI_CD_WORKFLOW`, `DEPLOYMENT_GUIDE`, `OBSERVABILITY_STANDARDS`,
`WINDOWS_ENVIRONMENT`.

---

## Bootstrap-procedure

1. **Projekttype:** Læs lokal `CLAUDE.md` → `## Project Overview`.
   Typer: Shiny | R Package | Quarto | TypeScript | Power BI Visual |
   Generic R (default). Detektion: TS = `package.json` + `tsconfig.json`;
   PBI = TS + `pbiviz.json` + `capabilities.json`.
2. **Platform:** Windows (win32) → kopiér manuelt
   `rules-ondemand/WINDOWS_ENVIRONMENT.md` → `rules/` for auto-load.
   ALDRIG `gh` CLI på Windows; fuld sti til R/Rscript.
3. **Verificér Tier 2 @-imports** i projekt-CLAUDE.md matcher typen
   (tabel ovenfor).
4. **OpenSpec:** `openspec/` findes → læs `openspec/project.md` +
   `openspec/AGENTS.md`, brug OpenSpec-workflow til non-trivielle
   ændringer. Findes ej → foreslå `openspec init` kun ved større
   arkitektur-ændringer.

---

**Sidst opdateret:** 2026-06-12
**Del af:** ~/.claude/ global configuration system
