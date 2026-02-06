#!/bin/bash
# claw_loop.sh - Three-tier development loop
# 
# Architecture:
#   Haiku (custodian) → Task selection + context building
#   Sonnet (coder)    → Implementation
#   Opus (supervisor) → External supervision via events
#
# State machine:
#   IDLE → SELECT → PREP → CODE → VALIDATE → COMMIT → [loop]

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${1:-.}"
cd "$PROJECT_ROOT"

CLAW_DIR=".claw"
WORKPLAN="$CLAW_DIR/WORKPLAN.md"
PROMPT_FILE="$CLAW_DIR/PROMPT.md"
STATUS_FILE="$CLAW_DIR/status.json"
EVENTS_DIR="$CLAW_DIR/events"
CONTEXT_FILE="$CLAW_DIR/context/current.md"
LOG_DIR="$CLAW_DIR/logs"

# Create directories
mkdir -p "$EVENTS_DIR" "$CLAW_DIR/context" "$LOG_DIR"

# Load .clawrc if it exists
if [[ -f ".clawrc" ]]; then
  source ".clawrc"
fi

# Defaults
MAX_ITERATIONS="${MAX_ITERATIONS:-50}"
HAIKU_MODEL="${HAIKU_MODEL:-claude-3-haiku-20240307}"
SONNET_MODEL="${SONNET_MODEL:-claude-sonnet-4-20250514}"
CLAUDE_TIMEOUT="${CLAUDE_TIMEOUT_MINUTES:-15}"

# State
ITERATION=0
STATE="IDLE"
EVENT_COUNTER=0

# Logging
log() {
  local level="$1"
  shift
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  echo "[$timestamp] [$level] $*" | tee -a "$LOG_DIR/loop.log"
}

# Event emission
emit_event() {
  local event_type="$1"
  shift
  EVENT_COUNTER=$((EVENT_COUNTER + 1))
  local event_file="$EVENTS_DIR/$(printf '%04d' $EVENT_COUNTER)-${event_type}.event"
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  
  cat > "$event_file" << EOF
{
  "id": $EVENT_COUNTER,
  "type": "$event_type",
  "timestamp": "$timestamp",
  "iteration": $ITERATION,
  $@
}
EOF
  log "INFO" "Emitted event: $event_type"
}

# Update status.json
update_status() {
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  cat > "$STATUS_FILE" << EOF
{
  "state": "$STATE",
  "iteration": $ITERATION,
  "current_task": "$CURRENT_TASK",
  "phase": "$CURRENT_PHASE",
  "last_update": "$timestamp"
}
EOF
}

# State: SELECT - Pick next task
state_select() {
  STATE="SELECT"
  update_status
  log "INFO" "Selecting next task..."
  
  TASK_JSON=$("$SCRIPT_DIR/get-next-task.sh" "$PROJECT_ROOT")
  TASK_STATUS=$(echo "$TASK_JSON" | jq -r '.status')
  
  if [[ "$TASK_STATUS" == "ALL_TASKS_COMPLETE" ]]; then
    log "INFO" "All tasks complete!"
    emit_event "loop_complete" '"message": "All tasks in WORKPLAN.md are complete"'
    return 1
  fi
  
  CURRENT_TASK=$(echo "$TASK_JSON" | jq -r '.task')
  CURRENT_PHASE=$(echo "$TASK_JSON" | jq -r '.phase')
  
  log "INFO" "Selected task: $CURRENT_TASK"
  emit_event "task_started" "\"task\": \"$CURRENT_TASK\", \"phase\": \"$CURRENT_PHASE\""
  
  return 0
}

# State: PREP - Build context packet
state_prep() {
  STATE="PREP"
  update_status
  log "INFO" "Building context packet..."
  
  TASK_JSON=$("$SCRIPT_DIR/get-next-task.sh" "$PROJECT_ROOT")
  "$SCRIPT_DIR/build-context.sh" "$PROJECT_ROOT" "$TASK_JSON" > "$CONTEXT_FILE"
  
  log "INFO" "Context packet written to $CONTEXT_FILE"
}

