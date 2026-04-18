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

✅ **OK uden aftale (på feature branch):**
- Flere commits i serie på samme feature branch indtil opgaven er logisk afsluttet
- Rediger og skriv filer (Claude Codes system-prompt håndterer allerede "check med bruger før hard-to-reverse actions")

✅ **OK uden aftale (generelt):**
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

**Versionering:** For regler om version-bump, NEWS-format, git-tags og
cross-repo bump-protokol — se `VERSIONING_POLICY.md`. Commit-prefixes
afgør default bump-størrelse (`feat:` → MINOR, `fix:` → PATCH, `BREAKING CHANGE:` → MAJOR).

---

## Pre-Commit Checks

**Automated:**
```bash
testthat::test_dir('tests/testthat')
lintr::lint_dir()
styler::style_dir()
devtools::check()  # For packages
```

**Manual checklist:** Se `DEVELOPMENT_PHILOSOPHY.md` → "Pre-Commit Checklist
(Master)" for den komplette liste (tests, logging, error handling, performance,
docs, formatering, linting, NAMESPACE, debug statements, secrets).

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
