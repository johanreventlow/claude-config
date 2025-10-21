# Observability Standards

Standarder for logging, monitoring og observability i R-baserede applikationer.

---

## 1) Logging Standards

### 1.1 Log Levels

**Standardiserede log levels:**

| Level | Når brug | Eksempel |
|-------|----------|----------|
| **DEBUG** | Detaljeret diagnostisk info | "User clicked button X with parameters: {...}" |
| **INFO** | Generel information om app flow | "App started successfully", "User logged in" |
| **WARN** | Potentielle problemer (ikke kritiske) | "API response slow (>2s)", "Cache miss" |
| **ERROR** | Fejl der kræver attention | "Database connection failed", "File not found" |
| **FATAL** | Kritiske fejl (app kan ikke fortsætte) | "Out of memory", "Critical dependency missing" |

### 1.2 Structured Logging

**Brug `logger` package for struktureret logging:**

```r
library(logger)

# Setup logging
log_threshold(INFO)  # Set minimum level
log_appender(appender_file("logs/app.log"))  # Log til fil

# Basic logging
log_info("User action", user = "john", action = "data_upload")
log_error("Database connection failed",
  host = Sys.getenv("DB_HOST"),
  error = e$message)

# JSON format (best for production)
log_appender(appender_file("logs/app.json",
  layout = layout_json()))
```

**Log output (JSON):**
```json
{
  "time": "2025-10-21T10:30:45Z",
  "level": "INFO",
  "message": "User action",
  "user": "john",
  "action": "data_upload",
  "session_id": "abc123"
}
```

### 1.3 Logging Configuration

**Environment-specific logging:**

```r
# R/logging_setup.R
setup_logging <- function() {
  env <- Sys.getenv("APP_ENV", "development")

  if (env == "production") {
    # Production: JSON format, INFO level
    log_threshold(INFO)
    log_appender(appender_file("logs/app.json", layout = layout_json()))
  } else if (env == "development") {
    # Development: Console, DEBUG level
    log_threshold(DEBUG)
    log_appender(appender_console)
  }

  log_info("Logging configured for environment: {env}")
}

# Kald i app startup
setup_logging()
```

### 1.4 Sensitive Data Filtering

**Filtrer sensitive data fra logs:**

```r
# ❌ FORKERT: Logger password
log_info("User login attempt",
  username = username,
  password = password)  # ALDRIG log passwords!

# ✅ KORREKT: Filtrer sensitive data
log_safe <- function(message, ..., .sensitive = c()) {
  args <- list(...)

  # Filtrer sensitive fields
  for (field in .sensitive) {
    if (field %in% names(args)) {
      args[[field]] <- "[REDACTED]"
    }
  }

  do.call(log_info, c(list(message), args))
}

# Brug
log_safe("User login attempt",
  username = username,
  password = password,
  .sensitive = c("password"))
# Output: username=john, password=[REDACTED]
```

### 1.5 Contextual Logging (Shiny)

**Tilføj session context til alle logs:**

```r
# R/utils_logging.R
create_session_logger <- function(session) {
  session_id <- session$token

  list(
    info = function(message, ...) {
      log_info(message, session_id = session_id, ...)
    },
    warn = function(message, ...) {
      log_warn(message, session_id = session_id, ...)
    },
    error = function(message, ...) {
      log_error(message, session_id = session_id, ...)
    }
  )
}

# I server function
server <- function(input, output, session) {
  logger <- create_session_logger(session)

  observeEvent(input$upload, {
    logger$info("File uploaded", filename = input$upload$name)
  })
}
```

---

## 2) Error Tracking

### 2.1 Sentry Integration

**Setup Sentry for automatic error reporting:**

