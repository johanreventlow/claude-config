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

**[PACKAGE_NAME]** - [Kort beskrivelse af pakken]

**Formål:**
- [Hvad gør pakken?]
- [Hvem er målgruppen?]

**Technology Stack:**
- R [version]
- [Development tools: devtools, usethis, roxygen2]

## Architecture

### Package Structure
```
package/
├── R/                    # R source code
├── man/                  # Documentation (auto-generated)
├── tests/
│   └── testthat/        # Unit tests
├── data/                 # Package data
├── data-raw/             # Scripts to generate data
├── vignettes/            # Long-form documentation
├── inst/                 # Additional files
├── DESCRIPTION           # Package metadata
├── NAMESPACE             # Exported functions (auto-generated)
└── README.md
```

### Module Organization
- `R/[module]_*.R` - Grouped by functionality
- One function per file or related functions together
- Internal functions prefixed with `.` or documented with `@keywords internal`

## Development Workflow

### Setup
```r
# Install dev dependencies
devtools::install_dev_deps()

# Load package for development
devtools::load_all()
```

### Common Commands

**Document package:**
```r
devtools::document()
```

**Run tests:**
```r
devtools::test()

# Or specific test
testthat::test_file("tests/testthat/test-feature.R")
```

**Check package:**
```r
devtools::check()
```

**Build and install:**
```r
devtools::install()
```

### Adding New Functions

```r
# 1. Create function in R/
usethis::use_r("function_name")

# 2. Write function with roxygen docs
#' Function Title
#'
#' @param x Description
#' @return Description
#' @export
#' @examples
#' function_name(x)
function_name <- function(x) {
  # Implementation
}

# 3. Document
devtools::document()

# 4. Add tests
usethis::use_test("function_name")

# 5. Check
devtools::check()
```

## Documentation

### Roxygen2 Standards

**Function documentation:**
```r
#' Brief title (one line)
#'
#' Longer description if needed.
#'
#' @param param1 Description of param1
#' @param param2 Description of param2
#' @return Description of return value
#' @export
#' @examples
#' # Example usage
#' my_function(1, 2)
```

**Package documentation:**
- Package-level docs in `R/[package]-package.R`
- Update with `usethis::use_package_doc()`

### Vignettes

```r
# Create vignette
usethis::use_vignette("introduction")

# Build vignettes
devtools::build_vignettes()
```

## Testing

### Test Structure
```r
# tests/testthat/test-feature.R
test_that("function works correctly", {
  expect_equal(my_function(1), 1)
  expect_error(my_function("a"))
})
```

### Test Coverage
```r
# Check coverage
covr::package_coverage()

# Report
covr::report()
```

### Coverage Goals
- Core functions: 100%
- Overall: ≥80%
- Exported functions: ≥90%

## Dependencies

### Managing Dependencies

**Add dependency:**
```r
# Imports (required)
usethis::use_package("dplyr")

# Suggests (optional)
usethis::use_package("ggplot2", type = "Suggests")
```

**Use functions:**
```r
# Explicit namespace calls (preferred)
dplyr::filter(data, condition)

# Or import in NAMESPACE (for commonly used functions)
#' @importFrom dplyr filter
```

## Data

### Package Data

```r
# Add data
usethis::use_data(my_dataset)

# Document data
usethis::use_r("data")

# In R/data.R:
#' My Dataset
#'
#' Description of the dataset
#'
#' @format A data frame with X rows and Y columns:
#' \describe{
#'   \item{var1}{Description}
#'   \item{var2}{Description}
#' }
#' @source \url{http://source.url}
"my_dataset"
```

### Internal Data
```r
# Internal data (not exported)
usethis::use_data(internal_data, internal = TRUE)
```

## Version Control

### Versioning
Follow Semantic Versioning (SemVer):
- MAJOR.MINOR.PATCH
- Example: 0.1.0, 1.0.0, 1.1.0

```r
# Increment version
usethis::use_version()
```

### NEWS.md
```r
# Create NEWS file
usethis::use_news_md()

# Update with changes for each version
```

## Release Process

### Pre-Release Checklist
- [ ] All tests pass (`devtools::check()`)
- [ ] Documentation updated
- [ ] NEWS.md updated
- [ ] Version number incremented
- [ ] No CRAN notes/warnings/errors
- [ ] Examples run successfully
- [ ] Vignettes build correctly

### Release Steps
```r
# 1. Check package
devtools::check()

# 2. Update version and NEWS
usethis::use_version()

# 3. Build package
devtools::build()

# 4. Submit to CRAN (if applicable)
devtools::submit_cran()
```

## Code Style

### Package-Specific Guidelines
- Follow tidyverse style guide
- Use `styler::style_pkg()` before commits
- Run `lintr::lint_package()` to check

### Naming
- Functions: `snake_case`
- Internal functions: `.snake_case` or document with `@keywords internal`
- Data: `snake_case`
- Classes: `UpperCamelCase` (S3/S4)

## Performance

### Profiling
```r
# Profile code
profvis::profvis({
  # Code to profile
})

# Benchmark
bench::mark(
  method1 = func1(),
  method2 = func2()
)
```

## CI/CD

### GitHub Actions
```r
# Setup R CMD check
usethis::use_github_action("check-standard")

# Setup test coverage
usethis::use_github_action("test-coverage")
```

## Troubleshooting

### Common Issues

**NAMESPACE conflicts:**
- Solution: Run `devtools::document()` to regenerate

**Tests fail on CI but pass locally:**
- Check platform-specific code
- Verify all dependencies in DESCRIPTION

**Documentation not updating:**
- Delete `man/` folder and run `devtools::document()`

## Project-Specific Guidelines

### [Domain-Specific Patterns]
[Hvis pakken har specifikke domæne-mønstre]

### [API Design]
[Design principles for package API]

## Constraints

### Breaking Changes
- Deprecate before removing functions
- Use lifecycle package for deprecation warnings
- Document breaking changes in NEWS.md

### CRAN Requirements (if applicable)
- Examples must run in < 5 seconds
- No internet access in examples/tests (unless \donttest)
- All CRAN policies must be followed
