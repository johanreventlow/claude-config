# R Development Standards

R-udvikling standarder på tværs projekter.

---

## Code Style

**Naming:**
- Funktioner/variabler: `snake_case`
- UI elementer: `camelCase` (Shiny)
- Konstanter: `UPPER_CASE`

**Sprog:**
- Kommentarer: dansk
- Kode: engelsk (funktions/variabelnavne)
- Dokumentation: dansk når målgruppe dansk

**Character Encoding:**
- **Altid** `encoding = 'UTF-8'` ved sourcing
- Database: `encoding = "UTF8"`
- Danske karakterer (æ, ø, å) håndteres korrekt

---

## Tidyverse

**Foretrukne pakker:**
- `dplyr` > base subsetting
- `tidyr` reshaping
- `purrr` > `apply` familie
- `readr` import
- `stringr` strings

**Pipe:**
- `|>` eller `%>%` konsistent
- Max 5-7 steps per chain
- Bryd længere chains med mellemresultater

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
2. Minimal kode bestå test
3. Refactor med test-sikkerhed
4. Kør tests kontinuerligt

**Framework:**
- `testthat` standard
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
- `renv` reproducibility
- Lock: `renv::snapshot()`
- Dokumentér i `DESCRIPTION` eller README

**Namespace:**
- Foretræk `pkg::fun()` (eksplicit namespace)
- Undgå `library()` i funktioner (kun scripts)

---

## Performance

**Vectorization:**
- Vektoriserede operationer > loops
- `purrr::map()` functional programming
- Undgå `for`-loops til simple transformationer

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
- `#'` roxygen kommentarer
- Dokumentér `@param`, `@return`, `@examples`
- Kør `devtools::document()` efter ændringer

**Inline comments:**
Forklar "hvorfor", ikke "hvad":
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

Se `DEVELOPMENT_PHILOSOPHY.md` → "Pre-Commit Checklist (Master)" for komplet liste. R-specifik tilføjelse:
- [ ] Character encoding verificeret (UTF-8)

---

**Sidst opdateret:** 2025-10-21