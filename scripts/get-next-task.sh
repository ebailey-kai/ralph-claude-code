#!/bin/bash
# get-next-task.sh - Extract the next unchecked task from WORKPLAN.md
# Outputs JSON with task info for Haiku context building

set -e

PROJECT_ROOT="${1:-.}"
WORKPLAN="$PROJECT_ROOT/.claw/WORKPLAN.md"

if [[ ! -f "$WORKPLAN" ]]; then
  echo '{"error": "WORKPLAN.md not found"}' >&2
  exit 1
fi

# Find the first unchecked task
TASK_LINE=$(grep -n '^\s*- \[ \]' "$WORKPLAN" | head -1)

if [[ -z "$TASK_LINE" ]]; then
  echo '{"status": "ALL_TASKS_COMPLETE"}'
  exit 0
fi

LINE_NUM=$(echo "$TASK_LINE" | cut -d: -f1)
FULL_LINE=$(echo "$TASK_LINE" | cut -d: -f2-)
TASK_TEXT=$(echo "$FULL_LINE" | sed 's/^\s*- \[ \] //' | sed 's/<!--.*-->//')

# Extract metadata from HTML comment if present
METADATA=""
if echo "$FULL_LINE" | grep -q '<!--.*-->'; then
  METADATA=$(echo "$FULL_LINE" | grep -oP '<!--\s*\K[^>]+(?=\s*-->)')
fi

# Extract slice and touches from metadata
SLICE=""
TOUCHES=""
if [[ -n "$METADATA" ]]; then
  SLICE=$(echo "$METADATA" | grep -oP 'slice:\s*\K[^,]+' | tr -d ' ' || true)
  TOUCHES=$(echo "$METADATA" | grep -oP 'touches:\s*\K[^,]+' | tr -d ' ' || true)
fi

# Find which phase this task is in
PHASE=$(head -n "$LINE_NUM" "$WORKPLAN" | grep -E "^## " | tail -1 | sed 's/^## //')

# Count tasks done and remaining in this phase
PHASE_START=$(grep -n "^## $PHASE" "$WORKPLAN" | head -1 | cut -d: -f1)
NEXT_PHASE_LINE=$(tail -n +$((PHASE_START + 1)) "$WORKPLAN" | grep -n "^## " | head -1 | cut -d: -f1 || echo "")

if [[ -n "$NEXT_PHASE_LINE" ]]; then
  PHASE_END=$((PHASE_START + NEXT_PHASE_LINE - 1))
else
  PHASE_END=$(wc -l < "$WORKPLAN")
fi

# Count tasks - using || true to handle no matches, then defaulting
DONE_IN_PHASE=$(sed -n "${PHASE_START},${PHASE_END}p" "$WORKPLAN" | grep -c '^\s*- \[x\]') || DONE_IN_PHASE=0
TODO_IN_PHASE=$(sed -n "${PHASE_START},${PHASE_END}p" "$WORKPLAN" | grep -c '^\s*- \[ \]') || TODO_IN_PHASE=0

# Total progress
TOTAL_DONE=$(grep -c '^\s*- \[x\]' "$WORKPLAN") || TOTAL_DONE=0
TOTAL_TODO=$(grep -c '^\s*- \[ \]' "$WORKPLAN") || TOTAL_TODO=0

# Output JSON
cat << EOF
{
  "status": "TASK_FOUND",
  "task": "$(echo "$TASK_TEXT" | sed 's/"/\\"/g')",
  "line": $LINE_NUM,
  "phase": "$(echo "$PHASE" | sed 's/"/\\"/g')",
  "phase_progress": {
    "done": $DONE_IN_PHASE,
    "remaining": $TODO_IN_PHASE
  },
  "total_progress": {
    "done": $TOTAL_DONE,
    "remaining": $TOTAL_TODO
  },
  "metadata": {
    "slice": "$SLICE",
    "touches": "$TOUCHES"
  }
}
EOF
