# claw-builder MVP: The Prep Loop

The first MVP is the **complete prep loop**. It produces spec files that the existing ralph_loop.sh can consume immediately. We build value without touching the dev loop.

```
┌─────────────────────────────────────────────────────────────────┐
│                     MVP: PREP LOOP                              │
│                                                                 │
│   Setup ──▶ PIB Builder ──▶ Architect ──▶ Bootstrap ──▶ Ready   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              EXISTING: ralph_loop.sh (unchanged)                │
└─────────────────────────────────────────────────────────────────┘
```

## Why This MVP?

1. **Immediate value** — Prep loop outputs work with current ralph
2. **Decoupled** — Can iterate on prep without touching dev loop
3. **The hard part** — PIB Builder is genuinely new; worth validating first
4. **Lower risk** — Existing ralph_loop.sh is battle-tested

## MVP Scope

### In Scope

**Phase 1: Setup**
- [ ] claw-setup skill (port from ralph-project-setup)
- [ ] Create project folder, git, .claw/ structure
- [ ] Optional GitHub remote creation
- [ ] Handoff to PIB Builder

**Phase 2: PIB Builder** (the new thing)
- [ ] Conversational interview flow
- [ ] Perplexity research integration
- [ ] PIB template filling
- [ ] Write PIB to .claw/specs/pib.md
- [ ] Write research docs to .claw/docs/
- [ ] Completeness checking
- [ ] Handoff to Architect

**Phase 3: Architect**
- [ ] claw-architect skill (port from ralph-architect)
- [ ] Read PIB and research docs
- [ ] Generate WORKPLAN.md (renamed from fix_plan.md)
- [ ] Generate PROMPT.md, AGENT.md
- [ ] Generate feature specs
- [ ] Copy CODING.md to specs/stdlib/
- [ ] Handoff to Bootstrap

**Phase 4: Bootstrap**
- [ ] claw-bootstrap skill (port from ralph-bootstrap)
- [ ] TypeScript language plugin
- [ ] Python language plugin
- [ ] Install tooling and dependencies
- [ ] Set up .claude/ with hooks
- [ ] Generate CLAUDE.md
- [ ] Project ready for ralph_loop.sh

### Out of Scope (v1)

- New three-tier dev loop (use existing ralph)
- Haiku exploration subagent
- OpenClaw plugin integration
- Additional language plugins beyond TS/Python

## Implementation Order

### Phase 1: Port Setup (2h)
1. Copy ralph-project-setup → claw-setup
2. Change .ralph → .claw references
3. Update directory structure
4. Test on sample project

### Phase 2: Build PIB Builder (4-6h)
1. Design interview flow script/prompt
2. Integrate Perplexity research
3. Implement PIB template logic
4. Write to .claw/specs/pib.md and .claw/docs/
5. Add completeness checking
6. Test with real project ideas

### Phase 3: Port Architect (2-3h)
1. Copy ralph-architect → claw-architect  
2. Update to read PIB from .claw/specs/pib.md
3. Rename fix_plan.md → WORKPLAN.md
4. Update all path references
5. Test with PIB Builder output

### Phase 4: Port Bootstrap (3-4h)
1. Copy ralph-bootstrap → claw-bootstrap
2. Create TypeScript plugin structure
3. Create Python plugin structure
4. Update for .claw/ paths
5. Test full prep loop → ralph_loop.sh

### Phase 5: Integration Testing (2h)
1. Run full prep loop on test project
2. Execute ralph_loop.sh on output
3. Verify smooth handoff
4. Document any gaps

## Success Criteria

MVP is complete when:

1. ✅ Can run: `Setup → PIB Builder → Architect → Bootstrap`
2. ✅ PIB Builder interviews user and produces quality PIB
3. ✅ Architect generates WORKPLAN.md from PIB
4. ✅ Bootstrap sets up TypeScript or Python tooling
5. ✅ Output works with existing ralph_loop.sh
6. ✅ Successfully used on a real project

## Estimated Effort

| Phase | Effort | Notes |
|-------|--------|-------|
| Setup | 2h | Mostly copy/rename |
| PIB Builder | 4-6h | New skill, core value |
| Architect | 2-3h | Port with updates |
| Bootstrap | 3-4h | Plugin structure |
| Integration | 2h | End-to-end testing |

**Total to MVP: ~13-17 hours**

## After MVP

Once prep loop works:

1. **Use it** — Generate specs for real projects, run with ralph
2. **Iterate on PIB Builder** — Improve interview flow based on usage
3. **Build new dev loop** — Three-tier system with Haiku custodian
4. **OpenClaw integration** — Plugin for supervision
