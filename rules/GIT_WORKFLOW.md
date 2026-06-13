# Git Workflow Standards

---

## ⚠️ OBLIGATORISKE REGLER (KRITISK)

❌ **ALDRIG:**
1. Merge til main/master uden eksplicit godkendelse
2. Push til remote uden anmodning
3. Claude attribution-footers:
   - ❌ "🤖 Generated with [Claude Code]"
   - ❌ "Co-Authored-By: Claude <noreply@anthropic.com>"
4. Bypass pre-commit/pre-push hooks uden eksplicit godkendelse
   (`--no-verify`, `--no-gpg-sign`, `SKIP_*=1`-env-flags).
   Fejlende hook = fix root cause, ej bypass.
5. Force push til shared branches, committe secrets, committe
   generated files (`.Rhistory`, `.RData`, `*.rds`, `_site/`)

✅ **OK uden aftale:** flere commits i serie på feature branch,
lokale branches (ingen push/merge), `git status`/`diff`/`log`.

---

## Branches & commits

**Branch-prefixes:** `feat/` · `fix/` · `refactor/` · `docs/` · `test/` · `chore/`

**Commit-format** (Conventional Commits, dansk beskrivelse):

```
type(scope): kort beskrivelse

Hvorfor, ikke hvordan. Reference: #123
```

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`, `style`.
Version-bump-mapping + NEWS-format: se `VERSIONING_POLICY.md`.

Pre-commit checklist: se `DEVELOPMENT_PHILOSOPHY.md` (master-kilde).

---

## Pull Requests

**ALTID `--draft`** — bruger markerer selv "Ready for review". Gælder
alle kontekster (direkte oprettelse, skills, automation).

```bash
gh pr create --draft --title "feat(scope): beskrivelse" --body "$(cat <<'EOF'
## Summary
<1-3 bullet points>

## Test plan
[Checklist med TODOs / kendte gaps]
EOF
)"
```

Windows uden `gh` CLI: se `WINDOWS_ENVIRONMENT.md` (on-demand).

---

**Sidst opdateret:** 2026-06-12
