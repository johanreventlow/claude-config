# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## 📚 Global Standards

**Dette projekt følger globale standarder dokumenteret i:**

- **R Development**: `~/.claude/rules/R_STANDARDS.md`
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

**[PROJECT_NAME]** - [Kort beskrivelse af projektet]

**Formål:**
- [Hvad løser projektet?]
- [Hvem er målgruppen?]

**Technology Stack:**
- R [version]
- [Andre teknologier]

## Architecture

### Project Structure
```
project/
├── R/              # R source files
├── data/           # Data files
├── tests/          # Test files
├── docs/           # Documentation
└── README.md
```

### Key Components
- **[Component 1]**: [Beskrivelse]
- **[Component 2]**: [Beskrivelse]

## Development Workflow

### Setup
```r
# Install dependencies
# [commands]

# Load project
# [commands]
```

### Common Commands

**Run tests:**
```r
testthat::test_dir('tests/testthat')
```

**Build/check:**
```r
# [projekt-specifikke commands]
```

## Important Patterns

### [Pattern 1]
[Beskrivelse af vigtige mønstre i projektet]

### [Pattern 2]
[Beskrivelse]

## Configuration

### [Config Type]
[Hvordan konfiguration håndteres]

## Dependencies

Required packages:
- `tidyverse` - Data manipulation
- [Andre dependencies]

## Troubleshooting

### [Common Issue 1]
- Problem: [beskrivelse]
- Solution: [løsning]

### [Common Issue 2]
- Problem: [beskrivelse]
- Solution: [løsning]

## Project-Specific Guidelines

### Code Style
[Projekt-specifikke style guidelines ud over globale standarder]

### Testing Strategy
[Test approach for dette projekt]

### Documentation
[Dokumentationskrav]

## Constraints

### Do Not Modify
- [Filer/områder der ikke må ændres]

### Breaking Changes
- [Hvad kræver ekstra opmærksomhed]
