# Agents

**[中文文档 (Chinese Documentation)](doc/AGENTS_ZH.md)**

Specialized agents do heavy work, return concise summaries, preserve context.

## Core Philosophy

> "Don't anthropomorphize subagents. Use them to organize your prompts and elide context. Subagents are best when they can do lots of work but then provide small amounts of information back to the main conversation thread."
>
> – Adam Wolff, Anthropic

## Available Agents

### 🔍 `code-analyzer`
- **Purpose**: Hunt bugs across many files, no main context pollution
- **Pattern**: Search files → Analyze → Return bug report
- **Usage**: Trace logic, find bugs, validate changes
- **Returns**: Concise bug report, critical findings only

### 📄 `file-analyzer`
- **Purpose**: Read + summarize verbose files (logs, outputs, configs)
- **Pattern**: Read → Extract → Summary
- **Usage**: Understand logs, analyze verbose output
- **Returns**: Key findings + actions (80-90% size reduction)

### 🧪 `test-runner`
- **Purpose**: Run tests, no output dump to main thread
- **Pattern**: Run → Capture log → Analyze → Summary
- **Usage**: Run tests, understand failures
- **Returns**: Results summary + failure analysis

### 🔀 `parallel-worker`
- **Purpose**: Coordinate parallel work streams per issue
- **Pattern**: Read analysis → Spawn sub-agents → Consolidate → Summary
- **Usage**: Parallel streams in worktree
- **Returns**: Consolidated status all parallel work

## Why Agents?

Agents = **context firewalls** protecting main conversation from overload:

```
Without Agent:
Main thread reads 10 files → Context explodes → Loses coherence

With Agent:
Agent reads 10 files → Main thread gets 1 summary → Context preserved
```

## How Agents Preserve Context

1. **Heavy Lifting** - Agents do messy work (read files, run tests, implement)
2. **Context Isolation** - Implementation details stay in agent
3. **Concise Returns** - Only essentials return to main
4. **Parallel Execution** - Multiple agents simultaneous, no collision

## Example Usage

```bash
# Analyzing code for bugs
Task: "Search for memory leaks in the codebase"
Agent: code-analyzer
Returns: "Found 3 potential leaks: [concise list]"
Main thread never sees: The hundreds of files examined

# Running tests
Task: "Run authentication tests"
Agent: test-runner
Returns: "2/10 tests failed: [failure summary]"
Main thread never sees: Verbose test output and logs

# Parallel implementation
Task: "Implement issue #1234 with parallel streams"
Agent: parallel-worker
Returns: "Completed 4/4 streams, 15 files modified"
Main thread never sees: Individual implementation details
```

## Creating New Agents

New agents follow:

1. **Single Purpose** - One clear job
2. **Context Reduction** - Return 10-20% of processed
3. **No Roleplay** - Task executors, not "experts"
4. **Clear Pattern** - input → processing → output
5. **Error Handling** - Fail gracefully, report clearly

## Anti-Patterns to Avoid

❌ **"Specialist" agents** (database-expert, api-expert)
   Same model, no different knowledge

❌ **Verbose output**
   Defeats context preservation

❌ **Agents talking to each other**
   Use coordinator agent (like parallel-worker)

❌ **Agents for simple tasks**
   Only when context reduction valuable

## Integration with PM System

Agents integrate with PM command system:

- `/pm:issue-analyze` → Identifies work streams
- `/pm:issue-start` → Spawns parallel-worker agent
- parallel-worker → Spawns multiple sub-agents
- Sub-agents → Work in parallel in the worktree
- Results → Consolidated back to main thread

Hierarchy maximizes parallelism, preserves context every level.