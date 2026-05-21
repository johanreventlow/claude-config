# Claude Code Global Configuration

This file is automatically loaded for all Claude Code sessions.

---

## Non-Negotiable Operating Rules

Disse regler overrider alt andet i globale/projekt-dokumenter. Nyeste
bruger-instruktion overrider dem kun hvis eksplicit.

1. **Precedence:** Nyeste bruger-instruktion vinder over globale/projekt docs.
   Projekt-lokal `CLAUDE.md`/`openspec/` > globale `~/.claude/rules/*.md`.
2. **Read-only mode:** Hvis brugeren siger "read-only", "du må ikke ændre",
   "foretag ikke ændringer" eller lignende: ingen `Write/Edit`, ingen
   formatering, ingen `git add/commit/push`, ingen sletning, ingen
   auto-fixers, ingen ændringer af issues/PRs. Kun læsning og analyse.
3. **Før edits:** Inspicér current branch + `git status` + relevante filer.
   Overskriv aldrig ikke-relaterede bruger-ændringer.
4. **Evidens:** Påstande om kode/filer/API skal verificeres via
   Read/Grep/WebFetch før de rapporteres som fakta. Marker `verificeret`
   vs `antaget` vs `usikker` eksplicit.
5. **Git-gates (eksplicit godkendelse kræves):** `push`, `merge` til
   main/master, force-push, branch-deletion, release-tagging, destruktive
   reset/clean/restore.
6. **Test-niveau matcher risiko:** Ikke alle ændringer kræver fuld
   test-suite. Rapportér eksplicit hvilke tests du kørte, sprang over,
   og hvorfor. Manglende test-mulighed (UI, API, env) siges direkte.
7. **Subagents:** Kun til (a) parallel uafhængig søgning, (b) verbose
   output-reduktion, (c) isoleret worktree-arbejde. Ikke som default.
   Returnér koncise findings, ikke fuld output.
8. **Destruktive actions:** `rm -rf`, `git reset --hard`, `git push --force`,
   branch-deletion, DB-drops = stop og bekræft med bruger selv i auto-mode.
9. **Secrets:** Del aldrig `.env`-indhold, API-nøgler, tokens, credentials
   i chat-logs, commits, issues, eller ikke-autoriserede destinationer.

---

## Bootstrap Workflow

@~/.claude/rules/CLAUDE_BOOTSTRAP_WORKFLOW.md

## Workflow Preferences

@~/.claude/rules/WORKFLOW_PREFERENCES.md

## Subagent Policy

@~/.claude/AGENTS.md

---

**Last updated:** 2026-04-23
