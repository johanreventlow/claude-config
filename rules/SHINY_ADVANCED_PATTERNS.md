# Shiny Advanced Patterns & Best Practices

Avancerede mønstre, anti-patterns, og best practices for Shiny applikationer.

---

## 1) Unified Event Architecture

### 1.1 Korrekt Mønster: Consolidated Event-Bus

```r
# ✅ KORREKT: Centraliseret event-bus
emit$data_updated(context = "upload")     # Erstatter: data_loaded + data_changed
emit$auto_detection_completed()
emit$ui_sync_requested()

observeEvent(app_state$events$data_updated, ignoreInit = TRUE,
  priority = OBSERVER_PRIORITIES$HIGH, {
  handle_data_update()
})
```

### 1.2 Anti-Pattern: Ad-hoc Reactivity

```r
# ❌ FORKERT: Ad-hoc reactiveVal triggers
legacy_trigger <- reactiveVal(NULL)
observeEvent(legacy_trigger(), { ... })

# Problemer:
# - Implicit afhængigheder
# - Svær at debugge
# - Race conditions sandsynlige
```

### 1.3 Event Infrastructure

**Struktur:**
* Events defineres i `global.R` (`app_state$events`)
* Emit-funktioner i `create_emit_api()`
* Lyttere i `R/utils_event_system.R` via `setup_event_listeners()`

**Fordele:**
- ✅ Eksplicit event flow
- ✅ Centraliseret state management
- ✅ Lettere at teste
- ✅ Performance observability

---

## 2) Unified State Management

### 2.1 Single Source of Truth

```r
# ✅ App state som single source of truth
app_state$data$current_data <- new_data
app_state$columns$mappings$x_column <- detected_column
app_state$session$auto_save_enabled <- TRUE

# ❌ FORKERT: Lokale reactiveVal spredt omkring
values$some_data <- data
local_state <- reactiveVal(NULL)
```

### 2.2 Hierarchical State Structure

```r
# ✅ KORREKT: Hierarkisk organisation
app_state$columns$auto_detect$in_progress
app_state$columns$mappings$x_column
app_state$columns$ui_sync$needed

# ❌ FORKERT: Flad struktur
app_state$auto_detected_columns      # Brug: auto_detect$results
app_state$x_column                   # Brug: mappings$x_column
```

### 2.3 Atomiske Opdateringer

```r
# ✅ KORREKT: Atomic update
safe_operation("Update column mapping", {
  app_state$columns$mappings$x_column <- detected_col
  app_state$columns$mappings$y_column <- detected_value
  # Hele operationen eller ingen af delen
})

# ❌ FORKERT: Separate opdateringer (race condition risk)
app_state$columns$mappings$x_column <- detected_col
# Her kunne anden observer trigger hvis y_column mangler
app_state$columns$mappings$y_column <- detected_value
```

---

## 3) Reactive Patterns Best Practices

### 3.1 Grundlæggende Regler

```r
# ✅ KORREKT
observeEvent(app_state$events$data_loaded, ignoreInit = TRUE,
  priority = OBSERVER_PRIORITIES$HIGH, {
  req(app_state$data$current_data)
  # ... logik
})

# ❌ FORKERT: Uspecificeret priority
observeEvent(app_state$events$data_loaded, {
  # Kan race med andre observers
})

# ❌ FORKERT: Manglende req()
observeEvent(app_state$events$data_loaded, {
  process_data(app_state$data$current_data)  # NULL hvis ikke loaded!
})
```

### 3.2 Priority Levels for Race Condition Prevention

```r
# Prioritering (højest først):
OBSERVER_PRIORITIES$CRITICAL   # Kritiske state updates
OBSERVER_PRIORITIES$HIGH       # Normale updates
OBSERVER_PRIORITIES$MEDIUM     # UI refresh
OBSERVER_PRIORITIES$LOW        # Optional side effects

# Eksempel workflow:
# 1. Data upload (CRITICAL)
# 2. Auto-detection (HIGH)
# 3. UI sync (MEDIUM)
# 4. Logging (LOW)
```

