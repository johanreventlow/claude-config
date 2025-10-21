# Shiny Development Standards

Standarder for udvikling af R Shiny applikationer.

---

## Reactive Programming

**Best practices:**
- `req()` for input validation
- `validate()` for brugervenlige fejlbeskeder
- `isolate()` til at bryde reactive dependencies
- Undgå reactive pollution (unødvendige dependencies)

**Observer patterns:**
```r
# ✅ Korrekt observeEvent
observeEvent(input$button, {
  req(input$data)
  process_data(input$data)
})

# ✅ Reactive expressions for computed values
filtered_data <- reactive({
  req(input$filter)
  data |> filter(category == input$filter)
})
```

**Reactive hierarchy:**
1. **Input** - Fra UI (`input$*`)
2. **Reactive expressions** - Computed values (`reactive({})`)
3. **Observers** - Side effects (`observeEvent`, `observe`)
4. **Output** - Til UI (`output$*`)

---

## Module Pattern

```r
# UI
my_module_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("input"), "Vælg:", choices = ...),
    plotOutput(ns("plot"))
  )
}

# Server
my_module_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    output$plot <- renderPlot({
      plot(data())
    })
  })
}
```

**Naming:**
- UI IDs: `camelCase` (fx `fileUpload`, `dataTable`)
- Server functions: `snake_case` (fx `process_upload`, `validate_data`)
- Modules: Konsistent prefix (`mod_upload_ui`, `mod_upload_server`)

---

## State Management

**Centralized state:**
```r
app_state <- reactiveValues(
  data = NULL,
  user_settings = list(),
  session_info = NULL
)

# Brug konsistent gennem appen
observeEvent(input$upload, {
  app_state$data <- read_data(input$upload$datapath)
})
```

**Undgå global mutable state:**
```r
# ❌ Farligt - delt mellem sessions
global_counter <- 0

# ✅ Session-specifik state
session_state <- reactiveValues(counter = 0)
```

Se `SHINY_ADVANCED_PATTERNS.md` for: event architecture, race conditions, hierarchical state.

---

## Performance

**Debouncing/Throttling:**
```r
debounced_input <- debounce(reactive(input$text), 1000)
throttled_slider <- throttle(reactive(input$slider), 500)
```

**Caching:**
```r
expensive_result <- reactive({
  req(input$data)
  process_large_dataset(input$data)  # Kun genberegn når input$data ændres
})
```

---

## Error Handling

**User-friendly errors:**
```r
output$table <- renderTable({
  validate(
    need(input$file, "Upload venligst en fil"),
    need(nrow(data()) > 0, "Filen indeholder ingen data")
  )
  data()
})
```

**Graceful degradation:**
```r
safe_data <- reactive({
  tryCatch({
    load_data(input$source)
  }, error = function(e) {
    showNotification("Kunne ikke indlæse data. Bruger cached version.", type = "warning")
    return(cached_data)
  })
})
```

---

## Testing

**shinytest2:**
```r
library(shinytest2)

test_that("Upload functionality works", {
  app <- AppDriver$new()
  app$upload_file(upload = test_file.csv)
  app$expect_values(output = "dataTable")
})
```

**Manual checklist:**
- [ ] Test med tomme inputs
- [ ] Test med ugyldige inputs
- [ ] Test reactive chains
- [ ] Test session cleanup
- [ ] Test på forskellige browsere

---

## UI Best Practices

**Responsive design:**
```r
fluidRow(
  column(4, selectInput(...)),
  column(8, plotOutput(...))
)
```

**Accessibility:**
- Beskrivende labels
- `aria-label` for skærmlæsere
- Keyboard navigation
- Passende farvekontrast

**Loading states:**
```r
output$plot <- renderPlot({
  req(input$data)
  withProgress(message = 'Beregner...', {
    result <- complex_analysis(input$data)
    incProgress(0.5)
    plot(result)
  })
})
```

---

## Security

**Input sanitization:**
```r
safe_input <- reactive({
  req(input$text)
  stringr::str_replace_all(input$text, "[<>]", "")
})
```

**File upload safety:**
```r
observeEvent(input$file, {
  req(input$file)
  ext <- tools::file_ext(input$file$name)
  validate(need(ext %in% c("csv", "xlsx"), "Kun CSV og XLSX tilladt"))
})
```

---

## Common Pitfalls

**Undgå:**
```r
# ❌ Reactive expressions i loops
for (i in 1:10) {
  output[[paste0("plot", i)]] <- renderPlot({ reactive_data() })
}

# ❌ Lange reactive chains (>5 steps)
data1 <- reactive({ ... })
data2 <- reactive({ process(data1()) })
data3 <- reactive({ process(data2()) })
# Kombiner til færre steps

# ❌ Global variables i server
my_var <- NULL
server <- function(input, output, session) {
  observeEvent(input$button, {
    my_var <<- input$value  # Deles mellem sessions!
  })
}
```

---

**Sidst opdateret:** 2025-10-21
