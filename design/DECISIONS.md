# Design Decisions Log

Tracking decisions made during claw-builder design.

---

## 2026-02-06: Initial Design Discussion

**Participants:** Eric, Kai

### Decision: Three-Tier Architecture
**Choice:** Haiku (custodian) → Sonnet (coder) → Opus (supervisor)

**Rationale:** 
- Haiku is cheap enough to burn liberally on prep work
- Keeps expensive Sonnet context focused on coding
- Opus supervision stays external and rare

---

### Decision: Both Bash Tools AND Haiku Subagent
**Choice:** Provide both deterministic bash tools and a Haiku exploration subagent

**Rationale:** (Eric's input)
- Bash tools for simple lookups: "show contract for X", "list files in slice Y"
- Haiku subagent for synthesis questions: "how does snapping interact with the grid?"
- Haiku burns cheap tokens exploring, returns concise summary to Sonnet
- Keeps Sonnet's context clean while enabling complex understanding
- Bash tools are building blocks that Haiku subagent also uses internally

**Not chosen:** Pure bash tools only (would miss synthesis capability)

---

### Decision: Rename fix_plan.md → WORKPLAN.md
**Choice:** Use WORKPLAN.md as the task list filename

**Rationale:**
- Not always "fixing" — could be new features, refactors
- Matches plan-oriented naming
- More professional/neutral

---

### Decision: Plugin Architecture with Standalone Core
**Choice:** Core loop as standalone CLI, OpenClaw plugin wraps it

**Rationale:**
- Keeps it useful to broader ralph community (no OpenClaw required)
- Deep integration for OpenClaw users (supervision hooks, cron, sessions)
- Clean separation of concerns

---

### Decision: Opinionated Architecture (VSA + Contracts)
**Choice:** Enforce Vertical Slice Architecture with strict file contracts

**Rationale:**
- Predictable structure enables deterministic tooling
- Contracts at file/slice level reduce need for LLM to read full implementations
- Aligns with Eric's CODING.md approach
- Trade-off: less flexible, but we're building for ourselves first

---

### Decision: Two-Loop Architecture (Prep + Dev)
**Choice:** Separate prep loop before dev loop

**Rationale:** (Eric's input)
- Vanilla ralph assumes you arrive with requirements written — this is a gap
- Prep loop takes you from idea to ready-to-build
- Clear handoff point between "figuring out what to build" and "building it"

**Not chosen:** Single loop where Claude figures out requirements as it goes (too risky, context pollution, scope creep)

---

### Decision: Prep Loop Phase Order
**Choice:** Setup → PIB Builder → Architect → Bootstrap

**Rationale:** (Eric's input)
- **Setup first:** Only needs a project name. Creates the container (folder, git, GitHub remote, .claw/ structure). Gives PIB Builder somewhere to write.
- **PIB Builder second:** Works inside the directory. Interviews user, does Perplexity research, writes PIB to `.claw/specs/pib.md` and research docs to `.claw/docs/`.
- **Architect third:** Reads the PIB and research docs. Generates WORKPLAN, PROMPT, specs. Now we know the full architecture.
- **Bootstrap last:** Reads what Architect decided (especially tech stack). Installs tooling, dependencies, .claude/ config.

Each phase writes files that the next phase reads. Clean data flow.

**Not chosen:** PIB Builder before Setup (would have nowhere to write research docs)

---

### Decision: PIB Builder Has Web Research
**Choice:** PIB Builder can use Perplexity to research during interview

**Rationale:**
- Validates tech stack choices before committing
- Surfaces existing solutions / prior art
- Identifies gotchas early
- Makes PIB more informed than user alone could produce

---

### Decision: Language Plugin System for Bootstrap
**Choice:** Bootstrap uses modular language plugins for stack-specific tooling

**Rationale:** (Eric's input)
- Bootstrap needs to set up deterministic code quality tools (linters, type checkers, formatters)
- Different languages have different tools and conventions
- Plugin system makes it easy to add new language support
- Start with TypeScript and Python
- Could have a skill that helps build new language plugins

**Plugin responsibilities:**
- Formatter (Biome, Ruff)
- Linter (Biome, Ruff)
- Type checker (tsc, MyPy)
- Test runner (Vitest, pytest)
- Package manager (npm, uv)
- Claude Code hooks (auto-format on save)
- Codebase navigation tools (language-specific)

See `LANGUAGE-PLUGINS.md` for full design.

---

## Pending Decisions

### Task Metadata Format
**Options:**
1. HTML comments: `<!-- slice:windows, touches:windowStore -->`
2. YAML frontmatter per task
3. Structured WORKPLAN.md with sections per task

**Leaning:** HTML comments (invisible in rendered markdown, parseable)

---

### Task Dependencies
**Question:** Should tasks support explicit `blocked_by` relationships?

**Options:**
1. No dependencies — just order tasks properly
2. Simple `after: task-id` annotations
3. Full dependency graph

**Leaning:** Start simple (option 1), add if needed

---

### Failure Handling
**Question:** What happens when Sonnet fails a task?

**Options:**
1. Retry N times, then pause
2. Skip, log to ISSUES.md, continue
3. Pause for supervisor intervention

**Leaning:** Configurable, default to option 3

---

### Supervision Event Delivery
**Question:** How does supervisor receive events?

**Options:**
1. Poll status.json (current ralph approach)
2. Webhook callback
3. File-based pub/sub (write to events/ directory)
4. Native OpenClaw integration (emit to session)

**Leaning:** Option 3 for standalone, option 4 for plugin
