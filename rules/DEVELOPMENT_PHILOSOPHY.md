# Development Philosophy & Communication

Centrale principper udvikling + kommunikation.

---

## Development Principles

- **Quality > speed**: Robusthed først. TDD default
  adfærdsændrende kode; ej påkrævet docs, kommentarer,
  formatering, CI-config el. rene refactors uden adfærdsændring.
- **Observability**: Struktureret logging ej valgfrit kode der
  rammer production-paths.
- **Test coverage (risk-based)**: Testniveau matcher risiko.
  Kritiske paths (data-load, state-sync, beregninger der driver UI)
  skal have test-dækning. Ambitionsmål ≥90% samlet, ej blokerende
  små bugfixes, docs el. config. Rapportér eksplicit hvilke
  tests kørt, sprunget, hvorfor.
- **Breaking changes**: Major version bump + deprecation warnings først
  (post-1.0). Pre-1.0 MINOR må indeholde breaking — markér tydeligt.
- **User-focused**: Design danske klinikere/brugere
- **Continuous improvement**: ADR'er arkitektoniske beslutninger

---

## Communication Guidelines

**Kerneprincipper:**
- **Intellektuel ærlighed**: Direkte om begrænsninger + trade-offs
- **Kritisk engagement**: Stil spørgsmål ved vigtige overvejelser
- **Balanceret evaluering**: Undgå tomme komplimenter
- **Retningsklarhed**: Fokusér projektets langsigtede kvalitet

**Kommunikationsstil:**
- Præcise action items: "Gør X i fil Y, linje Z"
- Marker manuelle skridt: **[MANUELT TRIN]**
- Faktuel rapportering
- Struktureret: Checklists, numbered steps, høj-level først

**Succeskriterium:** Fremmer dette produktiv tænkning el. standser det?

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
- **Error handling** via `tryCatch()` + `safe_operation()`
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

Struktureret logging via centralt logger-API (`log_debug`, `log_info`,
`log_warn`, `log_error`) med `component`-tag + named `details` list.
ALDRIG rå `cat()`. Detaljer + production-grade setup: se
`OBSERVABILITY_STANDARDS.md` (rules-ondemand) — @-import når relevant.

---

## Design Principles

**Single Responsibility:**
```r
# ✅ Hver funktion har ét ansvar
load_data <- function(file_path) { readr::read_csv(file_path) }
validate_data <- function(data) { stopifnot(nrow(data) > 0) }
process_data <- function(data) { data |> filter(value > 0) }
```

**Dependency Injection:** Dependencies som arguments, ej globals.

**Immutable Data Flow:** Returnér nye objekter, mutér ej originale.

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

- [ ] Tests kørt + bestået
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
- **Consistency**: Genbrug utils, følg eksisterende patterns

---

## Quality Standards

| Aspekt | Standard |
|--------|----------|
| Test coverage | Risk-based: kritiske paths dækkes; ambitionsmål ≥90% samlet; dokumentér skipped tests + hvorfor |
| Performance | Startup <100ms (Shiny), render <1s |
| Documentation | Roxygen2 alle exports, ADR'er arkitektur |
| Logging | Struktureret, komponenter tagget, context-aware |
| Error handling | `tryCatch()` el. `safe_operation()` kritiske paths |

---

## Breaking Changes Policy

Breaking change-regler konsolideret i `VERSIONING_POLICY.md` (§A semver,
§C NEWS-template, §F pre-1.0/1.0-overgang). Se fil for:
- Hvornår MAJOR vs MINOR (afhænger pre-1.0 vs post-1.0)
- Hvordan breaking changes dokumenteres i NEWS.md
- Cross-repo bump-protokol når sibling-pakke bryder API
- Pre-release checklist (inkl. eksplicitte `BREAKING CHANGE:`-commit-noter)

---

**Sidst opdateret:** 2025-10-21