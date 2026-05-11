---
name: end
description: >
  End-of-session handoff checklist that ensures all progress is documented
  and the next session starts with full context. Commits outstanding work,
  updates changelog/decisions/CLAUDE.md/MEMORY.md, and summarizes what was
  done. Use this skill whenever the user says "/end", "end session", "wrap
  up", "close out", "session handoff", "before quitting", "ready to stop",
  or otherwise signals that the current work session is concluding —
  even if they don't explicitly mention documentation or handoff.
---

# End Session Handoff

Run this before closing out a work session. Ensures all progress is documented
and the next session starts with full context.

## Checklist

Complete each step in order:

### 1. Commit outstanding work
- Stage and commit any uncommitted changes with descriptive messages
- Push to remote

### 2. Update changelog
- Append session progress to `docs/changelog.md`
- Use the existing format: `## Section Title (Date)` with bullet points
- Focus on what was built/changed, not how — keep entries concise
- Note closed GitHub issues with `#N` references

### 3. Update decisions
- Add any significant architectural or design decisions to `docs/decisions.md`
- Include: what was decided, why, and what alternatives were rejected
- Only decisions that would be non-obvious to a future reader
- Examples: technology choices, patterns adopted, workarounds for platform limitations

### 4. Update CLAUDE.md phase status
- Update the Roadmap section with phase progress (completed, partial, what's left)
- Do NOT add detailed build history — that goes in the changelog
- Keep CLAUDE.md lean: current state, not history

### 5. Update memory
- Update `MEMORY.md` index and relevant memory files with session state
- Note what's next and any context the next session needs
- Update test counts, data counts, or other metrics that changed

### 6. Summarize
- Tell the user what was done, what was committed, and what's queued for next session
- Note any open issues or blockers discovered during the session
