# Security Best Practices

Security standards og praktiske retningslinjer for sikker softwareudvikling i R, Shiny og relaterede teknologier.

---

## 1) Secret Management

### 1.1 Aldrig Commit Secrets

**OBLIGATORISK REGEL:** Secrets må **ALDRIG** committes til Git.

```
❌ FORKERT:
api_key <- "sk-abc123xyz456"  # Hardcoded secret
db_password <- "SuperSecret123"

✅ KORREKT:
api_key <- Sys.getenv("API_KEY")
db_password <- Sys.getenv("DB_PASSWORD")
```

**Typer af secrets:**
- API keys, tokens, passwords
- Database credentials
- Encryption keys
- OAuth client secrets
- SSH private keys
- Signing certificates

### 1.2 Lokal Udvikling: `.Renviron`

For lokal udvikling, brug `.Renviron` fil til at gemme secrets.

**Setup:**
```r
# Opret/rediger .Renviron fil
usethis::edit_r_environ(scope = "project")

# Tilføj secrets (én per linje)
API_KEY=sk-abc123xyz456
DB_PASSWORD=SuperSecret123
DB_HOST=localhost
DB_PORT=5432
```

**Vigtige regler:**
- ✅ Tilføj `.Renviron` til `.gitignore` (sker automatisk med `usethis`)
- ✅ Gem en `.Renviron.example` fil med placeholder-værdier til Git
- ✅ Dokumenter hvilke secrets der skal sættes i projekt README

**`.Renviron.example`:**
```bash
# Kopier denne fil til .Renviron og udfyld med rigtige værdier
API_KEY=your_api_key_here
DB_PASSWORD=your_db_password_here
DB_HOST=localhost
DB_PORT=5432
```

### 1.3 Production: Environment Variables

**Platform-specific guides:**

#### RStudio Connect
```r
# I app.R eller global.R
api_key <- Sys.getenv("API_KEY")

# Sæt environment variables i RStudio Connect UI:
# Content → Vars → Add Variable
```

#### shinyapps.io
```r
# Via rsconnect package
rsconnect::setAccountInfo(
  name = Sys.getenv("SHINYAPPS_ACCOUNT"),
  token = Sys.getenv("SHINYAPPS_TOKEN"),
  secret = Sys.getenv("SHINYAPPS_SECRET")
)

# Environment variables sættes i shinyapps.io dashboard
```

#### Docker
```dockerfile
# I docker-compose.yml
services:
  shiny-app:
    environment:
      - API_KEY=${API_KEY}
      - DB_PASSWORD=${DB_PASSWORD}
    env_file:
      - .env  # Aldrig commit .env filen!
```

### 1.4 Vault Solutions (Avanceret)

For enterprise setup med mange secrets:

- **HashiCorp Vault**: Centraliseret secret management
- **AWS Secrets Manager**: Til AWS-hosted apps
- **Azure Key Vault**: Til Azure-hosted apps

```r
# Eksempel: Hent fra Vault
library(vaultr)
vault <- vaultr::vault_client(addr = Sys.getenv("VAULT_ADDR"))
vault$auth$token(Sys.getenv("VAULT_TOKEN"))
secrets <- vault$secrets$kv2$get("myapp/prod")
```

---

## 2) Input Validation & Sanitization

### 2.1 Shiny Input Validation

**Altid valider bruger-input** før brug i queries, file operations eller beregninger.

```r
# ✅ KORREKT: Valider input
observeEvent(input$process_data, {
  # Brug shiny::req() til at kræve input
  req(input$file_upload)

  # Valider filtype
  validate(
    need(
      tools::file_ext(input$file_upload$name) %in% c("csv", "xlsx"),
      "Kun CSV eller Excel filer er tilladt"
    )
  )

  # Valider filstørrelse (max 50MB)
  validate(
    need(
      input$file_upload$size < 50 * 1024^2,
      "Filen er for stor (max 50MB)"
    )
  )

  # Process file...
})
```

### 2.2 SQL Injection Prevention

**Aldrig brug string concatenation** til at bygge SQL queries med bruger-input.

```r
# ❌ FORKERT: SQL Injection sårbar
user_input <- input$search_term
query <- paste0("SELECT * FROM users WHERE name = '", user_input, "'")
# Hvis user_input = "'; DROP TABLE users; --" så er du færdig!

# ✅ KORREKT: Brug parameterized queries
library(DBI)
con <- dbConnect(...)
query <- "SELECT * FROM users WHERE name = ?"
result <- dbGetQuery(con, query, params = list(input$search_term))
```