### 3.3 req() vs validate()

```r
# ✅ req(): Simpel condition check
observeEvent(input$upload, {
  req(input$upload)  # Skips hvis NULL
  process_file()
})

# ✅ validate(): Komplekse validering med error messages
output$chart <- renderPlot({
  validate(
    need(nrow(app_state$data$current_data) > 0,
         "Upload data først"),
    need(!is.null(input$x_column),
         "Vælg X-kolonne")
  )
  create_chart()
})
```

### 3.4 isolate() - Korrekt Brug

```r
# ✅ KORREKT: isolate() for non-reactive reads
observeEvent(input$save_button, {
  # button click trigger, men ikke reaktiv på data changes
  data <- isolate(app_state$data$current_data)
  save_to_file(data)
})

# ❌ FORKERT: isolate() på alt (skjuler dependencies)
reactive({
  isolate(
    isolate(
      isolate(complex_calculation())  # Hvad sker der?
    )
  )
})
```

### 3.5 Komplekse Reactives i safe_operation()

```r
# ✅ KORREKT: Wrap problematiske reactives
output$plot <- renderPlot({
  safe_operation("Chart rendering", {
    req(app_state$data$current_data)
    req(input$chart_type)
    create_spc_chart(
      app_state$data$current_data,
      chart_type = input$chart_type
    )
  }, fallback = NULL)
})
```

---

## 4) Race Condition Prevention (Hybrid Anti-Race Strategy)

### 4.1 5-Lags Defense

```
┌─────────────────────────────────────────────┐
│ 1. Event Architecture (Centraliseret)       │
│    Prioriterede centraliserede listeners    │
├─────────────────────────────────────────────┤
│ 2. State Atomicity                          │
│    Atomiske opdateringer via safe_operation │
├─────────────────────────────────────────────┤
│ 3. Functional Guards                        │
│    Guard conditions forhindrer overlap      │
├─────────────────────────────────────────────┤
│ 4. UI Atomicity                             │
│    Sikre wrappere for UI-opdateringer       │
├─────────────────────────────────────────────┤
│ 5. Input Debouncing                         │
│    Standard 800ms delay på hyppige events   │
└─────────────────────────────────────────────┘
```

### 4.2 Guard Pattern Eksempel

```r
# ✅ Guard conditions prevent overlap
update_column_choices_unified <- function() {
  # Guard: Check if other operation is running
  if (app_state$data$updating_table ||
      app_state$columns$auto_detect$in_progress) {
    return()  # Skip hvis anden operation kører
  }

  # Safe update
  app_state$columns$mappings$x_column <- detected_x
}

# ❌ FORKERT: Ingen guards
update_column_choices_unified <- function() {
  # Podem multiple calls at once!
  app_state$columns$mappings$x_column <- detected_x
}
```

### 4.3 Input Debouncing

```r
# ✅ KORREKT: Debounce hyppige inputs
observeEvent(input$search_text, {
  # Debounced i UI definition:
  # textInput("search_text", debounce = 800)

  req(nchar(input$search_text) > 0)
  perform_search(input$search_text)
}, ignoreInit = TRUE)
```

### 4.4 Feature Implementation Checklist

```r
# ✅ CHECKLIST for race condition prevention:

1. ☑ Emit via event-bus (ikke direkte reactive triggers)
2. ☑ Observer i setup_event_listeners() med korrekt prioritet
3. ☑ Guard conditions først (check running status)
4. ☑ Atomisk state update (hele eller intet)
5. ☑ UI opdatering gennem sikker wrapper
6. ☑ Debounce hyppige inputs
7. ☑ Test concurrent operations
```

---

## 5) Performance Optimization

### 5.1 Package Loading vs Source Loading

```r
# ✅ OPTIMALT: Package loading
library(SPCify)  # ~50-100ms

# ❌ LANGSOMT: Source loading (debug mode)
options(spc.debug.source_loading = TRUE)
source('global.R')  # ~400ms+
```

