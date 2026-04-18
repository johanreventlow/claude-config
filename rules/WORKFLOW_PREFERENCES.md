# Workflow Preferences

Brugerens foretrukne arbejdsmetoder og tools.

---

## OpenSpec (Obligatorisk)

OpenSpec er standard change management for ALLE projekter.

### Proaktiv Enforcement

✅ **Gør automatisk:**
- Foreslå `openspec init` hvis openspec/ ikke findes i projektet
- Foreslå `/openspec:proposal` ved:
  - Nye features/capabilities
  - Breaking changes til public API
  - Arkitektur-ændringer
  - Performance/security ændringer der påvirker behavior
- Brug `openspec list` og `openspec spec list` til at forstå kontekst
- Link OpenSpec changes til GitHub Issues

❌ **Skip OpenSpec for:**
- Bug fixes der genopretter existing behavior
- Typos, formatering, kommentarer
- Dependency updates (non-breaking)
- Konfigurationsændringer
- Tests for eksisterende behavior

### Workflow
1. **Proposal** → `/openspec:proposal` → godkendelse
2. **Implementation** → `/openspec:apply` → kode
3. **Archival** → `/openspec:archive` → deploy

---

## Superpowers Plugin (Kontekstuel)

Superpowers skills er kraftfulde værktøjer — brug dem når de reelt matcher
opgaven. Brug din vurdering baseret på opgavens karakter frem for at
invokere "for sikkerheds skyld".

### Kontekstuelle Skills

| Situation | Skill | Hvornår |
|-----------|-------|---------|
| Ny feature / større designvalg | `brainstorming` | Før implementation (ikke ved små ændringer eller forklaringsspørgsmål) |
| Godkendt plan klar til multi-fil refactor | `writing-plans` | Ved kompleks implementation med edge-cases |
| Ikke-triviel bug / uventet behavior | `systematic-debugging` | Før fixes (ikke ved almindelige syntaksfejl) |
| Færdiggørelse af arbejde | `verification-before-completion` | Før PR eller "færdig"-claim |
| Adfærdsændrende kode | `test-driven-development` | Ved ny funktionalitet eller logik-bugfix |
| Feature branch færdig | `finishing-a-development-branch` | Ved completion |
| Code review modtaget | `receiving-code-review` | Før ændringer implementeres |
| Ikke-triviel kode-commit | `/simplify` | > 10 linjer R-kode eller ny funktion/modul |

### Pre-Commit: /simplify (Kontekstuel)

`/simplify` bør køres før commits med **ikke-trivielle kode-ændringer**
(typisk > 10 linjer R-kode eller ny funktion/modul). Den reviewer ændret
kode for:
- Code reuse (duplikeret funktionalitet)
- Code quality (hacky patterns, leaky abstractions)
- Efficiency (unødvendigt arbejde, memory issues)

Eventuelle findings fixes inden commit udføres.

**Ikke nødvendig for:**
- Docs, typos, kommentarer
- Config-justeringer, dependency-bumps
- Tests for eksisterende adfærd
- Rene refactors uden adfærdsændring

### Skill-invokation: Brug din vurdering

Invoker skills når de reelt matcher opgaven — ikke "for sikkerheds skyld".
Brugerens eksplicitte `/command` invokeres altid. Når ingen skill matcher:
proceed direkte med din bedste vurdering.

---

**Sidst opdateret:** 2026-03-20
**Del af:** ~/.claude/ global configuration system
