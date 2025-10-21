# Architecture Patterns & Design Principles

Arkitektoniske mønstre, design principper, og best practices for R-projekter.

---

## 1) File Organization (Golem Conventions)

### 1.1 Shiny App Structure

```
project/
├── R/
│   ├── app_*.R              # Core app setup, startup hooks
│   ├── mod_*.R              # Shiny modules (UI + server)
│   ├── fct_*.R              # Business logic functions
│   ├── utils_server_*.R     # Server-side utilities
│   ├── utils_ui_*.R         # UI utilities and helpers
│   ├── config_*.R           # Configuration constants
│   ├── state_management.R   # Centralized app state
│   ├── global.R             # Startup and initialization
│   └── zzz.R                # Package startup hooks
│
├── inst/
│   ├── app/                 # Shiny app files (if packaged)
│   ├── config/              # Configuration files (YAML, etc)
│   └── assets/              # Static assets (CSS, images, etc)
│
├── tests/
│   └── testthat/            # Unit tests
│       ├── test-mod_*.R     # Module tests
│       ├── test-fct_*.R     # Function tests
│       └── test-reactive.R  # Reactive chain tests
│
├── docs/
│   ├── ARCHITECTURE.md      # High-level architecture
│   ├── KNOWN_ISSUES.md      # Known issues & workarounds
│   ├── adr/                 # Architecture Decision Records
│   │   ├── ADR-001-*.md
│   │   └── ADR-002-*.md
│   └── CONFIGURATION.md     # Config guide
│
├── vignettes/               # Long-form documentation
│
├── DESCRIPTION              # Package metadata
├── NAMESPACE                # Auto-generated, don't edit
├── .Rbuildignore            # What to exclude from build
├── .gitignore               # Git ignore patterns
└── CLAUDE.md                # Claude AI guidance
```

### 1.2 R Package Structure

```
package/
├── R/
│   ├── *.R                  # Functions (flat structure ok)
│   └── zzz.R                # Package startup
│
├── inst/
│   ├── extdata/             # External data files
│   └── config/              # Configuration
│
├── tests/testthat/
│   ├── test-*.R             # Tests for each file
│   └── fixtures/            # Test data
│
├── vignettes/               # Long-form docs
├── man/                     # Auto-generated from Roxygen
├── DESCRIPTION
├── NAMESPACE                # Auto-generated
└── CLAUDE.md
```

### 1.3 Naming Conventions

```r
# ✅ KORREKT
mod_data_loading.R          # Module: mod_*
fct_core_logic.R            # Function file: fct_*
utils_server_data.R         # Server utils: utils_server_*
utils_ui_inputs.R           # UI utils: utils_ui_*
config_settings.R           # Config: config_*
app_ui.R                    # App: app_*

# ❌ FORKERT
data_module.R               # Brug mod_ prefix
core_logic.R                # Brug fct_ prefix
helpers.R                   # Vær specifik (utils_server/utils_ui)
settings.R                  # Brug config_ prefix
```

### 1.4 Flat vs Nested

```
✅ FLAD struktur (Golem konvention):
R/
├── mod_data.R
├── mod_chart.R
├── fct_*.R
└── utils_server_*.R

❌ NESTED struktur (undgå):
R/
├── modules/
│   ├── data.R
│   └── chart.R
├── functions/
│   └── calc.R
└── utils/
    └── helpers.R
```

**Årsag:** Flad struktur gør filnavne mere meningsfulde og man undgår at "gemme" vigtig kode dybt nede.

---

## 2) State Management Patterns

### 2.1 App State Schema

```r
# ✅ KORREKT: Hierarkisk struktur
app_state <- new.env(parent = emptyenv())

app_state$events <- reactiveValues(
  data_loaded = 0L,
  processing_started = 0L,
  processing_completed = 0L,
  data_validated = 0L,
  ui_refresh_needed = 0L,
  ui_refresh_completed = 0L,
  user_action = 0L,
  session_reset = 0L,
  app_ready = 0L
)

app_state$data <- reactiveValues(
  current_data = NULL,
  original_data = NULL,
  file_info = NULL,
  updating_table = FALSE,
  table_operation_in_progress = FALSE,
  table_version = 0
)

app_state$processing <- reactiveValues(
  # Processing sub-system
  in_progress = FALSE,
  completed = FALSE,
  results = NULL,
  last_run = NULL,
  error = NULL
)

app_state$ui <- reactiveValues(
  # UI state sub-system
  current_selection = NULL,
  display_mode = "normal",
  pending_updates = list()
)

app_state$session <- reactiveValues(
  auto_save_enabled = TRUE,
  restoring_session = FALSE,
  file_uploaded = FALSE,
  user_started_session = FALSE,
  last_save_time = NULL,
  file_name = NULL
)
```

### 2.2 Event-Driven Pattern

