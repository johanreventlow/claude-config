# Versioning Policy

Standard for versionering, NEWS-format, git-tags og cross-repo bump-protokol
i BFH-økosystemet (biSPCharts, BFHcharts, BFHllm, BFHtheme).

---

## A. Semver 2.0 (strict)

| Bump | Trigger |
|------|---------|
| **MAJOR** (`X.0.0`) | Breaking change i public API: eksporteret funktion fjernet/omdøbt, ændret signatur, ændret returtype, ændret default adfærd der kan bryde kald |
| **MINOR** (`0.X.0`) | Ny eksporteret funktion, ny ikke-breaking parameter, ikke-breaking adfærdsudvidelse |
| **PATCH** (`0.0.X`) | Bugfix, dokumentation, intern refactor uden public API-effekt |

**Pre-1.0 (alle nuværende pakker):**
- MINOR-bumps **må** indeholde breaking changes — markeres tydeligt med `## Breaking changes` i NEWS
- MAJOR (`1.0.0`) reserveres til "produktion-klar" — se §F

**Bump-størrelse fra commit-prefixes** (jf. Conventional Commits i `GIT_WORKFLOW.md`):

| Prefix | Default bump |
|--------|--------------|
| `feat:` | MINOR |
| `fix:` | PATCH |
| `refactor:` / `perf:` / `chore:` / `docs:` / `test:` / `style:` | PATCH (eller ingen bump hvis intern) |
| `BREAKING CHANGE:` i body | MAJOR (post-1.0) eller MINOR (pre-1.0, markér tydeligt) |

---

## B. Git tag-format

**Standard:** `vMAJOR.MINOR.PATCH` — fx `v0.7.2`

**Regler:**
- Tag oprettes **efter** merge til `main`/`master`, peger på merge-commit
- Annoteret tag (ikke lightweight): `git tag -a v0.7.2 -m "Release v0.7.2"`
- Push tag eksplicit: `git push origin v0.7.2`
- Ingen `-dev`-suffix til releases (kun til ad hoc snapshots, hvis nødvendigt)

**Ekstraordinære tags accepteres:**
- `v0.7.2-rc1` (release candidate, kort levetid)
- `v0.7.2-hotfix.1` (kun hvis hovedlinjen er blokeret)

---

## C. NEWS.md template

**Sprog:** Dansk (matcher commits og UI-tekst).

**Format** (top = nyeste version):

```markdown
# PakkeNavn X.Y.Z

## Breaking changes
* Kort beskrivelse af brydningen + hvorfor + migration-hint hvis non-trivielt
  (#issue-nummer hvis relevant)

## Nye features
* Hvad ændrede sig + hvorfor det betyder noget for brugeren

## Bug fixes
* Symptom → fix (#issue-nummer)

## Interne ændringer
* Refactors, test-tilføjelser, ikke-bruger-vendt arbejde (valgfri sektion)

# PakkeNavn X.Y.Z-1
...
```

**Regler:**
- Kun de sektioner der har indhold inkluderes (drop tomme `## Bug fixes` osv.)
- Hver bullet beskriver **hvad + hvorfor** — ikke "hvordan" (kode-detaljer)
- Reference issues/PRs som `(#123)` ved slutning af bullet
- `(development)`-entries tillades øverst mellem releases — fjernes/omdøbes ved bump

---

## D. Pre-release checklist

Køres før hvert tag/push. Alle punkter SKAL bekræftes — ingen genveje.

```
[ ] 1. Tests bestået (`devtools::test()` eller `make test`)
[ ] 2. `devtools::check()` ren — ingen WARNINGs/ERRORs (NOTEs OK hvis dokumenteret)
[ ] 3. DESCRIPTION `Version:` bumpet efter §A
[ ] 4. NEWS.md har entry for ny version (ikke "(development)")
[ ] 5. Hvis ny eksport: `devtools::document()` kørt → NAMESPACE + .Rd opdateret
[ ] 6. Cross-repo: hvis pakken er sibling-dep, downstream `DESCRIPTION`
       `Imports:` lower-bound bumpet (i separat PR — se §E)
[ ] 7. Merge til main/master via PR (ikke direkte commit)
[ ] 8. Annoteret tag oprettes: `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
[ ] 9. Tag pushed: `git push origin vX.Y.Z`
```

---

## E. Cross-repo bump-protokol

**Når sibling-pakke bumper, skal downstream opdatere lower-bound:**

1. **Sibling-pakke** (fx BFHcharts) bumper og tagger `vX.Y.Z`
2. **Downstream** (fx biSPCharts) opretter separat PR:
   - Fil: `DESCRIPTION` → `BFHcharts (>= NEW_VERSION)`
   - Commit: `chore(deps): bump BFHcharts to X.Y.Z`
   - PR-beskrivelse refererer sibling NEWS-entry
3. **Hvis MAJOR bump i sibling:**
   - Tilføj migration-note i downstream NEWS:
     `* **Breaking change i BFHcharts X.0.0:** denne version bruger nyt API for Y. Se BFHcharts NEWS for detaljer.`

**Lower-bound `>=` betyder:**
- Downstream tester mod NEW_VERSION+ (ikke ældre)
- Ingen øvre grænse → øvre versioner antages bagudkompatible
- Ved breakage opdaget i sibling MAJOR-bump: bump downstream lower-bound for at "skip" inkompatibel version + tilpas kalder-kode

**Ingen `Remotes:` SHA-pinning** — strider mod manuel-flow og minder om renv-friktion.

---

## F. Pre-1.0 → 1.0-kriterier

En pakke kan bumpes til `1.0.0` når **alle** følgende holder:

- [ ] Public API stabil i ≥ 3 måneder uden breaking changes
- [ ] ≥ 90 % test-coverage på eksporterede funktioner
- [ ] Alle exports har komplet roxygen-dokumentation + `@examples`
- [ ] Pakken bruges aktivt i produktion (ikke kun udvikling)
- [ ] Breaking change policy kan håndhæves uden at forsinke release-cadence

**Konsekvens af 1.0:**
- Breaking changes kræver MAJOR bump (`2.0.0`)
- Deprecation warnings i mindst én MINOR-version før breaking removal

---

## G. Repo-specifikke noter

| Pakke | Aktuel version | Tag-historik | Bemærkning |
|-------|----------------|--------------|------------|
| `biSPCharts` | 0.2.0 | Blandet (`-dev`-suffix legacy) | Brug `vX.Y.Z` fremadrettet; `-dev`-tags bevares som historik |
| `BFHcharts` | 0.7.2 | `vX.Y.Z` konsistent | Følger politik |
| `BFHllm` | 0.1.1 | `vX.Y.Z` | Følger politik |
| `BFHtheme` | 0.4.0 | Ingen tags før retroaktiv `v0.4.0` | Tag fremadrettet ved hver release |

---

## Hvad denne politik IKKE dækker

- Automation (fledge/autonewsmd/semantic-release) — bevidst manuelt
- Dato-baseret versionering — alle pakker bruger semver
- Bounded constraints `(>= X, < Y)` — kun lower-bound
- Migration af eksisterende NEWS-historik — kun nye entries følger template
- Scheduled releases — ad-hoc forbliver normen

---

**Sidst opdateret:** 2026-04-17
**Del af:** ~/.claude/ global configuration system
