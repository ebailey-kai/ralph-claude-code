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

**Purpose:** Interview the user and build a complete Project Information Brief.

**Model:** Haiku or Sonnet (TBD — needs to be conversational)

**Works in:** The project directory created by Setup

**Capabilities:**
- Conversational interview (asks clarifying questions)
- Web research via Perplexity (tech stack validation, best practices, existing solutions)
- Writes research findings to `.claw/docs/`
- PIB template awareness (knows what sections need to be filled)
- Completeness checking (won't proceed until PIB is solid)

### Interview Flow

1. **Initial Capture**
   - "What do you want to build?"
   - "Who is it for?"
   - "What's the core problem it solves?"

2. **Tech Stack Discovery**
   - "What technologies are you thinking?"
   - "Any constraints? (existing codebase, team skills, deployment target)"
   - Research: validate stack choices, suggest alternatives if issues found
   - Write findings to `.claw/docs/stack-research.md`

3. **Requirements Elaboration**
   - "Walk me through how a user would use this"
   - "What are the must-haves vs nice-to-haves?"
   - "Any integrations needed? (auth, payments, APIs)"

4. **Scope & Constraints**
   - "How big is this? MVP or full product?"
   - "Any deadline or time constraints?"
   - "What's out of scope?"

5. **Research Phase**
   - Verify tech stack recommendations
   - Find existing solutions / prior art
   - Identify potential gotchas
   - Surface best practices for the stack
   - Write findings to `.claw/docs/`

6. **Completeness Check**
   - Review PIB template, identify gaps
   - Ask targeted follow-up questions
   - Present summary for user approval
   - Write final PIB to `.claw/specs/pib.md`

### PIB Template

Written to `.claw/specs/pib.md`:

```markdown
# Project Information Brief

## Project
- **Name:** [project name]
- **One-liner:** [single sentence description]
- **Problem:** [what problem does this solve?]
- **Users:** [who is this for?]

## Requirements

### Must Have (MVP)
- [requirement 1]
- [requirement 2]

### Should Have
- [requirement 1]

### Could Have (future)
- [requirement 1]

### Out of Scope
- [explicitly excluded thing]

## Tech Stack
- **Language:** [language + version]
- **Framework:** [framework + version]
- **Database:** [if applicable]
- **Auth:** [if applicable]
- **Deployment:** [target environment]
- **Testing:** [test framework]

### Stack Rationale
[Why these choices? What alternatives were considered?]

## Architecture Notes
[High-level architecture decisions, if any emerged during interview]

## Research Findings
[Key findings from Perplexity research — see .claw/docs/ for details]
- [finding 1]
- [finding 2]

## Open Questions
[Anything that needs to be resolved during architect phase]

## Constraints
- **Timeline:** [if any]
- **Team:** [solo, pair, team size]
- **Budget:** [if relevant]
```

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

PIB Builder should NOT hand off to Architect until:

- [ ] Project name and one-liner are clear
- [ ] Core problem is articulated
- [ ] At least 3 must-have requirements defined
- [ ] Tech stack is specified and validated via research
- [ ] Scope is defined (what's in, what's out)
- [ ] Research docs written to `.claw/docs/`
- [ ] PIB written to `.claw/specs/pib.md`
- [ ] User has approved the PIB summary

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

**Purpose:** Set up Claude Code and install tech stack tooling.

**Evolved from:** ralph-bootstrap

**Inputs:**
- Project folder with `.claw/` specs
- Tech stack info from PIB and AGENT.md

**Outputs:**
- `.claude/` directory with settings and hooks
- Codebase navigation subagent installed
- Package manager initialized (`npm install` / `uv sync`)
- Linting, formatting, type-checking configured
- `CLAUDE.md` generated
- `.clawrc` configured

### What It Creates

```
project-name/
├── .claude/
│   ├── settings.json       # Model config (Sonnet)
│   ├── hooks.json          # Auto-format hooks
│   └── agents/
│       └── codebase-nav.md # Haiku exploration subagent
├── CLAUDE.md               # Project context for Claude Code
├── .clawrc                 # Loop configuration
├── tsconfig.json           # (TypeScript)
├── biome.json              # (TypeScript)
├── pyproject.toml          # (Python)
└── node_modules/ or .venv/ # Dependencies installed
```

### Stack-Specific Configuration

**TypeScript:**
- Biome for linting + formatting
- tsconfig with strict mode
- PostToolUse hook: `biome check --write`

**Python:**
- Ruff for linting + formatting
- MyPy for type checking
- PostToolUse hook: `ruff check --fix && ruff format`

### Quality Gates

- [ ] `.claude/` settings and hooks are valid JSON
- [ ] Codebase nav subagent installed
- [ ] Dependencies installed successfully
- [ ] Linting runs without config errors
- [ ] Type checking runs without config errors
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
