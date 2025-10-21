# Deployment Guide

Praktisk guide til deployment af R-baserede projekter til produktion.

---

## 1) Production Readiness Checklist

### Universal Checklist (Alle Projekttyper)

Før deployment til produktion, verificer:

- [ ] **Code Quality**
  - [ ] Alle tests passerer (`devtools::test()`)
  - [ ] Linting uden fejl (`lintr::lint_package()`)
  - [ ] Code coverage ≥ 80% (for kritiske komponenter)
  - [ ] Ingen hardcoded secrets (scan med `grep -r "password\|api_key" R/`)

- [ ] **Dependencies**
  - [ ] `renv.lock` er up-to-date (`renv::snapshot()`)
  - [ ] Alle dependencies er fra trusted sources
  - [ ] Security vulnerabilities scannet (`oysteR::audit_installed_r_pkgs()`)

- [ ] **Documentation**
  - [ ] `README.md` med installation og usage instructions
  - [ ] `NEWS.md` eller changelog opdateret (for packages)
  - [ ] API dokumentation komplet (for packages og APIs)

- [ ] **Configuration**
  - [ ] Secrets i environment variables (se `SECURITY_BEST_PRACTICES.md`)
  - [ ] Environment-specific config separeret (dev/test/prod)
  - [ ] `.Renviron.example` eller config template dokumenteret

- [ ] **Monitoring & Logging**
  - [ ] Logging implementeret (se `OBSERVABILITY_STANDARDS.md`)
  - [ ] Error tracking konfigureret
  - [ ] Health check endpoint (for apps/APIs)

- [ ] **Performance**
  - [ ] Performance testing gennemført
  - [ ] Caching implementeret hvor relevant
  - [ ] Database queries optimeret

---

## 2) Environment Management

### 2.1 Environment Separation

**Tre miljøer (minimum):**

| Environment | Formål | Deployment |
|------------|--------|------------|
| **Development** | Lokal udvikling | Lokalt, docker-compose |
| **Testing/Staging** | QA, integration tests | Separat server/instance |
| **Production** | Live brugere | Production server |

### 2.2 Environment-Specific Configuration

**Pattern: Config files per environment**

```
config/
├── config.yml           # Shared config
├── config_dev.yml       # Development overrides
├── config_test.yml      # Testing overrides
└── config_prod.yml      # Production overrides
```

**I R:**
```r
# R/config.R
get_config <- function() {
  env <- Sys.getenv("APP_ENV", "development")
  config_file <- switch(env,
    "production" = "config/config_prod.yml",
    "testing" = "config/config_test.yml",
    "config/config_dev.yml"
  )

  yaml::read_yaml(config_file)
}

# Brug
config <- get_config()
db_host <- config$database$host
```

**Eller brug `config` package:**
```r
library(config)

# config.yml
# default:
#   database:
#     host: localhost
# production:
#   database:
#     host: prod-db.example.com

# Hent config baseret på R_CONFIG_ACTIVE env var
db_config <- config::get("database")
```

---

## 3) Shiny App Deployment

### 3.1 RStudio Connect

**Deployment workflow:**

```r
# 1. Forbered app
renv::snapshot()  # Lock dependencies
devtools::test()  # Verify tests pass

# 2. Deploy via rsconnect
library(rsconnect)
deployApp(
  appDir = ".",
  appName = "my-shiny-app",
  account = "my-account",
  server = "connect.example.com"
)
```

**Environment variables i RStudio Connect:**
1. Log ind på RStudio Connect
2. Find din app → Settings → Vars
3. Tilføj secrets (API_KEY, DB_PASSWORD, etc.)
4. Restart app

**Rollback:**
```r
# List deployments
deployments()

# Rollback til tidligere version
rollbackDeployment(deploymentId = "12345")
```

### 3.2 shinyapps.io

**Deployment:**

```r
# Setup (kun én gang)
rsconnect::setAccountInfo(
  name = Sys.getenv("SHINYAPPS_ACCOUNT"),
  token = Sys.getenv("SHINYAPPS_TOKEN"),
  secret = Sys.getenv("SHINYAPPS_SECRET")
)

# Deploy
rsconnect::deployApp(
  appDir = ".",
  appName = "my-app",
  appTitle = "My Shiny App"
)
```

**Begrænsninger:**
- Max 1GB RAM (gratis tier)
- Begrænsede compute resources
- Shared infrastructure

**Best practices:**
- Brug `shinyapps.io` til prototyper og mindre apps
- Overvej RStudio Connect eller Docker til production

### 3.3 Docker Deployment

**Dockerfile for Shiny app:**

