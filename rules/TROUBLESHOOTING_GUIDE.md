# Troubleshooting Guide

Systematisk tilgang til debugging og problemløsning.

---

## Debugging: 5 Steps

1. Reproducer med minimal case
2. Isolér komponent
3. Analyser logs
4. Test antagelser
5. Instrumenter med `log_debug()`
6. Binary search (deaktiver dele)
7. Dokumentér i tests/KNOWN_ISSUES.md

---

## Common Issues

| Problem | Symptom | Solution |
|---------|---------|----------|
| **Infinite loop** | CPU 100%, freeze | Cirkulære events → guards + `in_progress` check |
| **Race condition** | Inconsistent state | Atomic updates + priorities (se SHINY_ADVANCED_PATTERNS) |
| **Memory leak** | RAM stiger | `session$onSessionEnded` cleanup + `gc()` |
| **Slow reactives** | UI lag | Debounce input + cache + background jobs |
| **CSV parsing** | Encoding fejl | `locale = readr::locale(encoding = "UTF-8")` |
| **Type conversion** | "Cannot add character" | Eksplicit `col_types` i `readr::read_csv()` |
| **Missing values** | Færre punkter end forventet | `colSums(is.na(data))`, explicit NA-håndtering |

---

## Minimal Reproducible Example (MRE)

```r
# ✅ GOD: Minimal, isoleret, reproducerbar
library(MyApp)
test_data <- data.frame(id = 1:10, value = c(0.1, NA, 0.11, ...))
process_data(test_data)
# Error: [SPECIFIC ERROR MESSAGE]
```

**Rapporter med:**
1. Hvad forsøgte du?
2. Hvad skete i stedet?
3. Hvad forventede du?
4. MRE (kode + data)
5. Miljø (R version, pakke version)
6. Relevante log messages

---

## Debug Tools

```r
# Struktureret logging
log_debug("[MODULE]", "Beskrivelse", details = list(var = value))

# Inspect
str(obj), summary(obj), head(obj)

# Verify antagelser
stopifnot(nrow(data) > 0, all(c("x", "y") %in% names(data)))

# Performance
system.time({ operation() })
profvis::profvis({ runApp() })

# Memory
pryr::mem_used()
```

---

## Escalation

**Escalate til external package hvis:**
- Core functionality bugs i pakken
- API limitations
- Performance issues i pakke algorithms
- Manglende features

**Handle in project hvis:**
- Integration layer issues
- Data preprocessing
- Error messages/lokalisering
- Project-specific caching

---

## Known Issues

**Dokumentér i `docs/KNOWN_ISSUES.md`:**
```markdown
### Issue: [Titel]
**Symptom:** Hvad brugeren ser
**Root cause:** Problemet
**Workaround:** Midlertidig løsning
**Fixed in:** Version X.Y.Z (eller "Pending")
```

---

**Sidst opdateret:** 2025-10-21
