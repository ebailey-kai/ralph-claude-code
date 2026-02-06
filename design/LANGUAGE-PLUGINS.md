# Language Plugins

Bootstrap uses language plugins to set up stack-specific tooling. Each plugin knows how to configure linters, formatters, type checkers, and other code quality tools for its language.

## Overview

```
Bootstrap
    │
    ├── Reads tech stack from PIB/specs
    │
    ├── Loads appropriate language plugin
    │   ├── typescript/
    │   ├── python/
    │   └── [future languages]
    │
    └── Plugin installs and configures tooling
```

## Plugin Responsibilities

Each language plugin handles:

| Category | Purpose | Examples |
|----------|---------|----------|
| **Formatter** | Consistent code style | Biome, Prettier, Ruff, Black |
| **Linter** | Code quality rules | Biome, ESLint, Ruff, Pylint |
| **Type Checker** | Static type analysis | TypeScript, MyPy, Pyright |
| **Test Runner** | Run tests | Vitest, Jest, pytest |
| **Package Manager** | Dependency management | npm, pnpm, uv, pip |
| **Git Hooks** | Pre-commit checks | Husky, pre-commit |
| **Claude Code Hooks** | Auto-format on save | PostToolUse hooks |

## Plugin Structure

```
plugins/
├── typescript/
│   ├── plugin.yaml           # Plugin metadata
│   ├── templates/
│   │   ├── tsconfig.json
│   │   ├── biome.json
│   │   ├── package.json
│   │   └── .gitignore
│   ├── claude/
│   │   ├── settings.json
│   │   ├── hooks.json
│   │   └── agents/
│   │       └── codebase-nav.md
│   └── scripts/
│       ├── install.sh        # Run npm/pnpm install
│       ├── verify.sh         # Check tooling works
│       └── codebase-nav/     # Bash exploration tools
│           ├── list-slices.sh
│           ├── show-contract.sh
│           └── slice-deps.sh
│
├── python/
│   ├── plugin.yaml
│   ├── templates/
│   │   ├── pyproject.toml
│   │   ├── .gitignore
│   │   └── .pre-commit-config.yaml
│   ├── claude/
│   │   ├── settings.json
│   │   ├── hooks.json
│   │   └── agents/
│   │       └── codebase-nav.md
│   └── scripts/
│       ├── install.sh        # Run uv sync
│       ├── verify.sh
│       └── codebase-nav/
│           ├── list-modules.sh
│           ├── show-contract.sh
│           └── module-deps.sh
│
└── [language]/
    └── ...
```

## plugin.yaml

Each plugin declares its metadata and capabilities:

```yaml
# plugins/typescript/plugin.yaml
name: typescript
display_name: TypeScript
version: 1.0.0

# What this plugin provides
tools:
  formatter: biome
  linter: biome
  type_checker: tsc
  test_runner: vitest
  package_manager: npm  # or pnpm

# Commands Bootstrap should run
commands:
  install: npm install
  lint: npx biome check .
  format: npx biome check --write .
  type_check: npx tsc --noEmit
  test: npx vitest run

# Claude Code hook commands
hooks:
  post_write: npx biome check --write {{file}}
  post_edit: npx biome check --write {{file}}

# Files to copy from templates/
templates:
  - tsconfig.json
  - biome.json
  - package.json
  - .gitignore

# Placeholders to replace in templates
placeholders:
  - PROJECT_NAME
  - PROJECT_DESCRIPTION

# VSA conventions for this language
conventions:
  slice_location: src/slices/{name}/
  slice_manifest: slice.md
  contract_pattern: "/** ... */"  # JSDoc
  store_location: src/store/
```

```yaml
# plugins/python/plugin.yaml
name: python
display_name: Python
version: 1.0.0

tools:
  formatter: ruff
  linter: ruff
  type_checker: mypy
  test_runner: pytest
  package_manager: uv

commands:
  install: uv sync --dev
  lint: uv run ruff check .
  format: uv run ruff format .
  type_check: uv run mypy src/
  test: uv run pytest

hooks:
  post_write: uv run ruff check --fix {{file}} && uv run ruff format {{file}}
  post_edit: uv run ruff check --fix {{file}} && uv run ruff format {{file}}

templates:
  - pyproject.toml
  - .gitignore
  - .pre-commit-config.yaml

placeholders:
  - PROJECT_NAME
  - PROJECT_NAME_SNAKE
  - PROJECT_DESCRIPTION

conventions:
  slice_location: src/{project}/slices/{name}/
  slice_manifest: __init__.py  # docstring at top
  contract_pattern: '"""..."""'  # docstrings
  store_location: src/{project}/store/
```

