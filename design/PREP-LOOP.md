# Prep Loop: From Idea to Ready

The prep loop gets a project from "vague idea" to "ready to build" before the dev loop ever starts.

## Overview

```
User names project
      │
      ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    Setup    │────▶│ PIB Builder │────▶│  Architect  │────▶│  Bootstrap  │────▶│    Ready    │
│  (scaffold) │     │ (interview) │     │   (specs)   │     │  (tooling)  │     │  (dev loop) │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

| Phase | Skill | Input | Output |
|-------|-------|-------|--------|
| 1 | claw-setup | Project name | Folder + git + .claw/ structure + GitHub remote |
| 2 | PIB Builder | User's idea | PIB + research docs in .claw/docs/ |
| 3 | claw-architect | PIB | Full specs + WORKPLAN + PROMPT |
| 4 | claw-bootstrap | Specs (knows stack) | .claude/ + tooling + dependencies |

**Key insight:** Setup just creates the container. It only needs a project name. PIB Builder then works *inside* that directory, writing the PIB and any research docs. Architect reads those to build specs. Bootstrap reads specs to know what tooling to install.

---

## Phase 1: Setup (claw-setup)

**Purpose:** Create the project container — folder, git, GitHub remote, basic structure.

**Evolved from:** ralph-project-setup

**Inputs:**
- Project name
- Target location (`~/.openclaw/workspace/projects/`)
- Optional: GitHub org/account for remote

**Outputs:**
- Project folder created
- Git initialized with initial commit
- GitHub remote created and linked
- `.claw/` directory structure ready for PIB Builder
- `README.md`, `SUPERVISOR.md`
- Basic `.gitignore`

### What It Creates

```
project-name/
├── .claw/
│   ├── specs/
│   │   └── stdlib/       # Will hold CODING.md later
│   ├── docs/             # PIB Builder writes research here
│   ├── examples/
│   └── logs/
├── src/                  # Empty, ready for code
├── README.md             # Basic readme with project name
├── SUPERVISOR.md         # Supervision notes template
└── .gitignore            # Basic ignores (replaced by Bootstrap later)
```

### GitHub Remote

Setup can optionally create a GitHub repo:
```bash
gh repo create [org/]project-name --private --source=. --push
```

### Quality Gates

- [ ] Folder created in correct location
- [ ] Git initialized with initial commit
- [ ] `.claw/` structure in place (especially `docs/` for PIB Builder)
- [ ] GitHub remote created and pushed (if requested)

---

## Phase 2: PIB Builder

**Purpose:** Interview the user to produce a complete Project Intent Brief — a concise, implementation-agnostic document that captures **what** to build and **why**.

**Reference files:** `references/pib-builder/` contains:
- `instructions.md` — Full behavioral rules (from Eric's GPT)
- `interview-flow.md` — Step-by-step interview guide
- `template.md` — PIB template with all sections

**Model:** Sonnet (needs conversational ability)

**Works in:** The project directory created by Setup

### Core Principles (from Eric's GPT)

1. **Ask "what" questions only** — No tech, architecture, or implementation
2. **Write to PIB as you go** — Don't wait until the end
3. **Prefer bounded prompts** — Lists, examples, thresholds over open-ended
4. **Decisive defaulting** — If vague after one clarification, assume conservatively and proceed
5. **Web research for grounding** — Validate terminology and expectations, not implementation

### Interview Flow

**Step 0: Elevator Pitch**
- "In one sentence, what do you want this to do for a user?"

**Step 1: User and Pain**
- "Who is the primary user?"
- "What are they doing today?"
- "What's the most painful part of that workflow?"

**Step 2: Outcome and Success**
- "What does a great outcome look like?"
- "How would you know it's working?"
- **Failure boundary checkpoint:** "If the system did everything else perfectly but failed here, would you consider it a failure?"

**Step 3: Capabilities and Non-Goals**
- "List 3-7 must-have capabilities for v1."
- "List 3 things we explicitly will NOT do in v1."

**Step 4: Primary User Journeys**
- "Walk me through the happy path in 5-8 steps."

**Step 5: Quality Bar and Constraints**
- "What absolutely cannot go wrong?"
- "What's okay to be imperfect in v1?"
- "Any privacy, budget, or timeline constraints?"

**Step 6: Acceptance Tests**
- Translate capabilities into Given/When/Then tests
- Each test must be distinct and observable

**Step 7: Validation**
- Present completed PIB
- "Is anything missing or misrepresented?"

### Tech Stack (handled separately)

The PIB is implementation-agnostic. Tech stack discovery happens **after** the PIB is complete, as a bridge to Architect:

- "Now that we know what to build, what technologies are you thinking?"
- Research with Perplexity to validate choices
- Write findings to `.claw/docs/stack-research.md`

### PIB Template

Written to `.claw/specs/pib.md`. Full template in `references/pib-builder/template.md`.

**Sections:**
1. **Problem and User** — Who, context, pain points, why now
2. **Outcome** — Desired outcome, success signal, failure boundary
3. **In-Scope Capabilities** — User-facing behaviors for v1
4. **Explicit Non-Goals** — What we will NOT do
5. **Primary User Journeys** — 1-3 step-by-step flows
6. **Quality Bar** — Must-not-fail, acceptable trade-offs, performance expectations
7. **Constraints** — Privacy, compliance, budget, timeline, assumptions
8. **Acceptance Tests** — Given/When/Then tests (5-12)
9. **Deferred Implementation Questions** — "How" questions to resolve later
10. **Open Questions** — True intent blockers only
11. **Intent Clarity Self-Check** — Author confirmation checklist

**Key rule:** The PIB is implementation-agnostic. No tech stack, architecture, or code structure. Those come after, in the bridge to Architect.

### What PIB Builder Writes

```
.claw/
├── specs/
│   └── pib.md                  # The PIB itself
└── docs/
    ├── stack-research.md       # Tech stack research findings
    ├── prior-art.md            # Existing solutions found
    └── [topic]-research.md     # Other research as needed
