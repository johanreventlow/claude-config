# Git Workflow for Claude Configuration

## For Claude Code AI

**VIGTIGT:** Når du opdaterer filer i `~/.claude/` (rules, agents, commands, templates), skal du **altid foreslå at committe ændringerne** til git.

### Workflow

1. **Efter ændring af globale filer:**
   ```
   Du har opdateret ~/.claude/rules/R_STANDARDS.md

   Skal jeg committe denne ændring til ~/.claude/ git repository?

   Foreslået commit message:
   "docs: opdater tidyverse best practices med ny NULL coalescing pattern"
   ```

2. **Hvis bruger siger ja:**
   ```bash
   cd ~/.claude
   git add rules/R_STANDARDS.md
   git commit -m "docs: opdater tidyverse best practices med ny NULL coalescing pattern"
   ```

3. **Hvis bruger siger nej:**
   - Ændringerne forbliver uncommitted
   - Bruger kan selv committe senere
   - Vis reminder: "Husk at committe ændringer i ~/.claude/ når du er klar"

### Commit Message Guidelines

**Format:**
```
type: kort beskrivelse

Længere forklaring hvis nødvendigt.
```

**Types:**
- `feat` - Ny regel, agent, command eller template
- `docs` - Opdatering af eksisterende dokumentation
- `fix` - Rettelse af fejl
- `refactor` - Omstrukturering
- `chore` - Vedligeholdelse

**Eksempler:**
```
feat: tilføj performance-testing guidelines til R_STANDARDS
docs: opdater Shiny reactive patterns i SHINY_STANDARDS
feat: tilføj data-quality-reviewer agent
fix: ret typo i QUARTO_STANDARDS
```

### Files That Should Trigger Commit Prompt

**Altid prompt for commit:**
- `rules/*.md` - Global standards
- `agents/*.md` - Agent definitions
- `commands/*.md` - Command definitions
- `templates/*.md` - Project templates
- `README.md` - Documentation
- `.gitignore` - Git configuration

**Aldrig prompt for commit:**
- `debug/`, `downloads/`, `file-history/` - Runtime files
- `history.jsonl`, `settings.json` - Session state
- `projects/`, `session-env/`, `todos/` - Claude Code internals

### Multi-File Changes

Hvis flere filer ændres samtidigt:

```
Du har opdateret følgende filer i ~/.claude/:
- rules/R_STANDARDS.md
- rules/SHINY_STANDARDS.md

Skal jeg committe disse ændringer sammen?

Foreslået commit message:
"docs: opdater R og Shiny standards med konsistent error handling patterns"
```

### Project-Specific .claude/ Folders

For projekt-specifikke `.claude/` mapper (f.eks. `~/Documents/R/my-project/.claude/`):

**Option 1 - Del af projekt repo (anbefalet):**
```
Du har opdateret ~/Documents/R/my-project/.claude/agents/custom-agent.md

Denne fil er del af projekt git repository.
Skal jeg inkludere den i næste projekt commit?

(Tilføj til staging area, men commit ikke automatisk)
```

**Option 2 - Separat repo:**
```
Du har opdateret ~/Documents/R/my-project/.claude/agents/custom-agent.md

Skal jeg committe til separat .claude git repository?
```

### Checking Git Status

Før større operationer:

```bash
cd ~/.claude
git status
git diff
```

Vis brugeren uncommitted changes hvis relevant.

### Remote Repository

Hvis ~/.claude har remote configured:

```
Vil du også pushe ændringer til remote repository?

git push origin main
```

### Best Practices for AI

1. **Vær proaktiv**: Foreslå altid commit efter ændringer
2. **Vær klar**: Forklar hvad der blev ændret
3. **Vær hjælpsom**: Foreslå beskrivende commit messages
4. **Vær respektfuld**: Accepter hvis bruger siger nej
5. **Vær konsekvent**: Brug samme workflow hver gang

### Example Interaction

```
User: "Kan du opdatere R_STANDARDS.md med guidance om %>% vs |> pipe?"