# R Development Standards

Org-specifikke R-konventioner. Tier 2-profil — @-importeres af
R-projekters CLAUDE.md (pakker, Shiny, scripts).

---

## Naming & sprog

- Funktioner/variabler: `snake_case` · UI-elementer (Shiny): `camelCase`
  · Konstanter: `UPPER_CASE`
- Kommentarer + docs: **dansk** (forklar "hvorfor", ej "hvad").
  Kode (funktions-/variabelnavne): engelsk.
- **Altid UTF-8**: `encoding = 'UTF-8'` ved sourcing, `"UTF8"` i DB.
  Danske karakterer (æ, ø, å) skal håndteres korrekt.

## Stil

- Tidyverse-præference: `dplyr`/`tidyr`/`purrr`/`readr`/`stringr` over
  base-ækvivalenter. Pipe konsistent (`|>` el. `%>%`), max 5-7 steps —
  bryd længere chains med mellemresultater.
- Eksplicit namespace `pkg::fun()` i pakke-kode; `library()` kun i scripts.
- Formatering: `styler::style_file()` · linting: `lintr::lint()`.

## Testing

- `testthat`, organiseret i `tests/testthat/test-{feature}.R`.
- TDD for adfærdsændrende kode (jf. DEVELOPMENT_PHILOSOPHY.md).
- Kommandoer: `devtools::test()` (pakker), `testthat::test_dir('tests/testthat')`.

## Dependencies

- `renv` for reproducibility; `renv::snapshot()` efter ændringer.
- Roxygen2 på alle exports; `devtools::document()` efter signatur-ændringer.

## Error handling

`safe_operation()`-pattern + struktureret logging — se
`DEVELOPMENT_PHILOSOPHY.md`. ALDRIG rå `cat()` i production-paths.

---

**Sidst opdateret:** 2026-06-12