**Med `dplyr` og database backends:**
```r
# ✅ KORREKT: dplyr håndterer parameterisering
library(dplyr)
library(dbplyr)

users_tbl <- tbl(con, "users")
filtered <- users_tbl %>%
  filter(name == !!input$search_term)  # Sikkert
```

### 2.3 Path Traversal Prevention

**Valider file paths** for at forhindre adgang til filer uden for tilladte directories.

```r
# ❌ FORKERT: Path traversal sårbar
file_path <- paste0("data/", input$filename)
data <- read.csv(file_path)
# Hvis input$filename = "../../etc/passwd" kan du læse system filer!

# ✅ KORREKT: Valider at path er inden for tilladt directory
validate_safe_path <- function(base_dir, user_path) {
  # Normaliser paths
  full_path <- normalizePath(file.path(base_dir, user_path), mustWork = FALSE)
  base_normalized <- normalizePath(base_dir, mustWork = TRUE)

  # Tjek at full_path starter med base_dir
  if (!startsWith(full_path, base_normalized)) {
    stop("Invalid file path", call. = FALSE)
  }

  return(full_path)
}

# Brug
safe_path <- validate_safe_path("data/", input$filename)
data <- read.csv(safe_path)
```

### 2.4 XSS Prevention (Cross-Site Scripting)

**Escape HTML** når du viser bruger-genereret content.

```r
# ❌ FORKERT: XSS sårbar
output$user_comment <- renderUI({
  HTML(input$comment)  # Hvis comment indeholder <script>alert('XSS')</script>...
})

# ✅ KORREKT: Escape HTML
output$user_comment <- renderUI({
  tags$div(input$comment)  # Shiny escaper automatisk
})

# Eller eksplicit escaping
output$user_comment <- renderUI({
  HTML(htmltools::htmlEscape(input$comment))
})
```

---

## 3) Authentication & Authorization

### 3.1 Shiny Authentication Patterns

**Simple auth (basic protection):**

```r
# Brug shinymanager package
library(shinymanager)

# Wrap UI
ui <- secure_app(
  ui = dashboardPage(...),
  theme = "flatly"
)

# I server
server <- function(input, output, session) {
  # Check credentials
  res_auth <- secure_server(
    check_credentials = check_credentials("credentials.sqlite")
  )

  # Reactive til at få bruger info
  output$user_info <- renderText({
    paste("Logged in as:", res_auth$user)
  })
}
```

**Enterprise auth (SSO, OAuth):**

- **SAML/OAuth**: Brug platform-features (RStudio Connect, shinyapps.io)
- **Custom OAuth**: `googleAuthR`, `AzureAuth` packages

### 3.2 Session Management

**Best practices:**

```r
# Session timeout efter inaktivitet
session$onSessionEnded(function() {
  # Cleanup sensitive data
  rm(sensitive_data, envir = globalenv())
  gc()
})

# Auto-logout efter 30 minutter
observe({
  invalidateLater(30 * 60 * 1000)  # 30 min
  session$reload()
})
```

### 3.3 Role-Based Access Control (RBAC)

```r
# Definer roller og permissions
user_roles <- list(
  admin = c("read", "write", "delete", "admin"),
  editor = c("read", "write"),
  viewer = c("read")
)

# Check permissions
has_permission <- function(user, permission) {
  user_role <- get_user_role(user)
  permission %in% user_roles[[user_role]]
}

# Brug i UI
output$admin_panel <- renderUI({
  req(has_permission(res_auth$user, "admin"))
  # Admin UI...
})
```

---

## 4) Secure Communication

### 4.1 HTTPS Only

**OBLIGATORISK i produktion:**

- ✅ Alle production apps skal køre over HTTPS
- ✅ Redirect HTTP til HTTPS automatisk
- ✅ Brug HSTS (HTTP Strict Transport Security) headers

**Platform setup:**

- **RStudio Connect**: HTTPS konfigureres i admin panel
- **shinyapps.io**: HTTPS er automatisk enabled
- **Custom server**: Brug reverse proxy (nginx, Caddy) med Let's Encrypt

### 4.2 API Key Security

