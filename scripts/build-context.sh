#!/bin/bash
# build-context.sh - Build context packet for the current task
# Uses task metadata to gather relevant files and contracts

set -e

PROJECT_ROOT="${1:-.}"
TASK_JSON="${2:-}"

if [[ -z "$TASK_JSON" ]]; then
  echo "Usage: $0 <project-root> '<task-json>'" >&2
  exit 1
fi

# Parse task JSON
TASK=$(echo "$TASK_JSON" | jq -r '.task')
PHASE=$(echo "$TASK_JSON" | jq -r '.phase')
SLICE=$(echo "$TASK_JSON" | jq -r '.metadata.slice // empty')
TOUCHES=$(echo "$TASK_JSON" | jq -r '.metadata.touches // empty')
DONE=$(echo "$TASK_JSON" | jq -r '.phase_progress.done')
REMAINING=$(echo "$TASK_JSON" | jq -r '.phase_progress.remaining')

cd "$PROJECT_ROOT"

# Start building context
cat << EOF
# Context Packet

## Current Task

> $TASK

## Phase Progress

**$PHASE** — $DONE done, $REMAINING remaining

EOF

# If slice is specified, include slice info
if [[ -n "$SLICE" ]]; then
  SLICE_DIR="src/slices/$SLICE"
  if [[ -d "$SLICE_DIR" ]]; then
    echo "## Primary Slice: $SLICE"
    echo ""
    
    # Show slice.md if it exists
    if [[ -f "$SLICE_DIR/slice.md" ]]; then
      echo "### Slice Contract"
      echo '```markdown'
      cat "$SLICE_DIR/slice.md"
      echo '```'
      echo ""
    fi
    
    # List files in slice
    echo "### Files in Slice"
    echo '```'
    find "$SLICE_DIR" -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.py" \) ! -name "*.test.*" 2>/dev/null | sort
    echo '```'
    echo ""
  fi
fi

# If touches is specified, show those contracts
if [[ -n "$TOUCHES" ]]; then
  echo "## Related Files"
  echo ""
  
  IFS=',' read -ra TOUCH_LIST <<< "$TOUCHES"
  for touch in "${TOUCH_LIST[@]}"; do
    touch=$(echo "$touch" | tr -d ' ')
    
    # Try to find the file
    FOUND_FILE=""
    if [[ -f "src/store/${touch}.ts" ]]; then
      FOUND_FILE="src/store/${touch}.ts"
    elif [[ -f "src/${touch}.ts" ]]; then
      FOUND_FILE="src/${touch}.ts"
    fi
    
    if [[ -n "$FOUND_FILE" ]]; then
      echo "### $touch"
      echo ""
      echo "File: \`$FOUND_FILE\`"
      echo ""
      # Extract header docblock
      echo '```typescript'
      awk '/^\/\*\*/{p=1} p; /\*\//{if(p) exit}' "$FOUND_FILE" 2>/dev/null || echo "// No docblock found"
      echo '```'
      echo ""
    fi
  done
fi

# Look for relevant keywords in task
echo "## Relevant Files (by keyword)"
echo ""

# Extract keywords from task (capitalized words, likely identifiers)
KEYWORDS=$(echo "$TASK" | grep -oE '[A-Z][a-z]+[A-Z][a-zA-Z]*|[a-z]+Store|[a-z]+\.tsx?' | head -5)

if [[ -n "$KEYWORDS" ]]; then
  for keyword in $KEYWORDS; do
    MATCHES=$(find src -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.py" \) 2>/dev/null | xargs grep -l "$keyword" 2>/dev/null | head -3)
    if [[ -n "$MATCHES" ]]; then
      echo "Files mentioning \`$keyword\`:"
      for match in $MATCHES; do
        echo "- \`$match\`"
      done
      echo ""
    fi
  done
fi

# Include relevant specs
echo "## Relevant Specs"
echo ""

if [[ -f ".claw/specs/pib.md" ]]; then
  echo "See \`.claw/specs/pib.md\` for project requirements."
fi

# Check for feature specs that match the task
for spec in .claw/specs/*.md; do
  if [[ -f "$spec" && "$spec" != ".claw/specs/pib.md" ]]; then
    spec_name=$(basename "$spec" .md)
    if echo "$TASK" | grep -qi "$spec_name"; then
      echo ""
      echo "### $spec_name"
      echo '```markdown'
      head -50 "$spec"
      echo '```'
    fi
  fi
done

echo ""
echo "## Instructions"
echo ""
cat << 'EOF'
1. Implement ONLY the task described above
2. Follow existing code patterns and contracts
3. Write tests for new functionality
4. Run tests before committing
5. Mark the task with `[x]` in .claw/WORKPLAN.md
6. Commit with: `git add -A && git commit -m "feat: [description]"`
7. End with CLAW_STATUS block
EOF
