# Troubleshooting Guide

Systematisk tilgang til debugging, problemløsning og fejldiagnose.

---

## 1) Debugging Methodology

### 1.1 5-Trins Approach

```
┌─ Trin 1: Reproducer med minimal reproduktion
│  └─ Isolér problemet til mindste mulige case
│
├─ Trin 2: Isolér komponent
│  └─ Hvilken modul/funktion fejler?
│
├─ Trin 3: Analyser strukturerede logs
│  └─ Hvad siger log messagesne?
│
├─ Trin 4: Test antagelser
│  └─ Er mine antagelser korrekte?
│
├─ Trin 5: Instrumenter med log_debug()
│  └─ Tilføj mere verbositet strategisk
│
├─ Trin 6: Binary search (deaktiver dele)
│  └─ Sluk halvdelen af koden, gentag
│
└─ Trin 7: Dokumentér i tests eller docs/KNOWN_ISSUES.md
   └─ Del læring med teamet
```

### 1.2 Minimal Reproducible Example (MRE)

```r
# ✅ GOD: Minimal, isoleret, reproducerbar
library(SPCify)
test_data <- data.frame(
  date = seq(as.Date("2025-01-01"), by = "day", length.out = 10),
  value = c(0.1, 0.12, 0.11, NA, 0.15, 0.13, 0.09, 0.14, 0.12, 0.11)
)
create_spc_chart(test_data, "date", "value")
# Error: [SPECIFIC ERROR MESSAGE]

# ❌ DÅRLIG: Uklart, afhængig af ekstern state
# "Det virker ikke når jeg uploader"
```

### 1.3 Information Collection

Når du rapporterer problem:
```
1. Hvad forsøgte du at gøre?
2. Hvad skete der i stedet?
3. Hvad forventede du ville ske?
4. Minimal reproducer (kode + data)?
5. Miljø (R version, pakke version)?
6. Relevante log messages?
```

---

## 2) Common Issues & Solutions

### 2.1 Reactive Chains

#### Problem: Infinite Loop

**Symptom:**
* App freezer
* CPU stiger til 100%
* Browser responsive slows down

**Årsag:**
```r
# ❌ Cirkulær afhængighed
observeEvent(app_state$events$A, {
  emit$B()
})

observeEvent(app_state$events$B, {
  emit$A()  # Skaber loop!
})
```

**Løsning:**
```r
# ✅ Break cirkulen med guard
observeEvent(app_state$events$A, {
  if (app_state$processing) return()  # Guard
  app_state$processing <- TRUE
  emit$B()
  app_state$processing <- FALSE
})
```

**Debug:**
```r
# Tilføj logging
log_debug("[REACTIVE_CHAIN]", "Event A triggered")
log_debug("[REACTIVE_CHAIN]", "Event B emitted")
# Hvis du ser gentagne messages = infinite loop
```

#### Problem: Race Condition

**Symptom:**
* Inkonsistent state
* Forskellige resultater når der klikkes hurtigt
* Data mismatch mellem UI og state

**Årsag:**
```r
# ❌ Concurrent updates
observeEvent(input$upload, {
  app_state$data <- new_data
  emit$data_updated()
})

observeEvent(app_state$events$data_updated, {
  # Hvis denne reader app_state$data før den er complete
  process_data(app_state$data)
})
```

**Løsning:** Se SHINY_ADVANCED_PATTERNS.md - Hybrid Anti-Race Strategy

#### Problem: State Inconsistency

**Symptom:**
* `app_state$data$current` ≠ `app_state$data$displayed`
* Kolonne mappings mangler for nogle kolonner

**Debug:**
```r
# Inspicer fuld state
str(app_state)

# Verificer antagelser
stopifnot(
  length(app_state$columns$mappings) > 0,
  !is.null(app_state$columns$mappings$x_column)
)

# Trace state mutations
log_info("[STATE]", "State updated",
  details = list(
    current_data_rows = nrow(app_state$data$current_data),
    mappings = names(app_state$columns$mappings)
  ))
```

