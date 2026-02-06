# Prep Loop: From Idea to Ready

The prep loop gets a project from "vague idea" to "ready to build" before the dev loop ever starts.

## Overview

```
User has idea
      │
      ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ PIB Builder │────▶│    Setup    │────▶│  Architect  │────▶│  Bootstrap  │────▶│    Ready    │
│ (interview) │     │  (scaffold) │     │   (specs)   │     │  (tooling)  │     │  (dev loop) │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

| Phase | Skill | Input | Output |
|-------|-------|-------|--------|
| 1 | PIB Builder | User's idea | Validated PIB |
| 2 | claw-setup | PIB | Project folder + git + structure |
| 3 | claw-architect | PIB + folder | .claw/ specs + WORKPLAN |
| 4 | claw-bootstrap | Specs | .claude/ + tooling + dependencies |

## PIB Builder

**Purpose:** Interview the user and build a complete Project Information Brief.

**Model:** Haiku or Sonnet (TBD — needs to be conversational)

**Capabilities:**
- Conversational interview (asks clarifying questions)
- Web research via Perplexity (tech stack validation, best practices, existing solutions)
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

6. **Completeness Check**
   - Review PIB template, identify gaps
   - Ask targeted follow-up questions
   - Present summary for user approval

### PIB Template

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
[Key findings from Perplexity research]
- [finding 1]
- [finding 2]

## Open Questions
[Anything that needs to be resolved during architect phase]

## Constraints
- **Timeline:** [if any]
- **Team:** [solo, pair, team size]
- **Budget:** [if relevant]
```

### Quality Gates

PIB Builder should NOT hand off to Architect until:

- [ ] Project name and one-liner are clear
- [ ] Core problem is articulated
- [ ] At least 3 must-have requirements defined
- [ ] Tech stack is specified and validated via research
- [ ] Scope is defined (what's in, what's out)
- [ ] User has approved the PIB summary

## Architect (claw-architect)

**Purpose:** Take a complete PIB and generate all the files needed for the dev loop.

**Model:** Opus (or configurable) — needs strong reasoning for architecture decisions

**Inputs:**
- Completed PIB from PIB Builder
- Project directory (may be empty or existing codebase)

**Outputs:**
- `.claw/WORKPLAN.md` — Task list with metadata
- `.claw/PROMPT.md` — Instructions for the coder
- `.claw/AGENT.md` — Build/test/lint commands
- `.claw/config.yaml` — Loop configuration
- `.claw/specs/*.md` — Detailed specs (as needed)

### Architect Process

1. **Analyze PIB**
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
   - Specs for complex features

5. **Validation**
   - Check all files against quality gates
   - Present summary to user
   - Get approval before dev loop starts

### Architect Quality Gates

- [ ] All PIB requirements mapped to WORKPLAN tasks
- [ ] Tasks are atomic and independently completable
- [ ] Task dependencies are respected in ordering
- [ ] Build/test/lint commands verified via research
- [ ] PROMPT.md follows critical rules (see ralph-architect skill)
- [ ] User has approved the plan

## Setup (claw-setup)

**Purpose:** Scaffold project folder with git and basic structure.

**Evolved from:** ralph-project-setup

**Inputs:**
- Project name (from PIB)
- Target location (`~/.openclaw/workspace/projects/`)

**Outputs:**
- Project folder created
- Git initialized
- `.claw/` directory structure
- `README.md`, `SUPERVISOR.md`
- Basic `.gitignore`
- Initial commit

### What It Creates

```
project-name/
├── .claw/
│   ├── specs/
│   │   └── stdlib/
│   ├── examples/
│   ├── logs/
│   └── docs/
├── src/
├── README.md
├── SUPERVISOR.md
└── .gitignore
```

### Quality Gates

- [ ] Folder created in correct location
- [ ] Git initialized with initial commit
- [ ] `.claw/` structure in place
- [ ] README has project name and description from PIB

---

## Bootstrap (claw-bootstrap)

**Purpose:** Set up Claude Code and install tech stack tooling.

**Evolved from:** ralph-bootstrap

**Inputs:**
- Project folder (from Setup)
- Tech stack info (from Architect specs)

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
│   │   ├── stdlib/
│   │   │   └── CODING.md       # Coding standards
│   │   └── *.md                # Feature specs
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
   - PIB Builder needs to inspect and understand existing code
   - Architect needs to work with existing patterns, not impose new ones