```r
# Install package
# install.packages("sentryR")

library(sentryR)

# Configure Sentry (i global.R eller app startup)
sentry_configure(
  dsn = Sys.getenv("SENTRY_DSN"),
  environment = Sys.getenv("APP_ENV", "development"),
  release = packageVersion("myapp")
)

# Wrap reactive code
observeEvent(input$process, {
  sentry_capture({
    # Din kode her
    result <- process_data(input$data)
    output$result <- renderTable(result)
  })
})
```

**Manual error reporting:**

```r
# Report custom error
sentry_capture_exception(
  error = e,
  extra = list(
    user_id = user_id,
    data_size = nrow(data),
    operation = "data_processing"
  )
)
```

### 2.2 Error Context

**Capture meaningful context ved fejl:**

```r
# R/error_handling.R
safe_operation <- function(operation_name, code,
                          context = list(),
                          session = NULL) {
  tryCatch({
    code
  }, error = function(e) {
    # Log error med context
    log_error(
      paste0(operation_name, " failed"),
      error_message = e$message,
      stack_trace = paste(sys.calls(), collapse = "\n"),
      context = context,
      session_id = if (!is.null(session)) session$token else NA
    )

    # Report til Sentry
    if (Sys.getenv("APP_ENV") == "production") {
      sentry_capture_exception(e, extra = context)
    }

    # User-facing notification
    if (!is.null(session)) {
      showNotification(
        "En fejl opstod. Support er blevet notificeret.",
        type = "error",
        session = session
      )
    }

    return(NULL)
  })
}

# Brug
observeEvent(input$process, {
  result <- safe_operation(
    "Data processing",
    {
      process_data(input$file)
    },
    context = list(
      filename = input$file$name,
      filesize = input$file$size,
      user = session$user
    ),
    session = session
  )
})
```

---

## 3) Metrics & Performance Monitoring

### 3.1 Application Metrics

**Track key metrics:**

```r
# R/metrics.R
library(prometheus)  # Eller custom løsning

# Definer metrics
metrics <- list(
  requests_total = counter("http_requests_total", "Total HTTP requests"),
  request_duration = histogram("http_request_duration_seconds", "Request duration"),
  active_users = gauge("active_users", "Current active users"),
  data_processing_time = histogram("data_processing_seconds", "Data processing time")
)

# Increment counter
observeEvent(input$submit, {
  metrics$requests_total$inc()

  start_time <- Sys.time()
  result <- process_data()
  duration <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

  metrics$data_processing_time$observe(duration)
})
```

### 3.2 Performance Profiling

**Profil kritiske operationer:**

```r
# Brug tictoc til simple benchmarks
library(tictoc)

observeEvent(input$heavy_computation, {
  tic("Heavy computation")
  result <- complex_calculation()
  elapsed <- toc(quiet = TRUE)

  log_info("Computation completed",
    duration_seconds = elapsed$toc - elapsed$tic)
})

# Eller profvis til detaljeret profiling
if (Sys.getenv("PROFILE_ENABLED", "false") == "true") {
  profvis::profvis({
    runApp()
  })
}
```

### 3.3 Resource Usage Monitoring

```r
# Monitor memory usage
library(pryr)

log_memory_usage <- function() {
  mem_used <- pryr::mem_used()
  log_info("Memory usage",
    bytes = mem_used,
    mb = round(mem_used / 1024^2, 2))
}

# Periodisk check
observe({
  invalidateLater(60000)  # Hver minut
  log_memory_usage()
})
```

---

## 4) Health Checks

### 4.1 Health Check Implementation

**Basic health check:**

