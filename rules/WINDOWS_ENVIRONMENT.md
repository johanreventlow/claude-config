# Windows Environment Configuration

Platform-specifikke indstillinger for Windows-maskiner (Region Hovedstaden).

---

## R Installation

R er installeret i `C:\Program Files\R\` men er **IKKE i PATH**.

**Tilgængelige versioner:**
- `C:\Program Files\R\R-4.5.2\` (nyeste)
- `C:\Program Files\R\R-4.5.0\`
- `C:\Program Files\R\R-4.4.2\`
- `C:\Program Files\R\R-4.4.1\`

**Brug altid fuld sti til R og Rscript:**
```bash
# Korrekt (bash i VSCode terminal / Git Bash)
'/c/Program Files/R/R-4.5.2/bin/Rscript.exe' -e "devtools::test()"
'/c/Program Files/R/R-4.5.2/bin/R.exe' CMD check .

# Alternativ Windows-sti notation (hvis bash kræver det)
"/c/Program Files/R/R-4.5.2/bin/Rscript.exe"
```

**ALDRIG** kald bare `R` eller `Rscript` — de er ikke i PATH og vil fejle.

---

## GitHub uden gh CLI

`gh` CLI er **IKKE installeret** og kan ikke installeres (managed Windows-miljø).

**Git authentication:**
- Git er installeret: `C:\Program Files\Git\cmd\git.exe`
- Credential helper: `manager` (Git Credential Manager)
- GitHub auth fungerer via HTTPS + credential manager
- Bruger: `johanreventlow` / `johanreventlow@users.noreply.github.com`

**Alternativer til gh CLI:**
```bash
# I stedet for: gh pr create
# Brug: git push og opret PR manuelt i browser, eller brug git API via curl

# I stedet for: gh pr list
git ls-remote --heads origin

# I stedet for: gh issue list
# Brug GitHub web interface

# I stedet for: gh repo view
git remote -v

# Push til remote (efter eksplicit godkendelse)
git push -u origin <branch-name>
```

**VIGTIGT:** Foreslå ALDRIG `gh` kommandoer på Windows. Brug `git` kommandoer eller henvis til GitHub web interface i stedet.

---

## Shell Environment

Claude Code i VSCode bruger **Git Bash** (mingw64) som shell:
- Unix-stil stier: `/c/Users/...` (ikke `C:\Users\...`)
- Unix-kommandoer: `ls`, `cat`, `grep` etc. virker
- Windows-programmer kræver `.exe` suffix og fuld sti hvis ikke i PATH

**PATH indeholder:**
- `/mingw64/bin`, `/usr/bin` (Git Bash builtins)
- `C:\WINDOWS\system32`, `C:\WINDOWS`
- `C:\Program Files\Git\cmd`
- `C:\Program Files\Microsoft VS Code\bin`
- `C:\Program Files\nodejs`

**PATH indeholder IKKE:**
- R (`C:\Program Files\R\...`)
- Rtools
- gh CLI

---

## Praktiske Konsekvenser

### Kør R-kommandoer
```bash
# Devtools
'/c/Program Files/R/R-4.5.2/bin/Rscript.exe' -e "devtools::test()"
'/c/Program Files/R/R-4.5.2/bin/Rscript.exe' -e "devtools::check()"
'/c/Program Files/R/R-4.5.2/bin/Rscript.exe' -e "devtools::document()"
'/c/Program Files/R/R-4.5.2/bin/Rscript.exe' -e "devtools::load_all()"

# Styler/lintr
'/c/Program Files/R/R-4.5.2/bin/Rscript.exe' -e "styler::style_pkg()"
'/c/Program Files/R/R-4.5.2/bin/Rscript.exe' -e "lintr::lint_package()"

# Enkelt test-fil
'/c/Program Files/R/R-4.5.2/bin/Rscript.exe' -e "testthat::test_file('tests/testthat/test-db.R')"
```

### GitHub Workflow (uden gh)
```bash
# Opret og push feature branch
git checkout -b feat/ny-feature
git add <filer>
git commit -m "feat(scope): beskrivelse"
# STOP - vent på bruger-instruktion om push

# Når bruger siger "push":
git push -u origin feat/ny-feature
# Henvis til: https://github.com/johanreventlow/BFHddl/compare/feat/ny-feature
# for at oprette PR i browser
```

---

**Sidst opdateret:** 2026-03-17
**Del af:** ~/.claude/ global configuration system
