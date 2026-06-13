# TypeScript Development Standards

Org-specifikke TS-konventioner. Tier 2-profil — @-importeres fra
projekt-CLAUDE.md når projekttype er TypeScript.

---

## Naming & sprog

- Funktioner/variabler: `camelCase` · Typer/interfaces/klasser: `PascalCase`
  · Konstanter: `UPPER_SNAKE_CASE` · Filnavne: følg eksisterende
  repo-konvention (`kebab-case.ts` el. `camelCase.ts`) · React: `PascalCase.tsx`
- Identifiers: engelsk. Kommentarer: dansk når målgruppe dansk (matcher
  R-projekter). Forklar "hvorfor", ej "hvad".
- UTF-8 altid.

## Type safety (org-krav)

- `strict: true` + `noUncheckedIndexedAccess` + `exactOptionalPropertyTypes`
  i tsconfig.
- ❌ `any` forbudt — `unknown` + type guards. `as`-assertions kun ved
  sidste udvej med begrundelse.
- Discriminated unions for state-modellering. `as const` for literal types.
- Default exports undgås (refactor-fjendtlige); `import type` for type-only.

## Error handling

`Error`-subklasser (aldrig strings); Result-pattern
(`{ ok: true; value } | { ok: false; error }`) for forventede fejl.

## Testing

- TDD for adfærdsændrende kode (jf. `DEVELOPMENT_PHILOSOPHY.md`).
- Framework: følg repo-valg — `vitest` default i nye repos;
  `karma`+`jasmine` i Power BI visuals (browser-rendering påkrævet).
- Mock externt — aldrig egen kode (lift dependency til parameter).
- Coverage-ambition ≥80% på exports; rapportér eksplicit ved <80%.

## Dependencies

- Lockfile committed. Pin exact versions for kritiske deps i
  production-libs (ej `^X.Y.Z`).
- `npm audit` månedligt.

## Pre-commit (TS-tilføjelser til master-liste)

- [ ] `tsc --noEmit` + `npm run lint` rene
- [ ] `npm test` bestået; lockfile committed hvis deps ændret
- [ ] Ingen `any` / `// @ts-ignore` uden begrundelse
- [ ] Ingen `console.log` i production-paths
- [ ] TSDoc på alle exports

---

**Sidst opdateret:** 2026-06-12
**Del af:** ~/.claude/rules-profiles/typescript/
