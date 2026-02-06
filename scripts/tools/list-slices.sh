#!/bin/bash
# list-slices.sh - List all slices in the project
# Zero LLM cost - pure filesystem

set -e

PROJECT_ROOT="${1:-.}"

if [[ -d "$PROJECT_ROOT/src/slices" ]]; then
  for slice in "$PROJECT_ROOT/src/slices"/*/; do
    if [[ -d "$slice" ]]; then
      slice_name=$(basename "$slice")
      file_count=$(find "$slice" -type f \( -name "*.ts" -o -name "*.tsx" \) 2>/dev/null | wc -l)
      has_contract="no"
      [[ -f "$slice/slice.md" ]] && has_contract="yes"
      echo "$slice_name (files: $file_count, contract: $has_contract)"
    fi
  done
else
  echo "No slices directory found at $PROJECT_ROOT/src/slices"
  exit 1
fi
