# Observability Standards

Standarder for logging, monitoring og observability.

---

## Log Levels

| Level | Når brug | Eksempel |
|-------|----------|----------|
| DEBUG | Diagnostisk info | "User clicked X" |
| INFO | App flow | "App started", "User logged in" |
| WARN | Ikke-kritiske issues | "API slow (>2s)", "Cache miss" |
| ERROR | Kræver attention | "DB connection failed" |
| FATAL | App kan ikke fortsætte | "Out of memory" |

---

## Structured Logging

**Setup:**
```r
library(logger)
log_threshold(if (prod) INFO else DEBUG)
log_appender(appender_file("logs/app.json", layout = layout_json()))
log_info("msg", key = value, session_id = session$token)
```

**JSON output:**
```json
{
  "time": "2025-10-21T10:30:45Z",
  "level": "INFO",
  "message": "User action",
  "user": "john",
  "session_id": "abc123"
}
```

---

## Sensitive Data Filtering

**Filter passwords, tokens, keys:**
```r
log_safe <- function(message, ..., .sensitive = c()) {
  args <- list(...)
  for (field in .sensitive) {
    if (field %in% names(args)) args[[field]] <- "[REDACTED]"
  }
  do.call(log_info, c(list(message), args))
}

log_safe("Login attempt", username = username, password = password,
  .sensitive = c("password"))
# Output: username=john, password=[REDACTED]
```

---

## Contextual Logging (Shiny)

```r
create_session_logger <- function(session) {
  session_id <- session$token
  list(
    info = function(msg, ...) log_info(msg, session_id = session_id, ...),
    error = function(msg, ...) log_error(msg, session_id = session_id, ...)
  )
}

# I server
server <- function(input, output, session) {
  logger <- create_session_logger(session)
  logger$info("Session started")
}
```

---

## Error Tracking

**Sentry integration:**
```r
library(sentryR)
sentry_configure(
  dsn = Sys.getenv("SENTRY_DSN"),
  environment = Sys.getenv("APP_ENV"),
  release = packageVersion("myapp")
)

sentry_capture({
  result <- process_data()
})
```

---

## Metrics & Performance

**Track key metrics:**
```r
# Metrics
metrics <- list(
  requests_total = counter("http_requests_total"),
  request_duration = histogram("http_request_duration_seconds")
)

# Observe
observeEvent(input$submit, {
  metrics$requests_total$inc()
  start <- Sys.time()
  result <- process_data()
  duration <- as.numeric(difftime(Sys.time(), start, units = "secs"))
  metrics$request_duration$observe(duration)
})
```

**Performance profiling:**
```r
library(tictoc)
tic("Heavy computation")
result <- complex_calculation()
elapsed <- toc(quiet = TRUE)
log_info("Computation", duration_sec = elapsed$toc - elapsed$tic)
```

---

## Health Checks

```r
health_check <- function() {
  checks <- list(
    app = check_app_status(),
    database = check_database(),
    cache = check_cache()
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
    DBI::dbGetQuery(con, "SELECT 1")
    DBI::dbDisconnect(con)
    list(healthy = TRUE, message = "DB OK")
  }, error = function(e) {
    list(healthy = FALSE, message = e$message)
  })
}
```

---

## Alerting

**Alert thresholds:**
```r
ALERT_THRESHOLDS <- list(
  error_rate = 0.05,        # 5%
  response_time_p95 = 2.0,  # 2 sec
  memory_usage_pct = 0.90   # 90%
)

check_alert_conditions <- function() {
  error_rate <- calculate_error_rate()
  if (error_rate > ALERT_THRESHOLDS$error_rate) {
    send_alert(severity = "warning",
      message = sprintf("Error rate: %.2f%%", error_rate * 100))
  }
}
```

**Send alerts:**
```r
send_slack_alert <- function(severity, message) {
  library(slackr)
  color <- switch(severity,
    "critical" = "danger",
    "warning" = "warning",
    "info" = "good"
  )
  slackr::slackr_msg(text = message,
    channel = Sys.getenv("SLACK_ALERT_CHANNEL"),
    attachments = list(list(color = color)))
}
```

---

## Production Checklist

- [ ] Structured logging (JSON)
- [ ] Centralized aggregation (ELK, Splunk)
- [ ] Error tracking (Sentry)
- [ ] Health check endpoints
- [ ] Metrics collection
- [ ] Alerts configured
- [ ] Log rotation enabled
- [ ] PII filtered fra logs

---

**Sidst opdateret:** 2025-10-21
