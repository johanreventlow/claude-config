# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## 📚 Global Standards

**Dette projekt følger globale standarder dokumenteret i:**

- **R Development**: `~/.claude/rules/R_STANDARDS.md`
- **Quarto Development**: `~/.claude/rules/QUARTO_STANDARDS.md`
- **Git Workflow**: `~/.claude/rules/GIT_WORKFLOW.md`

**Globale agents tilgængelige:**
- `tidyverse-code-reviewer` - Review af tidyverse code patterns
- `performance-optimizer` - Performance analysis
- `security-reviewer` - Security audit
- `test-coverage-analyzer` - Test coverage analysis
- `refactoring-advisor` - Code quality improvements
- `legacy-code-detector` - Technical debt identification

**Globale commands tilgængelige:**
- `/boost` - Forbedring af prompts
- `/code-review-recent` - Review af nylige ændringer
- `/double-check` - Verification af implementering
- `/debugger` - Debug assistance

---

## Project Overview

**[SITE_NAME]** - [Kort beskrivelse af Quarto website]

**Formål:**
- [Hvad er formålet med sitet?]
- [Hvem er målgruppen?]

**Technology Stack:**
- Quarto [version]
- R for data processing og content generation
- [Andre teknologier]

## Architecture

### Site Structure
```
project/
├── _quarto.yml           # Site configuration
├── _metadata.yml         # Shared metadata
├── index.qmd             # Landing page
├── _settings/            # Configuration files
├── _includes/            # Shared templates
├── [section1]/           # Content sections
├── [section2]/
├── data/                 # Data files
├── R/                    # R scripts for content generation
└── _site/                # Generated output (gitignored)
```

### Data Flow

[Beskriv hvordan data flyder gennem systemet]

1. **Data Retrieval**: [Hvor kommer data fra?]
2. **Content Generation**: [Hvordan genereres indhold?]
3. **Rendering**: [Hvordan renderes sitet?]

## Development Workflow

### Common Commands

**Preview site:**
```r
quarto::quarto_preview()
```

**Render site:**
```r
quarto::quarto_render()
```

**Regenerate content:**
```r
# [Content generation commands]
source('R/generate_content.R', encoding = 'UTF-8')
```

### Content Generation

[Beskriv content generation process]

```r
# Example workflow
library(tidyverse)
library(yaml)

# Generate .qmd files
generate_pages <- function(data) {
  # Implementation
}
```

## Important Patterns

### YAML Frontmatter
```yaml
---
title: "Page Title"
subtitle: "Subtitle"
date: "2024-01-21"
categories: [category1, category2]
---
```

### Includes Pattern
```markdown
{{< include /_includes/template.qmd >}}
```

### Listings Configuration
```yaml
listing:
  - id: content-list
    contents: "posts/*.qmd"
    type: grid
    sort: "date desc"
```

## Configuration

### _quarto.yml
[Vigtige konfigurationsindstillinger]

```yaml
project:
  type: website
  output-dir: _site

website:
  title: "[SITE_NAME]"
  navbar:
    # ...

format:
  html:
    theme: cosmo
    toc: true
```

### Metadata Inheritance
- Site-level: `_quarto.yml`
- Directory-level: `_metadata.yml`
- Document-level: YAML frontmatter

## Styling

### Custom CSS
[Location og conventions for CSS]

### Themes
[Theme configuration]

## Data Management

### Data Sources
- [Data source 1]: [Beskrivelse]
- [Data source 2]: [Beskrivelse]

### Data Processing
[Hvordan data processeres]

### Data Updates
[Hvordan data opdateres]

## Dependencies

Required R packages:
- `tidyverse` - Data manipulation
- `yaml` - YAML parsing
- `quarto` - Site rendering
- [Andre dependencies]

## Troubleshooting

### Rendering Errors
- Problem: YAML frontmatter fejl
- Solution: Verificer syntax med YAML validator

- Problem: Include ikke fundet
- Solution: Check paths er relative til project root

### Content Generation Issues
- Problem: [Common issue]
- Solution: [Solution]

## Publishing

### Deployment Process
```bash
# [Deployment commands]
quarto publish [platform]
```

### Pre-Publish Checklist
- [ ] All pages render uden fejl
- [ ] Links verified (internal og external)
- [ ] Images load correctly
- [ ] Responsive design tested
- [ ] SEO metadata checked

## Danish Language

### Language Configuration
```yaml
lang: da
date-format: "D. MMMM YYYY"
toc-title: "Indhold"
```

### Translation Conventions
- UI: Dansk
- Content: Dansk
- Technical terms: [Approach]

## Project-Specific Guidelines

### Content Structure
[Hvordan content organiseres]

### Naming Conventions
- Files: [Convention]
- Directories: [Convention]
- IDs: [Convention]

### Update Frequency
[Hvor ofte opdateres content]

## Constraints

### Do Not Modify
- `_quarto.yml` navigation uden forståelse af site hierarchy
- [Andre kritiske filer]

### Generated Content
- Filer i `[generated_directory]/` er auto-genererede
- Rediger ALDRIG direkte - ændringer overskrives

## Automation

### Scheduled Tasks
[Hvis der er scheduled content generation]

### CI/CD
[Hvis der er automation setup]
