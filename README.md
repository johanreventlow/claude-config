# Claude Code Global Configuration

Dette repository indeholder globale standarder, agents, commands og templates for Claude Code udvikling.

## 📁 Struktur

```
~/.claude/
├── rules/              # Globale udviklingsstandarder
│   ├── R_STANDARDS.md
│   ├── SHINY_STANDARDS.md
│   ├── GIT_WORKFLOW.md
│   └── QUARTO_STANDARDS.md
├── agents/             # Generelle code review agents
├── commands/           # Generelle commands
├── templates/          # Templates til nye projekter
└── README.md
```

## 🎯 Anvendelse

### Automatisk Bootstrap ved Session Start

**Implementeret:** Smart Lazy Loading (Anbefaling 1)

Ved hver ny Claude Code session injicerer UserPromptSubmit hook automatisk bootstrap-instruktioner.

**Hvordan det virker:**
1. Hook kører ved første prompt (`~/.claude/hooks/ensure-bootstrap.sh`)
2. Injicerer mandatory reminder til at læse bootstrap-workflow
3. Auto-approval regler tillader friction-free læsning af `.claude/rules/**`
4. Claude læser relevante standarder baseret på projekttype

**Auto-approved reads:**
- `~/.claude/rules/**` - Alle globale standarder
- `~/Documents/R/*/CLAUDE.md` - Projekt-specifikke instruktioner

**Resultat:** Deterministisk bootstrap uden manuel intervention.

### I Projekter

Projekter refererer til disse globale standarder via deres `CLAUDE.md`:

```markdown
## 📚 Global Standards

**Dette projekt følger globale standarder dokumenteret i:**

- **R Development**: `~/.claude/rules/R_STANDARDS.md`
- **Shiny Development**: `~/.claude/rules/SHINY_STANDARDS.md`
- **Git Workflow**: `~/.claude/rules/GIT_WORKFLOW.md`
```

### Nye Projekter

Brug templates til at starte nye projekter:

```bash
# Shiny app
cp ~/.claude/templates/CLAUDE_TEMPLATE_SHINY.md ~/new-project/CLAUDE.md

# R package
cp ~/.claude/templates/CLAUDE_TEMPLATE_R_PACKAGE.md ~/new-package/CLAUDE.md

# Quarto website
cp ~/.claude/templates/CLAUDE_TEMPLATE_QUARTO.md ~/new-site/CLAUDE.md

# Generic R project
cp ~/.claude/templates/CLAUDE_TEMPLATE_GENERIC.md ~/new-project/CLAUDE.md
```

## 🔄 Git Workflow

### Opdatering af Globale Standarder

Når du opdaterer globale regler, agents eller templates:

```bash
cd ~/.claude

# Se ændringer
git status
git diff

# Commit ændringer
git add rules/R_STANDARDS.md
git commit -m "docs: opdater tidyverse best practices"

# (Optional) Push til remote
git push origin main
```

### Synkronisering På Tværs af Maskiner

Hvis du arbejder på flere maskiner:

```bash
# Første gang (på ny maskine)
cd ~
mv .claude .claude.backup  # Backup eksisterende hvis relevant
git clone <repository-url> .claude

# Senere updates
cd ~/.claude
git pull
```

## 📝 Commit Guidelines

**Commit message format:**
```
type: kort beskrivelse

Længere forklaring hvis nødvendigt.
```

**Types:**
- `feat`: Ny regel, agent, command eller template
- `docs`: Opdatering af eksisterende dokumentation
- `fix`: Rettelse af fejl i regler/templates
- `refactor`: Omstrukturering uden funktionsændring
- `chore`: Vedligeholdelse (gitignore, README, etc.)

**Eksempler:**
```bash
git commit -m "feat: tilføj QUARTO_STANDARDS.md"
git commit -m "docs: opdater Shiny reactive patterns i SHINY_STANDARDS.md"
git commit -m "feat: tilføj data-validation-reviewer agent"
git commit -m "fix: ret typo i R_STANDARDS.md"
```

## 🤖 Auto-Commit Forslag

Når Claude Code opdaterer filer i `~/.claude/`, bør den foreslå at committe ændringer.

**Workflow:**
1. Claude opdaterer en regel/agent/template
2. Claude foreslår: "Skal jeg committe denne ændring til ~/.claude/ git repo?"
3. Hvis ja: lav commit med beskrivende message
4. Hvis nej: ændringerne forbliver uncommitted (kan committes senere)

## 🔗 Projekt-Specifikke .claude/ Mapper

Projekt-specifikke agents/commands i `<projekt>/.claude/` kan også versionsstyres:

### Option 1: Del af Projekt Repo
```bash
# Inkluder .claude/ i projekt git repo
cd ~/project
git add .claude/
git commit -m "docs: tilføj projekt-specifikke Claude agents"
```

### Option 2: Separat Claude Config Repo
For projekter hvor du vil holde Claude config separat fra kodebase:

```bash
# Opret separat repo for projekt Claude config
cd ~/project/.claude
git init
git add .
git commit -m "initial: projekt-specifikke Claude agents"
```

## 📚 Vedligeholdelse

### Regulær Review
Gennemgå og opdater standarder regelmæssigt:
- Når nye R/Shiny best practices opstår
- Efter større refactorings i projekter
- Ved opdatering af dependencies eller frameworks

### Breaking Changes
Når globale standarder ændres væsentligt:
1. Dokumenter ændringen i commit message
2. Overvej om projekt-specifikke CLAUDE.md filer skal opdateres
3. Kommuniker breaking changes til teamet (hvis relevant)

## 🔍 Historie og Rollback

Se historik over ændringer:
```bash
cd ~/.claude
git log --oneline
git log rules/R_STANDARDS.md
```

Rollback til tidligere version:
```bash
git checkout <commit-hash> -- rules/R_STANDARDS.md
git commit -m "revert: rollback R_STANDARDS til tidligere version"
```

## 🌐 Deling og Collaboration

Hvis du arbejder i team eller vil dele dine standarder:

1. **Opret remote repository** (GitHub, GitLab, etc.)
2. **Push globale standarder:**
   ```bash
   cd ~/.claude
   git remote add origin <repository-url>
   git push -u origin main
   ```
3. **Andre kan klone:**
   ```bash
   git clone <repository-url> ~/.claude
   ```

## 📋 Checklist ved Ændringer

- [ ] Opdateret relevant fil (rules/agents/templates)
- [ ] Testet i et projekt
- [ ] Commit med beskrivende message
- [ ] Pushet til remote (hvis applicable)
- [ ] Dokumenteret breaking changes
