# Shiny Advanced Patterns & Best Practices

Avancerede mønstre, anti-patterns, og best practices for Shiny applikationer.

---

## 1) Unified Event Architecture

### 1.1 Korrekt Mønster: Consolidated Event-Bus

```r
# ✅ KORREKT: Centraliseret event-bus
emit$data_loaded()        # Replaces multiple ad-hoc triggers
emit$processing_completed()
emit$ui_sync_requested()

observeEvent(app_state$events$data_loaded, ignoreInit = TRUE,
  priority = OBSERVER_PRIORITIES$HIGH, {
  process_loaded_data()
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
app_state$ui$current_selection <- detected_value
app_state$session$auto_save_enabled <- TRUE

# ❌ FORKERT: Lokale reactiveVal spredt omkring
values$some_data <- data
local_state <- reactiveVal(NULL)
```

### 2.2 Hierarchical State Structure

```r
# ✅ KORREKT: Hierarkisk organisation
app_state$processing$in_progress
app_state$ui$selected_item
app_state$ui$sync$needed

# ❌ FORKERT: Flad struktur
app_state$is_processing              # Brug: processing$in_progress
app_state$item                       # Brug: ui$selected_item
```

### 2.3 Atomiske Opdateringer

```r
# ✅ KORREKT: Atomic update
safe_operation("Update UI state", {
  app_state$ui$primary_value <- new_primary
  app_state$ui$secondary_value <- new_secondary
  # Hele operationen eller ingen af delen
})

# ❌ FORKERT: Separate opdateringer (race condition risk)
app_state$ui$primary_value <- new_primary
# Her kunne anden observer trigger hvis secondary_value mangler
app_state$ui$secondary_value <- new_secondary
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
output$visualization <- renderPlot({
  safe_operation("Rendering visualization", {
    req(app_state$data$current_data)
    req(input$render_type)
    render_visualization(
      app_state$data$current_data,
      type = input$render_type
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
update_ui_state <- function() {
  # Guard: Check if other operation is running
  if (app_state$data$processing ||
      app_state$ui$updating) {
    return()  # Skip hvis anden operation kører
  }

  # Safe update
  app_state$ui$current_selection <- new_value
}

# ❌ FORKERT: Ingen guards
update_ui_state <- function() {
  # Kunnen multiple calls at once!
  app_state$ui$current_selection <- new_value
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
library(MyApp)  # ~50-100ms (packaged app)

# ❌ LANGSOMT: Source loading (debug mode)
options(my_app.debug.source_loading = TRUE)
source('global.R')  # ~400ms+ (not packaged)
```

### 5.2 Lazy Loading for Heavy Components

```r
LAZY_LOADING_CONFIG <- list(
  heavy_modules = list(
    data_processing = "R/fct_data_processing.R",
    advanced_features = "R/utils_advanced.R",
    performance_monitoring = "R/utils_performance.R",
    rendering = "R/fct_rendering.R"
  )
)

# Load kun når nødvendigt
ensure_module_loaded("data_processing")
```

### 5.3 Caching Strategy

```r
# Cache strategy:
CACHE_CONFIG <- list(
  user_data = list(ttl = 3600),              # 1 hour
  config_settings = list(ttl = 3600),        # 1 hour
  computed_results = list(ttl = 1800)        # 30 minutes
)

# ✅ Cache ved startup
get_cached_data <- function() {
  if (!is.null(CACHE$user_data)) {
    return(CACHE$user_data)
  }
  # Compute and cache
}
```

### 5.4 Performance Targets

* **Startup:** < 100ms
* **Data operations:** < 2s
* **Rendering:** < 1s
* **Complex computations:** < 5s

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
test_that("data_loaded event triggers processing", {
  # Setup
  test_data <- data.frame(x = 1:10, y = 11:20)

  # Trigger event
  app_state$events$data_loaded <- app_state$events$data_loaded + 1
  app_state$data$current_data <- test_data

  # Verify state
  expect_equal(app_state$data$current_data, test_data)
})
```

### 7.2 Shiny Test (UI Testing)

```r
test_that("Upload button triggers processing", {
  # Use shinytest2 for full app testing
  app <- shinytest2::AppDriver$new(...)

  app$upload("file_input", "test_data.csv")
  app$wait_for_value(output$status, ignore_init = TRUE)

  expect_true(app$is_visible("#success_message"))
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
