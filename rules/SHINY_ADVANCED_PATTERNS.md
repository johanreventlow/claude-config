# Shiny Advanced Patterns & Best Practices

Avancerede mønstre og anti-patterns for Shiny applikationer.

> **Bemærk:** Denne fil beskriver generiske mønstre. Konkrete navne
> (`app_state`, `emit`, `OBSERVER_PRIORITIES`, `safe_operation`) refererer
> til typiske projekt-specifikke konstruktioner — implementation
> dokumenteres i projektets lokale `CLAUDE.md` eller ADR'er. Juster
> navne til dit projekts konventioner.

---

## Event-Driven Architecture

| Pattern | Korrekt | Undgå |
|---------|---------|-------|
| **Event emit** | Centraliseret emit-API med navngivne events | Ad-hoc `reactiveVal()`-triggers spredt i server-kode |
| **Listeners** | `observeEvent(<state>$events$<name>, priority = <LEVEL>, ignoreInit = TRUE)` | Uspecificeret priority |
| **State** | Hierarkisk `reactiveValues`-struktur | Flat global state, globale `<<-`-assignments |

**Event infrastructure (typisk layout):**
- Events: `reactiveValues`-container (fx `app_state$events`) initialiseret centralt
- Emit API: factory-funktion returnerer list af emit-funktioner
- Listeners: centraliseret setup-funktion kaldt én gang per session

Se projektets ARCHITECTURE_PATTERNS eller ADR for konkret navngivning.

---

## Hierarchical State Management

Brug hierarkisk `reactiveValues` i stedet for flat global state. Typiske
niveauer: `events`, `data`, `ui`, `session`, `processing`.

**Atomiske opdateringer via en helper (typisk `safe_operation()`):**

```r
safe_operation("Update UI state", {
  state$ui$primary <- new_primary
  state$ui$secondary <- new_secondary
  # Hele operationen eller ingen af delen
})
```

Projekt-specifik state-schema dokumenteres i lokal `CLAUDE.md` /
`ARCHITECTURE_PATTERNS.md`.

---

## Race Condition Prevention (5 Lag)

**Hybrid Anti-Race Strategy:**
1. **Event Architecture:** Prioriterede centraliserede listeners
2. **State Atomicity:** Atomiske opdateringer via helper-wrapper
3. **Functional Guards:** Check `in_progress`/`updating`-flag før update
4. **UI Atomicity:** Sikre wrappere for UI-opdateringer
5. **Input Debouncing:** Standard 500-800ms delay på fritekst-inputs

**Guard pattern (generisk):**
```r
update_ui_state <- function(state, new_value) {
  if (isTRUE(state$data$processing) || isTRUE(state$ui$updating)) {
    return(invisible(NULL))  # Skip hvis anden operation kører
  }
  state$ui$current_selection <- new_value
}
```

**Feature implementation checklist:**
☑ Emit via event-bus ☑ Observer med prioritet ☑ Guard conditions
☑ Atomisk update ☑ UI wrapper ☑ Debounce input ☑ Test concurrent ops

---

## Reactive Best Practices

**Priority levels (generisk konvention):**
```r
# Typisk navngivning — projekter definerer egen konstant
OBSERVER_PRIORITIES <- list(
  CRITICAL = 100L,  # Kritiske state updates
  HIGH     = 50L,   # Normale updates
  MEDIUM   = 25L,   # UI refresh
  LOW      = 10L    # Optional side effects
)
```

**req() vs validate():**
```r
# req(): Simple condition check (skips hvis NULL)
observeEvent(input$upload, {
  req(input$upload)
  process_file()
})

# validate(): Kompleks validering med brugervenlige fejlbeskeder
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
# ✅ isolate() for non-reactive reads i observer
observeEvent(input$save_button, {
  data <- isolate(current_data())
  save_to_file(data)
})
```

---

## Performance Optimization

**Boot strategy:**
- Production: `library(MyApp)` (installeret pakke, ~50-100ms)
- Debug: `source('global.R')` med verbose logging (~400ms+)

**Lazy loading (generisk pattern):**
```r
# Registry over moduler der kun loades on-demand
LAZY_MODULES <- list(
  heavy_feature_a = "R/fct_heavy_feature_a.R",
  admin_tools    = "R/utils_admin.R"
)

ensure_module_loaded <- function(name) {
  if (!exists(name, envir = globalenv())) {
    source(LAZY_MODULES[[name]], local = FALSE)
  }
}
```

**Caching (generisk pattern):**
```r
# TTL-baseret cache-config; navne er projekt-specifikke
CACHE_CONFIG <- list(
  expensive_lookup  = list(ttl = 3600),  # 1 hour
  computed_results  = list(ttl = 1800)   # 30 min
)
```

**Typiske performance targets:**
- Startup: < 100ms (efter pkg-load)
- Data operations: < 2s for interaktive filtreringer
- Rendering: < 1s for typiske charts

Projekter bør måle og dokumentere egne targets i ADR.

---

## Error Handling

Se `DEVELOPMENT_PHILOSOPHY.md` for `safe_operation()`-pattern og
defensive programming-principper. Brug samme helper i Shiny-kontekst
— eksempler på atomiske opdateringer er i "Hierarchical State
Management"-sektionen ovenfor.

---

## Testing Reactive Code

**Unit testing event-listeners:**
```r
test_that("data_loaded event triggers downstream processing", {
  state <- reactiveValues(
    events = reactiveValues(data_loaded = 0L),
    data   = reactiveValues(current = NULL)
  )
  test_data <- data.frame(x = 1:10, y = 11:20)

  isolate({
    state$data$current  <- test_data
    state$events$data_loaded <- state$events$data_loaded + 1L
    expect_equal(state$data$current, test_data)
  })
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
log_debug(component = "[REACTIVE]", message = "Event triggered",
          details = list(event = "data_updated"))
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
| Globale `<<-` assignments | Shared state mellem sessions | Brug `reactiveValues` |

---

**Sidst opdateret:** 2026-04-23
