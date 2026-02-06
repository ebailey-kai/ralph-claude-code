# claw-builder Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        SUPERVISOR (Opus)                        │
│                   [OpenClaw / External Monitor]                 │
│         Receives events, intervenes when needed, guides         │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 │ events / intervention
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                         LOOP CONTROLLER                         │
│                                                                 │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐  │
│  │   IDLE   │───▶│  SELECT  │───▶│   PREP   │───▶│   CODE   │  │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘  │
│       ▲                                               │         │
│       │          ┌──────────┐    ┌──────────┐         │         │
│       └──────────│  COMMIT  │◀───│ VALIDATE │◀────────┘         │
│                  └──────────┘    └──────────┘                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                                 │
                    ┌────────────┴────────────┐
                    ▼                         ▼
┌─────────────────────────────┐ ┌─────────────────────────────────┐
│     CUSTODIAN (Haiku)       │ │         CODER (Sonnet)          │
│                             │ │                                 │
│ • Task selection            │ │ • Implementation                │
│ • Context packet building   │ │ • Testing                       │
│ • Exploration subagent      │ │ • Commits                       │
│                             │ │ • Uses bash tools + subagent    │
└─────────────────────────────┘ └─────────────────────────────────┘
                    │                         │
                    └────────────┬────────────┘
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                        PROJECT FILES                            │
│                                                                 │
│  .claw/                    src/                                 │
│  ├── WORKPLAN.md           ├── slices/                          │
│  ├── config.yaml           │   ├── feature-a/                   │
│  ├── status.json           │   │   ├── slice.md                 │
│  ├── events/               │   │   ├── components/              │
│  │   └── *.event           │   │   └── index.ts                 │
│  └── context/              │   └── feature-b/                   │
│      └── current.md        └── store/                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Directory Structure

### Project-Level (.claw/)

```
.claw/
├── WORKPLAN.md          # Task list with metadata
├── config.yaml          # Project-specific configuration
├── status.json          # Current loop state
├── events/              # Event files for supervisor
│   ├── 001-task-complete.event
│   └── 002-validation-failed.event
├── context/
│   └── current.md       # Last context packet sent to coder
├── ISSUES.md            # Problems encountered during loop
└── specs/               # Feature specifications
    └── *.md
```

### Global Installation

```
~/.claw-builder/
├── bin/
│   └── claw            # Main CLI
├── lib/
│   ├── loop.sh         # Core loop logic
│   ├── custodian.sh    # Haiku interactions
│   ├── coder.sh        # Sonnet interactions
│   └── tools/          # Bash exploration tools
│       ├── list-slices
│       ├── show-contract
│       ├── slice-deps
│       └── find-symbol
├── templates/
│   ├── WORKPLAN.md
│   ├── config.yaml
│   └── slice.md
└── agents/
    └── explorer.md     # Haiku exploration subagent prompt
```

## State Machine

### States

| State | Description | Actor |
|-------|-------------|-------|
| `IDLE` | Waiting to start | Loop |
| `TASK_SELECTION` | Picking next task | Haiku |
| `CONTEXT_PREP` | Building context packet | Haiku |
| `CODING` | Implementing task | Sonnet |
| `VALIDATION` | Running tests/checks | Loop |
| `COMMIT` | Committing changes | Loop |
| `PAUSED` | Waiting for intervention | Supervisor |
| `COMPLETE` | All tasks done | Loop |

### Transitions

```
IDLE ──[start]──▶ TASK_SELECTION
TASK_SELECTION ──[task found]──▶ CONTEXT_PREP
TASK_SELECTION ──[no tasks]──▶ COMPLETE
CONTEXT_PREP ──[packet ready]──▶ CODING
CODING ──[implementation done]──▶ VALIDATION
VALIDATION ──[pass]──▶ COMMIT
VALIDATION ──[fail]──▶ PAUSED (or retry)
COMMIT ──[success]──▶ TASK_SELECTION
PAUSED ──[intervention]──▶ TASK_SELECTION
```

## WORKPLAN.md Format

