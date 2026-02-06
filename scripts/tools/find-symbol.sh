#!/bin/bash
# find-symbol.sh - Find usages of a symbol in the codebase
# Zero LLM cost - ripgrep wrapper

set -e

SYMBOL="${1:-}"
PROJECT_ROOT="${2:-.}"

if [[ -z "$SYMBOL" ]]; then
  echo "Usage: $0 <symbol> [project-root]" >&2
  exit 1
fi

cd "$PROJECT_ROOT"

# Use ripgrep if available, fall back to grep
if command -v rg &> /dev/null; then
  rg -n --type ts --type tsx --type py "$SYMBOL" src/ 2>/dev/null || echo "No matches found"
else
  grep -rn "$SYMBOL" src/ --include="*.ts" --include="*.tsx" --include="*.py" 2>/dev/null || echo "No matches found"
fi
