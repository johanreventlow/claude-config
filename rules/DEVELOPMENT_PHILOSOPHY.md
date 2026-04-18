# Development Philosophy & Communication

Centrale principper for udvikling og kommunikation.

---

## Development Principles

- **Quality > speed**: Robusthed først, TDD obligatorisk
- **Observability**: Struktureret logging ikke valgfrit
- **Test coverage**: ≥90% samlet, 100% kritiske paths
- **Breaking changes**: Major version bump + deprecation warnings først
- **User-focused**: Design for danske klinikere/brugere
- **Continuous improvement**: ADR'er for arkitektoniske beslutninger

---

## Communication Guidelines

**Kerneprincipper:**
- **Intellektuel ærlighed**: Vær direkte om begrænsninger og trade-offs
- **Kritisk engagement**: Stil spørgsmål ved vigtige overvejelser
- **Balanceret evaluering**: Undgå tomme komplimenter
- **Retningsklarhed**: Fokusér på projektets langsigtede kvalitet

**Kommunikationsstil:**
- Præcise action items: "Gør X i fil Y, linje Z"
- Marker manuelle skridt: **[MANUELT TRIN]**
- Faktuel rapportering
- Struktureret: Checklists, numbered steps, høj-level først

**Succeskriterium:** Fremmer dette produktiv tænkning eller standser det?

---

## Test-Driven Development (TDD)

✅ **OBLIGATORISK:**
1. Skriv tests først
2. Kør tests kontinuerligt - skal altid bestå
3. Refactor med test-sikkerhed
4. Ingen breaking changes uden eksplicit godkendelse

**Test-kommandoer:**
```r
# R packages
devtools::test()
devtools::check()

# Shiny apps
testthat::test_dir('tests/testthat')

# Quarto
quarto::quarto_render()
```

---

## Defensive Programming

- **Input validation** ved entry points
- **Error handling** via `tryCatch()` og `safe_operation()`
- **Scope guards** med `exists()` checks
- **Graceful degradation** med fallback-mønstre
- **State consistency** gennem centraliseret state

**safe_operation() pattern:**
```r
safe_operation <- function(operation_name, code, fallback = NULL, session = NULL) {
  tryCatch({
    code
  }, error = function(e) {
    log_error("[ERROR_HANDLER]", paste(operation_name, "fejlede"),
      details = list(error_message = e$message), session = session)
    return(fallback)
  })
}
```

---

## Observability & Logging

**Struktureret logging:**
```r
log_debug(component = "[APP_SERVER]", message = "Initialiserer",
  details = list(session_id = session$token))
```

- Brug centralt logger-API: `log_debug()`, `log_info()`, `log_warn()`, `log_error()`
- Angiv `component` felt
- Tilføj data i `details` som named list
- ALDRIG rå `cat()`-kald

---

## ADR Template

```markdown
# ADR-NNN: [Titel]

Status: Accepted | Proposed | Deprecated | Superseded

Kontekst: [Problem]

Beslutning: [Løsning + hvorfor]

Konsekvenser: [Fordele/ulemper]

Dato: YYYY-MM-DD
```

**Placering:** `docs/adr/ADR-NNN-description.md`

---

## Pre-Commit Checklist (Master)

- [ ] Tests kørt og bestået
- [ ] Manual functionality test
- [ ] Logging valideret (strukturerede logs)
- [ ] Error handling verificeret
- [ ] Performance vurderet
- [ ] Dokumentation opdateret
- [ ] Code formateret (`styler::style_file()`)
- [ ] Linting uden fejl (`lintr::lint()`)
- [ ] NAMESPACE opdateret hvis relevant (`devtools::document()`)
- [ ] Ingen debug statements (`browser()`, rogue `print()`)
- [ ] Ingen secrets committed

---

## Code Review Criteria

- **Correctness**: Logik, edge cases, type safety, reaktive afhængigheder
- **Readability**: Selvforklarende struktur, korte funktioner
- **Maintainability**: Ingen sideeffekter, solid testdækning, DRY principle
- **Performance**: Effektive operationer, caching, vektorisering
- **Consistency**: Genbrug af utils, følg eksisterende patterns

---

## Quality Standards

| Aspekt | Standard |
|--------|----------|
| Test coverage | ≥90% samlet, 100% kritiske paths |
| Performance | Startup <100ms (Shiny), render <1s |
| Documentation | Roxygen2 for alle exports, ADR'er for arkitektur |
| Logging | Struktureret, komponenter tagget, context-aware |
| Error handling | `tryCatch()` eller `safe_operation()` for kritiske paths |

---

## Breaking Changes Policy

Breaking change-regler er nu konsolideret i `VERSIONING_POLICY.md` (§A semver,
§C NEWS-template, §F pre-1.0/1.0-overgang). Se denne fil for:
- Hvornår MAJOR vs MINOR (afhænger af pre-1.0 vs post-1.0)
- Hvordan breaking changes dokumenteres i NEWS.md
- Cross-repo bump-protokol når sibling-pakke bryder API
- Pre-release checklist (inkl. eksplicitte `BREAKING CHANGE:`-commit-noter)

---

**Sidst opdateret:** 2025-10-21
