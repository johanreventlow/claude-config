# Claude Bootstrap Workflow

**Denne fil dokumenterer PROCEDUREN som Claude følger når arbejde starter i et af dine projekter.**

Hver gang du starter en session i et projekt, skal jeg automatisk udføre denne bootstrap-procedure.

---

## 📚 Centraliserede Guidelines Oversigt

**5 nye comprehensive rule files** dækker områder fra CLAUDE.md.backup:

| File | Dækker | Vigtige Områder |
|------|--------|-----------------|
| `DEVELOPMENT_PHILOSOPHY.md` | Punkt 11+12 | Philosophy, Communication, ADR'er, Quality standards |
| `GEMINI_CLI_GUIDE.md` | Punkt 13 | Large codebase analysis med Gemini CLI |
| `SHINY_ADVANCED_PATTERNS.md` | Punkt 3 | Event architecture, State management, Race conditions |
| `TROUBLESHOOTING_GUIDE.md` | Punkt 8 | Debugging methodology, Common issues, Escalation |
| `ARCHITECTURE_PATTERNS.md` | Punkt 6+10 | File organization, State patterns, Modularity |

Derudover eksisterer:
- `R_STANDARDS.md` - R development conventions
- `SHINY_STANDARDS.md` - Shiny best practices
- `GIT_WORKFLOW.md` - Git workflow + OBLIGATORISKE regler
- `QUARTO_STANDARDS.md` - Quarto development

---

## 🚀 Bootstrap Procedure (Trin for Trin)

### Trin 1: Identificer Projekttypen

Læs den lokale `CLAUDE.md` og find `## Project Overview` sektionen:

```markdown
## Project Overview

**[Project Name]** - [Beskrivelse]
**Type:** [Shiny | R Package | Quarto | Generic]
```

### Trin 2: Læs Globale Standarder Baseret på Type

Baseret på projekttype, læs automatisk disse filer:

#### 🟦 Shiny Application
```
ALTID læs (centraliseret guides):
- ~/.claude/rules/R_STANDARDS.md
- ~/.claude/rules/SHINY_STANDARDS.md
- ~/.claude/rules/SHINY_ADVANCED_PATTERNS.md
- ~/.claude/rules/GIT_WORKFLOW.md
- ~/.claude/rules/DEVELOPMENT_PHILOSOPHY.md

Specifikke projekter:
- ~/.claude/rules/ARCHITECTURE_PATTERNS.md (hvis relevant)
- ~/.claude/rules/TROUBLESHOOTING_GUIDE.md (ved fejlfinding)

Derefter:
- Lokal CLAUDE.md (projekt-specifik override)
```

#### 📦 R Package
```
ALTID læs (centraliseret guides):
- ~/.claude/rules/R_STANDARDS.md
- ~/.claude/rules/ARCHITECTURE_PATTERNS.md
- ~/.claude/rules/GIT_WORKFLOW.md
- ~/.claude/rules/DEVELOPMENT_PHILOSOPHY.md

Specifikke projekter:
- ~/.claude/rules/TROUBLESHOOTING_GUIDE.md (ved fejlfinding)
- ~/.claude/rules/GEMINI_CLI_GUIDE.md (for codebase analyse)

Derefter:
- Lokal CLAUDE.md (projekt-specifik override)
```

#### 📄 Quarto Website/Publication
```
ALTID læs (centraliseret guides):
- ~/.claude/rules/QUARTO_STANDARDS.md
- ~/.claude/rules/GIT_WORKFLOW.md
- ~/.claude/rules/DEVELOPMENT_PHILOSOPHY.md

Specifikke projekter:
- ~/.claude/rules/TROUBLESHOOTING_GUIDE.md (ved fejlfinding)

Derefter:
- Lokal CLAUDE.md (projekt-specifik override)
```

#### 🔧 Generic R Project
```
ALTID læs (centraliseret guides):
- ~/.claude/rules/R_STANDARDS.md
- ~/.claude/rules/ARCHITECTURE_PATTERNS.md
- ~/.claude/rules/GIT_WORKFLOW.md
- ~/.claude/rules/DEVELOPMENT_PHILOSOPHY.md

Specifikke projekter:
- ~/.claude/rules/TROUBLESHOOTING_GUIDE.md (ved fejlfinding)
- ~/.claude/rules/GEMINI_CLI_GUIDE.md (for codebase analyse)

Derefter:
- Lokal CLAUDE.md (projekt-specifik override)
```