```

### Quality Gates

PIB is complete when:

- [ ] All sections filled or marked N/A with rationale
- [ ] Capabilities are specific and user-facing
- [ ] Non-goals are explicit and enforceable
- [ ] 5-12 acceptance tests exist and are observable
- [ ] Every capability maps to ≥1 acceptance test
- [ ] No non-goal is contradicted by a capability
- [ ] Privacy and budget posture explicit (or assumed)
- [ ] Open questions ≤3, and only true intent blockers
- [ ] User has approved the PIB
- [ ] Tech stack discovery complete (post-PIB)
- [ ] Research docs written to `.claw/docs/`

---

## Phase 3: Architect (claw-architect)

**Purpose:** Take the PIB and generate all spec files needed for the dev loop.

**Evolved from:** ralph-architect

**Model:** Opus (or configurable) — needs strong reasoning for architecture decisions

**Inputs:**
- Completed PIB at `.claw/specs/pib.md`
- Research docs at `.claw/docs/`
- Project directory

**Outputs:**
- `.claw/WORKPLAN.md` — Task list with metadata
- `.claw/PROMPT.md` — Instructions for the coder
- `.claw/AGENT.md` — Build/test/lint commands
- `.claw/config.yaml` — Loop configuration
- `.claw/specs/*.md` — Detailed feature specs (as needed)
- `.claw/specs/stdlib/CODING.md` — Coding standards

### Architect Process

1. **Analyze PIB**
   - Read `.claw/specs/pib.md` and `.claw/docs/`
   - Understand requirements and constraints
   - Identify architectural patterns needed
   - Determine phase breakdown

2. **Research (if needed)**
   - Verify build/test/lint commands for the stack
   - Research framework-specific patterns
   - Find libraries for required functionality

3. **Generate WORKPLAN.md**
   - Break requirements into atomic tasks
   - Order by dependency
   - Add metadata (slice, complexity, touches)
   - Group into phases

4. **Generate Supporting Files**
   - PROMPT.md tailored to the project
   - AGENT.md with verified commands
   - Feature specs for complex requirements
   - Copy CODING.md to specs/stdlib/

5. **Validation**
   - Check all files against quality gates
   - Present summary to user
   - Get approval before proceeding to Bootstrap

### What Architect Creates

```
.claw/
├── WORKPLAN.md                 # Task list with metadata
├── PROMPT.md                   # Coder instructions
├── AGENT.md                    # Build/test/lint commands
├── config.yaml                 # Loop configuration
└── specs/
    ├── pib.md                  # (from PIB Builder)
    ├── stdlib/
    │   └── CODING.md           # Coding standards
    ├── [feature-1].md          # Feature spec
    └── [feature-2].md          # Feature spec
```

### Quality Gates

- [ ] All PIB requirements mapped to WORKPLAN tasks
- [ ] Tasks are atomic and independently completable
- [ ] Task dependencies are respected in ordering
- [ ] Build/test/lint commands verified via research
- [ ] PROMPT.md follows critical rules (task checking, status block, etc.)
- [ ] CODING.md copied to specs/stdlib/
- [ ] User has approved the WORKPLAN

---

## Phase 4: Bootstrap (claw-bootstrap)

**Purpose:** Set up Claude Code and install tech stack tooling via language plugins.

**Evolved from:** ralph-bootstrap

**Inputs:**
- Project folder with `.claw/` specs
- Tech stack info from PIB and AGENT.md

**Outputs:**
- `.claude/` directory with settings and hooks
- Codebase navigation subagent installed
- Code quality tools configured (linter, formatter, type checker)
- Package manager initialized, dependencies installed
- `CLAUDE.md` generated
- `.clawrc` configured

### Language Plugin System

Bootstrap uses modular **language plugins** to handle stack-specific tooling. Each plugin knows how to set up:

| Category | TypeScript | Python |
|----------|------------|--------|
| Formatter | Biome | Ruff |
| Linter | Biome | Ruff |
| Type Checker | tsc | MyPy |
| Test Runner | Vitest | pytest |
| Package Manager | npm/pnpm | uv |
| Auto-format Hook | `biome check --write` | `ruff check --fix && ruff format` |

Plugins live in `plugins/{language}/` and contain:
- `plugin.yaml` — metadata, commands, conventions
- `templates/` — config files (tsconfig.json, pyproject.toml, etc.)
- `claude/` — settings.json, hooks.json, codebase-nav agent
- `scripts/` — install.sh, verify.sh, codebase-nav tools

See `LANGUAGE-PLUGINS.md` for full plugin design.

### Bootstrap Flow

1. Read tech stack from `.claw/specs/pib.md`
2. Load appropriate language plugin
3. Copy templates, replace placeholders
4. Set up `.claude/` from plugin
5. Run `plugin.commands.install`
6. Run `plugin.scripts/verify.sh`
7. Generate `CLAUDE.md`
8. Configure `.clawrc`

### What It Creates

```
project-name/
├── .claude/
│   ├── settings.json       # Model config (Sonnet)
│   ├── hooks.json          # Auto-format hooks (from plugin)
│   └── agents/
│       └── codebase-nav.md # Haiku exploration subagent (from plugin)
├── CLAUDE.md               # Project context for Claude Code
├── .clawrc                 # Loop configuration
├── [plugin templates]      # tsconfig.json, biome.json, pyproject.toml, etc.
└── [dependencies]          # node_modules/ or .venv/
```

### Quality Gates

- [ ] Language plugin loaded successfully
- [ ] Templates copied and placeholders replaced
- [ ] `.claude/` settings and hooks are valid JSON
- [ ] Codebase nav subagent installed
- [ ] Dependencies installed successfully (`plugin.commands.install`)
- [ ] Linting runs without errors (`plugin.commands.lint`)
- [ ] Type checking runs without errors (`plugin.commands.type_check`)
- [ ] `CLAUDE.md` generated with correct commands
- [ ] `.clawrc` configured with appropriate ALLOWED_TOOLS

---

## Handoff to Dev Loop

Once Bootstrap completes:

1. `.claw/` has specs, WORKPLAN, PROMPT, AGENT files
2. `.claude/` has settings, hooks, codebase-nav subagent
3. Dependencies installed and tooling verified
4. `CLAUDE.md` provides project context
5. User has approved the WORKPLAN
6. Status is set to `ready`
7. Dev loop can be started with `claw start`

### The Complete File Structure

```
project-name/
├── .claw/                      # Prep loop output
│   ├── WORKPLAN.md             # Task list with metadata
│   ├── PROMPT.md               # Coder instructions
│   ├── AGENT.md                # Build/test/lint commands
│   ├── config.yaml             # Loop configuration
│   ├── status.json             # Loop state (created at runtime)
│   ├── specs/
│   │   ├── pib.md              # Project Information Brief
│   │   ├── stdlib/
│   │   │   └── CODING.md       # Coding standards
│   │   └── *.md                # Feature specs
│   ├── docs/                   # Research from PIB Builder
│   │   ├── stack-research.md
│   │   └── *.md
│   ├── events/                 # Supervisor events (runtime)
│   └── logs/                   # Loop logs (runtime)
│
├── .claude/                    # Claude Code config
│   ├── settings.json           # Model + permissions
│   ├── hooks.json              # Auto-format hooks
│   └── agents/
│       └── codebase-nav.md     # Haiku exploration subagent
│
├── src/                        # Source code (empty at start)
├── CLAUDE.md                   # Project context for Claude Code
├── SUPERVISOR.md               # Supervision notes
├── README.md                   # Project readme
├── .clawrc                     # Loop config
└── [stack files]               # tsconfig.json, pyproject.toml, etc.
```

---

## Open Questions

1. **Should PIB Builder be conversational (Sonnet) or interview-script (Haiku)?**
   - Conversational is more natural but more expensive
   - Script-based is cheaper but less flexible
   - Could be configurable

2. **How interactive should Architect be?**
   - Fully autonomous (generate everything, present for approval)?
   - Collaborative (ask questions during generation)?

3. **What happens if user wants to modify the plan after approval?**
   - Edit WORKPLAN.md manually?
   - Re-run Architect with updated PIB?
   - Both?

4. **How do we handle existing codebases?**
   - Skip Setup (folder exists)
   - PIB Builder inspects existing code
   - Architect works with existing patterns, not impose new ones
