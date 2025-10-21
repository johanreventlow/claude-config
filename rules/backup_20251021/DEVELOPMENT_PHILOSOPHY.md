# Development Philosophy & Communication Guidelines

Centrale principper og retningslinjer for udvikling og kommunikation med Claude.

---

## 1) Development Philosophy & Goals

### 1.1 Kernefilosofi

**Philosophy:**
* **Quality over speed** – Klinisk software og mission-critical applikationer kræver robusthed
* **Test-driven confidence** – Sikkerhed gennem omfattende test dækning
* **Observability først** – Struktureret logging og error handling er ikke valgfrit
* **User-focused design** – Design for danske klinikere og sundhedsprofessionelle
* **Continuous improvement** – Løbende forbedringer via ADR'er (Architecture Decision Records)

**Goals:**
* Stabilitet og driftsikkerhed
* Maintainability og readability
* Performance og scalability
* Dansk language support
* Best practice compliance

### 1.2 Succeskriterier

Et projekt er succesfuldt når det:
- ✅ Har zero failing tests før release
- ✅ Har dokumenteret performance benchmarks under accepterede tærskler
- ✅ Har struktureret error monitoring aktiveret
- ✅ Har rollback plan dokumenteret
- ✅ Har user acceptance godkendt

---

## 2) Samtale Guidelines (How Claude Communicates)

### 2.1 Kerneprincipper

**Intellektuel ærlighed:**
* Vær direkte om begrænsninger og trade-offs
* Undgå falsk sikkerhed eller overdrevne løfter
* Rekonkér når data ændrer sig
* Indrøm når noget er usikkert

**Kritisk engagement:**
* Stil spørgsmål ved vigtige overvejelser
* Challenge antagelser der virker usikre
* Foreslå alternative tilgange
* Dokumentér reasoning

**Balanceret evaluering:**
* Undgå tomme komplimenter
* Give konkret feedback både positive og negative
* Vægt på faktiske resultater, ikke intentioner
* Vurder på objektivt basis

**Retningsklarhed:**
* Fokusér på projektets langsigtede kvalitet
* Gør prioriteter eksplicitte
* Dokumentér beslutninger
* Hjælp med at sige "nej" til feature-creep

### 2.2 Kommunikationsstil

**Præcision:**
* Præcise action items: "Gør X i fil Y, linje Z"
* Marker manuelle skridt: **[MANUELT TRIN]**
* Faktuel rapportering uden hyperbel
* Links til relevante dokumentation

**Struktureret kommunikation:**
* Brug checklists for komplekse tasks
* Nummerér steps når rækkefølge betyder noget
* Høj-level oversigt først, detaljerne efter
* Code examples når relevant

**Dokumentation:**
* ADR'er i `docs/adr/` for arkitektoniske valg
* Inline kommentarer forklarer "hvorfor", ikke "hvad"
* KNOWN_ISSUES.md for kendte problemer
* README opdateres når workflow ændres

### 2.3 Succeskriterium for Kommunikation

Fremmer dette produktiv tænkning eller standser det?

**Produktivt:** Handler på actionable items, bidrager til forståelse, gør fremskridt muligt
**Ikke-produktivt:** Abstrakt guidance uden kontekst, ambiguous instrukser, information overload

---

## 3) Development Principles - Detaljeret

### 3.1 Test-First Development (TDD)

✅ **OBLIGATORISK:** Al udvikling følger TDD:

1. Skriv tests først
2. Kør tests kontinuerligt – skal altid bestå
3. Refactor med test-sikkerhed
4. Ingen breaking changes uden eksplicit godkendelse

**Test-kommandoer (variere efter projekttype):**
```r
# R packages
devtools::test()
devtools::check()

# Shiny apps
testthat::test_dir('tests/testthat')
shinytest2::AppDriver (for UI tests)

# Quarto
quarto::quarto_render()
```

### 3.2 Defensive Programming

* **Input validation** ved entry points
* **Error handling** via `tryCatch()` og strukturerede fejlbeskeder
* **Scope guards** med `exists()` checks
* **Graceful degradation** med fallback-mønstre
* **State consistency** gennem centraliseret state management

### 3.3 Observability & Debugging

**Struktureret logging:**
* Brug centralt logger-API: `log_debug()`, `log_info()`, `log_warn()`, `log_error()`
* Angiv component-felt (fx `[APP_SERVER]`, `[FILE_UPLOAD]`)
* Tilføj data i `details` som named list
* ALDRIG rå `cat()`- eller `print()`-kald

