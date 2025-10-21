# CI/CD Workflow

Standards for Continuous Integration og Continuous Deployment i R-baserede projekter.

---

## 1) CI/CD Principles

### 1.1 Continuous Integration (CI)

**Definition:** Automatisk bygge og teste kode ved hver commit/PR.

**Formål:**
- ✅ Catch bugs tidligt
- ✅ Ensure code quality
- ✅ Prevent breaking changes
- ✅ Fast feedback til developers

**Core practices:**
- Automated testing på alle branches
- Automated linting og style checks
- Code coverage tracking
- Platform compatibility checks

### 1.2 Continuous Deployment (CD)

**Definition:** Automatisk deploye kode til miljøer efter successful CI.

**Formål:**
- ✅ Reducer manual deployment errors
- ✅ Accelerate release cycles
- ✅ Consistent deployment process
- ✅ Enable rapid rollback

**Deployment stages:**
```
Code Commit → CI (test) → Deploy to Staging → Manual Approval → Deploy to Production
```

---

## 2) GitHub Actions Basics

### 2.1 Workflow File Structure

```yaml
name: CI                      # Workflow name

on:                           # Triggers
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:                         # Jobs to run
  test:
    runs-on: ubuntu-latest    # Runner OS
    steps:                    # Individual steps
      - uses: actions/checkout@v3
      - name: Run tests
        run: Rscript -e "devtools::test()"
```

**Placering:** `.github/workflows/ci.yml`

### 2.2 Common Actions for R

```yaml
# Checkout code
- uses: actions/checkout@v3

# Setup R
- uses: r-lib/actions/setup-r@v2
  with:
    r-version: '4.3.2'

# Setup renv
- uses: r-lib/actions/setup-renv@v2

# Setup pandoc (for Quarto/RMarkdown)
- uses: r-lib/actions/setup-pandoc@v2

# Setup Quarto
- uses: quarto-dev/quarto-actions/setup@v2
```

---

## 3) CI Workflows by Project Type

### 3.1 R Package CI Workflow

**`.github/workflows/R-CMD-check.yml`:**

```yaml
name: R-CMD-check

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  R-CMD-check:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        r-version: ['4.2.3', '4.3.2']

    steps:
      - uses: actions/checkout@v3

      - uses: r-lib/actions/setup-r@v2
        with:
          r-version: ${{ matrix.r-version }}

      - uses: r-lib/actions/setup-r-dependencies@v2

      - name: Check package
        run: rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "error")
        shell: Rscript {0}

      - name: Test coverage
        if: matrix.os == 'ubuntu-latest' && matrix.r-version == '4.3.2'
        run: |
          covr::codecov(token = "${{ secrets.CODECOV_TOKEN }}")
        shell: Rscript {0}
```

**Features:**
- ✅ Test på multiple OS (Linux, Windows, macOS)
- ✅ Test på multiple R versions
- ✅ Code coverage upload til Codecov

### 3.2 Shiny App CI Workflow

**`.github/workflows/shiny-ci.yml`:**

```yaml
name: Shiny App CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - uses: r-lib/actions/setup-r@v2
        with:
          r-version: '4.3.2'

      - uses: r-lib/actions/setup-renv@v2

      - name: Run tests
        run: |
          Rscript -e "devtools::test()"

      - name: Lint code
        run: |
          Rscript -e "lintr::lint_package()"

      - name: Check app loads
        run: |
          Rscript -e "shiny::runApp(port=3838, launch.browser=FALSE)" &
          sleep 10
          curl --fail http://localhost:3838 || exit 1

  docker-build:
    runs-on: ubuntu-latest
    needs: test

    steps:
      - uses: actions/checkout@v3

      - name: Build Docker image
        run: docker build -t myapp:${{ github.sha }} .

      - name: Test Docker image
        run: |
          docker run -d -p 3838:3838 --name test-app myapp:${{ github.sha }}
          sleep 10
          curl --fail http://localhost:3838 || exit 1
          docker stop test-app
```

### 3.3 Quarto Site CI Workflow

**`.github/workflows/quarto-publish.yml`:**

```yaml
name: Publish Quarto Site

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

      - uses: r-lib/actions/setup-renv@v2

      - name: Render Quarto
        run: quarto render

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./docs
```

---

## 4) Code Quality Checks

### 4.1 Linting Workflow

**`.github/workflows/lint.yml`:**

