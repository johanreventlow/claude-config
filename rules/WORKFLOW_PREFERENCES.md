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

## Superpowers Plugin (Obligatorisk)

Superpowers skills skal bruges proaktivt.

### Proaktive Skills

| Situation | Skill | Hvornår |
|-----------|-------|---------|
| Ny feature / kreativt arbejde | `brainstorming` | ALTID før implementation |
| Implementation af plan | `writing-plans` | Når design er godkendt |
| Fejl / uventet behavior | `systematic-debugging` | ALTID før fixes |
| Kode skrevet | `verification-before-completion` | Før commit/PR |
| Tests | `test-driven-development` | ALTID ved nye features |
| Feature branch færdig | `finishing-a-development-branch` | Ved completion |
| Code review modtaget | `receiving-code-review` | Før ændringer |
| **Før commit** | **`/simplify`** | **ALTID før git commit** |

### Pre-Commit: /simplify (Obligatorisk)

`/simplify` SKAL køres før enhver commit. Den reviewer ændret kode for:
- Code reuse (duplikeret funktionalitet)
- Code quality (hacky patterns, leaky abstractions)
- Efficiency (unødvendigt arbejde, memory issues)

Eventuelle findings fixes inden commit udføres.

### Regel
Hvis der er bare 1% chance for at en skill er relevant,
SKAL den invokeres via Skill tool.

---

**Sidst opdateret:** 2026-03-20
**Del af:** ~/.claude/ global configuration system
