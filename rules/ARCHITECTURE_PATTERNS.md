# Architecture Patterns & Design Principles

Arkitektoniske mønstre og design principper for R-projekter.

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

**Årsag:** Flad struktur gør filnavne meningsfulde, undgår at "gemme" vigtig kode dybt.

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

## Design Principles

**Single Responsibility:**
```r
# ✅ Hver funktion har én ansvar
load_data <- function(file_path) { readr::read_csv(file_path) }
validate_data <- function(data) { stopifnot(nrow(data) > 0) }
process_data <- function(data) { data |> filter(value > 0) }

# Orkestrering
full_pipeline <- function(file_path) {
  data <- load_data(file_path)
  validate_data(data)
  process_data(data)
}
```

**Dependency Injection:**
```r
# ✅ Dependencies som argumenter
create_chart <- function(data, x_col, y_col, emit, theme = theme_bfh()) {
  emit$chart_started()
  # render chart
  emit$chart_completed()
}
```

**Immutable Data Flow:**
```r
# ✅ Return nye objekter
transform_data <- function(data) {
  result <- data |> mutate(new_col = x * 2)
  result  # Return kopi, original intakt
}
```

---

## Configuration Management

| Ansvar | File | Eksempler |
|--------|------|-----------|
| Branding | `config_branding.R` | Hospital navn, logo, farver |
| Chart types | `config_chart_types.R` | SPC mappings |
| Priorities | `config_observer_priorities.R` | Race prevention |
| SPC | `config_spc_config.R` | Validation, colors |
| UI | `config_ui.R` | Widths, heights, fonts |
| System | `config_system_config.R` | Timeouts, debounce |
| Environment | `inst/golem-config.yml` | Dev/prod/test |

**Access pattern:**
```r
# ✅ Funktioner som getters (validering + caching)
get_hospital_branding <- function() { ... }
get_chart_type <- function(type_name) { ... }

# ❌ Direkte konstanter (kan ikke cache/validere)
HOSPITAL_BRANDING$colors$primary
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

## Constraints

❌ **Gør IKKE:**
- Automatiske commits uden aftale
- Stor refaktorering uden godkendelse
- Ændringer af centrale config files
- Nye dependencies uden diskussion
- **ALDRIG ændre NAMESPACE** uden explicit godkendelse

✅ **GØR:**
- Test alt før commit
- Dokumenter arkitektur beslutninger (ADR'er)
- Diskutér før major refactoring
- Hold dependencies minimale
- Brug `devtools::document()` for NAMESPACE

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
