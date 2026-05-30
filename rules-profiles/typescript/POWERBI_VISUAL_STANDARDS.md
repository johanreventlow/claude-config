# Power BI Custom Visual Standards

Standarder for Power BI custom visuals (TypeScript + Power BI Visuals
SDK). Tier 2 sub-profil — @-importeres sammen med
`TYPESCRIPT_STANDARDS.md` når projekt er Power BI visual.

---

## Projekt-identifikation

Power BI custom visual: indeholder
- `pbiviz.json` (visual-metadata)
- `capabilities.json` (data-kontrakt + formatting roles)
- Dependency `powerbi-visuals-api` i `package.json`
- Build via `pbiviz package` (ej `webpack` direkte)

---

## Build Pipeline

**Toolchain:**
- `pbiviz` CLI (Microsoft) — orchestrerer webpack + asset-packaging
- Output: `dist/<name>.pbiviz` (zip-baseret container)

**Standard commands:**
```bash
pbiviz start           # Live dev-server (cert kræves)
pbiviz package         # Production .pbiviz
pbiviz package --no-stats   # Skip webpack stats
pbiviz package --no-pbiviz  # Kun assets, ej zip
```

**Certificate setup (Mac/Linux):**
```bash
pbiviz install-cert    # Generér + installér dev-cert
# Tilføj til system-keychain (kræves for HTTPS i Power BI Service)
```

**Mac-specifik:** Power BI Desktop findes ej til Mac. Test via
`powerbi.com` (Power BI Service) i browser med dev-cert installeret.
Final-verifikation på Windows med Power BI Desktop.

---

## Filer der ALDRIG modificeres uden grund

- `node_modules/` — npm-managed
- `dist/` — gen-build hver gang
- `.tmp/`, `.cache/` — pbiviz interne
- `webpack.statistics*.html` — build-output

Alle bør være i `.gitignore`.

---

## capabilities.json — data-kontrakt

**Definerer:**
- `dataRoles` — input-felter brugeren kan binde (måling, kategori, etc.)
- `dataViewMappings` — hvordan Power BI strukturerer data til visual
- `objects` — formatting pane (settings)
- `privileges` — fx `WebAccess` for eksterne fetches

**Regler:**
- Ændringer her er **breaking** for eksisterende rapporter — bump version
- `displayName`-felter er bruger-synlige — lokaliseringskandidater
- Test enhver `dataRoles`-ændring mod eksisterende `.pbix`-filer

---

## pbiviz.json — visual-metadata

**Centrale felter:**
- `visual.name` — internt ID (ej brugersynligt)
- `visual.displayName` — vist i Power BI visuals-galleri
- `visual.guid` — UNIK per visual. ALDRIG genbrug på tværs versioner.
- `visual.version` — semver, skal matche `package.json` `version`
- `apiVersion` — Power BI Visuals API-version (afhænger af `powerbi-visuals-api`)

**Versionering:**
- Bump `pbiviz.json` `version` + `package.json` `version` synkront
- `apiVersion` bumpes kun ved bevidst SDK-upgrade

---

## Settings / Formatting Model

**Moderne approach:** Formatting Model API (API v5.1+)
- Defineres i `src/settings.ts` via `FormattingSettingsService`
- TypeScript-klasser med decorators eller plain objects
- Auto-genererer Power BI formatting pane

**Legacy:** `objectEnumerationUtility` (API v4.x og tidligere) — undgå
i nye visuals.

**Mønster:**
```typescript
class CardSettings extends FormattingSettingsCard {
  toggle = new ToggleSwitch({...});
  // ...
}
```

---

## Rendering (D3)

**Konventioner:**
- Single `<svg>`-root pr. visual instance
- `update()`-pattern: re-render ved hver `update()`-call fra host
- D3 selections cached i klasse-properties for performance
- ALDRIG `document.querySelector` — brug `this.target`-element fra
  visual-constructor

**Resize:**
- Host kalder `update()` med ny viewport
- Genberegn skalaer (`d3.scaleLinear`, etc.) hver gang
- Cache statisk data (grænser, beregninger) udenfor render-loop

---

## Testing

**Karma + Jasmine** = etableret konvention i pbiviz-projekter.
Reason: visualisering kræver browser-DOM, Karma kører i headless
Chromium.

**Coverage:**
- Beregnings-logik (limits, rules, statistik) = TESTBAR uden DOM
  → kør i Node hvis muligt for hurtighed
- Rendering-logik = Karma med real DOM

**Test-strategi for Anhøj-port:**
- Reference-datasæt fra `qicharts2` (R) → hardcoded JSON
- Forvent samme output → snapshot/assert
- Sammenlign mod eksisterende regler i Fase 1 (sanity check)

---

## Distribution

**Tre kanaler:**
1. **AppSource** (Microsoft-certificeret) — kræver Microsoft Partner Center,
   privacy-policy, EULA, support-kontakt
2. **Organisations-galleri** — admin-uploaded `.pbiviz`-filer pr. tenant
3. **Direkte `.pbiviz`-fil** — uploadet manuelt i hver rapport

**AppSource-krav (hvis relevant):**
- `EULA.pdf` i repo-rod
- `privacy-policy.md` med kontakt
- Visual må ej kalde eksterne URLs uden `privileges.WebAccess` i
  `capabilities.json`
- Ingen tracking/analytics uden eksplicit user-consent

---

## Performance

**Power BI viewport-constraints:**
- Visual kan rendere mange gange/sekund ved resize, cross-filter, etc.
- `update()` skal være idempotent + hurtig
- Tunge beregninger: cache med data-hash som key

**Memory:**
- Husk at fjerne D3 event-listeners ved `destroy()` (hvis API understøtter)
- Undgå retained references til store data-arrays

---

## Security / Privacy

- ALDRIG send Power BI data til eksterne tjenester uden eksplicit
  `WebAccess`-privilege + user-consent
- ALDRIG embed credentials/API-keys i visual-koden — pakkes med
  `.pbiviz`
- Externt fetch: kun via dokumenterede endpoints, dokumentér i
  privacy-policy

---

## Pre-Release Checklist (Power BI-specific)

Se `VERSIONING_POLICY.md` for generel pre-release. Tilføjelser:

- [ ] `pbiviz.json` `version` matcher `package.json` `version`
- [ ] `pbiviz package` bygger uden fejl
- [ ] `.pbiviz` testet i Power BI Service eller Desktop
- [ ] Eksisterende `.pbix`-rapporter åbner uden data-loss
- [ ] `capabilities.json` ændringer dokumenteret (breaking?)
- [ ] `privacy-policy.md` opdateret hvis WebAccess ændret
- [ ] `apiVersion`-bump dokumenteret hvis SDK opgraderet

---

## Referencer

- Power BI Visuals SDK: https://learn.microsoft.com/en-us/power-bi/developer/visuals/
- `powerbi-visuals-api` types: `node_modules/powerbi-visuals-api/index.d.ts`
- `pbiviz` CLI: https://github.com/microsoft/PowerBI-visuals-tools

---

**Sidst opdateret:** 2026-05-19
**Del af:** ~/.claude/rules-profiles/typescript/
