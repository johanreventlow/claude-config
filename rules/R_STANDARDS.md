# R Development Standards

Generelle standarder for R-udvikling på tværs af alle projekter.

---

## Code Style

**Naming:**
- Funktioner/variabler: `snake_case`
- UI elementer: `camelCase` (Shiny)
- Konstanter: `UPPER_CASE`

**Sprog:**
- Kommentarer: Dansk
- Kode: Engelsk (funktionsnavne, variabelnavne)
- Dokumentation: Dansk når målgruppen er dansk

**Character Encoding:**
- **Altid** `encoding = 'UTF-8'` ved sourcing
- Database: `encoding = "UTF8"`
- Danske karakterer (æ, ø, å) skal håndteres korrekt

---

## Tidyverse

**Foretrukne pakker:**
- `dplyr` > base subsetting
- `tidyr` for reshaping
- `purrr` > `apply` familie
- `readr` for import
- `stringr` for strings

**Pipe:**
- Brug `|>` eller `%>%` konsistent
- Max 5-7 steps per chain
- Break længere chains med mellemresultater

---

## Error Handling

**Defensive programming:**
```r
# tryCatch for kritiske operationer
result <- tryCatch({
  risikabel_operation()
}, error = function(e) {
  log_error("Operation fejlede", details = list(error = e$message))
  return(fallback_value)
})

# Input validation
validate_input <- function(x) {
  stopifnot(is.numeric(x), length(x) > 0, !anyNA(x))
}
```

**Safe operation pattern:**
Se `DEVELOPMENT_PHILOSOPHY.md` for `safe_operation()` implementation.

---

## Testing

**TDD approach:**
1. Skriv tests først
2. Implementer minimal kode til at bestå test
3. Refactor med test-sikkerhed
4. Kør tests kontinuerligt

**Framework:**
- `testthat` som standard
- Organiser i `tests/testthat/`
- Navngivning: `test-{feature}.R`

**Commands:**
```r
testthat::test_dir('tests/testthat')
testthat::test_file('tests/testthat/test-feature.R')
```

---

## Dependencies

**Package management:**
- `renv` for reproducibility
- Lock med `renv::snapshot()`
- Dokumenter i `DESCRIPTION` eller README

**Namespace:**
- Prefer `pkg::fun()` (eksplicit namespace)
- Undgå `library()` i funktioner (kun scripts)

---

## Performance

**Vectorization:**
- Brug vektoriserede operationer > loops
- `purrr::map()` for functional programming
- Undgå `for`-loops for simple transformationer

**Memory:**
```r
# ✅ Effektiv (pre-allocate)
result <- vector("list", length(input))
for (i in seq_along(input)) {
  result[[i]] <- process(input[[i]])
}

# ❌ Ineffektiv (growing objects)
result <- list()
for (item in input) {
  result <- c(result, list(process(item)))
}
```

---

## Documentation

**Roxygen2:**
- Brug `#'` for roxygen kommentarer
- Dokumenter `@param`, `@return`, `@examples`
- Kør `devtools::document()` efter ændringer

**Inline comments:**
Forklarer "hvorfor", ikke "hvad":
```r
# ✅ God kommentar
# Konverter til date for at håndtere forskellige input formater
dato <- as.Date(dato_string)

# ❌ Dårlig kommentar
# Konverter til date
dato <- as.Date(dato_string)
```

---

## Pre-Commit Checklist

Se `DEVELOPMENT_PHILOSOPHY.md` → "Pre-Commit Checklist (Master)" for den
komplette liste. R-specifik tilføjelse:
- [ ] Character encoding verificeret (UTF-8)

---

## Code Review Fokus

- **Correctness**: Logik, edge cases, type safety
- **Readability**: Selvforklarende kode, passende kommentarer
- **Maintainability**: DRY principle, single responsibility
- **Performance**: Vektorisering, memory efficiency

---

**Sidst opdateret:** 2025-10-21
