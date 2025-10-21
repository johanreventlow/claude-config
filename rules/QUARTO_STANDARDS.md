# Quarto Development Standards

Standarder for udvikling af Quarto websites og dokumenter.

---

## Quick Reference

**Structure:** `_quarto.yml`, `index.qmd`, `posts/`, `_extensions/`, `_site/` (gitignored)

**YAML frontmatter:**
```yaml
---
title: "Titel"
author: "Forfatter"
date: "2024-01-21"
lang: da                        # Dansk sprog
date-format: "D. MMMM YYYY"
format:
  html:
    toc: true
    code-fold: true
---
```

**Commands:**
```r
quarto::quarto_preview()                     # Preview
quarto::quarto_render()                      # Render
quarto::quarto_render("page.qmd")           # Specific file
```

**Bash:**
```bash
quarto preview
quarto render
quarto render --execute-daemon-restart      # Clean render
quarto publish gh-pages                     # GitHub Pages
quarto publish netlify                      # Netlify
```

---

## Configuration

**`_quarto.yml` template:**
```yaml
project:
  type: website
  output-dir: _site

website:
  title: "Site Title"
  navbar:
    left:
      - href: index.qmd
        text: Home

format:
  html:
    theme: cosmo
    toc: true
    css: styles.css
```

---

## Content Generation

**Dynamic content:**
```r
library(yaml)
yaml_content <- list(title = "Auto-generated", subtitle = "Desc")
write_file(paste0("---\n", as.yaml(yaml_content), "---\n"), "output.qmd")
```

**Includes:**
```markdown
{{< include _common_header.qmd >}}
```

---

## Listings

```yaml
listing:
  - id: blog-posts
    contents: "posts/*.qmd"
    type: grid
    sort: "date desc"
    categories: true
```

---

## Common Issues

| Problem | Fix |
|---------|-----|
| YAML errors | Tjek indentation, balanced quotes |
| Include paths | Relative til project root: `{{< include /_file.qmd >}}` |
| Render fails | Clear cache: `quarto preview --execute-daemon-restart` |

---

## Publishing

**GitHub Pages:**
```yaml
# _quarto.yml
project:
  output-dir: docs

# Enable i GitHub: Settings → Pages → Source: main, folder: /docs
```

**`.gitignore`:**
```
/_site/
/.quarto/
```

---

**Sidst opdateret:** 2025-10-21