```r
# R/health_check.R
health_check <- function() {
  checks <- list(
    app = check_app_status(),
    database = check_database(),
    cache = check_cache(),
    external_api = check_external_dependencies()
  )

  overall_healthy <- all(sapply(checks, `[[`, "healthy"))

  list(
    status = if (overall_healthy) "healthy" else "unhealthy",
    timestamp = Sys.time(),
    checks = checks
  )
}

check_database <- function() {
  tryCatch({
    con <- get_db_connection()
    result <- DBI::dbGetQuery(con, "SELECT 1")
    DBI::dbDisconnect(con)

    list(healthy = TRUE, message = "Database connection OK")
  }, error = function(e) {
    list(healthy = FALSE, message = e$message)
  })
}

check_cache <- function() {
  # Check Redis, memcached, etc.
  list(healthy = TRUE, message = "Cache OK")
}

check_external_dependencies <- function() {
  # Check external APIs
  api_up <- tryCatch({
    response <- httr::GET("https://api.example.com/health", timeout = 5)
    httr::status_code(response) == 200
  }, error = function(e) FALSE)

  list(
    healthy = api_up,
    message = if (api_up) "External API reachable" else "External API down"
  )
}
```

### 4.2 Expose Health Endpoint

**For Plumber API:**

```r
#* Health check endpoint
#* @get /health
function(req, res) {
  health <- health_check()

  if (health$status == "unhealthy") {
    res$status <- 503  # Service Unavailable
  }

  return(health)
}
```

**For Shiny (via Plumber sidecar):**

```r
# Separate plumber.R fil
library(plumber)

pr() %>%
  pr_get("/health", function() {
    health_check()
  }) %>%
  pr_run(port = 8080)
```

---

## 5) Alerting

### 5.1 Alert Thresholds

**Definer alert thresholds:**

```r
# R/alerting.R
ALERT_THRESHOLDS <- list(
  error_rate = 0.05,        # 5% error rate
  response_time_p95 = 2.0,  # 2 seconds
  memory_usage_pct = 0.90,  # 90% memory
  disk_usage_pct = 0.85     # 85% disk
)

check_alert_conditions <- function() {
  # Check error rate
  error_rate <- calculate_error_rate()
  if (error_rate > ALERT_THRESHOLDS$error_rate) {
    send_alert(
      severity = "warning",
      message = sprintf("Error rate elevated: %.2f%%", error_rate * 100)
    )
  }

  # Check memory
  mem_pct <- get_memory_usage_percent()
  if (mem_pct > ALERT_THRESHOLDS$memory_usage_pct) {
    send_alert(
      severity = "critical",
      message = sprintf("Memory usage critical: %.1f%%", mem_pct * 100)
    )
  }
}
```

### 5.2 Alert Channels

**Send alerts via forskellige channels:**

```r
send_alert <- function(severity, message, channel = "slack") {
  log_error("ALERT", severity = severity, message = message)

  switch(channel,
    "slack" = send_slack_alert(severity, message),
    "email" = send_email_alert(severity, message),
    "pagerduty" = send_pagerduty_alert(severity, message)
  )
}

send_slack_alert <- function(severity, message) {
  library(slackr)

  color <- switch(severity,
    "critical" = "danger",
    "warning" = "warning",
    "info" = "good"
  )

  slackr::slackr_msg(
    text = message,
    channel = Sys.getenv("SLACK_ALERT_CHANNEL"),
    username = "AppMonitor",
    icon_emoji = ":warning:",
    attachments = list(list(color = color))
  )
}
```

---

## 6) Log Aggregation & Analysis

### 6.1 Centralized Logging (ELK Stack)

**Ship logs til Elasticsearch:**

```r
# Brug logger med custom appender
library(logger)
library(elastic)

# Elasticsearch appender
appender_elasticsearch <- function(index = "app-logs") {
  function(level, msg, ...) {
    doc <- list(
      timestamp = Sys.time(),
      level = level,
      message = msg,
      ...
    )

    elastic::docs_create(
      index = index,
      body = doc,
      conn = connect()
    )
  }
}

# Setup
log_appender(appender_elasticsearch())
```

### 6.2 Log Rotation

**Rotate log files for at undgå at fylde disk:**

```r
# Brug logger med rotation
library(logger)

log_appender(
  appender_file(
    file = "logs/app.log",
    max_lines = 100000,    # Max lines før rotation
    max_bytes = 10485760,  # 10 MB
    max_files = 5          # Keep 5 rotated files
  )
)
```

---

## 7) Dashboards & Visualization

### 7.1 Logging Dashboard (Shiny)

**Simple admin dashboard:**

```r
# R/mod_admin_logs.R
admin_logs_ui <- function(id) {
  ns <- NS(id)
  tagList(
    dateRangeInput(ns("date_range"), "Date Range"),
    selectInput(ns("log_level"), "Log Level",
      choices = c("All", "ERROR", "WARN", "INFO")),
    DTOutput(ns("log_table"))
  )
}

admin_logs_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    logs <- reactive({
      # Read logs from file or database
      parse_log_file("logs/app.json") %>%
        filter(
          time >= input$date_range[1],
          time <= input$date_range[2]
        )
    })

    output$log_table <- renderDT({
      data <- logs()
      if (input$log_level != "All") {
        data <- filter(data, level == input$log_level)
      }
      datatable(data)
    })
  })
}
```

### 7.2 Metrics Dashboard

**Visualiser metrics med Grafana eller custom Shiny dashboard:**

```r
# Eksporter metrics til Prometheus format
library(prometheus)

# Expose metrics endpoint
#* @get /metrics
function() {
  metrics$requests_total$collect()
  metrics$request_duration$collect()
  # Return i Prometheus format
}
```

---

## 8) Best Practices Checklist

### Development
- [ ] Logger alle væsentlige events (start, stop, errors)
- [ ] Brug struktureret logging (JSON format)
- [ ] Test logging i lokalt miljø
- [ ] Inkluder context i log messages

### Production
- [ ] Centraliseret log aggregation (ELK, Splunk, etc.)
- [ ] Error tracking aktiveret (Sentry, Bugsnag)
- [ ] Health check endpoints eksponeret
- [ ] Metrics collection implementeret
- [ ] Alerts konfigureret for kritiske metrics
- [ ] Log rotation aktiveret
- [ ] Sensitive data filtreret fra logs

### Monitoring
- [ ] Dashboard til realtime metrics
- [ ] Alert notifications til on-call team
- [ ] Regular review af error rates og trends
- [ ] Performance baseline etableret

---

## 9) Example: Complete Observability Setup

```r
# global.R
library(logger)
library(sentryR)

# 1. Setup logging
setup_logging <- function() {
  env <- Sys.getenv("APP_ENV", "development")

  log_threshold(if (env == "production") INFO else DEBUG)
  log_appender(appender_file("logs/app.json", layout = layout_json()))
  log_info("Application starting", environment = env)
}

# 2. Setup error tracking
setup_sentry <- function() {
  if (Sys.getenv("APP_ENV") == "production") {
    sentry_configure(
      dsn = Sys.getenv("SENTRY_DSN"),
      environment = Sys.getenv("APP_ENV"),
      release = as.character(packageVersion("myapp"))
    )
    log_info("Sentry error tracking enabled")
  }
}

# 3. Startup
setup_logging()
setup_sentry()

# server.R
server <- function(input, output, session) {
  logger <- create_session_logger(session)

  # Log session start
  logger$info("Session started", user_agent = session$request$HTTP_USER_AGENT)

  # Monitored operation
  observeEvent(input$process, {
    result <- safe_operation(
      "Data processing",
      {
        tic("process_data")
        data <- process_data(input$file)
        elapsed <- toc(quiet = TRUE)

        logger$info("Data processed",
          rows = nrow(data),
          duration_ms = (elapsed$toc - elapsed$tic) * 1000)

        data
      },
      context = list(filename = input$file$name),
      session = session
    )
  })

  # Cleanup
  session$onSessionEnded(function() {
    logger$info("Session ended")
  })
}
```

---

**Sidst opdateret:** 2025-10-21
**Del af:** ~/.claude/ global configuration system
