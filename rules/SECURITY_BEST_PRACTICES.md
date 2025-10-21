# Security Best Practices

Security standards for sikker R- og Shiny-udvikling.

---

## Secret Management

**OBLIGATORISK:** Secrets i env vars ALDRIG i kode

```r
# ❌ FORKERT
api_key <- "sk-abc123xyz456"

# ✅ KORREKT
api_key <- Sys.getenv("API_KEY")
```

**Lokal udvikling:**
- `.Renviron` for secrets (git ignored)
- `.Renviron.example` committed (placeholders)

**Production:**
- RStudio Connect: UI → Content → Vars
- shinyapps.io: Dashboard env vars
- Docker: `env_file: .env` (git ignored)
- Vault: HashiCorp Vault, AWS Secrets Manager

**Types:** API keys, passwords, tokens, certificates, encryption keys

---

## Input Validation

**File upload:**
```r
observeEvent(input$file, {
  req(input$file)
  ext <- tools::file_ext(input$file$name)
  validate(need(ext %in% c("csv", "xlsx"), "Kun CSV/XLSX"))
  validate(need(input$file$size < 50*1024^2, "Max 50MB"))
})
```

**SQL injection prevention:**
```r
# ✅ Parameterized queries
dbGetQuery(con, "SELECT * FROM users WHERE name = ?",
  params = list(input$search_term))

# ✅ dplyr (auto-parameterized)
tbl(con, "users") |> filter(name == !!input$search_term)

# ❌ String concatenation
paste0("SELECT * FROM users WHERE name = '", input$search_term, "'")
```

**Path traversal prevention:**
```r
validate_safe_path <- function(base_dir, user_path) {
  full_path <- normalizePath(file.path(base_dir, user_path), mustWork = FALSE)
  base_normalized <- normalizePath(base_dir, mustWork = TRUE)
  if (!startsWith(full_path, base_normalized)) {
    stop("Invalid path", call. = FALSE)
  }
  full_path
}

safe_path <- validate_safe_path("data/", input$filename)
data <- read.csv(safe_path)
```

**XSS prevention:**
```r
# ✅ Shiny auto-escaper
output$user_comment <- renderUI({
  tags$div(input$comment)
})

# ✅ Explicit escaping
HTML(htmltools::htmlEscape(input$comment))
```

---

## Authentication & Authorization

**Simple auth (shinymanager):**
```r
library(shinymanager)
ui <- secure_app(ui = dashboardPage(...))
server <- function(input, output, session) {
  res_auth <- secure_server(
    check_credentials = check_credentials("credentials.sqlite")
  )
}
```

**RBAC:**
```r
user_roles <- list(
  admin = c("read", "write", "delete"),
  editor = c("read", "write"),
  viewer = c("read")
)

has_permission <- function(user, permission) {
  permission %in% user_roles[[get_user_role(user)]]
}

output$admin_panel <- renderUI({
  req(has_permission(res_auth$user, "admin"))
  # Admin UI
})
```

---

## Secure Communication

**HTTPS only i production:**
- ✅ Alle prod apps over HTTPS
- ✅ Redirect HTTP → HTTPS
- ✅ HSTS headers

**API keys i headers:**
```r
# ✅ Header
httr::GET("https://api.example.com/data",
  add_headers(Authorization = paste("Bearer", Sys.getenv("API_KEY"))))

# ❌ URL
paste0("https://api.example.com/data?api_key=", api_key)
```

---

## Dependency Security

**Vulnerability scanning:**
```r
library(oysteR)
audit_results <- audit_installed_r_pkgs()
if (nrow(audit_results$vulnerabilities) > 0) {
  stop("Vulnerabilities detected!")
}
```

**Update strategy:**
```r
# Månedligt
renv::status()
renv::update()
```

---

## Data Protection

**PII anonymization:**
```r
log_user_action <- function(user_id, action) {
  hashed_id <- digest::digest(user_id, algo = "sha256")
  log_info("User action", user = hashed_id, action = action)
}
```

**Encryption (at rest):**
```r
library(sodium)
key <- sha256(charToRaw(Sys.getenv("ENCRYPTION_KEY")))
encrypted <- simple_encrypt(charToRaw("sensitive data"), key)
decrypted <- rawToChar(simple_decrypt(encrypted, key))
```

**In transit:** HTTPS/TLS altid, encrypted DB connections (SSL)

---

## Security Checklist

- [ ] Secrets i env vars (ikke kode)
- [ ] `.Renviron`/`.env` i `.gitignore`
- [ ] Input validated
- [ ] SQL parameterized
- [ ] Path traversal checks
- [ ] HTTPS i prod
- [ ] Auth implemented
- [ ] Packages scanned (`oysteR`)
- [ ] PII handled korrekt
- [ ] Error messages safe
- [ ] Logging filtrerer secrets

---

## Incident Response

**If secret leaked:**
1. **Revoke** straks
2. **Rotate** til ny
3. **Audit** logs
4. **Notify** stakeholders
5. **Post-mortem**

**If security breach:**
1. **Isoler** system
2. **Dokumentér** (logs, timeline)
3. **Notify** security team
4. **Patch** sårbarhed
5. **Audit** for lignende issues
6. **Post-mortem**

---

**Sidst opdateret:** 2025-10-21
