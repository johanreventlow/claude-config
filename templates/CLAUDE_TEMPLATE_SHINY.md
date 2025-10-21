# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## 📚 Global Standards

**Dette projekt følger globale standarder dokumenteret i:**

- **R Development**: `~/.claude/rules/R_STANDARDS.md`
- **Shiny Development**: `~/.claude/rules/SHINY_STANDARDS.md`
- **Git Workflow**: `~/.claude/rules/GIT_WORKFLOW.md`

**Globale agents tilgængelige:**
- `tidyverse-code-reviewer` - Review af tidyverse code patterns
- `shiny-code-reviewer` - Review af Shiny apps
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

**[APP_NAME]** - [Kort beskrivelse af Shiny appen]

**Formål:**
- [Hvad gør appen?]
- [Hvem er brugerne?]

**Technology Stack:**
- R Shiny [version]
- [Andre packages: golem, shinytest2, etc.]

## Architecture

### App Structure
```
app/
├── R/
│   ├── app_ui.R           # UI definition
│   ├── app_server.R       # Server logic
│   ├── mod_*.R            # Shiny modules
│   ├── fct_*.R            # Business logic functions
│   ├── utils_*.R          # Utility functions
│   └── state_management.R # Centralized state
├── data/                  # Data files
├── tests/                 # Tests
│   ├── testthat/          # Unit tests
│   └── shinytest2/        # UI tests
└── inst/                  # Assets, config
```

### State Management

**App State Structure:**
```r
app_state <- reactiveValues(
  data = NULL,
  user_settings = list(),
  session_info = NULL
)
```

### Module Architecture
- **[Module 1]**: [Beskrivelse og ansvar]
- **[Module 2]**: [Beskrivelse og ansvar]

## Development Workflow

### Running the App

**Development mode:**
```r
# Run locally
shiny::runApp()

# Or with golem
golem::run_dev()
```

**Testing:**
```r
# Unit tests
testthat::test_dir('tests/testthat')

# Shiny tests
shinytest2::test_app()
```

### Common Operations

**Add new module:**
```r
# Create module files
golem::add_module(name = "module_name")
```

**Deploy:**
```r
# [Deployment commands]
```

## Reactive Architecture

### Observer Priorities
```r
# High priority observers (UI updates)
observeEvent(..., priority = 1000)

# Normal priority (data processing)
observeEvent(..., priority = 500)

# Low priority (logging, analytics)
observeEvent(..., priority = 100)
```

### Event System
[Beskrivelse af event-driven architecture hvis relevant]

## Important Patterns

### Safe Operations
```r
safe_operation <- function(operation_name, code, fallback = NULL) {
  tryCatch({
    code
  }, error = function(e) {
    showNotification(paste("Fejl:", e$message), type = "error")
    return(fallback)
  })
}
```

### Input Validation
```r
# Always validate inputs
observeEvent(input$submit, {
  req(input$data)
  validate(
    need(nrow(data()) > 0, "Data er tom"),
    need(!anyNA(data()), "Data indeholder manglende værdier")
  )
})
```

## Performance

### Optimization Strategies
- Debounce rapid inputs (standard: 800ms)
- Cache expensive computations
- Use reactive expressions for shared logic
- Lazy load heavy modules

## Security

### Input Sanitization
- Validate all file uploads
- Sanitize text inputs
- Check file types and sizes
- [Andre security measures]

## Testing

### Test Strategy
- **Unit tests**: Pure functions og business logic
- **Integration tests**: Reactive chains
- **UI tests**: User workflows med shinytest2

### Test Coverage Goals
- Critical paths: 100%
- Overall: ≥80%

## Configuration

### Environment Variables
```r
# Development
Sys.setenv(ENV = "dev")

# Production
Sys.setenv(ENV = "prod")
```

### App Configuration
[Hvordan app konfigureres - golem options, config files, etc.]

## Dependencies

Required packages:
- `shiny` - Core framework
- `tidyverse` - Data manipulation
- [Andre dependencies]

## Troubleshooting

### Reactive Issues
- Problem: Infinite reactive loop
- Solution: Check for circular dependencies, use `isolate()`

### Performance Issues
- Problem: Slow rendering
- Solution: Profile with `profvis`, add debouncing

### State Issues
- Problem: State shared between sessions
- Solution: Ensure all state is session-specific (inside `server` function)

## Deployment

### Pre-Deployment Checklist
- [ ] All tests pass
- [ ] Performance tested with realistic data
- [ ] Error handling verified
- [ ] Logging configured
- [ ] Security reviewed

### Deployment Steps
[Deployment process]

## Project-Specific Guidelines

### UI/UX Conventions
- [Branding requirements]
- [Color schemes]
- [Layout patterns]

### Danish Language
- UI text: Dansk
- Error messages: Dansk, brugervenlige
- Comments: Dansk

## Constraints

### Do Not Modify
- [Core files der ikke må ændres]
- [Database schemas]
- [API contracts]

### Breaking Changes
- State structure changes require migration
- Module interface changes require update af consumers
- [Andre breaking changes]