# State: CODE - Run Sonnet
state_code() {
  STATE="CODE"
  update_status
  log "INFO" "Running Sonnet on task..."
  
  local start_time=$(date +%s)
  local output_file="$LOG_DIR/iteration-${ITERATION}.log"
  
  # Build the prompt by combining PROMPT.md and context
  local full_prompt=$(cat "$PROMPT_FILE")
  full_prompt+="\n\n---\n\n"
  full_prompt+=$(cat "$CONTEXT_FILE")
  
  # Run Claude
  if timeout $((CLAUDE_TIMEOUT * 60)) claude -p "$full_prompt" --model "$SONNET_MODEL" > "$output_file" 2>&1; then
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    log "INFO" "Sonnet completed in ${duration}s"
    
    # Check for CLAW_STATUS in output
    if grep -q "CLAW_STATUS" "$output_file"; then
      CLAW_STATUS=$(grep -A3 "CLAW_STATUS" "$output_file" | grep "STATUS:" | sed 's/.*STATUS: //' | tr -d ' ')
      log "INFO" "Status: $CLAW_STATUS"
    fi
    
    return 0
  else
    log "ERROR" "Claude timed out or failed"
    emit_event "error" '"message": "Claude timed out or failed"'
    return 1
  fi
}

# State: VALIDATE - Check build/tests
state_validate() {
  STATE="VALIDATE"
  update_status
  log "INFO" "Validating changes..."
  
  # Check if there are changes to validate
  if ! git diff --quiet 2>/dev/null; then
    log "INFO" "Changes detected, running tests..."
    
    # Try to run tests (check common commands)
    if [[ -f "package.json" ]] && grep -q '"test"' package.json; then
      if npm test 2>&1 | tee -a "$LOG_DIR/iteration-${ITERATION}.log"; then
        log "INFO" "Tests passed"
        return 0
      else
        log "WARN" "Tests failed"
        emit_event "validation_failed" '"reason": "tests failed"'
        return 1
      fi
    elif [[ -f "pyproject.toml" ]]; then
      if uv run pytest 2>&1 | tee -a "$LOG_DIR/iteration-${ITERATION}.log"; then
        log "INFO" "Tests passed"
        return 0
      else
        log "WARN" "Tests failed"
        emit_event "validation_failed" '"reason": "tests failed"'
        return 1
      fi
    else
      log "INFO" "No test command found, skipping validation"
      return 0
    fi
  else
    log "INFO" "No changes detected"
    return 0
  fi
}

# State: COMMIT - Commit changes
state_commit() {
  STATE="COMMIT"
  update_status
  
  if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
    log "INFO" "Committing changes..."
    git add -A
    git commit -m "feat: $CURRENT_TASK" 2>&1 | tee -a "$LOG_DIR/iteration-${ITERATION}.log" || true
    
    emit_event "task_complete" "\"task\": \"$CURRENT_TASK\", \"iteration\": $ITERATION"
  else
    log "INFO" "No changes to commit"
  fi
}

# Main loop
main() {
  log "INFO" "Starting claw loop in $PROJECT_ROOT"
  log "INFO" "Max iterations: $MAX_ITERATIONS"
  
  # Check prerequisites
  if [[ ! -f "$WORKPLAN" ]]; then
    log "ERROR" "WORKPLAN.md not found at $WORKPLAN"
    exit 1
  fi
  
  if [[ ! -f "$PROMPT_FILE" ]]; then
    log "ERROR" "PROMPT.md not found at $PROMPT_FILE"
    exit 1
  fi
  
  STATE="IDLE"
  update_status
  emit_event "loop_started" '"max_iterations": '$MAX_ITERATIONS
  
  while [[ $ITERATION -lt $MAX_ITERATIONS ]]; do
    ITERATION=$((ITERATION + 1))
    log "INFO" "=== Iteration $ITERATION ==="
    
    # SELECT
    if ! state_select; then
      break
    fi
    
    # PREP
    state_prep
    
    # CODE
    if ! state_code; then
      log "WARN" "Coding failed, pausing..."
      STATE="PAUSED"
      update_status
      emit_event "loop_paused" '"reason": "coding failed"'
      break
    fi
    
    # VALIDATE
    if ! state_validate; then
      log "WARN" "Validation failed, continuing..."
      # Could add retry logic here
    fi
    
    # COMMIT
    state_commit
    
    # Check if we should stop
    if [[ "$CLAW_STATUS" == "COMPLETE" ]]; then
      log "INFO" "Loop marked complete by Sonnet"
      break
    fi
    
    if [[ "$CLAW_STATUS" == "BLOCKED" ]]; then
      log "WARN" "Loop blocked, needs intervention"
      STATE="PAUSED"
      update_status
      emit_event "loop_paused" '"reason": "blocked"'
      break
    fi
    
    # Small delay between iterations
    sleep 2
  done
  
  STATE="IDLE"
  update_status
  log "INFO" "Loop finished after $ITERATION iterations"
}

# Run
main "$@"
