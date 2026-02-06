# claw-builder Vision

> Two-loop autonomous development system: intelligent project preparation followed by efficient, supervised coding.

## Overview

claw-builder evolves ralph-claude-code into a two-loop system:

1. **Prep Loop** — From vague idea to ready-to-build (PIB Builder → Architect)
2. **Dev Loop** — From tasks to working code (Haiku → Sonnet → Opus supervision)

This is new. Vanilla ralph assumes you show up with requirements already written. claw-builder helps you figure out what to build before building it.

```
┌─────────────────────────────────────────────────────────────────┐
│                       PREP LOOP                                 │
│                                                                 │
│   PIB Builder ──▶ Setup ──▶ Architect ──▶ Bootstrap ──▶ Ready   │
│   (interview)    (scaffold) (specs)      (tooling)              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                       DEV LOOP                                  │
│                                                                 │
│   Haiku ──▶ Haiku ──▶ Sonnet ──▶ Validate ──▶ Commit ──▶ [loop] │
│   (select)  (context)  (code)                                   │
│                                                                 │
│                    Opus (supervision)                           │
└─────────────────────────────────────────────────────────────────┘
```

## Prep Loop Phases

| Phase | Skill | Purpose |
|-------|-------|---------|
| 1 | **claw-setup** | Create container: folder, git, GitHub remote, .claw/ structure |
| 2 | **PIB Builder** (new) | Interview user, research with Perplexity, write PIB + docs |
| 3 | **claw-architect** | Read PIB, generate specs + WORKPLAN + PROMPT |
| 4 | **claw-bootstrap** | Set up .claude/, tooling, hooks, dependencies |

Setup creates the container, PIB Builder works inside it, Architect reads what PIB Builder wrote, Bootstrap reads what Architect decided.

## The Three Tiers (Dev Loop)

| Tier | Model | Role | Cost |
|------|-------|------|------|
| **Custodian** | Haiku | Task selection, context prep, light research | ~$0.25/M tokens |
| **Coder** | Sonnet | Implementation, testing, commits | ~$3/M tokens |
| **Supervisor** | Opus | Oversight, intervention, guidance | ~$15/M tokens (used sparingly) |

## Core Principles

### 1. Opinionated Architecture
We enforce **Vertical Slice Architecture** with strict conventions:
- Slices live in predictable locations
- Every file has a header contract (docblock)
- Clear separation of responsibilities
- Predictable import/export patterns

This enables **deterministic tooling** — we can build bash tools that navigate the codebase without burning LLM tokens.

### 2. Context Efficiency
Sonnet's context window is expensive. We minimize it by:
- Haiku prepares focused context packets per task
- Exploration subagent (Haiku) answers complex questions, returns summaries
- Bash tools for simple lookups (zero LLM cost)
- Task metadata guides what context to include

### 3. Explicit State Machine
Every loop iteration has clear states:
```
IDLE → TASK_SELECTION → CONTEXT_PREP → CODING → VALIDATION → COMMIT → [loop]
```
State transitions are logged. No ambiguity about where the loop is.

### 4. Dual Distribution
- **Standalone CLI**: Works without OpenClaw for the broader community
- **OpenClaw Plugin**: Deep integration with supervision, cron, session spawning

## The Prep Loop (New)

Vanilla ralph assumes you arrive with a PRD. claw-builder helps you build one.

### PIB Builder
- **Purpose:** Interview the user, build a complete Project Information Brief
- **Capabilities:** Conversational interview, Perplexity research, template-aware
- **Output:** Validated PIB document ready for Architect
- **Quality gate:** Won't proceed until PIB is complete and approved

### claw-architect (evolved from ralph-architect)
- **Purpose:** Take PIB, generate all files for the dev loop
- **Capabilities:** Task decomposition, spec generation, command verification
- **Output:** Complete `.claw/` directory (WORKPLAN.md, PROMPT.md, specs, config)
- **Quality gate:** Won't proceed until plan is approved

See `PREP-LOOP.md` for full details.

## Key Differences from ralph-claude-code

| Aspect | ralph | claw-builder |
|--------|-------|--------------|
| **Prep phase** | Manual (you write the PRD) | Automated (PIB Builder + Architect) |
| Task selection | First unchecked item | Haiku analyzes and picks optimally |
| Context | Static PROMPT.md | Dynamic per-task context packets |
| Navigation | Claude figures it out | Built-in tools + Haiku subagent |
| Architecture | Agnostic | Opinionated (VSA + contracts) |
| State | Implicit | Explicit state machine |
| Supervision | External (cron) | Native hooks + OpenClaw integration |

## The Three Tiers in Detail

### Custodian (Haiku)
Runs at loop start and on-demand:
- Reads WORKPLAN.md, selects next task
- Considers task dependencies, complexity, current project state
- Builds a context packet tailored to the task
- Answers Sonnet's exploration questions during coding

### Coder (Sonnet)
The workhorse:
- Receives focused context packet
- Has access to exploration tools (bash + Haiku subagent)
- Implements, tests, commits
- Marks tasks complete
- Emits status for supervision

### Supervisor (Opus via OpenClaw)
Watches from outside:
- Receives events on completion, failure, stuck detection
- Can intervene with guidance
- Handles escalation when loop is confused
- Makes architectural decisions when needed

## Open Questions

1. **Task dependencies**: Should WORKPLAN.md support explicit `blocked_by` relationships?
2. **Failure handling**: Retry? Skip and flag? Pause for human?
3. **Multi-project**: Can one claw-builder instance manage multiple projects?
4. **Model flexibility**: Should custodian/coder models be configurable per-project?

## Next Steps

1. Document the architecture in detail
2. Design the WORKPLAN.md format with task metadata
3. Spec out the bash exploration tools
4. Design the Haiku subagent interface
5. Define the state machine and status.json format
6. Plan the OpenClaw plugin integration
