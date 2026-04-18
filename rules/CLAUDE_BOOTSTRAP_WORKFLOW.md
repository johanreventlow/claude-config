# Claude Bootstrap Workflow

Bootstrap-procedure som Claude følger når arbejde starter i et projekt.

---

## Bootstrap Procedure

### Trin 1: Identificer Projekttype

Læs lokal `CLAUDE.md` → find `## Project Overview` → identificer type:
- **Shiny** | **R Package** | **Quarto** | **Generic R** (default)
- **TypeScript** | **Generic** (ikke-R)

Hvis ingen `CLAUDE.md` findes eller ingen type er angivet: antag **Generic R**.

### Trin 1b: Detektér Platform

Hvis platform er **Windows** (win32):
- Læs `WINDOWS_ENVIRONMENT.md` — indeholder R-stier, GitHub-workaround (ingen gh CLI), og shell-detaljer
- Brug altid fuld sti til R/Rscript (ikke i PATH)
- Brug aldrig `gh` kommandoer — brug `git` + browser i stedet

### Trin 2: Læs Globale Standarder

**🟦 Shiny Application**
```
ALTID læs:
- R_STANDARDS.md
- SHINY_STANDARDS.md
- SHINY_ADVANCED_PATTERNS.md
- GIT_WORKFLOW.md
- VERSIONING_POLICY.md
- DEVELOPMENT_PHILOSOPHY.md
- WORKFLOW_PREFERENCES.md

Ved behov:
- ARCHITECTURE_PATTERNS.md
- TROUBLESHOOTING_GUIDE.md
```

**📦 R Package**
```
ALTID læs:
- R_STANDARDS.md
- ARCHITECTURE_PATTERNS.md
- GIT_WORKFLOW.md
- VERSIONING_POLICY.md
- DEVELOPMENT_PHILOSOPHY.md
- WORKFLOW_PREFERENCES.md

Ved behov:
- TROUBLESHOOTING_GUIDE.md
```

**📄 Quarto Website/Publication**
```
ALTID læs:
- QUARTO_STANDARDS.md
- GIT_WORKFLOW.md
- DEVELOPMENT_PHILOSOPHY.md
- WORKFLOW_PREFERENCES.md

Ved behov:
- TROUBLESHOOTING_GUIDE.md
```

**🔧 Generic R Project**
```
ALTID læs:
- R_STANDARDS.md
- ARCHITECTURE_PATTERNS.md
- GIT_WORKFLOW.md
- VERSIONING_POLICY.md
- DEVELOPMENT_PHILOSOPHY.md
- WORKFLOW_PREFERENCES.md

Ved behov:
- TROUBLESHOOTING_GUIDE.md
```

**🟨 TypeScript Project**
```
ALTID læs (auto-loaded globale regler bruges):
- GIT_WORKFLOW.md
- DEVELOPMENT_PHILOSOPHY.md
- WORKFLOW_PREFERENCES.md
- SECURITY_BEST_PRACTICES.md

Ignorér R-specifikke globale regler:
- R_STANDARDS.md
- SHINY_STANDARDS.md
- SHINY_ADVANCED_PATTERNS.md
- QUARTO_STANDARDS.md
- ARCHITECTURE_PATTERNS.md (R/Golem-specifik)

Følg TypeScript-konventioner:
- ESLint/Prettier for formatering og linting
- tsconfig.json for compiler-indstillinger
- npm/pnpm for package management
- Vitest/Jest for testing
- Conventional Commits (samme format som R-projekter)
```

**⬜ Generic Project (ikke-R, ikke-TS)**
```
ALTID læs (auto-loaded globale regler bruges):
- GIT_WORKFLOW.md
- DEVELOPMENT_PHILOSOPHY.md
- WORKFLOW_PREFERENCES.md
- SECURITY_BEST_PRACTICES.md

Ignorér R-specifikke globale regler:
- R_STANDARDS.md
- SHINY_STANDARDS.md
- SHINY_ADVANCED_PATTERNS.md
- QUARTO_STANDARDS.md
- ARCHITECTURE_PATTERNS.md

Følg projekt-specifik CLAUDE.md for sprogspecifikke konventioner.
```

**📋 OpenSpec (Standard for alle projekter)**
```
OpenSpec Integration:
- Hvis openspec/ ikke findes: Foreslå `openspec init`
- Hvis openspec/ findes: Læs openspec/project.md og openspec/AGENTS.md
- Brug OpenSpec workflow for alle non-trivielle ændringer

Fordele:
- Detaljeret projekt-specifik dokumentation
- Struktureret change management
- Single source of truth for konventioner
```

### Trin 3: Anvend Standarderne

Efter læsning:
1. Enforc regler ved code review
2. Foreslå struktur baseret på best practices
3. Foreslå git workflow
4. Flag afvigelser fra standarderne

---

## Enforcement Rules

### For Alle Projekttyper

✅ **Gør automatisk:**
- Læs lokale CLAUDE.md + relevante globale filer
- Foreslå git branches
- Enforc commit message format
- Flag manglende tests
- Kontroller pre-commit checklist

❌ **Gør IKKE - OBLIGATORISKE REGLER:**
- Commit direkte til main/master
- Merge til main/master uden eksplicit godkendelse
- Push til remote uden anmodning
- Ændre git config
- Skrive filer uden godkendelse
- **ALDRIG tilføj Claude attribution footers** til commits
  - ❌ "🤖 Generated with Claude Code"
  - ❌ "Co-Authored-By: Claude <noreply@anthropic.com>"
- Push og merge uden eksplicit instruktion

### Ekstra Enforcement

**Shiny Apps:**
- Kontroller reactive patterns
- Flag potential reactive storms
- Foreslå reactive prioritization
- Check error handling

**R Packages:**
- Kontroller `devtools::check()` status
- Enforc documentation requirements
- Kontroller test coverage
- Flag NAMESPACE manual edits

**Quarto:**
- Kontroller render output
- Validér listings og cross-references
- Check broken links

**TypeScript:**
- Kontroller ESLint/Prettier compliance
- Enforc strict TypeScript (no `any` uden begrundelse)
- Kontroller test coverage (Vitest/Jest)
- Flag manglende type annotations på exports

**Generic (ikke-R):**
- Følg projektets egne conventions fra CLAUDE.md
- Enforc generelle kvalitetsstandarder (TDD, logging, error handling)

---

## Checklist for Bootstrap

- [ ] Læst lokal CLAUDE.md
- [ ] Identificeret projekttype
- [ ] Detekteret platform (Windows → læs WINDOWS_ENVIRONMENT.md)
- [ ] Læst alle relevante globale rules
- [ ] OpenSpec: Initialiseret eller læst eksisterende
- [ ] Workflow preferences: Læst og klar til enforcement
- [ ] Forstået projekt-specifik guidance
- [ ] Klar til at enforce standarder
- [ ] Kan foreslå struktur+workflow

---

**Sidst opdateret:** 2026-03-24
**Del af:** ~/.claude/ global configuration system