### 2.2 Performance Issues

#### Problem: Memory Leak

**Symptom:**
* RAM stiger over tid
* App bliver langsomt efter timer
* Browser bruger > 500MB

**Årsag:**
```r
# ❌ Objects ikke frigivet ved session end
observeEvent(input$process, {
  huge_data <- load_all_data()  # 100MB
  # Aldrig frigivet!
})
```

**Løsning:**
```r
# ✅ Cleanup ved session end
session$onSessionEnded(function() {
  rm(huge_data, envir = globalenv())
  gc()
})

# ✅ Eller brug reactive med cleanup
large_dataset <- reactive({
  on.exit(gc())  # Cleanup når reactive flusher
  load_data()
})
```

**Debug:**
```r
# Profvis hele session
profvis::profvis({
  runApp()
})

# Eller brug memory profiling
pryr::mem_used()
```

#### Problem: Slow Reactives

**Symptom:**
* UI responder langsomt
* Klik på knap viser delay

**Årsag:**
```r
# ❌ Kompleks beregning uden debounce
observeEvent(input$search_text, {
  slow_search(input$search_text)  # Kan tage 5s
})
```

**Løsning:**
```r
# ✅ Debounce input (UI level)
textInput("search_text", debounce = 800)

# ✅ Eller brug reactive() med debounce
search_results <- eventReactive(
  input$search_button,  # Click, not text input
  { slow_search(input$search_text) }
)

# ✅ Eller background job
observeEvent(input$process_big_file, {
  promises::future_promise({
    heavy_computation()
  }) %...>% {
    show_results()
  }
})
```

#### Problem: UI Blocking

**Symptom:**
* UI frysed mens operation kører
* Kan ikke scrolle eller interagere

**Løsning:**
```r
# ✅ Background job
observeEvent(input$export, {
  future::future({
    write_excel(data, file)
  }) %...>% {
    showNotification("Eksporteret!")
  }
})
```

### 2.3 Data Issues

#### Problem: CSV Parsing Errors

**Symptom:**
* Filer uploader men viser fejl
* Kolonner mislabelered
* Encoding problemer (æøå vises forkert)

**Debug:**
```r
# Læs problemer
readr::read_csv("file.csv") %>%
  readr::problems()  # Vis parsing errors

# Eksplicit specify encoding
readr::read_csv("file.csv", locale = readr::locale(encoding = "UTF-8"))

# Tjek delimiter
data.table::fread("file.csv", sep = "auto")
```

#### Problem: Missing Values / NA

**Symptom:**
* Nedenstørrelse efter upload
* Chart viser færre punkter end forventet

**Debug:**
```r
# Tjek NA pattern
colSums(is.na(data))
data[rowSums(is.na(data)) > 0, ]

# Eksplicit NA-håndtering
data <- data %>%
  dplyr::filter(!is.na(value)) %>%
  tidyr::fill(x_column, .direction = "down")
```

#### Problem: Type Conversion Errors

**Symptom:**
* "Cannot add object of class character" fejl
* Numeriske kolonner bliver behandlet som tekst

**Debug:**
```r
# Tjek typer
str(data)
typeof(data$value)

# Eksplicit col_types
readr::read_csv("file.csv",
  col_types = readr::cols(
    date = readr::col_date(),
    value = readr::col_double()
  )
)
```

---

## 3) Debugging Tools & Commands

### 3.1 Logging & Inspection

```r
# ✅ Struktureret logging
log_debug("[MODULE_NAME]", "Beskrivelse",
  details = list(var = value, count = nrow(data)))

# Inspicer objekter
str(obj)
summary(obj)
head(obj)
tail(obj)

# Verificer antagelser
stopifnot(
  nrow(data) > 0,
  all(c("x", "y") %in% names(data)),
  is.numeric(data$value)
)
```

### 3.2 Profiling

