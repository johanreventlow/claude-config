# CI/CD Workflow

Standards for Continuous Integration og Deployment i R-projekter.

---

## Principles

**CI (Continuous Integration):**
- Automated testing på alle commits/PRs
- Automated linting og style checks
- Code coverage tracking
- Platform compatibility checks

**CD (Continuous Deployment):**
- Deploy til staging efter CI
- Manual approval for production
- Rollback procedure dokumenteret

---

## GitHub Actions Basics

**Common R actions:**
```yaml
- uses: actions/checkout@v3
- uses: r-lib/actions/setup-r@v2
  with:
    r-version: '4.3.2'
- uses: r-lib/actions/setup-renv@v2     # Auto caching
- uses: r-lib/actions/setup-pandoc@v2
- uses: quarto-dev/quarto-actions/setup@v2
```

---

## Workflows by Type

**R Package:**
```yaml
# .github/workflows/R-CMD-check.yml
jobs:
  check:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu, windows, macos]
        r: ['4.2.3', '4.3.2']
    steps:
      - uses: actions/checkout@v3
      - uses: r-lib/actions/setup-r@v2
      - uses: r-lib/actions/setup-r-dependencies@v2
      - run: rcmdcheck::rcmdcheck(args = "--no-manual")
```

**Shiny App:**
- Test + lint + Docker build
- Deploy til staging/production

**Quarto:**
- Render + deploy til GitHub Pages

---

## Code Quality

**Linting:**
```yaml
- run: |
    lints <- lintr::lint_package()
    if (length(lints) > 0) quit(status = 1)
  shell: Rscript {0}
```

**Style check:**
```yaml
- run: |
    restyled <- styler::style_pkg(dry = "on")
    if (length(restyled$changed) > 0) quit(status = 1)
  shell: Rscript {0}
```

---

## Caching

```yaml
# renv auto-caching
- uses: r-lib/actions/setup-renv@v2

# Docker layer caching
- uses: docker/build-push-action@v4
  with:
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

---

## Branch Protection

**Setup → Branches → Add rule for `main`:**
- ✅ Require pull request (1 approval)
- ✅ Require status checks (R-CMD-check, Lint)
- ✅ Require branches up to date
- ✅ Include administrators

---

## Secrets Management

**Setup secrets:** Repository → Settings → Secrets and variables → Actions

**Brug:**
```yaml
env:
  API_KEY: ${{ secrets.API_KEY }}
```

**Environment secrets:**
```yaml
jobs:
  deploy-prod:
    environment: production
    steps:
      - env:
          PROD_API_KEY: ${{ secrets.PROD_API_KEY }}
```

---

## Notifications

**Slack:**
```yaml
- if: failure()
  uses: slackapi/slack-github-action@v1
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK_URL }}
    payload: |
      {"text": "❌ Build failed: ${{ github.repository }}"}
```

---

## Checklist

- [ ] Automated tests på PRs
- [ ] Linting enforced
- [ ] Code coverage tracked (>80%)
- [ ] Security scans (weekly)
- [ ] Branch protection enabled
- [ ] Deployment automated til staging
- [ ] Manual approval for production
- [ ] Environment secrets configured
- [ ] Notifications setup

---

**Sidst opdateret:** 2025-10-21
