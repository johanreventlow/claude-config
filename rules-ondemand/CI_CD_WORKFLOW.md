# CI/CD Workflow

Org-specifikke CI/CD-konventioner R-projekter.

---

## Code Quality Gates (CI)

**lintr som CI-gate:**
```yaml
- run: |
    lints <- lintr::lint_package()
    if (length(lints) > 0) quit(status = 1)
  shell: Rscript {0}
```

**styler som CI-gate:**
```yaml
- run: |
    restyled <- styler::style_pkg(dry = "on")
    if (length(restyled$changed) > 0) quit(status = 1)
  shell: Rscript {0}
```

Begge gates = obligatoriske. Kode fails CI hvis lints > 0 eller style-diff.

---

## Branch Protection (`main`)

**GitHub → Settings → Branches → Add rule `main`:**
- ✅ Require pull request (1 approval)
- ✅ Require status checks: R-CMD-check, Lint, Style
- ✅ Require branches up to date before merging
- ✅ Include administrators

---

## Notifikationer

**Slack ved build-fejl:**
```yaml
- if: failure()
  uses: slackapi/slack-github-action@v1
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK_URL }}
    payload: |
      {"text": "❌ Build failed: ${{ github.repository }} — ${{ github.ref }}"}
```

---

## Checklist

- [ ] lintr enforced (0 lints krav)
- [ ] styler enforced (clean diff krav)
- [ ] Code coverage tracked (≥80 %)
- [ ] Security scans (ugentligt)
- [ ] Branch protection aktiveret på `main`
- [ ] Environment-secrets konfigureret per env
- [ ] Slack-notifikationer ved fejl

---

**Sidst opdateret:** 2026-06-12