```yaml
name: Lint

on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - uses: r-lib/actions/setup-r@v2

      - name: Install lintr
        run: install.packages("lintr")
        shell: Rscript {0}

      - name: Lint
        run: |
          lints <- lintr::lint_package()
          print(lints)
          if (length(lints) > 0) {
            quit(status = 1)
          }
        shell: Rscript {0}
```

### 4.2 Style Check Workflow

```yaml
name: Style Check

on: [pull_request]

jobs:
  style:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - uses: r-lib/actions/setup-r@v2

      - name: Install styler
        run: install.packages("styler")
        shell: Rscript {0}

      - name: Check style
        run: |
          restyled <- styler::style_pkg(dry = "on")
          if (length(restyled$changed) > 0) {
            cat("Files need styling:\n")
            print(restyled$changed)
            quit(status = 1)
          }
        shell: Rscript {0}
```

### 4.3 Security Scan

```yaml
name: Security Scan

on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly
  push:
    branches: [main]

jobs:
  security:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - uses: r-lib/actions/setup-r@v2

      - name: Install oysteR
        run: install.packages("oysteR")
        shell: Rscript {0}

      - name: Security audit
        run: |
          audit <- oysteR::audit_installed_r_pkgs()
          if (nrow(audit$vulnerabilities) > 0) {
            print(audit$vulnerabilities)
            quit(status = 1)
          }
        shell: Rscript {0}
```

---

## 5) CD: Automated Deployment

### 5.1 Deploy to RStudio Connect

**`.github/workflows/deploy-connect.yml`:**

```yaml
name: Deploy to RStudio Connect

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - uses: r-lib/actions/setup-r@v2

      - uses: r-lib/actions/setup-renv@v2

      - name: Deploy to RStudio Connect
        env:
          CONNECT_SERVER: ${{ secrets.CONNECT_SERVER }}
          CONNECT_API_KEY: ${{ secrets.CONNECT_API_KEY }}
        run: |
          library(rsconnect)
          rsconnect::connectApiUser(
            account = "my-account",
            server = Sys.getenv("CONNECT_SERVER"),
            apiKey = Sys.getenv("CONNECT_API_KEY")
          )
          rsconnect::deployApp(
            appDir = ".",
            appName = "my-app",
            forceUpdate = TRUE
          )
        shell: Rscript {0}
```

### 5.2 Deploy to Docker Registry

```yaml
name: Build and Push Docker

on:
  push:
    tags:
      - 'v*'  # Trigger on version tags

jobs:
  docker:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Login to DockerHub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Extract version
        id: meta
        run: echo "version=${GITHUB_REF#refs/tags/v}" >> $GITHUB_OUTPUT

      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: |
            myorg/myapp:latest
            myorg/myapp:${{ steps.meta.outputs.version }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### 5.3 Multi-Environment Deployment

```yaml
name: Multi-Environment Deploy

on:
  push:
    branches:
      - develop  # Deploy to staging
      - main     # Deploy to production

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Determine environment
        id: env
        run: |
          if [[ "${{ github.ref }}" == "refs/heads/main" ]]; then
            echo "environment=production" >> $GITHUB_OUTPUT
            echo "url=${{ secrets.PROD_URL }}" >> $GITHUB_OUTPUT
          else
            echo "environment=staging" >> $GITHUB_OUTPUT
            echo "url=${{ secrets.STAGING_URL }}" >> $GITHUB_OUTPUT
          fi

      - name: Deploy
        env:
          DEPLOY_URL: ${{ steps.env.outputs.url }}
          API_KEY: ${{ secrets.API_KEY }}
        run: |
          # Deployment script
          ./deploy.sh ${{ steps.env.outputs.environment }}
```

---

## 6) Caching for Performance

### 6.1 Cache R Packages

```yaml
- name: Cache R packages
  uses: actions/cache@v3
  with:
    path: ${{ env.R_LIBS_USER }}
    key: ${{ runner.os }}-r-${{ hashFiles('renv.lock') }}
    restore-keys: |
      ${{ runner.os }}-r-
```

### 6.2 Cache renv

```yaml
- uses: r-lib/actions/setup-renv@v2
  # Automatisk caching af renv library
```

### 6.3 Cache Docker Layers

```yaml
- name: Build Docker with cache
  uses: docker/build-push-action@v4
  with:
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

---

## 7) Branch Protection & Status Checks

### 7.1 GitHub Branch Protection Setup

**Settings → Branches → Add rule for `main`:**

- ✅ **Require pull request before merging**
  - Require approvals: 1
  - Dismiss stale reviews

