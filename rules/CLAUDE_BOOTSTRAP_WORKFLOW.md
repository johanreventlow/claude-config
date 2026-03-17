# Claude Bootstrap Workflow

Bootstrap-procedure som Claude følger når arbejde starter i et projekt.

---

## Bootstrap Procedure

### Trin 1: Identificer Projekttype

Læs lokal `CLAUDE.md` → find `## Project Overview` → identificer type:
- **Shiny** | **R Package** | **Quarto** | **Generic**

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
- DEVELOPMENT_PHILOSOPHY.md
- WORKFLOW_PREFERENCES.md

Ved behov:
- TROUBLESHOOTING_GUIDE.md
- GEMINI_CLI_GUIDE.md
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
- DEVELOPMENT_PHILOSOPHY.md
- WORKFLOW_PREFERENCES.md

Ved behov:
- TROUBLESHOOTING_GUIDE.md
- GEMINI_CLI_GUIDE.md
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

**Sidst opdateret:** 2026-03-17
**Del af:** ~/.claude/ global configuration system
