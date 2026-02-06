# claw-builder MVP

Minimum viable version to validate the architecture and start dogfooding.

## MVP Scope

### In Scope

**Prep Loop (manual for v1):**
- [ ] claw-setup skill (port from ralph-project-setup, rename .ralph → .claw)
- [ ] claw-architect skill (port from ralph-architect, use WORKPLAN.md)
- [ ] claw-bootstrap skill (port from ralph-bootstrap)
- [ ] TypeScript language plugin only

**Dev Loop (the novel part):**
- [ ] Core loop script (evolved from ralph_loop.sh)
- [ ] Haiku task selection (simple: next unchecked)
- [ ] Haiku context builder (port clawOS scripts)
- [ ] Bash exploration tools (port clawOS scripts)
- [ ] File-based events for supervision
- [ ] Status.json tracking

**Supervision:**
- [ ] claw-supervisor skill (port from ralph-supervisor)
- [ ] File-based event watching
- [ ] Basic intervention capability

### Out of Scope (v1)

- PIB Builder (do manually for now)
- Haiku exploration subagent (use bash tools only)
- Python language plugin
- OpenClaw plugin integration
- Automated GitHub remote creation in setup
- Framework sub-plugins (React, Next.js variants)

## Implementation Order

### Phase 1: Port and Rename

Port existing ralph skills to claw-* versions:

1. **claw-setup** — Copy ralph-project-setup, change .ralph → .claw
2. **claw-architect** — Copy ralph-architect, use WORKPLAN.md, update paths
3. **claw-bootstrap** — Copy ralph-bootstrap, update for .claw

### Phase 2: Dev Loop Core

Build the new dev loop:

1. **Task selection script** — Port get-next-task.sh
2. **Context builder** — Port gather-task-context.sh, build-base-context.sh
3. **Loop controller** — Evolve ralph_loop.sh with state machine
4. **Event emitter** — Write events to .claw/events/

### Phase 3: Exploration Tools

Bash tools for codebase navigation:

1. **list-slices** — List all slices in src/slices/
2. **show-contract** — Extract header docblock from file
3. **slice-deps** — Parse imports/exports for a slice
4. **find-symbol** — Ripgrep with smart filtering

### Phase 4: Supervision

Supervision capability:

1. **Event watcher** — Poll or inotify on .claw/events/
2. **claw-supervisor skill** — Port ralph-supervisor
3. **Basic intervention** — Send guidance to loop

### Phase 5: Dogfooding

Use claw-builder to continue building claw-builder:

1. Set up claw-builder as a claw project
2. Create WORKPLAN.md for remaining features
3. Run the loop, supervised

## Success Criteria

MVP is complete when:

1. Can scaffold a new TypeScript project with claw-setup
2. Can generate specs/WORKPLAN with claw-architect
3. Can bootstrap tooling with claw-bootstrap
4. Dev loop can pick tasks and run Sonnet
5. Events written for supervision
6. Can supervise and intervene when needed
7. Successfully used to build more of claw-builder

## Estimated Effort

| Phase | Effort | Notes |
|-------|--------|-------|
| Phase 1 | 2-3 hours | Mostly copy/rename |
| Phase 2 | 4-6 hours | Core loop work |
| Phase 3 | 2-3 hours | Port existing scripts |
| Phase 4 | 2-3 hours | Supervision setup |
| Phase 5 | Ongoing | Dogfooding |

**Total to MVP: ~10-15 hours**

## Next Steps After MVP

1. Add Haiku exploration subagent
2. Add PIB Builder skill
3. Add Python language plugin
4. OpenClaw plugin integration
5. More sophisticated failure handling
