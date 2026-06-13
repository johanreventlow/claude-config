# Development Philosophy

Centrale udviklings-principper.

---

## Principper

- **Quality > speed**: Robusthed først.
- **TDD (risk-based)**: Tests først for adfærdsændrende kode. Ej påkrævet:
  docs, kommentarer, formatering, CI-config, rene refactors uden
  adfærdsændring. Testniveau matcher risiko — kritiske paths (data-load,
  state-sync, beregninger der driver UI) SKAL dækkes. Ambitionsmål ≥90%
  samlet, ej blokerende for små fixes. Rapportér kørte/sprungne tests.
- **Observability**: Struktureret logging obligatorisk i production-paths
  via `log_debug`/`log_info`/`log_warn`/`log_error` med `component`-tag +
  named `details`. ALDRIG rå `cat()`. Production-setup:
  `OBSERVABILITY_STANDARDS.md` (on-demand).
- **Breaking changes**: Se `VERSIONING_POLICY.md`.
- **User-focused**: Design til danske klinikere/brugere.
- **ADR'er** for arkitektoniske beslutninger → `docs/adr/ADR-NNN-beskrivelse.md`
  (Status/Kontekst/Beslutning/Konsekvenser/Dato).

---

## safe_operation() pattern

Kritiske operationer wrappes:

```r
safe_operation <- function(operation_name, code, fallback = NULL, session = NULL) {
  tryCatch({
    code
  }, error = function(e) {
    log_error("[ERROR_HANDLER]", paste(operation_name, "fejlede"),
      details = list(error_message = e$message), session = session)
    return(fallback)
  })
}
```

Suppleret af: input validation ved entry points, `exists()`-guards,
graceful degradation med fallbacks, centraliseret state.

---

## Pre-Commit Checklist (master — eneste kilde)

- [ ] Tests kørt + bestået
- [ ] Manuel funktionstest
- [ ] Struktureret logging valideret
- [ ] Error handling verificeret
- [ ] Dokumentation opdateret
- [ ] Formateret (`styler::style_file()`) + lint ren (`lintr::lint()`)
- [ ] NAMESPACE opdateret hvis relevant (`devtools::document()`)
- [ ] Ingen debug statements (`browser()`, rogue `print()`)
- [ ] Ingen secrets committed
- [ ] UTF-8 encoding verificeret (R)

---

## Quality Standards

| Aspekt | Standard |
|--------|----------|
| Test coverage | Risk-based; kritiske paths dækkes; dokumentér skipped + hvorfor |
| Performance | Startup <100ms (Shiny), render <1s |
| Documentation | Roxygen2 alle exports, ADR'er arkitektur |
| Error handling | `safe_operation()` i kritiske paths |

---

**Sidst opdateret:** 2026-06-12
