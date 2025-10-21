# Quarto Development Standards

Standarder for udvikling af Quarto websites og dokumenter.

## Project Structure

### Typical Layout
```
project/
├── _quarto.yml           # Site configuration
├── _metadata.yml         # Shared metadata
├── index.qmd             # Landing page
├── about.qmd
├── posts/
│   ├── _metadata.yml     # Post-specific metadata
│   ├── post1.qmd
│   └── post2.qmd
├── _extensions/          # Custom extensions
└── _site/                # Rendered output (gitignored)
```

## Configuration

### _quarto.yml Best Practices
```yaml
project:
  type: website
  output-dir: _site
  preview:
    port: 4200
    browser: true

website:
  title: "Site Title"
  navbar:
    background: light
    left:
      - href: index.qmd
        text: Home
  sidebar:
    - id: main
      contents:
        - section: "Section"
          contents:
            - file.qmd

format:
  html:
    theme: cosmo
    toc: true
    css: styles.css
```

### Metadata Inheritance
- Site-level: `_quarto.yml`
- Directory-level: `_metadata.yml`
- Document-level: YAML frontmatter

## YAML Frontmatter

### Essential Fields
```yaml
---
title: "Document Title"
author: "Author Name"
date: "2024-01-21"
format:
  html:
    toc: true
    code-fold: true
---
```

### Danish Language Setup
```yaml
---
lang: da
date-format: "D. MMMM YYYY"
toc-title: "Indhold"
---
```

## Content Generation

### Dynamic Content
```r
# Generate .qmd files programmatically
library(yaml)

yaml_content <- list(
  title = "Auto-generated Page",
  subtitle = "Description"
)

yaml_string <- paste0(
  "---\n",
  as.yaml(yaml_content),
  "---\n\n",
  "{{< include /_includes/template.qmd >}}"
)

write_file(yaml_string, "output.qmd")
```

### Includes Pattern
```markdown
---
title: "My Page"
---

{{< include _common_header.qmd >}}

Page-specific content here.

{{< include _common_footer.qmd >}}
```

## Listings

### Listing Configuration
```yaml
listing:
  - id: blog-posts
    contents: "posts/*.qmd"
    type: grid
    sort: "date desc"
    categories: true
    fields:
      - title
      - date
      - description
      - author
```

### Custom Listings
```yaml
listing:
  - id: custom-list
    contents: "*.qmd"
    type: table
    fields: [title, subtitle]
    field-display-names:
      title: "Titel"
      subtitle: "Beskrivelse"
    table-hover: true
    sort-ui: false
    filter-ui: false
```

## Rendering

### Preview Commands
```r
# Preview entire site
quarto::quarto_preview()

# Preview specific file
quarto::quarto_preview(file = "docs/page.qmd")

# Preview without watching
quarto::quarto_preview(file = "page.qmd", watch = FALSE)
```

### Render Commands
```r
# Render entire site
quarto::quarto_render()

# Render specific file
quarto::quarto_render("page.qmd")

# Render to specific format
quarto::quarto_render("page.qmd", output_format = "pdf")
```

### Command Line
```bash
# Preview
quarto preview

# Render
quarto render

# Render and don't execute code
quarto render --execute-daemon-restart

# Clean output
quarto preview --no-execute
```

## Code Execution

### R Code Chunks
```{r}
#| label: fig-plot
#| fig-cap: "Figure caption"
#| echo: false
#| warning: false
#| message: false

library(ggplot2)
ggplot(data, aes(x, y)) + geom_point()
```

### Chunk Options
- `echo` - Vis kode (true/false)
- `eval` - Evaluer kode (true/false)
- `include` - Inkluder output (true/false)
- `warning` - Vis warnings (true/false)
- `message` - Vis messages (true/false)

## Styling

### Custom CSS
```css
/* styles.css */
.custom-class {
  color: #333;
  font-family: 'Arial', sans-serif;
}

.hero-banner {
  background: linear-gradient(to right, #667eea 0%, #764ba2 100%);
  padding: 2rem;
}
```

### SCSS Themes
```scss
// theme.scss
$primary: #2c3e50;
$secondary: #3498db;

.navbar {
  background-color: $primary;
}
```

## Troubleshooting

### Common Issues

**YAML Frontmatter Errors**
```yaml
# ❌ Forkert: Ubalancerede quotes
title: "My Title

# ✅ Korrekt
title: "My Title"

# ❌ Forkert: Forkert indentation
format:
html:
  toc: true

# ✅ Korrekt
format:
  html:
    toc: true
```

**Include Paths**
```markdown
# ✅ Korrekt: Relativ til project root
{{< include /_settings/template.qmd >}}

# ✅ Korrekt: Relativ til current file
{{< include ../common/header.qmd >}}

# ❌ Forkert: Absolute system path
{{< include /Users/name/project/file.qmd >}}
```

**Rendering Issues**
- Verificer alle includes eksisterer
- Check YAML syntax (brug YAML validator)
- Ensure code chunks execute without errors
- Clear cache: `quarto preview --execute-daemon-restart`

## Performance

### Optimization Tips
- Cache expensive computations
- Use `freeze` for content that doesn't change
- Minimize dependencies
- Optimize images

### Freeze Strategy
```yaml
# _quarto.yml
execute:
  freeze: auto  # Only re-render when source changes
```

## Accessibility

### Best Practices
- Use semantic HTML
- Provide alt text for images
- Ensure good color contrast
- Support keyboard navigation
- Use descriptive link text

### Example
```markdown
![Alt text describing the image](image.png)

[Descriptive link text](url.html) (not "click here")
```

## Publishing

### GitHub Pages
```bash
# Render and publish
quarto publish gh-pages

# With custom domain
quarto publish gh-pages --custom-domain example.com
```

### Netlify
```bash
quarto publish netlify
```

### Pre-Publish Checklist
- [ ] All pages render without errors
- [ ] Links are valid (internal and external)
- [ ] Images load correctly
- [ ] Responsive design works
- [ ] Test on multiple browsers
- [ ] Check SEO metadata
- [ ] Verify analytics (if applicable)

## File Organization

### Clean Structure
```
project/
├── _quarto.yml
├── index.qmd
├── docs/
│   ├── guide.qmd
│   └── reference.qmd
├── _includes/
│   ├── header.qmd
│   └── footer.qmd
├── _settings/
│   └── metadata.yml
├── assets/
│   ├── images/
│   └── css/
└── data/
    └── dataset.csv
```

### .gitignore
```gitignore
/_site/
/.quarto/
*.html
```

## Multi-language Support

### Language Setup
```yaml
# _quarto.yml
lang: da

# Custom translations
language:
  title-block-author-single: "Forfatter"
  title-block-published: "Publiceret"
```

## Advanced Features

### Computations
```{r}
#| output: asis

# Generate dynamic content
cat("## Dynamic Heading\n\n")
cat(paste("Generated at:", Sys.time()))
```

### Cross-references
```markdown
See @fig-plot for details.

See @tbl-data for the data.

See @eq-formula for the equation.
```

### Callouts
```markdown
::: {.callout-note}
This is a note.
:::

::: {.callout-warning}
This is a warning.
:::

::: {.callout-important}
This is important.
:::
```
