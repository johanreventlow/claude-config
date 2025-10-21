# Deployment Guide

Guide til deployment af R-projekter til produktion.

---

## Production Checklist

- [ ] Tests passed
- [ ] Linting clean
- [ ] renv.lock updated
- [ ] No secrets in code
- [ ] Environment vars configured
- [ ] Logging enabled
- [ ] Health check endpoint
- [ ] Performance tested
- [ ] Documentation updated

---

## Environment Management

| Environment | Deploy | Purpose |
|-------------|--------|---------|
| Development | Lokalt | Udvikling |
| Testing/Staging | Separat server | QA, integration |
| Production | Production server | Live brugere |

**Config pattern:**
```r
get_config <- function() {
  env <- Sys.getenv("APP_ENV", "development")
  config_file <- switch(env,
    "production" = "config/config_prod.yml",
    "testing" = "config/config_test.yml",
    "config/config_dev.yml"
  )
  yaml::read_yaml(config_file)
}
```

---

## Deployment Commands

**RStudio Connect:**
```r
rsconnect::deployApp(appDir = ".", appName = "my-app")
```
Env vars: RStudio Connect UI → Content → Vars

**shinyapps.io:**
```r
rsconnect::deployApp()
```
Env vars: shinyapps.io dashboard

**Docker:**
```bash
docker build -t app:tag .
docker compose up -d
```
Env vars: `docker-compose.yml` `env_file: .env`

**Quarto:**
```bash
quarto publish gh-pages
```

---

## Docker Setup

**Dockerfile:**
```dockerfile
FROM rocker/shiny-verse:4.3.2
WORKDIR /app
COPY renv.lock renv.lock
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R
RUN R -e "renv::restore()"
COPY . /app
EXPOSE 3838
CMD ["R", "-e", "shiny::runApp('/app', host = '0.0.0.0', port = 3838)"]
```

**docker-compose.yml:**
```yaml
services:
  app:
    build: .
    ports:
      - "3838:3838"
    environment:
      - API_KEY=${API_KEY}
    env_file:
      - .env  # Git ignored
    restart: unless-stopped
```

---

## Health Checks

```r
#* @get /health
function() {
  checks <- list(
    db = check_db(),
    cache = check_cache()
  )
  list(status = if (all_healthy) "ok" else "unhealthy", checks = checks)
}
```

---

## Rollback

**RStudio Connect:**
```r
rsconnect::rollbackDeployment(deploymentId = "12345")
```

**Docker:**
```bash
docker tag app:v1.1.0 app:latest
docker compose up -d
```

---

## Platform Comparison

| Feature | RStudio Connect | shinyapps.io | Docker |
|---------|----------------|--------------|--------|
| Ease | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Scalability | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Best For | Enterprise | Prototypes | Custom infra |

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| "Package X not found" | Verify `renv.lock` updated |
| "Secret not found" | Check env vars i platform |
| Database connection fails | Verify network, credentials, firewall |
| "Works locally, not prod" | Check `APP_ENV` var, file paths, logs |

---

**Sidst opdateret:** 2025-10-21
