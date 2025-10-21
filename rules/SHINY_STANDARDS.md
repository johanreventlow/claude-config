# Shiny Development Standards

Standarder for udvikling af R Shiny applikationer.

## Reactive Programming

### Observer Patterns
```r
# ✅ Korrekt brug af observeEvent
observeEvent(input$button, {
  req(input$data)
  process_data(input$data)
})

# ✅ Reactive expressions for computed values
filtered_data <- reactive({
  req(input$filter)
  data |> filter(category == input$filter)
})

# ❌ Undgå observe uden trigger
observe({
  # Dette kører ved enhver reactive dependency
  updateUI()
})
```

### Best Practices
- Brug `req()` for input validation
- Brug `validate()` for brugervenlige fejlbeskeder
- Brug `isolate()` til at bryde reactive dependencies
- Undgå reactive pollution (unødvendige dependencies)

### Reactive Hierarchy
1. **Input** - Fra UI (input$*)
2. **Reactive expressions** - Computed values (`reactive({})`)
3. **Observers** - Side effects (`observeEvent`, `observe`)
4. **Output** - Til UI (output$*)

## UI and Server Structure

### Module Pattern
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

### Naming Conventions
- **UI IDs**: `camelCase` (fx `fileUpload`, `dataTable`)
- **Server functions**: `snake_case` (fx `process_upload`, `validate_data`)
- **Modules**: Konsistent prefix (fx `mod_upload_ui`, `mod_upload_server`)

## State Management

### Centralized State
```r
# Opret central state
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

### Undgå Global Mutable State
```r
# ❌ Farligt - delt mellem sessions
global_counter <- 0

server <- function(input, output, session) {
  observeEvent(input$button, {
    global_counter <<- global_counter + 1  # FARLIGT!
  })
}

# ✅ Session-specifik state
server <- function(input, output, session) {
  session_state <- reactiveValues(counter = 0)

  observeEvent(input$button, {
    session_state$counter <- session_state$counter + 1
  })
}
```

## Performance Optimization

### Debouncing and Throttling
```r
# Debounce hurtige inputs
debounced_input <- debounce(reactive(input$text), 1000)

# Throttle kontinuerlige updates
throttled_slider <- throttle(reactive(input$slider), 500)
```

### Caching
```r
# Cache tunge beregninger
expensive_result <- reactive({
  req(input$data)
  # Kun genberegn når input$data ændres
  process_large_dataset(input$data)
})
```

### Async Operations
```r
# Brug promises for lange operationer
library(promises)
library(future)

plan(multisession)

output$result <- renderPlot({
  future({
    long_running_computation()
  }) %...>%
    plot()
})
```

## Error Handling

### User-Friendly Errors
```r
output$table <- renderTable({
  validate(
    need(input$file, "Upload venligst en fil"),
    need(nrow(data()) > 0, "Filen indeholder ingen data")
  )

  data()
})
```

### Graceful Degradation
```r
server <- function(input, output, session) {
  # Fallback ved fejl
  safe_data <- reactive({
    tryCatch({
      load_data(input$source)
    }, error = function(e) {
      showNotification("Kunne ikke indlæse data. Bruger cached version.", type = "warning")
      return(cached_data)
    })
  })
}
```

## Testing

### Shiny Testing Framework
```r
# Brug shinytest2
library(shinytest2)

test_that("Upload functionality works", {
  app <- AppDriver$new()

  app$upload_file(upload = test_file.csv)
  app$expect_values(output = "dataTable")
})
```

### Manual Testing Checklist
- [ ] Test med tomme inputs
- [ ] Test med ugyldige inputs
- [ ] Test reactive chains
- [ ] Test session cleanup
- [ ] Test på forskellige browsere

## UI Best Practices

### Responsive Design
```r
# Brug fluidRow og column
fluidRow(
  column(4, selectInput(...)),
  column(8, plotOutput(...))
)

# Overvej mobile users
tags$head(
  tags$meta(name = "viewport", content = "width=device-width, initial-scale=1")
)
```

### Accessibility
- Brug beskrivende labels
- Tilføj `aria-label` for skærmlæsere
- Sørg for keyboard navigation
- Passende farvekontrast

### Loading States
```r
# Vis loading indicator
output$plot <- renderPlot({
  req(input$data)

  withProgress(message = 'Beregner...', {
    # Længere beregning
    result <- complex_analysis(input$data)
    incProgress(0.5)
    plot(result)
  })
})
```

## Security

### Input Sanitization
```r
# Valider og sanitize user input
safe_input <- reactive({
  req(input$text)
  # Fjern potentielt farlige tegn
  stringr::str_replace_all(input$text, "[<>]", "")
})
```

### File Upload Safety
```r
observeEvent(input$file, {
  req(input$file)

  # Valider filtype
  ext <- tools::file_ext(input$file$name)
  validate(need(ext %in% c("csv", "xlsx"), "Kun CSV og XLSX tilladt"))

  # Scan for farligt indhold
  # ...
})
```

## Deployment

### Preparation
- Test i production-lignende miljø
- Verificer dependencies
- Test med realistiske data volumener
- Dokumenter deployment process

### Monitoring
- Log errors og warnings
- Monitor performance metrics
- Track user sessions
- Implementer health checks

## Common Pitfalls

### Avoid These Patterns
```r
# ❌ Reactive expressions i loops
for (i in 1:10) {
  output[[paste0("plot", i)]] <- renderPlot({
    reactive_data()  # Reactive dependency skabt i loop
  })
}

# ❌ Lange reactive chains
data1 <- reactive({ ... })
data2 <- reactive({ process(data1()) })
data3 <- reactive({ process(data2()) })
data4 <- reactive({ process(data3()) })
# Overvej at kombinere til færre steps

# ❌ Global variables i server
my_var <- NULL
server <- function(input, output, session) {
  observeEvent(input$button, {
    my_var <<- input$value  # Deles mellem sessions!
  })
}
```
