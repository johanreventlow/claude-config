# Shiny Development Standards

Org-specifikke konventioner Shiny apps i BFH-økosystemet.

---

## Navngivning

| Element | Konvention | Eksempel |
|---------|-----------|---------|
| Module UI | `mod_<navn>_ui` | `mod_upload_ui` |
| Module server | `mod_<navn>_server` | `mod_upload_server` |
| Hjælpefunktioner (server-logik) | `fct_<verb>_<noun>` | `fct_load_data`, `fct_validate_input` |
| Utilities (delt hjælper) | `utils_<navn>` | `utils_formatting`, `utils_date` |
| UI IDs | `camelCase` | `fileUpload`, `dataTable` |
| Server-funktioner | `snake_case` | `process_upload`, `validate_data` |

**Module-fil:** `R/mod_<navn>.R` indeholder begge (`_ui` + `_server`).

---

## State Management

Centraliseret `reactiveValues` — aldrig globale mutable variables (deles
mellem sessions via `<<-`). Hierarkisk struktur, event-architecture, race
conditions: se `SHINY_ADVANCED_PATTERNS.md`.

---

## Fejlhåndtering

Brugervenlige fejlbeskeder via `validate(need(...))`. Graceful degradation
via `safe_operation()` (se `DEVELOPMENT_PHILOSOPHY.md`). Input-sanitering,
filupload-validering, XSS, SQL injection: se `SECURITY_BEST_PRACTICES.md`.

---

## Anti-Patterns

```r
# ❌ Reactive expressions i loops
for (i in 1:10) {
  output[[paste0("plot", i)]] <- renderPlot({ reactive_data() })
}

# ❌ Lange reactive chains (>5 steps) — kombiner til færre steps

# ❌ Global variables i server (deles mellem sessions)
my_var <- NULL
server <- function(input, output, session) {
  observeEvent(input$button, {
    my_var <<- input$value
  })
}
```

---

## Testing

**shinytest2** til integration-tests. Manuel checklist:
- [ ] Tomme + ugyldige inputs
- [ ] Reactive chains
- [ ] Session cleanup (`session$onSessionEnded`)
- [ ] Tilgængelighed (labels, keyboard navigation)

---

**Sidst opdateret:** 2026-06-12
