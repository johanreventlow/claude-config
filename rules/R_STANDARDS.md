# R Development Standards

Generelle standarder for R-udvikling på tværs af alle projekter.

## Code Style

### Naming Conventions
- **Funktioner og variabler**: `snake_case` for logik
- **UI elementer**: `camelCase` for UI-komponenter (Shiny)
- **Konstanter**: `UPPER_CASE` for konfiguration

### Sprog
- **Kommentarer**: Dansk
- **Kode**: Engelsk (funktionsnavne, variabelnavne)
- **Dokumentation**: Dansk når målgruppen er dansk

### Character Encoding
- **Altid** brug `encoding = 'UTF-8'` ved sourcing af filer
- Database connections: `encoding = "UTF8"`
- Danske karakterer (æ, ø, å) skal håndteres korrekt

## Tidyverse Conventions

### Foretrukne Pakker
- `dplyr` over base R subsetting
- `tidyr` for data reshaping
- `purrr` over `apply` familie
- `readr` for import
- `stringr` for string operations

### Pipe Usage
- Brug `|>` (native pipe) eller `%>%` konsistent gennem projektet
- Hold pipe chains overskuelige (max 5-7 steps)
- Break længere chains i logiske dele med mellemresultater

### Best Practices
```r
# ✅ God praksis
data |>
  filter(aktiv == TRUE) |>
  select(id, navn, dato) |>
  mutate(dato = as.Date(dato))

# ❌ Undgå
data[data$aktiv == TRUE, c("id", "navn", "dato")]
```

## Error Handling

### Defensive Programming
```r
# Brug tryCatch for kritiske operationer
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

### Safe Operation Pattern
```r
safe_operation <- function(operation_name, code, fallback = NULL, session = NULL) {
  tryCatch({
    code
  }, error = function(e) {
    # Log error
    message(sprintf("[ERROR] %s: %s", operation_name, e$message))
    return(fallback)
  })
}
```

## Testing

### Test-Driven Development (TDD)
1. Skriv tests først
2. Implementer minimal kode til at bestå test
3. Refactor med test-sikkerhed
4. Kør tests kontinuerligt

### Testing Framework
- Brug `testthat` som standard
- Organiser tests i `tests/testthat/`
- Navngivning: `test-{feature}.R`

### Test Commands
```r
# Alle tests
testthat::test_dir('tests/testthat')

# Specifik test-fil
testthat::test_file('tests/testthat/test-feature.R')
```

## Dependencies

### Package Management
- Brug `renv` for reproducerbare environments
- Lock dependencies med `renv::snapshot()`
- Dokumenter package requirements i `DESCRIPTION` eller README

### Namespace Calls
- Prefer eksplicitte namespace calls: `pkg::fun()`
- Undgå `library()` i funktioner (kun i scripts)

## Performance

### Vectorization
- Brug vektoriserede operationer fremfor loops
- `purrr::map()` for funktionel programmering
- Undgå `for`-loops for simple transformationer

### Memory Efficiency
```r
# ✅ Effektiv
result <- vector("list", length(input))
for (i in seq_along(input)) {
  result[[i]] <- process(input[[i]])
}

# ❌ Ineffektiv (voksende objekter)
result <- list()
for (item in input) {
  result <- c(result, list(process(item)))
}
```

## Documentation

### Roxygen2
- Brug `#' ` for roxygen kommentarer
- Dokumenter `@param`, `@return`, `@examples`
- Kør `devtools::document()` efter ændringer

### Inline Comments
```r
# Danske kommentarer forklarer "hvorfor", ikke "hvad"
# ✅ God kommentar
# Konverter til date for at håndtere forskellige input formater
dato <- as.Date(dato_string)

# ❌ Dårlig kommentar
# Konverter til date
dato <- as.Date(dato_string)
```

## Quality Assurance

### Pre-Commit Checklist
- [ ] Tests kørt og bestået
- [ ] Kode formateret (`styler::style_file()`)
- [ ] Linting uden fejl (`lintr::lint()`)
- [ ] Dokumentation opdateret
- [ ] Character encoding verificeret

### Code Review
Fokuser på:
- **Correctness**: Logik, edge cases, type safety
- **Readability**: Selvforklarende kode, passende kommentarer
- **Maintainability**: DRY principle, single responsibility
- **Performance**: Vektorisering, memory efficiency
