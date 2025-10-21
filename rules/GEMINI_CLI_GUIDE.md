# Gemini CLI Guide for Large Codebase Analysis

Guide til at bruge Gemini CLI (`gemini -p`) for at analysere store R- og Shiny-kodebaser.

---

## 1) Hvornår Brug Gemini CLI

Brug `gemini -p` når du skal:

* **Analysere hele R- eller Shiny-kodebaser** på tværs af mange filer
* **Forstå sammenhængen mellem moduler, reaktive kæder og helpers**
* **Finde duplikerede mønstre eller anti-patterns** (fx ukontrollerede `observe()`-kald)
* Arbejde med **mange filer (>100 KB samlet)** eller **komplekse Shiny-projekter**
* **Sammenligne implementeringer** (fx ny vs. gammel logging, caching, theme-pakke)
* **Verificere arkitektur, moduler og funktionalitet** på tværs af hele projektet
* **Få et overblik over afhængigheder, imports og pakke-struktur**

**Fordel:** Gemini har et **meget stort kontekstvindue** og kan håndtere **hele R-pakker eller Shiny-apps** der ville overstige andre modellers grænser.

---

## 2) Basis Kommando og Fil-inklusion

### 2.1 Basis Kommando

```bash
gemini -p "din prompt her"
```

### 2.2 `@`-Syntaks til Fil-inklusion

Brug `@` til at inkludere filer eller mapper direkte i prompten. **Stier skal være relative til arbejdsmappen.**

**Enkeltfil-analyse:**
```bash
gemini -p "@app.R Forklar hvordan denne Shiny-app er struktureret og hvilke reaktive elementer den indeholder"
```

**Flere filer:**
```bash
gemini -p "@R/server.R @R/ui.R Beskriv hvordan input, reaktive udtryk og outputs hænger sammen"
```

**Hele pakken eller appen:**
```bash
gemini -p "@R/ @inst/ Summarize the architecture and modular structure of this Shiny package"
```

**Inkluder tests og hjælpefiler:**
```bash
gemini -p "@R/ @tests/testthat/ Analyze unit test coverage and identify missing test areas"
```

**Analyse af hele projektet:**
```bash
gemini -p "@./ Give me an overview of this R Shiny project – main modules, dependencies, and architecture"

# Alternativt:
gemini --all_files -p "Analyze project structure, dependencies, and logging implementation"
```

---

## 3) Implementerings-tjek Eksempler

### 3.1 Tjek om specifikke features er implementeret

```bash
gemini -p "@R/ Has the new export feature been implemented? Show relevant functions and files"
```

### 3.2 Verificér logging

```bash
gemini -p "@R/ Is structured logging implemented consistently across all modules and functions?"
```

### 3.3 Reaktivitet og performance

```bash
gemini -p "@R/ Is reactive chain management handled properly to avoid circular dependencies or redundant computations?"
```

### 3.4 Fejlhåndtering

```bash
gemini -p "@R/ Are tryCatch or safe_call used consistently to handle runtime errors in Shiny observers and reactives?"
```

### 3.5 Caching og datalagring

```bash
gemini -p "@R/ @data/ Is any caching mechanism (e.g. memoise or duckdb caching) implemented for heavy computations?"
```

### 3.6 Testdækning

```bash
gemini -p "@tests/ @R/ Are critical modules and business logic covered by unit tests?"
```

### 3.7 Sikkerhed

```bash
gemini -p "@app.R @R/ Check for potential security issues – are user inputs validated and sanitized before database operations?"
```

---

## 4) Avancerede Analyse Prompts

### 4.1 Dependency graph

```bash
gemini -p "@R/ @modules/ @tests/ Create a dependency graph of all modules and explain their interrelations"
```

### 4.2 Helper functions oversigt

```bash
gemini -p "@R/utils/ Summarize all helper functions and classify them by purpose (logging, data, plotting, etc.)"
```

### 4.3 Code quality evaluering

```bash
gemini -p "@R/ @inst/theme/ Evaluate code quality and naming consistency for this custom ggplot theme package"
```

### 4.4 Data flow mapping

```bash
gemini -p "@R/ @data/ Identify where SPC data is loaded, transformed, and visualized; map out the data flow"
```

### 4.5 Detect unused code

```bash
gemini -p "@R/ Detect unused or redundant functions in the codebase"
```

