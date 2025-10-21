# Claude Code Templates

Templates til oprettelse af CLAUDE.md filer i nye projekter.

## Available Templates

### 1. Generic R Project
**File:** `CLAUDE_TEMPLATE_GENERIC.md`

Brug til:
- Simple R scripts
- Data analysis projekter
- Projekter uden specifik framework

### 2. Shiny Application
**File:** `CLAUDE_TEMPLATE_SHINY.md`

Brug til:
- Shiny apps
- Shiny dashboards
- Golem-baserede projekter

### 3. Quarto Website
**File:** `CLAUDE_TEMPLATE_QUARTO.md`

Brug til:
- Quarto websites
- Quarto blogs
- Documentation sites
- Data portals

### 4. R Package
**File:** `CLAUDE_TEMPLATE_R_PACKAGE.md`

Brug til:
- R packages
- Package development
- CRAN submissions

## How to Use

1. **Opret nyt projekt**

2. **Kopier relevant template:**
```bash
# For et Shiny projekt
cp ~/.claude/templates/CLAUDE_TEMPLATE_SHINY.md /path/to/project/CLAUDE.md

# For et Quarto projekt
cp ~/.claude/templates/CLAUDE_TEMPLATE_QUARTO.md /path/to/project/CLAUDE.md

# For en R package
cp ~/.claude/templates/CLAUDE_TEMPLATE_R_PACKAGE.md /path/to/project/CLAUDE.md

# For et generisk R projekt
cp ~/.claude/templates/CLAUDE_TEMPLATE_GENERIC.md /path/to/project/CLAUDE.md
```

3. **Tilpas CLAUDE.md:**
   - Erstat `[PLACEHOLDERS]` med projekt-specifikke værdier
   - Fjern irrelevante sections
   - Tilføj projekt-specifikke patterns og guidelines

4. **Fjern ubrugte globale references:**
   - Hvis ikke Shiny: fjern reference til `SHINY_STANDARDS.md`
   - Hvis ikke Quarto: fjern reference til `QUARTO_STANDARDS.md`

## Template Structure

Alle templates følger samme struktur:

```markdown
# CLAUDE.md

## 📚 Global Standards
[References til globale regler]

## Project Overview
[Projekt beskrivelse]

## Architecture
[Arkitektur og struktur]

## Development Workflow
[Commands og workflows]

## Important Patterns
[Projekt-specifikke mønstre]

## Configuration
[Konfiguration]

## Dependencies
[Dependencies]

## Troubleshooting
[Common issues]

## Project-Specific Guidelines
[Specifikke guidelines]

## Constraints
[Begrænsninger]
```

## Customization Tips

### Placeholders at erstatte:
- `[PROJECT_NAME]` - Dit projektnavn
- `[APP_NAME]` - App navn (Shiny)
- `[SITE_NAME]` - Website navn (Quarto)
- `[PACKAGE_NAME]` - Package navn (R Package)
- `[Component 1]`, `[Module 1]` etc. - Dine komponenter
- `[beskrivelse]` - Dine beskrivelser

### Sections at tilpasse:
- **Project Overview**: Beskriv dit specifikke projekt
- **Architecture**: Dokumenter din faktiske arkitektur
- **Common Commands**: Tilføj dine faktiske commands
- **Important Patterns**: Dokumenter dine etablerede mønstre
- **Troubleshooting**: Tilføj kendte problemer

### Sections at fjerne hvis irrelevant:
- Module architecture (hvis ikke modulært)
- State management (hvis ikke kompleks state)
- Publishing (hvis ikke public)
- CI/CD (hvis ikke setup)

## Quick Start Example

```bash
# 1. Opret nyt Quarto projekt
cd ~/projects
quarto create-project my-website

# 2. Kopier template
cp ~/.claude/templates/CLAUDE_TEMPLATE_QUARTO.md my-website/CLAUDE.md

# 3. Rediger CLAUDE.md
cd my-website
code CLAUDE.md  # eller din foretrukne editor

# 4. Erstat placeholders
# Find-replace [SITE_NAME] → "My Website"
# Udfyld projekt-specifikke detaljer
# Slet irrelevante sections

# 5. Commit
git init
git add CLAUDE.md
git commit -m "docs: tilføj CLAUDE.md"
```

## Global Rules Reference

Alle templates refererer til disse globale regler:

- `~/.claude/rules/R_STANDARDS.md` - R development standards
- `~/.claude/rules/SHINY_STANDARDS.md` - Shiny-specific standards
- `~/.claude/rules/QUARTO_STANDARDS.md` - Quarto-specific standards
- `~/.claude/rules/GIT_WORKFLOW.md` - Git workflow standards

## Global Agents Reference

Alle templates har adgang til disse agents:

- `tidyverse-code-reviewer` - Review af tidyverse code
- `shiny-code-reviewer` - Review af Shiny apps
- `performance-optimizer` - Performance analysis
- `security-reviewer` - Security audit
- `test-coverage-analyzer` - Test coverage
- `refactoring-advisor` - Code quality
- `legacy-code-detector` - Technical debt

## Maintenance

Når du opdaterer globale standarder:
1. Opdater filer i `~/.claude/rules/`
2. Eksisterende projekter får automatisk nye standarder
3. Ingen behov for at opdatere projekt-specifikke CLAUDE.md filer
