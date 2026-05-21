# Git Workflow Standards

Standarder Git workflow + version control.

---

## Branch Strategy

**Branch naming:**
- `feat/` - Nye features
- `fix/` - Bug fixes
- `refactor/` - Code refactoring
- `docs/` - Dokumentation
- `test/` - Test-ændringer
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
3. Claude attribution footers:
   - ❌ "🤖 Generated with [Claude Code]"
   - ❌ "Co-Authored-By: Claude <noreply@anthropic.com>"
4. Bypass pre-commit/pre-push hooks uden eksplicit godkendelse
   (`--no-verify`, `--no-gpg-sign`, `SKIP_*=1`-env-flags).
   Fejlende hook = fix root cause, ej bypass.

✅ **OK uden aftale (feature branch):**
- Flere commits i serie samme feature branch indtil opgave logisk afsluttet
- Rediger + skriv filer (Claude Code system-prompt håndterer "check bruger før hard-to-reverse actions")

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

**Versionering:** Regler version-bump, NEWS-format, git-tags +
cross-repo bump-protokol — se `VERSIONING_POLICY.md`. Commit-prefixes
afgør default bump (`feat:` → MINOR, `fix:` → PATCH, `BREAKING CHANGE:` → MAJOR).

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
(Master)" komplet liste (tests, logging, error handling, performance,
docs, formatering, linting, NAMESPACE, debug statements, secrets).

---

## Pull Request Process

**ALTID `--draft`** — bruger markerer selv "Ready for review" efter godkendelse.
Gælder ved direkte PR-oprettelse, skills (`commit-push-pr`, `triage-and-ship`,
osv.) og enhver anden kontekst.

```bash
gh pr create --draft --title "feat(scope): beskrivelse" --body "$(cat <<'EOF'
## Summary
<1-3 bullet points>

## Test plan
[Bulleted markdown checklist of TODOs for testing the pull request...]
EOF
)"
```

Brug `## Test plan` til uafkrydsede items for kendte gaps / manglende tests.

Windows uden `gh` CLI: se `WINDOWS_ENVIRONMENT.md` (rules-ondemand).

**PR checklist:** Kode følger style + tests bestået + docs opdateret +
breaking changes dokumenteret.

---

## Safety Rules

❌ Aldrig: force push shared branches, commit secrets/API keys, commit
generated files (`.Rhistory`, `.RData`, `*.rds`, `_site/`).

✅ Altid: pull før push, test før commit, review egen diff, focused +
atomic commits.

---

**Sidst opdateret:** 2025-10-21