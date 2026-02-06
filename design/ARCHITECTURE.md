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

Tasks are ordered by the Architect in implementation order. Haiku simply picks the next unchecked item — no need for dependency analysis at runtime.

```markdown
# WORKPLAN

## Phase 1: Foundation

- [ ] Set up project structure
- [ ] Create base window component
- [x] Implement window store

## Phase 2: Features

- [ ] Add window snapping
- [ ] Build taskbar
```

### Optional Task Metadata (HTML Comments)

Metadata helps the custodian build better context packets. It's optional — tasks work without it.

```markdown
- [ ] Add window snapping <!-- slice:windows, touches:windowStore -->
```

| Key | Description | Example |
|-----|-------------|---------|
| `slice` | Primary slice affected | `slice:windows` |
| `touches` | Other files/stores affected | `touches:windowStore,shellStore` |

**Note:** `complexity` and `after` were considered but removed. Architect handles ordering, so `after` is redundant. Complexity doesn't change how the task is executed.

### Task Selection

Haiku's job is simple:
1. Find first line matching `- [ ]`
2. Extract task text
3. Extract optional metadata from HTML comment
4. Build context packet based on slice/touches

No intelligence needed — Architect already ordered tasks correctly.

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

Versions of these already exist in `clawOS/scripts/context-builder/` — we'll port them.

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

**Source scripts to port:**
- `clawOS/scripts/context-builder/get-next-task.sh` — Task selection
- `clawOS/scripts/context-builder/gather-task-context.sh` — Context building
- `clawOS/scripts/context-builder/build-base-context.sh` — Base project info

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

## Supervision Architecture

Two modes: standalone (file-based) and OpenClaw-integrated.

### Standalone Mode (File-Based Events)

Uses filesystem as an event queue. Simple, durable, survives crashes.

**Event flow:**
```
Loop Controller
      │
      ├── Writes events to .claw/events/NNN-type.event
      │
      └── Updates .claw/status.json
      
Supervisor (external)
      │
      ├── Watches .claw/events/ (inotify or polling)
      │
      ├── Reads new .event files
      │
      └── Takes action (intervene, alert, log)
```

**Event file format:**
```json
// .claw/events/007-task-complete.event
{
  "id": 7,
  "type": "task_complete",
  "task": "Implement window snapping",
  "duration_seconds": 342,
  "files_changed": ["src/slices/windows/hooks/useSnap.ts"],
  "tests_passed": true,
  "timestamp": "2026-02-06T17:20:00Z"
}
```

**Event types:**
| Type | When | Supervisor Action |
|------|------|-------------------|
| `task_started` | Loop begins a task | Log |
| `task_complete` | Task finished successfully | Log, maybe celebrate |
| `validation_failed` | Tests/lint failed | Decide: retry or intervene |
| `loop_stuck` | No progress for N iterations | Intervene |
| `loop_paused` | Awaiting intervention | Respond |
| `loop_complete` | All tasks done | Notify user |
| `error` | Unexpected error | Debug, restart |

**Supervisor polling (bash):**
```bash
# Simple polling supervisor
while true; do
  for event in .claw/events/*.event; do
    [[ -f "$event.processed" ]] && continue
    cat "$event"
    touch "$event.processed"
  done
  sleep 30
done
```

**Supervisor with inotify (more efficient):**
```bash
inotifywait -m -e create .claw/events/ | while read dir action file; do
  [[ "$file" == *.event ]] && cat ".claw/events/$file"
done
```

### OpenClaw Mode (Native Integration)

When running as an OpenClaw plugin, events emit directly to sessions.

**Event flow:**
```
Loop Controller (in isolated session)
      │
      ├── Emits events via OpenClaw internal API
      │
      └── Events route to supervisor session
      
Supervisor (Opus in main session)
      │
      ├── Receives events as system messages
      │
      ├── Can send messages back to coder session
      │
      └── Has full OpenClaw capabilities (cron, memory, etc.)
```

**Advantages over file-based:**
- Real-time event delivery
- Bidirectional communication (supervisor can send to coder)
- Integrated with OpenClaw cron for scheduled health checks
- Supervisor has access to memory, web search, etc.

**Plugin config:**
```yaml
# OpenClaw plugin config
plugins:
  claw-builder:
    projects:
      - path: ~/projects/my-app
        supervision: true
        cron_interval: 30m
```
# OpenClaw plugin config
plugins:
  claw-builder:
    projects:
      - path: ~/projects/my-app
        supervision: true
        cron_interval: 30m
```