```r
# ✅ KORREKT: Centraliseret event emit
handle_data_upload <- function(new_data, emit) {
  safe_operation("Data upload state update", {
    app_state$data$current_data <- new_data
    app_state$data$file_info <- get_file_info()
    emit$data_loaded()  # Trigger listeners
  })
}

# Listener med prioritet
observeEvent(app_state$events$data_loaded,
  ignoreInit = TRUE,
  priority = OBSERVER_PRIORITIES$HIGH, {
  req(app_state$data$current_data)
  emit$processing_started()
})
```

### 2.3 Hierarchical State Access

```r
# ✅ KORREKT
app_state$processing$results
app_state$ui$current_selection
app_state$ui$display_mode

# ❌ FORKERT (legacy/flat)
app_state$results                        # Brug processing$results
app_state$selection                      # Brug ui$current_selection
```

**Fordele:**
- Logisk organisation
- Mindsker navnekollusioner
- Lettere at finde relaterede state
- Simplere at mock i tests

---

## 3) Modularity & Extension Points

### 3.1 Single Responsibility Principle

```r
# ✅ KORREKT: Hver funktion har en ansvar
load_data <- function(file_path) {
  # ALENE ansvarlig for at læse filer
  readr::read_csv(file_path)
}

validate_data <- function(data) {
  # ALENE ansvarlig for validering
  stopifnot(nrow(data) > 0)
}

process_data <- function(data) {
  # ALENE ansvarlig for transformation
  data %>%
    dplyr::filter(value > 0) %>%
    dplyr::mutate(log_value = log(value))
}

# Orkestrering
full_pipeline <- function(file_path) {
  data <- load_data(file_path)
  validate_data(data)
  process_data(data)
}

# ❌ FORKERT: Blandet ansvar
everything <- function(file_path) {
  # Load + validate + process + save + notify + log
  # + 100 andre ting...
}
```

### 3.2 Dependency Injection

```r
# ✅ KORREKT: Dependencies som argumenter
create_chart <- function(data, x_col, y_col, emit, theme = theme_bfh()) {
  # Alle dependencies eksplicit
  emit$chart_started()
  # render chart
  emit$chart_completed()
}

# ❌ FORKERT: Globale dependencies
create_chart <- function(data, x_col, y_col) {
  # Hvor kommer emit fra? Hvor kommer theme fra?
  emit$chart_started()  # Magic!
  # render chart
}
```

### 3.3 Immutable Data Flow

```r
# ✅ KORREKT: Return nye objekter
transform_data <- function(data) {
  result <- data %>%
    dplyr::mutate(new_col = x * 2)
  result  # Return kopi, original intakt
}

# ❌ FORKERT: Mutér eksisterende
transform_data <- function(data) {
  data$new_col <- data$x * 2  # Muterer input!
  invisible(data)
}
```

---

## 4) Constraints & Do-Nots

### 4.1 Generelle Constraints

```
❌ Gør IKKE:
- Automatiske commits uden aftale
- Stor refaktorering uden godkendelse
- Ændringer af centrale configuration files
- Nye dependencies uden diskussion
- Manuelle NAMESPACE ændringer (brug devtools::document())

✅ GØR:
- Test alt før commit
- Dokumenter arkitektur beslutninger (ADR'er)
- Diskutér før major refactoring
- Hold dependencies minimale
- Brug devtools::document() for NAMESPACE
```

### 4.2 Project-Specific Constraints

Se `CLAUDE.md` i projekt - der kan være ekstra begrænsninger:

```markdown
## Constraints (fra CLAUDE.md)

### Do Not Modify
* Exported function signatures (breaking changes)
* Control limit formulas uden statistisk validering
* NAMESPACE (auto-generated)
* Chart type detection logic uden tests

### Breaking Changes
Requires: Major version bump, Deprecation warnings først, Migration guide
```

---

## 5) Performance Architecture

### 5.1 Startup Optimization

```r
# ✅ Fast: Package loading
library(SPCify)  # ~50-100ms

# ❌ Slow: Source loading (debug mode)
options(spc.debug.source_loading = TRUE)
source('global.R')  # ~400ms+
```

### 5.2 Lazy Loading

```r
LAZY_LOADING_CONFIG <- list(
  heavy_modules = list(
    file_operations = "R/fct_file_operations.R",
    advanced_debug = "R/utils_advanced_debug.R",
    performance_monitoring = "R/utils_performance.R",
    plot_generation = "R/fct_spc_plot_generation.R"
  )
)

# Load kun når nødvendigt
ensure_module_loaded <- function(module_name) {
  if (!exists(paste0(module_name, "_loaded"))) {
    source(LAZY_LOADING_CONFIG$heavy_modules[[module_name]])
    assign(paste0(module_name, "_loaded"), TRUE, envir = globalenv())
  }
}
```

### 5.3 Caching Strategy

