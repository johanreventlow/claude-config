# Claude Code Global Configuration

Centraliseret konfiguration for Claude Code på tværs af projekter og maskiner.

## Struktur

```
~/.claude/
├── CLAUDE.md                 # Global entry point (auto-loaded)
├── settings.json             # Global settings (model, statusline, auto-approval)
├── settings.local.json       # Lokale permissions
├── statusline.sh             # Custom statusline script
│
├── rules/                    # Globale udviklingsstandarder (14 filer)
│   ├── CLAUDE_BOOTSTRAP_WORKFLOW.md   # Bootstrap procedure
│   ├── R_STANDARDS.md                 # R udvikling
│   ├── SHINY_STANDARDS.md             # Shiny basics
│   ├── SHINY_ADVANCED_PATTERNS.md     # Shiny advanced
│   ├── GIT_WORKFLOW.md                # Git workflow
│   ├── DEVELOPMENT_PHILOSOPHY.md      # Udviklingsfilosofi
│   ├── ARCHITECTURE_PATTERNS.md       # Arkitekturmønstre
│   ├── QUARTO_STANDARDS.md            # Quarto websites
│   ├── TROUBLESHOOTING_GUIDE.md       # Debugging
│   ├── SECURITY_BEST_PRACTICES.md     # Sikkerhed
│   ├── OBSERVABILITY_STANDARDS.md     # Logging/monitoring
│   ├── CI_CD_WORKFLOW.md              # CI/CD
│   ├── DEPLOYMENT_GUIDE.md            # Deployment
│   └── GEMINI_CLI_GUIDE.md            # Gemini CLI til store kodebaser
│
├── agents/                   # Specialiserede review agents (15 filer)
│   ├── tidyverse-code-reviewer.md
│   ├── shiny-code-reviewer.md
│   ├── architecture-validator.md
│   ├── performance-optimizer.md
│   ├── security-reviewer.md
│   ├── test-coverage-analyzer.md
│   ├── refactoring-advisor.md
│   ├── legacy-code-detector.md
│   ├── error-handling-reviewer.md
│   ├── logging-reviewer.md
│   ├── configuration-reviewer.md
│   ├── code-analyzer.md
│   ├── file-analyzer.md
│   ├── test-runner.md
│   └── parallel-worker.md
│
├── commands/                 # Slash commands
│   ├── bootstrap.md          # /bootstrap - Læs relevante standarder
│   ├── debugger.md           # /debugger - Debugging specialist
│   ├── boost.md              # /boost - Performance boost
│   ├── reflection.md         # /reflection - Selvrefleksion
│   ├── code-rabbit.md        # /code-rabbit - Code review
│   └── re-init.md            # /re-init - Geninitialisering
│
├── templates/                # CLAUDE.md templates til nye projekter
│   ├── CLAUDE_TEMPLATE_SHINY.md
│   ├── CLAUDE_TEMPLATE_R_PACKAGE.md
│   ├── CLAUDE_TEMPLATE_QUARTO.md
│   └── CLAUDE_TEMPLATE_GENERIC.md
│
├── hooks/                    # Git/bash hooks
├── scripts/                  # Hjælpescripts
└── plugins/                  # Installerede plugins
```

## Sådan virker det

### Automatisk loading

Claude Code læser automatisk `~/.claude/CLAUDE.md` ved session start. Denne fil bruger native `@import` til at inkludere bootstrap-workflowet:

```markdown
# ~/.claude/CLAUDE.md
@~/.claude/rules/CLAUDE_BOOTSTRAP_WORKFLOW.md
```

### Bootstrap-processen

1. **Projekttype identificeres** fra lokal `CLAUDE.md` (`## Project Overview`)
2. **Relevante rules læses** baseret på type (Shiny, R Package, Quarto, Generic)
3. **Standarder enforces** gennem hele sessionen

### Projekt-integration

Projekter refererer til globale standarder via deres lokale `CLAUDE.md`:

```markdown
## Project Overview
**Type:** R Package

## Global Standards Reference
- **R Development:** `~/.claude/rules/R_STANDARDS.md`
- **Git Workflow:** `~/.claude/rules/GIT_WORKFLOW.md`
```

## Installation

### Mac/Linux

```bash
# Clone til ~/.claude
git clone https://github.com/johanreventlow/claude-config.git ~/.claude

# Eller hvis ~/.claude allerede eksisterer
cd ~
mv .claude .claude.backup
git clone https://github.com/johanreventlow/claude-config.git .claude
```

### Windows (PowerShell)

```powershell
# Clone til brugerens .claude mappe
git clone https://github.com/johanreventlow/claude-config.git $env:USERPROFILE\.claude
```

### Windows (Git Bash)

```bash
git clone https://github.com/johanreventlow/claude-config.git ~/.claude
```

### Efter installation

1. **Tilpas stier i `settings.json`** hvis nødvendigt (Mac-stier → Windows-stier)
2. **Installer plugins:**
   ```bash
   claude plugins install claude-mem@thedotmack
   ```
3. **Statusline (valgfrit):** `statusline.sh` kræver bash - på Windows brug Git Bash eller deaktiver i settings.json

## Synkronisering på tværs af maskiner

### Pull ændringer

```bash
cd ~/.claude
git pull origin main
```

### Push ændringer

```bash
cd ~/.claude
git add -A
git commit -m "docs: opdater R_STANDARDS"
git push origin main
```

## Nye projekter

Brug templates til at oprette `CLAUDE.md` i nye projekter:

```bash
# Shiny app
cp ~/.claude/templates/CLAUDE_TEMPLATE_SHINY.md ~/nyt-projekt/CLAUDE.md

# R package
cp ~/.claude/templates/CLAUDE_TEMPLATE_R_PACKAGE.md ~/ny-pakke/CLAUDE.md

# Quarto website
cp ~/.claude/templates/CLAUDE_TEMPLATE_QUARTO.md ~/ny-site/CLAUDE.md

# Generic R projekt
cp ~/.claude/templates/CLAUDE_TEMPLATE_GENERIC.md ~/nyt-projekt/CLAUDE.md
```

## Commit guidelines

```bash
# Types
feat:     # Ny regel, agent, command eller template
docs:     # Opdatering af dokumentation
fix:      # Rettelse af fejl
refactor: # Omstrukturering
chore:    # Vedligeholdelse

# Eksempler
git commit -m "feat: tilføj vue-code-reviewer agent"
git commit -m "docs: opdater SHINY_STANDARDS med nye patterns"
git commit -m "fix: ret typo i GIT_WORKFLOW"
```

## Filer der IKKE committes

Følgende er gitignored (lokale/session-specifikke):

- `history.jsonl` - Samtalehistorik
- `plans/` - Session-specifikke planer
- `todos/` - Todo-lister
- `debug/` - Debug logs
- `session-env/` - Session environment
- `shell-snapshots/` - Shell snapshots
- `plugins/cache/` - Plugin cache
- `.DS_Store` - macOS metadata

## OpenSpec

OpenSpec er **projekt-specifikt** og forbliver i hvert projekt:

```
projekt/
├── openspec/
│   ├── AGENTS.md      # Auto-genereret af openspec update
│   ├── project.md     # Projekt-specifik kontekst
│   ├── specs/         # Capability specs
│   └── changes/       # Ændringsforslag
```

Opdater OpenSpec i alle projekter efter CLI-opgradering:

```bash
cd ~/projekt1 && openspec update
cd ~/projekt2 && openspec update
```

---

**Repository:** https://github.com/johanreventlow/claude-config
**Sidst opdateret:** 2025-12-14