### Trin 3: Anvend Standarderne

Nu når jeg har læst alle relevante standarder, skal jeg:

1. **Enforce regler** ved code review
2. **Foreslå struktur** baseret på best practices
3. **Foreslå git workflow** baseret på GIT_WORKFLOW.md
4. **Flag afvigelser** fra standarderne

---

## 📋 Enforcement Rules (Efter Bootstrap)

### For Alle Projekttyper

✅ **Gør automatisk:**
- Læs lokale CLAUDE.md + relevante globale filer
- Foreslå git branches baseret på GIT_WORKFLOW.md
- Enforce commit message format
- Flag manglende tests
- Kontroller pre-commit checklist

❌ **Gør IKKE automatisk - OBLIGATORISKE REGLER:**
- Commit direkte til main/master
- Merge til main/master uden eksplicit godkendelse
- Push til remote uden anmodning
- Ændre git config
- Skrive filer uden godkendelse
- **ALDRIG tilføj Claude attribution footers** til commits
  - ❌ "🤖 Generated with Claude Code"
  - ❌ "Co-Authored-By: Claude <noreply@anthropic.com>"
  - ❌ Anden AI attribution
  - ✅ Commits skal være 100% dine egne
- Push og merge uden eksplicit instruktion

### For Shiny Apps (Ekstra)

✅ **Ekstra enforcement:**
- Kontroller reactive patterns mod SHINY_STANDARDS.md
- Flag potential reactive storms
- Foreslå reactive prioritization
- Check for proper error handling

### For R Packages (Ekstra)

✅ **Ekstra enforcement:**
- Kontroller `devtools::check()` status
- Enforce documentation requirements
- Kontroller test coverage
- Flag NAMESPACE/manual edits

### For Quarto (Ekstra)

✅ **Ekstra enforcement:**
- Kontroller render output
- Validér listings og cross-references
- Check for broken links

---

## 🔍 Example: Full Bootstrap in BFHcharts

```
Session Start in BFHcharts:

1. Læs ~/Documents/R/BFHcharts/CLAUDE.md
   → Identificer: "R Package" type

2. Læs relevante globale filer:
   ✅ ~/.claude/rules/R_STANDARDS.md
   ✅ ~/.claude/rules/GIT_WORKFLOW.md

3. Anvend standarder:
   - Expect: Roxygen2 documentation
   - Expect: testthat tests, ≥90% coverage
   - Expect: devtools::check() pass
   - Expect: Feature branches (feat/*)
   - Expect: Dansk commit messages
   - Expect: TDD approach

4. Work guidet af alle disse standarder
```

---

## 📌 Visual Workflow

```
┌─────────────────────────────────┐
│ User starts session in projekt  │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│ Claude: Læs lokal CLAUDE.md     │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│ Claude: Identificer projekttype │
│ (Shiny? Package? Quarto?)       │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│ Claude: Læs relevante globale   │
│ standards baseret på type       │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│ Claude: Anvend alle standarder  │
│ gennem hele session             │
└─────────────────────────────────┘
```

---

## 🎯 Praktisk Implementering

### Jeg skal spørge mig selv:

```
1. Hvad er projekttypen? (Scan CLAUDE.md)
2. Hvilke globale rules skal jeg følge? (Check liste ovenfor)
3. Har jeg læst dem alle? (Var jeg proaktiv?)
4. Kan jeg forklare standarderne? (Kunne jeg forsvare mig?)
5. Giver det mening for projektet? (Eller skal der være project-overrides?)
```

---

## ✅ Checklist for Bootstrap

- [ ] Læst lokal CLAUDE.md
- [ ] Identificeret projekttype
- [ ] Læst alle relevante globale rules
- [ ] Forstået projekt-specifik guidance
- [ ] Klar til at enforce standarder
- [ ] Kan foreslå struktur+workflow

---

## 📝 Note for Brugeren

**Du behøver ikke at gøre noget!** Jeg udfører denne bootstrap automatisk når jeg starter i et af dine projekter.

Du vil muligvis mærke:
- Mere konsistente forslag
- Bedre enforcement af dine standards
- Proaktive suggestions baseret på best practices
- Færre spørgsmål om "hvad vil du have?"

Dette kommer fra at jeg læser alle relevante standarder automatisk.

---

**Sidst opdateret:** 2025-10-21
**Del af:** ~/.claude/ global configuration system