## Bootstrap Flow with Plugins

```
1. Read tech stack from .claw/specs/pib.md
   └── Extract: language, framework, package_manager

2. Load language plugin
   └── plugins/{language}/plugin.yaml

3. Copy templates
   └── For each file in plugin.templates:
       └── Copy to project root, replace placeholders

4. Set up .claude/
   └── Copy plugin's claude/ directory
   └── Merge with any project-specific overrides

5. Run install
   └── Execute plugin.commands.install

6. Verify tooling
   └── Run plugin's scripts/verify.sh
   └── Check lint, type_check, test commands work

7. Generate CLAUDE.md
   └── Include plugin-specific commands and conventions
```

## Adding a New Language

To add support for a new language:

1. **Create plugin directory**: `plugins/{language}/`

2. **Write plugin.yaml** with:
   - Tool choices (formatter, linter, type checker, etc.)
   - Commands for each tool
   - Claude Code hook commands
   - Template file list
   - VSA conventions for the language

3. **Create templates/** with:
   - Package manifest (package.json, pyproject.toml, Cargo.toml, etc.)
   - Tool config files (biome.json, ruff section, rustfmt.toml, etc.)
   - .gitignore for the language

4. **Create claude/** with:
   - settings.json (can usually copy from another plugin)
   - hooks.json with language-specific format commands
   - agents/codebase-nav.md tailored to the language

5. **Create scripts/** with:
   - install.sh — install dependencies
   - verify.sh — check all tools work
   - codebase-nav/ — bash tools for the language

6. **Test the plugin** on a sample project

## Plugin Builder Skill (Future)

A skill that helps create new language plugins:

1. **Interview**: Ask about the language, preferred tools, conventions
2. **Research**: Use Perplexity to find current best practices
3. **Generate**: Create plugin.yaml, templates, scripts
4. **Test**: Scaffold a test project, run verify.sh
5. **Document**: Generate README for the plugin

This makes it easy to add support for:
- Go
- Rust
- Java/Kotlin
- Ruby
- PHP
- etc.

## Tool Selection Philosophy

**Prefer training-data-rich tools.** The goal is smooth autonomous coding, not bleeding-edge tech. Agents are more effective with well-established tools they've seen extensively in training data.

**When choosing tools for a plugin:**
1. Is it well-documented with years of Stack Overflow answers?
2. Is it heavily represented in GitHub repos the model trained on?
3. Will the agent know the correct API without hallucinating?

**Deviate only when:**
- Massive productivity gain justifies the learning curve (Ruff is 100x faster)
- Tool has reached critical mass in training data
- Specific project requirement mandates it

## Initial Plugins

### TypeScript Plugin

**Tools:**
- Biome (formatter + linter, replaces ESLint + Prettier)
- TypeScript (type checker)
- Vitest (test runner)
- npm or pnpm (package manager)

**Why Biome:** Faster, single tool for format + lint, good defaults, less config. Reaching critical mass in training data.

**Why not newer frameworks?** React/Next.js over Solid/Qwik — agents know React deeply.

### Python Plugin

**Tools:**
- Ruff (formatter + linter, replaces Black + isort + Flake8 + many others)
- MyPy (type checker)
- pytest (test runner)
- uv (package manager, replaces pip + venv + pip-tools)

**Why Ruff:** 10-100x faster than alternatives, single tool, excellent defaults. Well-documented.
**Why uv:** Fast, handles venv + deps + lockfile, modern. Created by Astral (Ruff team).
**Why pytest:** Battle-tested, massive training data presence. Not a newer alternative.

## Open Questions

1. **Framework sub-plugins?** Should we have React, Next.js, FastAPI variants within TypeScript/Python plugins? Or handle via plugin.yaml options?

2. **Monorepo support?** How do plugins handle monorepo setups (Turborepo, Nx, etc.)?

3. **Plugin versioning?** How do we handle updates to plugins (new tool versions, changed best practices)?

4. **Plugin discovery?** Where do plugins live? Bundled with claw-builder? Separate repo? User-contributed?