```r
# ❌ FORKERT: API key i URL
url <- paste0("https://api.example.com/data?api_key=", api_key)

# ✅ KORREKT: API key i header
library(httr)
response <- GET(
  "https://api.example.com/data",
  add_headers(Authorization = paste("Bearer", Sys.getenv("API_KEY")))
)
```

---

## 5) Dependency Security

### 5.1 Package Vulnerability Scanning

**Check for known vulnerabilities:**

```r
# Brug oysteR package til security audit
library(oysteR)

# Scan project dependencies
audit_results <- audit_installed_r_pkgs()
audit_results

# I CI/CD pipeline
if (nrow(audit_results$vulnerabilities) > 0) {
  stop("Security vulnerabilities detected!")
}
```

### 5.2 Keep Packages Updated

**Update strategy:**

```r
# Check for updates regelmæssigt (månedligt)
renv::status()
renv::update()

# Check security advisories
# https://github.com/r-hub/safepkgs
```

**I `.gitignore`:**
```
renv/library/
renv/local/
renv/cellar/
```

---

## 6) Data Protection

### 6.1 Personally Identifiable Information (PII)

**Minimér PII exposure:**

```r
# ✅ Anonymiser data før logging
log_user_action <- function(user_id, action) {
  # Hash user_id frem for at bruge raw value
  hashed_id <- digest::digest(user_id, algo = "sha256")
  log_info("User action", user = hashed_id, action = action)
}

# ✅ Filtrer PII fra error messages
tryCatch({
  process_data(user_email = "john@example.com")
}, error = function(e) {
  # Ikke log user_email direkte
  log_error("Data processing failed", error = e$message)
})
```

### 6.2 Data Encryption

**At rest:**
```r
# Encrypt sensitive data før gemning
library(sodium)

# Generer nøgle (gem sikkert!)
key <- sha256(charToRaw(Sys.getenv("ENCRYPTION_KEY")))

# Encrypt
plaintext <- "sensitive data"
encrypted <- simple_encrypt(charToRaw(plaintext), key)

# Decrypt
decrypted <- rawToChar(simple_decrypt(encrypted, key))
```

**In transit:**
- ✅ Altid brug HTTPS/TLS
- ✅ Brug encrypted database connections (SSL)

---

## 7) Security Checklist

### Pre-Deployment Checklist

- [ ] Alle secrets i environment variables (ikke i kode)
- [ ] `.Renviron` og `.env` filer i `.gitignore`
- [ ] Input validation på alle bruger-inputs
- [ ] SQL queries bruger parameterized queries
- [ ] File paths valideres mod path traversal
- [ ] HTTPS enabled i produktion
- [ ] Authentication implementeret (hvis påkrævet)
- [ ] Package vulnerabilities scannet
- [ ] PII håndteres korrekt
- [ ] Error messages afslører ikke sensitive data
- [ ] Session management konfigureret
- [ ] Logging inkluderer ikke secrets

### Security Review Process

**Ved code review:**
1. Scan for hardcoded secrets (`grep -r "password\|api_key\|secret" R/`)
2. Verificer input validation på nye endpoints/features
3. Tjek at nye dependencies er fra trusted sources
4. Review error handling (undgår sensitive data leakage?)

---

## 8) Incident Response

### Hvis Secret Leaked

**Umiddelbare handlinger:**

1. **Revoke** den leaked secret straks
2. **Rotate** til ny secret
3. **Audit** logs for uautoriseret brug
4. **Notify** relevante stakeholders
5. **Post-mortem**: Hvordan skete det? Hvordan forhindres det?

### Hvis Security Breach

1. **Isoler** påvirket system
2. **Dokumenter** alt (logs, timeline)
3. **Notify** security team/admin
4. **Patch** sårbarheden
5. **Audit** for andre lignende issues
6. **Post-mortem** og lessons learned

---

## 9) Security Resources

### Tools
- **oysteR**: R package vulnerability scanning
- **goodpractice**: Code quality og security checks
- **renv**: Dependency isolation
- **sodium**: Encryption i R
- **digest**: Hashing

### Learning
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [R Security Best Practices (R Consortium)](https://www.r-consortium.org/)
- [Secure Coding in R (Book)](https://bookdown.org/)

---

**Sidst opdateret:** 2025-10-21
**Del af:** ~/.claude/ global configuration system
