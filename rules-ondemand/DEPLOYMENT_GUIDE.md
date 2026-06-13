# Deployment Guide

Org-specifikke deployment-konventioner R/Shiny apps.

---

## Miljø-konfiguration

```r
get_config <- function() {
  env <- Sys.getenv("APP_ENV", "development")
  config_file <- switch(env,
    "production" = "config/config_prod.yml",
    "testing"    = "config/config_test.yml",
    "config/config_dev.yml"
  )
  yaml::read_yaml(config_file)
}
```

`APP_ENV` sættes i platform-miljøet — aldrig hardkodet.

---

## RStudio Connect (primær platform)

```r
rsconnect::deployApp(appDir = ".", appName = "my-app")
```

- Env vars: RStudio Connect UI → Content → Vars
- Rollback: `rsconnect::rollbackDeployment(deploymentId = "12345")`
- `renv.lock` skal være opdateret inden deploy

---

## Health Check (Plumber API-endpoint)

```r
#* @get /health
function() {
  checks <- list(db = check_db(), cache = check_cache())
  all_healthy <- all(sapply(checks, isTRUE))
  list(status = if (all_healthy) "ok" else "unhealthy", checks = checks)
}
```

---

## Fejlfinding

| Problem | Fix |
|---------|-----|
| "Package X not found" | Verificér `renv.lock` er opdateret + committed |
| "Secret not found" | Tjek env vars i RConnect UI → Content → Vars |
| Database connection fails | Verificér netværk, credentials, firewall-regler |
| "Works locally, not prod" | Tjek `APP_ENV`-var, fil-stier, strukturerede logs |

---

## Checklist

- [ ] Tests bestået
- [ ] `renv.lock` opdateret
- [ ] Ingen secrets i kode
- [ ] `APP_ENV` konfigureret korrekt
- [ ] Health check endpoint fungerer
- [ ] Logging aktiveret (strukturerede logs)

---

**Sidst opdateret:** 2026-06-12