### 5.2 Lazy Loading for Heavy Components

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
ensure_module_loaded("file_operations")
```

### 5.3 Caching Strategy

```r
# Cache anti-patterns:
CACHE_CONFIG <- list(
  hospital_branding = list(ttl = 3600),      # 1 hour
  observer_priorities = list(ttl = 3600),    # 1 hour
  chart_types_config = list(ttl = 3600)      # 1 hour
)

# ✅ Cache ved startup
get_hospital_branding <- function() {
  if (!is.null(CACHE$hospital_branding)) {
    return(CACHE$hospital_branding)
  }
  # Compute and cache
}
```

### 5.4 Performance Targets

* **Startup:** < 100ms (achieved: 55-57ms)
* **Data upload:** < 2s
* **Chart rendering:** < 1s
* **Column detection:** < 5s (med stor data)

---

## 6) Error Handling in Reactivity

### 6.1 safe_operation() Helper

```r
safe_operation <- function(
  operation_name,
  code,
  fallback = NULL,
  session = NULL,
  show_user = FALSE
) {
  tryCatch({
    code
  }, error = function(e) {
    log_error(
      component = "[ERROR_HANDLER]",
      message = paste(operation_name, "fejlede"),
      details = list(error_message = e$message),
      session = session,
      show_user = show_user
    )
    return(fallback)
  })
}

# Brug:
output$plot <- renderPlot({
  safe_operation("Chart rendering", {
    create_chart(app_state$data$current_data)
  }, fallback = NULL)
})
```

### 6.2 Error Recovery

```r
# ✅ KORREKT: Graceful degradation
observeEvent(input$export, {
  result <- safe_operation("Export to Excel", {
    write_excel(data, file = "output.xlsx")
  }, fallback = NULL)

  if (is.null(result)) {
    showNotification("Export fejlede. Prøv igen.", type = "error")
  } else {
    showNotification("Eksporteret!", type = "success")
  }
})
```

---

## 7) Testing Reactive Code

### 7.1 Unit Testing Reactives

```r
test_that("data_updated event triggers column detection", {
  # Setup
  test_data <- data.frame(x = 1:10, y = 11:20)

  # Trigger event
  app_state$events$data_updated$0  # Increment to trigger
  app_state$data$current_data <- test_data

  # Verify state
  expect_equal(app_state$data$current_data, test_data)
})
```

### 7.2 Shiny Test (UI Testing)

```r
test_that("Upload button triggers file processing", {
  # Use shinytest2 for full app testing
  app <- shinytest2::AppDriver$new(...)

  app$upload("file_input", "test_data.csv")
  app$wait_for_value(input$auto_detect_button, ignore_init = TRUE)

  expect_true(app$get_value(input = "detection_complete"))
})
```

---

## 8) Debugging Reactive Problems

### 8.1 Common Issues

| Problem | Symptom | Solution |
|---------|---------|----------|
| Infinite loop | App freezes, CPU 100% | Cirkulære event-afhængigheder, bryd med guards |
| Race condition | Inconsistent state | Atomic updates, priority ordering |
| Memory leak | RAM stiger over tid | `session$onSessionEnded`, isolate reactives |
| Slow reactives | UI lags | Debounce/throttle, cache, background jobs |

### 8.2 Debugging Tools

```r
# ✅ Brug structured logging
log_debug("[REACTIVE]", "Event triggered",
  details = list(event = "data_updated", state = app_state$data$status))

# ✅ Inspect state
print(str(app_state))

# ✅ Timeline analysis
system.time({
  # operationen
})

# ✅ profvis for bottlenecks
profvis::profvis({
  source('global.R')
  runApp()
})
```

---

## 9) Anti-Patterns to Avoid

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| Too many observers | Race conditions, hard to trace | Use event-bus |
| Nested reactives | Performance, confusion | Flatten structure |
| Implicit dependencies | Silent failures | Use explicit events |
| Missing req() | NULL values crash app | Add validation |
| Unbounded caching | Memory leak | Set TTL/size limits |

---

**Sidst opdateret:** 2025-10-21
**Del af:** ~/.claude/ global configuration system