```r
# Performance profiling
profvis::profvis({
  source('global.R')
  runApp()
})

# Benchmark specific operation
bench::mark(
  slow_function(),
  fast_function(),
  iterations = 10
)

# Memory profiling
pryr::mem_used()
pryr::object_size(large_object)
```

### 3.3 Interactive Debugging

```r
# Pause execution
browser()  # Or use RStudio breakpoints

# Step through
n          # Next line
s          # Step into function
f          # Finish function
c          # Continue
Q          # Quit debugging

# Inspect in debugger
print(variable)
ls()       # What's in environment?
```

### 3.4 Unit Tests for Debugging

```r
# Isolér fejl med test
test_that("column detection handles NA", {
  data <- data.frame(x = c(1, 2, NA), y = c("a", "b", "c"))
  result <- detect_columns(data)
  expect_equal(result$x, "numeric")
  expect_equal(result$y, "character")
})

# Run single test
testthat::test_file("tests/testthat/test-specific.R")
```

---

## 4) Known Issues & Workarounds

### 4.1 Where to Document

File: `docs/KNOWN_ISSUES.md`

Template:
```markdown
### Issue: [Kort titulo]

**Symptom:** Hvad brugeren ser

**Root cause:** Hvad er problemet

**Workaround:** Midlertidig løsning

**Fixed in:** Version X.Y.Z (eller "Pending")

**References:** ADR-001, PR#123
```

### 4.2 Reporting to maintainer

Hvis problem skyldes ekstern pakke (BFHcharts, BFHtheme):

```
1. Documenter issue i docs/KNOWN_ISSUES.md
2. Create GitHub issue med minimal reproducer
3. Tag maintainer: @username
4. Reference ekstern repo: BFHcharts/issue/123
5. Implementér workaround i SPCify (mark as temporary)
```

---

## 5) Escalation Process

### 5.1 When to Escalate

**Escalate to BFHcharts if:**
- Core chart rendering bugs
- Statistiske beregningsfejl
- Manglende chart types eller features
- BFHcharts API limitations
- Performance issues i BFHcharts algorithms

**Handle in SPCify if:**
- Parameter mapping (qicharts2 → BFHcharts)
- UI integration og Shiny reaktivitet
- Data preprocessing og validering
- Fejlbeskeder og dansk lokalisering
- SPCify-specifik caching

### 5.2 Escalation Template

```
## Escalation to BFHcharts

**Summary:** [Kort beskrivelse]

**Issue in SPCify:** docs/KNOWN_ISSUES.md#123

**MRE:**
[Minimal reproducer showing problem]

**Expected behavior:**
[Hvad skulle ske]

**Actual behavior:**
[Hvad sker]

**Suggested fix:**
[Hvis du har idé]

**Workaround in SPCify:**
[Midlertidig løsning]
```

---

## 6) Best Practices

### 6.1 Proactive Debugging

```r
# ✅ Debug-mode flag
if (isTRUE(getOption("spc.debug", FALSE))) {
  log_debug("[DEBUG]", "Verbose logging enabled")
}

# ✅ Test edge cases
test_that("handles empty data", { ... })
test_that("handles all NA column", { ... })
test_that("handles large dataset", { ... })
```

### 6.2 Documentation

**Alle bugs skal dokumenteres med:**
- [ ] MRE (Minimal Reproducible Example)
- [ ] Log output
- [ ] Stack trace (hvis relevant)
- [ ] Environment info (R version, package versions)

### 6.3 Prevention

```r
# ✅ Input validation
validate_data <- function(data) {
  stopifnot(
    is.data.frame(data),
    nrow(data) > 0,
    all(c("required_col") %in% names(data))
  )
}

# ✅ Explicit error messages
if (is.null(data)) {
  stop("Data must be loaded before processing", call. = FALSE)
}
```

---

**Sidst opdateret:** 2025-10-21
**Del af:** ~/.claude/ global configuration system