```r
CACHE_CONFIG <- list(
  hospital_branding = list(ttl = 3600),       # 1 hour
  observer_priorities = list(ttl = 3600),     # 1 hour
  chart_types_config = list(ttl = 3600)       # 1 hour
)

# Implementering
get_cached_value <- function(key, compute_fn, ttl = NULL) {
  cache_key <- paste0("cache_", key)

  if (exists(cache_key, envir = globalenv())) {
    cached <- get(cache_key, envir = globalenv())
    if (Sys.time() - cached$time < ttl) {
      return(cached$value)
    }
  }

  value <- compute_fn()
  assign(cache_key, list(value = value, time = Sys.time()), envir = globalenv())
  value
}
```

---

## 6) Testing Architecture

### 6.1 Test Structure

```
tests/testthat/
├── test-mod_data.R          # Module tests
├── test-fct_chart.R         # Function tests
├── test-reactive.R          # Reactive patterns
├── test-state_management.R  # State tests
├── fixtures/                # Test data
│   ├── sample_data.csv
│   └── test_config.R
└── helpers.R                # Shared test utilities
```

### 6.2 Test Levels

```r
# Level 1: Unit tests (pure functions)
test_that("calculate_ucl handles edge cases", {
  expect_equal(calculate_ucl(0.5, 10), expected_value)
})

# Level 2: Integration tests (functions + state)
test_that("data upload triggers auto-detection", {
  test_data <- read.csv("fixtures/sample.csv")
  app_state$data$current_data <- test_data
  app_state$events$data_loaded <- app_state$events$data_loaded + 1
  expect_equal(app_state$columns$auto_detect$completed, TRUE)
})

# Level 3: UI tests (full Shiny)
test_that("Chart renders after data upload", {
  app <- shinytest2::AppDriver$new(...)
  app$upload("file_input", "fixtures/sample.csv")
  app$wait_for_value(input = "chart_ready", ignore_init = TRUE)
  expect_true(app$is_visible("#chart"))
})
```

---

## 7) Extensibility

### 7.1 Adding New Features

```
1. Start med tests (TDD)
2. Implementer inkrementelt
3. Følg eksisterende patterns:
   - Event-bus for triggering
   - app_state for state management
   - Struktureret logging
   - Guard conditions for race prevention
4. Dokumentér (ADR hvis større)
5. Monitorér performance impact
```

### 7.2 Adding New Chart Type (Example)

```r
# 1. Tests first
test_that("p_chart generates correct control limits", {
  data <- data.frame(n = rep(100, 10), events = 5:14)
  result <- create_p_chart(data, "n", "events")
  expect_equal(result$ucl, expected_ucl, tolerance = 0.001)
})

# 2. Implement
create_p_chart <- function(data, n_col, events_col) {
  # Implementation following existing patterns
}

# 3. Register type
register_chart_type(
  name = "p-chart",
  handler = create_p_chart,
  description = "Proportion chart"
)

# 4. Document
#' @export
#' @rdname create_spc_chart
```

---

## 8) Configuration Management

### 8.1 Config Organization

| Ansvar | File | Eksempler |
|--------|------|----------|
| Hospital branding | `config_branding.R` | Navn, logo, farver, theme |
| Chart definitions | `config_chart_types.R` | SPC chart type mappings |
| Observer priorities | `config_observer_priorities.R` | Execution order |
| SPC constants | `config_spc_config.R` | Validation rules, colors |
| Logging context | `config_log_contexts.R` | Log component names |
| UI layout | `config_ui.R` | Widths, heights, fonts |
| System config | `config_system_config.R` | Performance timeouts |
| Environment | `inst/golem-config.yml` | Dev/prod/test settings |

### 8.2 Config Access Pattern

```r
# ✅ KORREKT: Funktioner som getters
get_hospital_branding <- function() {
  # Validering og caching
}

get_chart_type <- function(type_name) {
  # Lookup og fallback
}

# ❌ FORKERT: Direkte konstanter
HOSPITAL_BRANDING$colors$primary

# Årsag: Kan ikke cache, kan ikke validere, svær at mock i tests
```

---

## 9) Documentation & ADRs

### 9.1 Architecture Decision Records

**Hvornår lav ADR:**
- Arkitektoniske val der påvirker flere moduler
- Trade-offs mellem alternativer
- Beslutninger der skal mindes i fremtiden

**Template:** Se DEVELOPMENT_PHILOSOPHY.md

**Placering:** `docs/adr/ADR-NNN-description.md`

### 9.2 Documentation Files

```
docs/
├── ARCHITECTURE.md          # High-level overview
├── KNOWN_ISSUES.md          # Known problems & workarounds
├── CONFIGURATION.md         # Config guide
├── DATA_FLOW.md            # Data pipeline visualization
├── TESTING.md              # Test strategy
└── adr/
    ├── ADR-001-event-bus.md
    ├── ADR-002-state-management.md
    └── ADR-003-*.md
```

---

**Sidst opdateret:** 2025-10-21
**Del af:** ~/.claude/ global configuration system
