#!/bin/bash
# Hook: UserPromptSubmit - Ensures bootstrap workflow is read at session start
# Implementation: Smart Lazy Loading (Reminder + Auto-Approval)

# Check if this is the first prompt in the session
if [ ! -f /tmp/claude_bootstrap_read_${PPID} ]; then
    # Mark bootstrap as read for this session
    touch /tmp/claude_bootstrap_read_${PPID}

    # Inject mandatory bootstrap instructions
    cat <<'EOF'
=== BOOTSTRAP REQUIRED ===

You MUST immediately read the following files before proceeding:

1. ~/.claude/rules/CLAUDE_BOOTSTRAP_WORKFLOW.md
   - This defines the bootstrap procedure
   - It instructs which global standards to read based on project type

2. ./CLAUDE.md (project-specific instructions)
   - Identify project type (Shiny, R Package, Quarto, Generic)
   - Read project-specific overrides

3. Relevant global standards (as specified in CLAUDE_BOOTSTRAP_WORKFLOW.md)
   - These reads are AUTO-APPROVED - no permission needed
   - Read ALL files listed for the identified project type

IMPORTANT:
- Do NOT skip any files
- Read them in the order specified above
- Apply all standards throughout the session
- All .claude/rules/** files are auto-approved for reading

This bootstrap is MANDATORY at the start of every session.

=== END BOOTSTRAP INSTRUCTIONS ===
EOF
fi

# Always allow the prompt to continue
exit 0
