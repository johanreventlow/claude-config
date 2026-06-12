# TypeScript Development Standards

TypeScript-udvikling standarder på tværs projekter. Tier 2 profil-rule —
@-importeres fra projekt-CLAUDE.md når projekttype er TypeScript.

---

## Code Style

**Naming:**
- Funktioner/variabler/properties: `camelCase`
- Typer/interfaces/klasser/enums: `PascalCase`
- Konstanter (top-level immutable): `UPPER_SNAKE_CASE`
- Filnavne: `kebab-case.ts` eller `camelCase.ts` (følg eksisterende repo-konvention)
- React-komponenter: `PascalCase.tsx`

**Sprog:**
- Identifiers: engelsk
- Kommentarer: dansk når målgruppe dansk (matcher R-projekter)
- Bruger-vendt UI-tekst: følg projektets sprogvalg

**Encoding:** UTF-8 ALTID. Eksplicit `// @ts-check` ej nødvendig — `tsconfig.json` styrer.

---

## Type Safety

**Strict mode obligatorisk** i `tsconfig.json`:
```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true
  }
}
```

**Regler:**
- ❌ `any` forbudt — brug `unknown` + narrow med type guards
- ❌ `as` type-assertions kun ved sidste udvej (dokumentér hvorfor)
- ✅ `unknown` for externt data (API responses, JSON.parse)
- ✅ Type guards (`is X`-funktioner) for runtime-narrowing
- ✅ Discriminated unions for state-modellering (`type State = { kind: "loading" } | { kind: "ready"; data: T }`)
- ✅ `readonly` for immutable arrays/properties hvor relevant
- ✅ `const`-assertions (`as const`) for literal types

**Generics:** Prefer over overloads. Constrain med `extends` når muligt.

---

## Module System

**ES Modules default:**
```typescript
// ✅ Named imports
import { foo, bar } from "./module";

// ✅ Type-only imports (tree-shakable, eksplicit intent)
import type { Foo } from "./types";

// ❌ Default exports — undgå når muligt (refactor-fjendtligt)
```

**Path conventions:**
- Relative imports for intra-repo (`./`, `../`)
- Bare imports for npm-deps (`react`, `lodash`)
- Path-aliases (`@/`) hvis konfigureret i `tsconfig.json` + bundler

**ESM:** Hvis `package.json` har `"type": "module"`, kræves eksplicit `.js`-extensions i imports (selv for `.ts`-filer).

---

## Error Handling

**Throw `Error`-subklasser, aldrig strings:**
```typescript
// ✅
class ValidationError extends Error {
  constructor(message: string, public readonly field: string) {
    super(message);
    this.name = "ValidationError";
  }
}
throw new ValidationError("Invalid email", "email");

// ❌
throw "Invalid email";
```

**Result-pattern for forventede fejl:**
```typescript
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

function parse(input: string): Result<number> {
  const n = Number(input);
  return isNaN(n)
    ? { ok: false, error: new Error("Not a number") }
    : { ok: true, value: n };
}
```

**Async:** Wrap toplevel awaits i `try/catch` ved I/O. Lad uventede errors propagere.

---

## Testing

**TDD default** ved adfærdsændrende kode (jf. `DEVELOPMENT_PHILOSOPHY.md`).

**Framework:** Følg eksisterende repo-valg:
- `vitest` — moderne default, Vite-baseret
- `jest` — etableret, stort økosystem
- `karma` + `jasmine` — legacy, browser-rendering (fx Power BI visuals)
- `mocha` + `chai` — Node-tooling

**Organisation:**
- Co-located: `foo.ts` + `foo.test.ts` i samme mappe
- Eller `__tests__/`-mappe pr. modul
- Eller `test/`-mappe i repo-rod (følg eksisterende)

**Test-konventioner:**
- `describe("ModuleName", ...)` for grouping
- `it("should do X when Y", ...)` for cases
- Arrange-Act-Assert pattern
- Mock externt — aldrig egen kode (lift dependency til parameter i stedet)

**Coverage:** Ambitionsmål ≥80% på exports. Rapportér eksplicit ved <80%.

---

## Dependencies

**Package management:**
- Lockfile committed: `package-lock.json` | `pnpm-lock.yaml` | `yarn.lock`
- ALDRIG `^X.Y.Z` for kritiske deps i production-libs — pin exact
- `npm audit` / `pnpm audit` månedligt
- `npm outdated` før upgrade-runder

**Namespace:**
- Foretræk explicit imports — undgå wildcard `import *`
- Side-effect imports kun ved polyfills (`import "core-js/stable"`)

**Dev vs runtime:**
- `dependencies`: runtime
- `devDependencies`: build, test, lint, type-deps
- Strict separation — wrong placement bryder production install

---

## Performance

**Type-checking:**
- `tsc --noEmit` for type-only kontrol (hurtigt)
- Inkrementel build: `"incremental": true` i tsconfig
- Project references for monorepos

**Runtime:**
- Foretræk built-ins (`Array.map`, `for...of`) over external lib hvis simple
- Lazy-loading (`import()`-syntax) for store optional modules
- `WeakMap`/`WeakSet` for object-keyed caches der ej skal blokere GC
- Mål før optimering — `console.time` / `performance.now`

**Bundle:** Tree-shaking kræver ES modules. Side-effect-frie pakker markeres `"sideEffects": false` i `package.json`.

---

## Linting & Formatting

**ESLint flat config (`eslint.config.mjs`) default** i nye repos.
Legacy `.eslintrc.json` accepteres i ældre repos.

**Required plugins (typisk):**
- `@typescript-eslint/parser` + `@typescript-eslint/eslint-plugin`
- `eslint-plugin-import` for module-order
- Project-specifikke (React, Vue, osv.)

**Prettier:** Brug hvis repo har `.prettierrc`. Ej dobbelt-konfigurér style i ESLint.

**Pre-commit:** `npm run lint` + `npm run typecheck` skal være rene.

---

## Documentation

**TSDoc for alle exports:**
```typescript
/**
 * Beregner medianen af en numerisk array.
 *
 * @param values - Input-array (mindst ét element)
 * @returns Medianen — eller `NaN` for tom array
 * @throws {RangeError} hvis array er tom og strict mode aktiv
 *
 * @example
 * ```ts
 * median([1, 2, 3, 4]); // 2.5
 * ```
 */
export function median(values: readonly number[]): number { ... }
```

**Inline-kommentarer:**
Forklar "hvorfor", ikke "hvad":
```typescript
// ✅ God: Anhøj-tærskel kræver log2(n) + 3 baseret på qicharts2-reference
const maxRun = Math.round(Math.log2(nUseful)) + 3;

// ❌ Dårlig: Beregn maxRun
const maxRun = Math.round(Math.log2(nUseful)) + 3;
```

---

## Pre-Commit Checklist (TS-specific)

Se `DEVELOPMENT_PHILOSOPHY.md` for master-liste. TS-specifikke tilføjelser:

- [ ] `npm run typecheck` (eller `tsc --noEmit`) rent
- [ ] `npm run lint` rent
- [ ] `npm test` bestået
- [ ] Lockfile commited hvis deps ændret
- [ ] Ingen `any` introduceret (medmindre dokumenteret)
- [ ] Ingen `console.log` i production-paths
- [ ] Ingen `// @ts-ignore` uden begrundelse-kommentar

---

**Sidst opdateret:** 2026-05-19
**Del af:** ~/.claude/rules-profiles/typescript/