- ✅ **Require status checks to pass**
  - R-CMD-check
  - Lint
  - Test coverage

- ✅ **Require branches to be up to date**

- ✅ **Include administrators** (alle skal følge regler)

### 7.2 Required Status Checks

```yaml
# .github/workflows/required-checks.yml
name: Required Checks

on: [pull_request]

jobs:
  # Combine all required checks
  all-checks:
    runs-on: ubuntu-latest
    needs: [test, lint, coverage]

    steps:
      - name: All checks passed
        run: echo "All required checks passed"
```

---

## 8) Secrets Management in CI/CD

### 8.1 GitHub Secrets

**Setup secrets:**
1. Repository → Settings → Secrets and variables → Actions
2. Add secrets:
   - `DOCKERHUB_USERNAME`
   - `DOCKERHUB_TOKEN`
   - `CONNECT_API_KEY`
   - `CODECOV_TOKEN`

**Brug i workflows:**
```yaml
env:
  API_KEY: ${{ secrets.API_KEY }}
```

### 8.2 Environment Secrets

**For environment-specific secrets:**

```yaml
jobs:
  deploy-prod:
    runs-on: ubuntu-latest
    environment: production  # Links til GitHub Environment

    steps:
      - name: Deploy
        env:
          PROD_API_KEY: ${{ secrets.PROD_API_KEY }}
        run: ./deploy.sh
```

---

## 9) Notifications & Monitoring

### 9.1 Slack Notifications

```yaml
- name: Notify Slack on failure
  if: failure()
  uses: slackapi/slack-github-action@v1
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK_URL }}
    payload: |
      {
        "text": "❌ Build failed: ${{ github.repository }} on ${{ github.ref }}"
      }
```

### 9.2 Email Notifications

```yaml
- name: Send email on deployment
  if: success()
  uses: dawidd6/action-send-mail@v3
  with:
    server_address: smtp.gmail.com
    server_port: 465
    username: ${{ secrets.EMAIL_USERNAME }}
    password: ${{ secrets.EMAIL_PASSWORD }}
    subject: "Deployment successful: ${{ github.repository }}"
    body: "Deployed to production at ${{ github.sha }}"
    to: team@example.com
```

---

## 10) Best Practices Checklist

### CI/CD Setup
- [ ] Automated tests run på alle PRs
- [ ] Linting og style checks enforced
- [ ] Code coverage tracked (>80% for kritiske components)
- [ ] Security scans scheduled (weekly)
- [ ] Branch protection enabled på `main`
- [ ] Required status checks configured

### Deployment
- [ ] Automated deployment til staging
- [ ] Manual approval for production
- [ ] Environment-specific secrets configured
- [ ] Rollback procedure documented
- [ ] Deployment notifications setup

### Performance
- [ ] Caching enabled for packages
- [ ] Docker layer caching configured
- [ ] Parallel jobs used where possible

### Monitoring
- [ ] Build status badges i README
- [ ] Slack/email notifications configured
- [ ] Failed build alerts to team

---

## 11) Example: Complete CI/CD Pipeline

**Full workflow combining CI + CD:**

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  # Stage 1: Test
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: r-lib/actions/setup-r@v2
      - uses: r-lib/actions/setup-renv@v2
      - run: Rscript -e "devtools::test()"

  # Stage 2: Lint
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: r-lib/actions/setup-r@v2
      - run: Rscript -e "lintr::lint_package()"

  # Stage 3: Build Docker
  build:
    runs-on: ubuntu-latest
    needs: [test, lint]
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - uses: docker/build-push-action@v4
        with:
          push: true
          tags: myapp:${{ github.sha }}

  # Stage 4: Deploy to Staging
  deploy-staging:
    runs-on: ubuntu-latest
    needs: build
    environment: staging
    if: github.ref == 'refs/heads/develop'
    steps:
      - run: ./deploy.sh staging

  # Stage 5: Deploy to Production
  deploy-production:
    runs-on: ubuntu-latest
    needs: build
    environment: production
    if: github.ref == 'refs/heads/main'
    steps:
      - run: ./deploy.sh production

      - name: Notify team
        uses: slackapi/slack-github-action@v1
        with:
          webhook-url: ${{ secrets.SLACK_WEBHOOK }}
          payload: |
            {
              "text": "✅ Deployed to production: ${{ github.sha }}"
            }
```

---

**Sidst opdateret:** 2025-10-21
**Del af:** ~/.claude/ global configuration system