```markdown
# WORKPLAN

## Phase 1: Foundation

- [ ] Set up project structure <!-- slice:shell, complexity:low -->
- [ ] Create base window component <!-- slice:windows, complexity:medium -->
- [x] Implement window store <!-- slice:windows, touches:windowStore -->

## Phase 2: Features

- [ ] Add window snapping <!-- slice:windows, after:window-store, complexity:high -->
- [ ] Build taskbar <!-- slice:taskbar, after:window-component -->
```

### Task Metadata (HTML Comments)

| Key | Description | Values |
|-----|-------------|--------|
| `slice` | Primary slice affected | Slice name |
| `touches` | Other files/stores affected | Comma-separated |
| `complexity` | Estimated difficulty | low, medium, high |
| `after` | Task dependency | Task description substring |

## Context Packet

What Haiku builds for each task:

```markdown
## Task
> Implement window snapping

## Phase Context
Phase 2: Features — 3 done, 5 remaining

## Relevant Slices

### windows (primary)
[slice.md content]

Files:
- components/Window.tsx
- hooks/useWindowDrag.ts
- index.ts

### Key Contracts

#### windowStore.ts
[header docblock]

## Related Specs
[relevant spec excerpts]

## Instructions
1. Implement ONLY the task above
2. Follow existing patterns
3. Run tests before committing
4. Check off task in WORKPLAN.md
5. Emit CLAW_STATUS block when done
```

## Exploration Tools

### Bash Tools (Zero LLM Cost)

```bash
# List all slices
claw tools list-slices
# → shell, windows, taskbar, launcher

# Show file contract
claw tools show-contract src/slices/windows/components/Window.tsx
# → [header docblock]

# Find slice dependencies
claw tools slice-deps windows
# → imports from: store/windowStore, shared/types
# → imported by: shell, taskbar

# Find symbol usages
claw tools find-symbol snapWindow
# → src/slices/windows/hooks/useSnap.ts:45
# → src/store/windowStore.ts:123
```

### Haiku Subagent (Cheap LLM Cost)

For complex questions:
```
Sonnet: "How does window dragging interact with the snap system?"

→ Spawns Haiku subagent
→ Haiku reads: useWindowDrag.ts, useSnap.ts, windowStore.ts, snap-spec.md
→ Returns: 500-token summary of the interaction
→ Sonnet continues with understanding, minimal context consumed
```

## Status.json

```json
{
  "state": "CODING",
  "current_task": "Implement window snapping",
  "phase": "Phase 2: Features",
  "phase_progress": { "done": 3, "remaining": 5 },
  "loop_iteration": 7,
  "started_at": "2026-02-06T17:00:00Z",
  "last_transition": "2026-02-06T17:15:00Z",
  "coder_session": "abc123",
  "recent_events": [
    { "type": "task_complete", "task": "Build taskbar", "at": "..." },
    { "type": "validation_pass", "at": "..." }
  ]
}
```

## Event Files

Written to `.claw/events/` for supervisor consumption:

```json
// 007-task-complete.event
{
  "type": "task_complete",
  "task": "Implement window snapping",
  "duration_seconds": 342,
  "files_changed": ["src/slices/windows/hooks/useSnap.ts"],
  "tests_passed": true,
  "timestamp": "2026-02-06T17:20:00Z"
}
```

```json
// 008-validation-failed.event
{
  "type": "validation_failed",
  "task": "Add keyboard shortcuts",
  "error": "Test failed: useKeyboard.test.ts",
  "stdout": "...",
  "retry_count": 2,
  "timestamp": "2026-02-06T17:25:00Z"
}
```

## OpenClaw Plugin Integration

When running as an OpenClaw plugin:

1. **Supervision**: Events emit to OpenClaw session instead of files
2. **Cron**: Loop health checks via OpenClaw cron jobs
3. **Session spawning**: Coder runs in isolated OpenClaw session
4. **Intervention**: Supervisor can send messages directly to coder session

```yaml
# OpenClaw plugin config
plugins:
  claw-builder:
    projects:
      - path: ~/projects/my-app
        supervision: true
        cron_interval: 30m
```
