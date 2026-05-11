# Architecture Patterns (Shiny/Golem)

Golem-specifikke arkitektur-mønstre. Universelle design-principles
(Single Responsibility, DI, Immutable Flow): se
`DEVELOPMENT_PHILOSOPHY.md`.

---

## File Organization (Golem)

**Flat structure i `/R/`:**
- `mod_*.R` - Shiny modules
- `fct_*.R` - Business logic
- `utils_server_*.R` - Server utilities
- `utils_ui_*.R` - UI utilities
- `config_*.R` - Configuration
- `app_*.R` - Core app
- `state_management.R` - Centralized state

**Årsag:** Flad struktur gør filnavne meningsfulde, undgår "gemme" vigtig kode dybt.

---

## State Management

**App state schema:**
```r
app_state$events         # Event triggers (0L increments)
app_state$data           # current_data, original_data, file_info, updating_table
app_state$processing     # in_progress, completed, results, error
app_state$ui             # current_selection, display_mode, pending_updates
app_state$session        # auto_save_enabled, file_uploaded, user_started_session
```

**Event-driven pattern:**
```r
handle_data_upload <- function(new_data, emit) {
  safe_operation("Data upload", {
    app_state$data$current_data <- new_data
    emit$data_loaded()
  })
}

observeEvent(app_state$events$data_loaded, ignoreInit = TRUE,
  priority = OBSERVER_PRIORITIES$HIGH, {
  req(app_state$data$current_data)
  emit$processing_started()
})
```

---

## Configuration Management

Typisk fil-fordeling Shiny/Golem-applikation. Navne illustrative —
tilpas projektets domæne.

| Ansvar | Fil (eksempel) | Indhold |
|--------|----------------|---------|
| Branding | `config_branding.R` | Navn, logo, farver, CSS-tokens |
| Domæne-mappings | `config_<domain>_types.R` | DA→EN lookups, fx chart-types |
| Observer-priorities | `config_observer_priorities.R` | Race prevention |
| Domæne-config | `config_<domain>_config.R` | Validation, default-værdier |
| UI | `config_ui.R` | Widths, heights, fonts |
| System | `config_system_config.R` | Timeouts, debounce |
| Environment | `inst/golem-config.yml` | Dev/prod/test |

**Access pattern:**
```r
# ✅ Funktioner som getters (validering + caching)
get_branding <- function() { ... }
get_chart_type <- function(type_name) { ... }

# ❌ Direkte konstanter (kan ikke cache/validere)
BRANDING_CONFIG$colors$primary
```

---

## Performance Architecture

**Startup:**
- Production: `library(MyApp)` (~50-100ms)
- Debug: `source('global.R')` (~400ms+)

**Lazy loading:**
```r
LAZY_LOADING_CONFIG <- list(
  heavy_modules = list(
    file_operations = "R/fct_file_operations.R",
    advanced_debug = "R/utils_advanced_debug.R"
  )
)
ensure_module_loaded("file_operations")
```

**Caching:**
```r
CACHE_CONFIG <- list(
  hospital_branding = list(ttl = 3600),  # 1 hour
  config_settings = list(ttl = 3600)
)
```

---

## NAMESPACE Handling

**Aldrig rediger `NAMESPACE` manuelt** — fil autogenereret.
Kør `devtools::document()` når roxygen `@export`/`@importFrom` ændres.
Review diff før commit — uventede NAMESPACE-ændringer = signal om
utilsigtet roxygen-redigering, skal stoppes.

---

## Testing Architecture

**Test levels:**
```r
# Unit tests (pure functions)
test_that("calculate_ucl handles edge cases", {
  expect_equal(calculate_ucl(0.5, 10), expected_value)
})

# Integration tests (functions + state)
test_that("data upload triggers auto-detection", {
  app_state$data$current_data <- test_data
  app_state$events$data_loaded <- app_state$events$data_loaded + 1
  expect_equal(app_state$columns$auto_detect$completed, TRUE)
})

# UI tests (full Shiny)
test_that("Chart renders after upload", {
  app <- shinytest2::AppDriver$new()
  app$upload("file_input", "fixtures/sample.csv")
  expect_true(app$is_visible("#chart"))
})
```

---

## Extension Points

**Adding new features:**
1. Start med tests (TDD)
2. Implementer inkrementelt
3. Følg eksisterende patterns (event-bus, app_state, logging, guards)
4. Dokumentér (ADR hvis større)
5. Monitorér performance

---

**Sidst opdateret:** 2025-10-21