```dockerfile
FROM rocker/shiny-verse:4.3.2

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy renv files
COPY renv.lock renv.lock
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R

# Restore R packages
RUN R -e "renv::restore()"

# Copy app files
COPY . /app

# Expose Shiny port
EXPOSE 3838

# Run app
CMD ["R", "-e", "shiny::runApp('/app', host = '0.0.0.0', port = 3838)"]
```

**docker-compose.yml:**

```yaml
version: '3.8'

services:
  shiny-app:
    build: .
    ports:
      - "3838:3838"
    environment:
      - APP_ENV=production
      - API_KEY=${API_KEY}
      - DB_PASSWORD=${DB_PASSWORD}
    env_file:
      - .env  # Ikke commit denne fil!
    volumes:
      - ./logs:/app/logs
    restart: unless-stopped

  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

**Build og deploy:**

```bash
# Build image
docker build -t my-shiny-app:latest .

# Test lokalt
docker run -p 3838:3838 --env-file .env my-shiny-app:latest

# Deploy til server
docker compose up -d

# Check logs
docker compose logs -f shiny-app
```

---

## 4) R Package Deployment

### 4.1 Internal Package Repository

**Setup med `drat`:**

```r
# På repository server
library(drat)

# Opret repository (kun én gang)
drat::initRepo("~/R-packages")

# Tilføj package til repo
pkg_path <- "path/to/mypackage_1.0.0.tar.gz"
drat::insertPackage(pkg_path, "~/R-packages")

# Host via GitHub Pages eller intern server
```

**Brug fra andre projekter:**

```r
# Tilføj repository
options(repos = c(
  MyRepo = "https://my-company.github.io/R-packages",
  CRAN = "https://cloud.r-project.org"
))

# Install package
install.packages("mypackage")
```

### 4.2 GitHub Installation

**Via `remotes`:**

```r
# Public repo
remotes::install_github("username/mypackage")

# Private repo (kræver GitHub token)
remotes::install_github("username/mypackage",
  auth_token = Sys.getenv("GITHUB_PAT")
)

# Specific version/tag
remotes::install_github("username/mypackage@v1.0.0")
```

**Setup GitHub PAT:**

```r
# Opret PAT med usethis
usethis::create_github_token()

# Gem i .Renviron
usethis::edit_r_environ()
# Tilføj: GITHUB_PAT=ghp_xxxxxxxxxxxxx
```

### 4.3 CRAN Submission

**Pre-submission checklist:**

```r
# 1. Check package
devtools::check()

# 2. Check on multiple platforms
rhub::check_for_cran()

# 3. Check win-builder
devtools::check_win_devel()
devtools::check_win_release()

# 4. Spell check
spelling::spell_check_package()

# 5. Update cran-comments.md
usethis::use_cran_comments()
```

**Submission:**

```r
# Submit til CRAN
devtools::submit_cran()
```

**Version bumping:**

```r
# Bump version
usethis::use_version("minor")  # eller "major", "patch", "dev"

# Update NEWS.md
usethis::use_news_md()
```

---

## 5) Quarto Website Deployment

### 5.1 GitHub Pages

**Setup:**

```yaml
# _quarto.yml
project:
  type: website
  output-dir: docs  # Important for GitHub Pages
```

**Deployment workflow:**

```bash
# 1. Render website
quarto render

# 2. Commit rendered output
git add docs/
git commit -m "docs: update website"
git push

# 3. Enable GitHub Pages (kun én gang)
# Go to GitHub repo → Settings → Pages
# Source: Deploy from branch
# Branch: main, folder: /docs
```

**GitHub Actions (automatisk):**

`.github/workflows/publish-quarto.yml`:

```yaml
name: Publish Quarto Website

on:
  push:
    branches: [main]

jobs:
  build-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: quarto-dev/quarto-actions/setup@v2

      - uses: r-lib/actions/setup-r@v2
        with:
          r-version: '4.3.2'

      - name: Install R dependencies
        run: |
          Rscript -e 'install.packages("renv")'
          Rscript -e 'renv::restore()'

      - name: Render Quarto
        run: quarto render

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./docs
```

### 5.2 Netlify

**Deployment via Git:**

1. Login på Netlify
2. "New site from Git" → vælg repository
3. Build settings:
   - Build command: `quarto render`
   - Publish directory: `_site` (eller `docs`)
4. Deploy

**netlify.toml (optional):**

```toml
[build]
  command = "quarto render"
  publish = "_site"

[build.environment]
  R_VERSION = "4.3.2"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

---

## 6) Database Deployment & Migrations

### 6.1 Database Connections

**Production connection pattern:**