### 4.6 Architecture compliance

```bash
gemini -p "@R/ Check if this codebase follows Single Responsibility Principle and event-driven patterns"
```

### 4.7 Performance bottleneck identification

```bash
gemini -p "@R/fct_*.R Identify potential performance bottlenecks in file operations and data transformations"
```

---

## 5) Vigtige Noter

* `@`-stier er **relative til din aktuelle arbejdsmappe** når du kører `gemini`
* CLI'en **indsætter filindhold direkte i konteksten**
* Du behøver **ikke** `--yolo`-flag for læse-analyse
* Gemini's kontekstvindue kan håndtere **hele R-pakker eller Shiny-apps**
* **Vær præcis** i prompten for at få brugbare resultater
* Start med high-level oversigt, drill down i detaljer hvis nødvendigt

---

## 6) Integration med Development Workflow

Brug Gemini CLI til:

1. **Arkitektur verification** før større refaktorering
2. **Code review** på tværs af moduler
3. **Pattern detection** for at identificere inconsistencies
4. **Dependency analysis** før nye features
5. **Test coverage gaps** identifikation
6. **Security audit** af hele codebase

### 6.1 Eksempel Workflow (generelt)

```bash
# 1. Analysér før refaktorering
gemini -p "@R/ Analyze current architecture and identify areas for improvement"

# 2. Verificér efter implementation
gemini -p "@R/ Has the new pattern been implemented consistently across the codebase?"

# 3. Test coverage check
gemini -p "@tests/ @R/ Are all critical code paths covered by unit tests?"

# 4. Performance audit
gemini -p "@R/ Identify performance bottlenecks: inefficient loops, missing caches, or circular dependencies"

# 5. Security check
gemini -p "@R/ Check for potential security vulnerabilities: unvalidated inputs, unsafe operations, or data leaks"
```

### 6.2 Projekt-Specifik Tilpasning

Juster kommandoer baseret på dit projekt:

- **R Package:** Focus på documentation, test coverage, API design
- **Shiny App:** Focus på reactive patterns, state management, race conditions
- **Quarto:** Focus på render performance, listings, cross-references

---

## 7) Tips & Tricks

### 7.1 Strukturering af Prompts

**God struktur:**
```
"I have a Shiny app with these modules: @R/mod_*.R

Are there any state consistency issues between these modules?
Also check for potential race conditions and circular dependencies."
```

**Dårlig struktur:**
```
"Analyze everything"
```

### 7.2 Få Mere Detalje

Hvis svaret er for overordnet, follow-up:
```bash
gemini -p "... (fra tidligere query)

Now focus specifically on the reactive chain in [specific module].
Show me the exact functions and dependencies."
```

### 7.3 Sammenligning af Implementeringer

```bash
gemini -p "Compare these two logging approaches:

Old way: @old_code/logging.R
New way: @new_code/logging.R

Which is better for performance and maintainability?"
```

---

## 8) Når IKKE at Bruge Gemini CLI

❌ **Brug IKKE Gemini CLI når:**
- Du skal ændre kode (use Claude Code for det)
- Du har små files (<10 KB) - brug Claude direkte
- Du er usikker på security/privacy af kodebase
- Du har sensitive kommerciel kode

✅ **I stedet:** Brug Claude Code direkte for kodeændringer

---

## 9) Best Practices

### 9.1 Styre Kontekstvinduesstørrelse

Hvis hele projektet er enormt:
```bash
# Start småt
gemini -p "@R/utils/ Summarize helper functions"

# Derefter ekspandér
gemini -p "@R/ @tests/ Full codebase analysis"
```

### 9.2 Dokumenter Resultater

Gem vigtige Gemini-analyser:
```bash
# Export til markdown
gemini -p "@R/ ... spørgsmål ..." > analysis-$(date +%Y%m%d).md

# Reference i ADR eller docs/
# Brug som basis for refactoring plan
```

### 9.3 Gentag Analyser Periodisk

```bash
# Månedlig: Check for code drift
gemini -p "@R/ Has our code quality degraded? Any new anti-patterns?"

# Før major releases: Full audit
gemini -p "@./ Full security, performance, and architecture audit"
```

---

**Sidst opdateret:** 2025-10-21
**Del af:** ~/.claude/ global configuration system
