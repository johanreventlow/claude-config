# Gemini CLI Guide for Large Codebase Analysis

Guide til brug af Gemini CLI (`gemini -p`) for store R- og Shiny-kodebaser.

---

## Hvornår Brug Gemini CLI

Brug `gemini -p` når:
- Analysere hele kodebaser (>100KB)
- Forstå sammenhæng mellem moduler
- Finde duplikerede patterns/anti-patterns
- Verificere arkitektur compliance
- Security/performance audit
- Sammenligne implementeringer

**Fordel:** Meget stort kontekstvindue - kan håndtere hele R-pakker/Shiny-apps

---

## Basis Syntax

```bash
gemini -p "prompt"                    # Basic
gemini -p "@file.R prompt"            # Single file
gemini -p "@R/ @tests/ prompt"        # Multiple dirs
gemini --all_files -p "prompt"        # Full project
```

**`@`-stier er relative til arbejdsmappe**

---

## Common Use Cases

| Analyse | Command |
|---------|---------|
| Feature check | `gemini -p "@R/ Is [feature] implemented?"` |
| Logging | `gemini -p "@R/ Is structured logging consistent?"` |
| Architecture | `gemini -p "@R/ Check compliance with [pattern]"` |
| Security | `gemini -p "@R/ Security vulnerabilities?"` |
| Performance | `gemini -p "@R/ Identify bottlenecks"` |
| Dependencies | `gemini -p "@R/ @tests/ Dependency graph"` |
| Code quality | `gemini -p "@R/ Code quality issues?"` |
| Test coverage | `gemini -p "@tests/ @R/ Coverage gaps?"` |

---

## Integration med Workflow

**Brug til:**
1. Arkitektur verification før refaktorering
2. Code review på tværs af moduler
3. Pattern detection (inconsistencies)
4. Dependency analysis før nye features
5. Test coverage gaps
6. Security audit

**Eksempel workflow:**
```bash
# Før refaktorering
gemini -p "@R/ Analyze architecture and identify improvement areas"

# Efter implementation
gemini -p "@R/ Is [pattern] implemented consistently?"

# Test coverage
gemini -p "@tests/ @R/ Are critical paths covered?"
```

---

## When NOT to Use

❌ **Brug IKKE når:**
- Du skal ændre kode (use Claude Code)
- Små files (<10 KB) - brug Claude direkte
- Sensitive/commercial kode

✅ **I stedet:** Brug Claude Code for kodeændringer

---

## Best Practices

**Strukturering:**
```bash
# ✅ God struktur
"Analyze @R/mod_*.R for state consistency issues and race conditions"

# ❌ Dårlig struktur
"Analyze everything"
```

**Follow-up:** Hvis svar er for overordnet:
```bash
"Focus specifically on reactive chain in [module]. Show exact functions."
```

---

**Sidst opdateret:** 2025-10-21
