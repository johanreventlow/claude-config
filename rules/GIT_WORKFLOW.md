# Git Workflow Standards

Standarder for Git workflow og version control.

---

## Branch Strategy

**Branch naming:**
- `feat/` - Nye features
- `fix/` - Bug fixes
- `refactor/` - Code refactoring
- `docs/` - Dokumentation
- `test/` - Test-relaterede ændringer
- `chore/` - Vedligeholdelse

**Opret feature branch:**
```bash
git checkout -b feat/ny-feature
git checkout -b fix/bug-beskrivelse
```

---

## ⚠️ OBLIGATORISKE REGLER (KRITISK)

❌ **ALDRIG:**
1. Merge til master/main uden eksplicit godkendelse
2. Push til remote uden anmodning
3. Tilføj Claude attribution footers:
   - ❌ "🤖 Generated with [Claude Code]"
   - ❌ "Co-Authored-By: Claude <noreply@anthropic.com>"

⏸️ **STOP efter feature branch commit** - vent på instruktion:
```bash
git checkout -b fix/feature-name
# ... arbejd og commit ...
git commit -m "beskrivelse"
# STOP HER - vent på instruktion
```

✅ **OK uden aftale:**
- `git status`, `git diff`, `git log`
- Lokale branches (ingen push/merge)

---

## Commit Guidelines

**Format:**
```
type(scope): kort beskrivelse

Længere forklaring (hvorfor, ikke hvordan).
- Bullet points
- Reference: #123
```

**Types:**
`feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`, `style`

---

## Pre-Commit Checks

```bash
# Automated
testthat::test_dir('tests/testthat')
lintr::lint_dir()
styler::style_dir()
devtools::check()  # For packages

# Manual checklist
```
- [ ] Kode kompilerer
- [ ] Tests bestået
- [ ] Dokumentation opdateret
- [ ] NAMESPACE opdateret (hvis relevant)
- [ ] Ingen debug statements
- [ ] Ingen secrets

---

## Pull Request Process

**Via GitHub CLI:**
```bash
gh pr create \
  --title "Feat: Beskrivelse" \
  --body "## Ændringer
- Punkt 1
- Punkt 2

## Test plan
- [x] Unit tests
- [x] Manual test"
```

**PR checklist:**
- [ ] Kode følger style guide
- [ ] Tests bestået
- [ ] Dokumentation opdateret
- [ ] Ingen breaking changes (eller dokumenteret)

---

## Common Operations

**Sync med main:**
```bash
git checkout main
git pull origin main
git checkout feat/ny-feature
git rebase main  # Eller: git merge main
```

**Fix mistakes:**
```bash
# Undo sidste commit (behold ændringer)
git reset --soft HEAD~1

# Amend sidste commit
git commit --amend -m "Ny besked"
```

**Stashing:**
```bash
git stash        # Gem arbejde
git stash pop    # Hent tilbage
```

---

## Branch Hygiene

```bash
# Slet merged branches
git branch -d feat/old-feature
git push origin --delete feat/old-feature
git fetch --prune
```

---

## Safety Rules

❌ **Never:**
- Force push til shared branches: `git push --force origin main`
- Commit sensitive data (API keys, passwords, credentials)
- Commit generated files (tilføj til `.gitignore`):
  - `*.Rhistory`, `.RData`, `*.rds`, `_site/`

✅ **Always:**
- Pull før push
- Test før commit
- Review egen diff før commit
- Write meaningful commit messages
- Keep commits focused and atomic

---

**Sidst opdateret:** 2025-10-21
