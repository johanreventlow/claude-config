# Shiny Advanced Patterns & Best Practices

Avancerede mønstre og anti-patterns for Shiny applikationer.

---

## Event-Driven Architecture

| Pattern | Korrekt | Undgå |
|---------|---------|-------|
| **Event emit** | `emit$data_loaded()` centraliseret | Ad-hoc `reactiveVal()` triggers |
| **Listeners** | `observeEvent(app_state$events$X, priority = HIGH, ignoreInit = TRUE)` | Uspecificeret priority |
| **State** | `app_state$data$current_data` hierarkisk | Flat global state |

**Event infrastructure:**
- Events: `app_state$events` i `global.R`
- Emit API: `create_emit_api()` funktioner
- Listeners: `setup_event_listeners()` i `R/utils_event_system.R`

---

## Hierarchical State Management

```r
app_state$events         # Event triggers (0L increments)
app_state$data           # current_data, original_data, file_info, updating_table
app_state$processing     # in_progress, completed, results, error
app_state$ui             # current_selection, display_mode, pending_updates
app_state$session        # auto_save_enabled, file_uploaded, user_started_session
```

**Atomiske opdateringer:**
```r
safe_operation("Update state", {
  app_state$ui$primary <- new_primary
  app_state$ui$secondary <- new_secondary
  # Hele operationen eller ingen af delen
})
```

---

## Race Condition Prevention (5 Lag)

**Hybrid Anti-Race Strategy:**
1. **Event Architecture**: Prioriterede centraliserede listeners
2. **State Atomicity**: Atomiske opdateringer via `safe_operation()`
3. **Functional Guards**: Check `in_progress` før update
4. **UI Atomicity**: Sikre wrappere for UI-opdateringer
5. **Input Debouncing**: Standard 800ms delay

**Guard pattern:**
```r
update_ui_state <- function() {
  if (app_state$data$processing || app_state$ui$updating) {
    return()  # Skip hvis anden operation kører
  }
  app_state$ui$current_selection <- new_value
}
```

**Feature implementation checklist:**
☑ Emit via event-bus ☑ Observer med prioritet ☑ Guard conditions ☑ Atomisk update ☑ UI wrapper ☑ Debounce input ☑ Test concurrent ops

---

## Reactive Best Practices

**Priority levels:**
```r
OBSERVER_PRIORITIES$CRITICAL   # Kritiske state updates
OBSERVER_PRIORITIES$HIGH       # Normale updates
OBSERVER_PRIORITIES$MEDIUM     # UI refresh
OBSERVER_PRIORITIES$LOW        # Optional side effects
```

**req() vs validate():**
```r
# req(): Simple condition check (skips hvis NULL)
observeEvent(input$upload, {
  req(input$upload)
  process_file()
})

# validate(): Kompleks validering med error messages
output$chart <- renderPlot({
  validate(
    need(nrow(data()) > 0, "Upload data først"),
    need(!is.null(input$x_column), "Vælg X-kolonne")
  )
  create_chart()
})
```

**isolate() korrekt brug:**
```r
# ✅ isolate() for non-reactive reads
observeEvent(input$save_button, {
  data <- isolate(app_state$data$current_data)
  save_to_file(data)
})
```

---

## Performance Optimization

**Boot strategy:**
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
  hospital_branding = list(ttl = 3600),    # 1 hour
  computed_results = list(ttl = 1800)      # 30 min
)
```

**Performance targets:**
- Startup: < 100ms
- Data operations: < 2s
- Rendering: < 1s

---

## Error Handling

**safe_operation() helper:**
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

## Testing Reactive Code

**Unit testing:**
```r
test_that("data_loaded event triggers processing", {
  test_data <- data.frame(x = 1:10, y = 11:20)
  app_state$events$data_loaded <- app_state$events$data_loaded + 1
  app_state$data$current_data <- test_data
  expect_equal(app_state$data$current_data, test_data)
})
```

---

## Debugging

| Problem | Symptom | Solution |
|---------|---------|----------|
| Infinite loop | App freezes, CPU 100% | Cirkulære event-afhængigheder → guards |
| Race condition | Inconsistent state | Atomic updates + priorities |
| Memory leak | RAM stiger over tid | `session$onSessionEnded` cleanup + `gc()` |
| Slow reactives | UI lags | Debounce/throttle + cache + background jobs |

**Debug tools:**
```r
log_debug("[REACTIVE]", "Event triggered", details = list(event = "data_updated"))
system.time({ operation() })
profvis::profvis({ runApp() })
```

---

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| Too many observers | Race conditions | Use event-bus |
| Nested reactives | Performance, confusion | Flatten structure |
| Implicit dependencies | Silent failures | Use explicit events |
| Missing req() | NULL values crash | Add validation |
| Unbounded caching | Memory leak | Set TTL/size limits |

---

**Sidst opdateret:** 2025-10-21
