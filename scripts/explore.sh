#!/bin/bash
# explore.sh - Haiku-powered codebase exploration
# 
# Usage: ./explore.sh <project-root> "<question>"
#
# Sends a question to Haiku with codebase context, returns a concise answer.
# Cheaper than having Sonnet read full files.

set -e

PROJECT_ROOT="${1:-.}"
QUESTION="${2:-}"

if [[ -z "$QUESTION" ]]; then
  echo "Usage: $0 <project-root> '<question>'" >&2
  exit 1
fi

cd "$PROJECT_ROOT"

# Build exploration context
CONTEXT=$(cat << 'EOF'
You are a codebase exploration assistant. Your job is to answer questions about the codebase concisely.

## Codebase Structure

EOF
)

# Add directory tree
CONTEXT+="### Directory Structure\n\`\`\`\n"
CONTEXT+=$(find src -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.py" \) 2>/dev/null | head -30 | sort)
CONTEXT+="\n\`\`\`\n\n"

# Add slice contracts if they exist
if [[ -d "src/slices" ]]; then
  CONTEXT+="### Slice Contracts\n\n"
  for slice_md in src/slices/*/slice.md; do
    if [[ -f "$slice_md" ]]; then
      slice_name=$(dirname "$slice_md" | xargs basename)
      CONTEXT+="#### $slice_name\n"
      CONTEXT+=$(cat "$slice_md" | head -20)
      CONTEXT+="\n\n"
    fi
  done
fi

# Add store interfaces if they exist
if [[ -d "src/store" ]]; then
  CONTEXT+="### Store Interfaces\n\n"
  for store in src/store/*.ts; do
    if [[ -f "$store" ]]; then
      store_name=$(basename "$store")
      CONTEXT+="#### $store_name\n\`\`\`typescript\n"
      # Extract interfaces and type exports
      grep -E "^(export )?(interface|type|const use)" "$store" | head -15
      CONTEXT+="\n\`\`\`\n\n"
    fi
  done
fi

# Build the prompt
PROMPT=$(cat << EOF
$CONTEXT

## Question

$QUESTION

## Instructions

1. Answer the question based on the codebase structure and contracts shown above
2. Be concise — aim for 100-300 words
3. Reference specific file paths when relevant
4. If you need to see a specific file's implementation, say which one
5. Do NOT guess — if the info isn't in the context, say so

## Answer
EOF
)

# Call Haiku
HAIKU_MODEL="${HAIKU_MODEL:-claude-3-haiku-20240307}"

claude -p "$PROMPT" --model "$HAIKU_MODEL" --max-tokens 500
