# Git Workflow Standards

Standarder for Git workflow og version control.

## Branch Strategy

### Feature Branches
```bash
# Opret feature branch
git checkout -b feat/ny-feature
git checkout -b fix/bug-beskrivelse
git checkout -b refactor/forbedring
git checkout -b docs/dokumentation
```

### Branch Naming
- `feat/` - Nye features
- `fix/` - Bug fixes
- `refactor/` - Code refactoring
- `docs/` - Dokumentation
- `test/` - Test-relaterede ændringer
- `chore/` - Vedligeholdelse

## Commit Guidelines

### Commit Messages (Dansk)
```
type(scope): kort handle-orienteret beskrivelse

Længere forklaring af hvad og hvorfor (ikke hvordan).

- Bullet points for flere ændringer
- Reference til issues: #123
```

### Commit Types
- `feat` - Ny funktionalitet
- `fix` - Bug fix
- `refactor` - Refactoring uden funktionsændring
- `test` - Tilføj eller opdater tests
- `docs` - Dokumentation
- `chore` - Vedligeholdelse (dependencies, config)
- `perf` - Performance forbedring
- `style` - Formatering (ingen kodeændring)

### Good Commit Examples
```bash
# ✅ God commit message
git commit -m "feat(data): tilføj support for Excel import

Implementerer read_excel() wrapper med validering.
Håndterer både .xls og .xlsx formater.

- Tilføjet error handling for korrupte filer
- Opdateret tests
- Dokumenteret i README

Fixes #42"

# ❌ Dårlig commit message
git commit -m "updated stuff"
git commit -m "fix"
```

## Protected Branches

### Master/Main Branch
- **ALDRIG** commit direkte til master/main
- **ALTID** gennem pull requests
- Kræver code review
- Automatiske tests skal bestå

### Working on Features
```bash
# 1. Opret feature branch
git checkout -b feat/ny-feature

# 2. Arbejd og commit
git add .
git commit -m "feat: implementer ny feature"

# 3. Push til remote
git push -u origin feat/ny-feature

# 4. Opret Pull Request (kun efter godkendelse)
gh pr create --title "Feat: Ny feature" --body "Beskrivelse..."
```

## Pre-Commit Checks

### Automated Checks
```bash
# Kør tests
testthat::test_dir('tests/testthat')

# Linting
lintr::lint_dir()

# Formattering
styler::style_dir()

# Build check (for packages)
devtools::check()
```

### Manual Checks
- [ ] Kode kompilerer uden fejl
- [ ] Tests bestået
- [ ] Dokumentation opdateret
- [ ] NAMESPACE opdateret (hvis relevant)
- [ ] Ingen debug statements (`browser()`, `print()`)
- [ ] Ingen secrets eller credentials

## Pull Request Process

### Creating PRs
```bash
# Gennem GitHub CLI
gh pr create \
  --title "Feat: Beskrivelse" \
  --body "## Ændringer
- Punkt 1
- Punkt 2

## Test plan
- [x] Unit tests
- [x] Manual test

## Screenshots
(hvis relevant)"
```

### PR Template
```markdown
## Beskrivelse
[Beskriv ændringerne]

## Motivation og kontekst
[Hvorfor er denne ændring nødvendig?]

## Type ændring
- [ ] Bug fix
- [ ] Ny feature
- [ ] Breaking change
- [ ] Dokumentation

## Test plan
- [ ] Unit tests tilføjet/opdateret
- [ ] Manual test udført
- [ ] Edge cases testet

## Checklist
- [ ] Kode følger projekt style guide
- [ ] Tests bestået
- [ ] Dokumentation opdateret
- [ ] Ingen breaking changes (eller dokumenteret)
```

## Common Operations

### Syncing with Main
```bash
# Opdater din branch med seneste ændringer
git checkout main
git pull origin main
git checkout feat/ny-feature
git rebase main

# Eller merge (hvis rebase ikke er muligt)
git merge main
```

### Fixing Mistakes
```bash
# Undo sidste commit (behold ændringer)
git reset --soft HEAD~1

# Undo sidste commit (slet ændringer)
git reset --hard HEAD~1

# Amend sidste commit message
git commit --amend -m "Ny besked"

# Amend sidste commit (tilføj flere ændringer)
git add forgotten_file.R
git commit --amend --no-edit
```

### Stashing Changes
```bash
# Gem arbejde midlertidigt
git stash

# Liste stashes
git stash list

# Hent stash tilbage
git stash pop

# Anvend stash uden at fjerne
git stash apply
```

## Collaboration

### Code Review Guidelines
- Vær konstruktiv og respektfuld
- Fokuser på kode, ikke person
- Giv konkrete forslag
- Anerkend gode løsninger
- Test ændringerne lokalt hvis muligt

### Responding to Review
- Adresser alle kommentarer
- Forklar beslutninger hvis nødvendigt
- Vær åben for feedback
- Opdater PR baseret på feedback
- Markér kommentarer som resolved

## Best Practices

### Atomic Commits
- Én logisk ændring per commit
- Kommitter der kan stå alene
- Undgå "WIP" commits i main branch

### Commit Frequency
- Commit ofte i feature branches
- Squash/rebase før merge til main
- Bevar logisk commit historie

### Branch Hygiene
```bash
# Slet merged branches lokalt
git branch -d feat/old-feature

# Slet merged branches remote
git push origin --delete feat/old-feature

# Ryd op i gamle tracking branches
git fetch --prune
```

## Safety Rules

### Never Do This
❌ Force push til shared branches:
```bash
git push --force origin main  # ALDRIG!
```

❌ Commit sensitive data:
- API keys
- Passwords
- Database credentials
- Private keys

❌ Commit generated files (tilføj til `.gitignore`):
- `*.Rhistory`
- `.RData`
- `*.rds` (medmindre data)
- `_site/` (Quarto output)

### Always Do This
✅ Pull før push
✅ Test før commit
✅ Review egen diff før commit
✅ Write meaningful commit messages
✅ Keep commits focused and atomic

## Git Configuration

### Recommended Setup
```bash
# Sæt dit navn og email
git config --global user.name "Dit Navn"
git config --global user.email "din@email.dk"

# Sæt default branch navn
git config --global init.defaultBranch main

# Enable colored output
git config --global color.ui auto

# Set default editor
git config --global core.editor "code --wait"
```

### Useful Aliases
```bash
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
```
