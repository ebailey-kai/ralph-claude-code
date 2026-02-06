#!/bin/bash
# show-contract.sh - Extract header docblock from a file
# Zero LLM cost - pure text processing

set -e

FILE="${1:-}"

if [[ -z "$FILE" ]]; then
  echo "Usage: $0 <file-path>" >&2
  exit 1
fi

if [[ ! -f "$FILE" ]]; then
  echo "File not found: $FILE" >&2
  exit 1
fi

# Detect file type and extract appropriate contract
case "$FILE" in
  *.ts|*.tsx|*.js|*.jsx)
    # Extract JSDoc comment at start of file
    awk '
      /^\/\*\*/ { p=1 }
      p { print }
      /\*\// { if(p) exit }
    ' "$FILE"
    ;;
  *.py)
    # Extract docstring at start of file
    awk '
      /^"""/ || /^'\'''\'''\''/ { 
        if (!started) { started=1; p=1 } 
        else { print; exit }
      }
      p { print }
    ' "$FILE"
    ;;
  *.md)
    # Show first 30 lines
    head -30 "$FILE"
    ;;
  *)
    echo "Unknown file type: $FILE" >&2
    exit 1
    ;;
esac