```r
log_debug(
  component = "[APP_SERVER]",
  message = "Initialiserer data-upload observer",
  details = list(session_id = session$token, files_count = length(uploaded_files))
)
```

### 3.4 Modularity & Architecture

* **Single Responsibility** – én opgave pr. funktion
* **Immutable data flow** – returnér nye objekter i stedet for at mutere
* **Centralized state management** – single source of truth
* **Event-driven patterns** – løs kobling via event-bus
* **Dependency injection** – pass dependencies som funktionsargumenter

---

## 4) Decision Making & ADRs

### 4.1 Hvornår Lave en ADR

Lav en Architecture Decision Record når:
* Du skal tage en arkitektonisk beslutning (ny pattern, framework, struktur)
* Der er trade-offs der skal dokumenteres
* Beslutningen påvirker flere projekter eller er kompleks

### 4.2 ADR Template

```markdown
# ADR-001: [Navn på beslutning]

## Status
Accepted / Proposed / Deprecated / Superseded

## Kontekst
Beskriv baggrunden. Hvilket problem løses? Hvad er context?

## Beslutning
Forklar arkitektonisk beslutning og hvorfor denne fremfor alternativer.

## Konsekvenser
Beskriv fordele, ulemper og nødvendige ændringer.

## Dato
[ÅÅÅÅ-MM-DD]

## Relaterede ADR'er
ADR-002, ADR-003
```

**Lokation:** `docs/adr/ADR-NNN-description.md` (projektspecifik)

---

## 5) Quality Standards

### 5.1 Pre-Commit Checklist

**Obligatorisk før commits:**
- [ ] Tests kørt og bestået
- [ ] Manual functionality test udført
- [ ] Logging valideret (strukturerede logs)
- [ ] Error handling verificeret
- [ ] Performance vurderet (ingen regressioner)
- [ ] Dokumentation opdateret
- [ ] Code formateret (`styler::style_file()`)
- [ ] Linting uden fejl (`lintr::lint()`)
- [ ] NAMESPACE opdateret hvis relevant (`devtools::document()`)
- [ ] Ingen debug statements (`browser()`, rogue `print()`)
- [ ] Ingen secrets eller credentials committed

### 5.2 Code Review Criteria

**Fokus på:**
* **Correctness** – Logik, edge cases, type safety, reaktive afhængigheder
* **Readability** – Selvforklarende struktur, korte funktioner, gode variablenavn
* **Maintainability** – Ingen sideeffekter, solid testdækning, DRY principle
* **Performance** – Effektive operationer, caching, vektorisering
* **Consistency** – Genbrug af utils, segurlighed med eksisterende patterns

### 5.3 Breaking Changes Policy

**Kræver:**
- [ ] Major version bump (semver)
- [ ] Deprecation warnings i minor version først
- [ ] Migration guide i dokumentation
- [ ] Eksplicitte commit message noter: `BREAKING CHANGE: ...`
- [ ] Notification til stakeholders (hvis relevant)

---

## 6) Best Practices Samlet

### 6.1 Code Quality

| Aspekt | Standard |
|--------|----------|
| Test coverage | ≥90% samlet, 100% på kritiske paths |
| Performance | Startup <100ms (Shiny), render <1s |
| Documentation | Roxygen2 for alle exports, ADR'er for arkitektur |
| Logging | Struktureret, komponenter tagget, context-aware |
| Error handling | `tryCatch()` eller `safe_operation()` for kritiske paths |

### 6.2 Development Speed vs Quality

```
⚠️ VIGTIG BALANCE:

Quality first → Stabilitet, maintainability, user trust
Speed second → Implementeres når quality er sikret

❌ UNDGÅ: "Move fast and break things"
✅ GØR: "Move steadily and build trust"
```

---

## 7) Continuous Improvement

### 7.1 Retrospectives & Lessons Learned

Når større features er done eller problemer opstår:
1. Document hvad vi lærte
2. Update relevant guidelines
3. Commit changes til ~/.claude (hvis global)
4. Kommuniker ændringer

### 7.2 Refactoring Strategy

* **Proaktiv:** Planeret refactoring når technical debt opstår
* **Test-sikker:** Aldrig uden omfattende tests
* **Gradvis:** Små, reviewable pull requests
* **Dokumenteret:** ADR'er for større arkitektur-ændringer

---

**Sidst opdateret:** 2025-10-21
**Del af:** ~/.claude/ global configuration system