```r
# R/db_connection.R
get_db_connection <- function() {
  DBI::dbConnect(
    RPostgres::Postgres(),
    host = Sys.getenv("DB_HOST"),
    port = as.integer(Sys.getenv("DB_PORT", "5432")),
    dbname = Sys.getenv("DB_NAME"),
    user = Sys.getenv("DB_USER"),
    password = Sys.getenv("DB_PASSWORD"),
    # SSL i production
    sslmode = if (Sys.getenv("APP_ENV") == "production") "require" else "prefer"
  )
}
```

### 6.2 Database Migrations

**Pattern: SQL migration files**

```
db/migrations/
├── 001_initial_schema.sql
├── 002_add_users_table.sql
└── 003_add_indexes.sql
```

**Migration runner:**

```r
# R/db_migrate.R
run_migrations <- function(con) {
  # Opret migrations tracking table
  DBI::dbExecute(con, "
    CREATE TABLE IF NOT EXISTS schema_migrations (
      version INTEGER PRIMARY KEY,
      applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  ")

  # Find applied migrations
  applied <- DBI::dbGetQuery(con, "SELECT version FROM schema_migrations")$version

  # Find migration files
  migrations <- list.files("db/migrations", pattern = "*.sql", full.names = TRUE)

  for (migration_file in migrations) {
    version <- as.integer(sub("^(\\d+)_.*", "\\1", basename(migration_file)))

    if (version %in% applied) {
      next
    }

    message("Applying migration ", version)
    sql <- readLines(migration_file, warn = FALSE)
    DBI::dbExecute(con, paste(sql, collapse = "\n"))

    DBI::dbExecute(con, "INSERT INTO schema_migrations (version) VALUES (?)", params = list(version))
  }
}
```

---

## 7) Health Checks & Monitoring

### 7.1 Health Check Endpoint (Shiny/Plumber)

```r
# For Plumber API
#* @get /health
function() {
  list(
    status = "ok",
    timestamp = Sys.time(),
    version = packageVersion("myapp")
  )
}

# For Shiny (via custom route)
# I global.R eller app.R
addResourcePath("health", "www/health")

# www/health/index.html
# Simple static page med "OK" status
```

### 7.2 Liveness vs Readiness

**Liveness:** Er appen alive?
```r
#* @get /healthz
function() {
  list(status = "alive")
}
```

**Readiness:** Er appen klar til at modtage traffic?
```r
#* @get /readyz
function() {
  # Check database connection
  db_ok <- tryCatch({
    con <- get_db_connection()
    DBI::dbIsValid(con)
  }, error = function(e) FALSE)

  if (db_ok) {
    list(status = "ready")
  } else {
    res$status <- 503  # Service Unavailable
    list(status = "not ready", reason = "database unavailable")
  }
}
```

---

## 8) Rollback Procedures

### 8.1 Shiny Apps (RStudio Connect)

```r
# Via R
rsconnect::rollbackDeployment(deploymentId = "12345")

# Via UI
# RStudio Connect → App → Versions → Activate previous version
```

### 8.2 Docker Deployments

```bash
# Tag nye images med version
docker build -t my-app:v1.2.0 -t my-app:latest .

# Deploy ny version
docker compose up -d

# Hvis der er problemer, rollback:
docker compose down
docker tag my-app:v1.1.0 my-app:latest
docker compose up -d
```

### 8.3 R Packages

```r
# Installer previous version
remotes::install_github("username/mypackage@v1.0.0")

# Eller via CRAN
remotes::install_version("mypackage", version = "1.0.0")
```

---

## 9) Deployment Troubleshooting

### Common Issues

**"Package X not found" i deployment:**
- ✅ Verificer `renv.lock` er opdateret (`renv::snapshot()`)
- ✅ Check at deployment platform har adgang til package repository

**"Secret not found" errors:**
- ✅ Verificer environment variables er sat i deployment platform
- ✅ Check variable navne matcher (case-sensitive!)

**Database connection failures:**
- ✅ Check network connectivity fra deployment server til database
- ✅ Verificer database credentials
- ✅ Check firewall rules

**"App works locally but not in production":**
- ✅ Check `APP_ENV` environment variable
- ✅ Verificer file paths (absolute vs relative)
- ✅ Check log files for errors

---

## 10) Platform Comparison

| Feature | RStudio Connect | shinyapps.io | Docker |
|---------|----------------|--------------|--------|
| **Cost** | Enterprise license | Free tier + paid | Infrastructure only |
| **Ease of Use** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Scalability** | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Customization** | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Security** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ (depends on setup) |
| **Best For** | Enterprise Shiny/R Markdown | Prototypes, demos | Custom infrastructure, microservices |

---

**Sidst opdateret:** 2025-10-21
**Del af:** ~/.claude/ global configuration system
