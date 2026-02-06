#!/bin/bash
# slice-deps.sh - Show slice dependencies
# Parses imports to show what a slice depends on

set -e

SLICE="${1:-}"
PROJECT_ROOT="${2:-.}"

if [[ -z "$SLICE" ]]; then
  echo "Usage: $0 <slice-name> [project-root]" >&2
  exit 1
fi

SLICE_DIR="$PROJECT_ROOT/src/slices/$SLICE"

if [[ ! -d "$SLICE_DIR" ]]; then
  echo "Slice not found: $SLICE_DIR" >&2
  exit 1
fi

echo "=== Slice: $SLICE ==="
echo ""

# Find imports from other slices
echo "Imports from other slices:"
grep -rh "from.*slices/" "$SLICE_DIR" --include="*.ts" --include="*.tsx" 2>/dev/null | \
  grep -v "from.*slices/$SLICE" | \
  sed "s/.*from ['\"]//; s/['\"].*//; s/.*slices\///" | \
  cut -d'/' -f1 | \
  sort -u | \
  while read dep; do echo "  → $dep"; done

echo ""

# Find imports from store
echo "Store dependencies:"
grep -rh "from.*store/" "$SLICE_DIR" --include="*.ts" --include="*.tsx" 2>/dev/null | \
  sed "s/.*from ['\"]//; s/['\"].*//; s/.*store\///" | \
  sort -u | \
  while read dep; do echo "  → $dep"; done

echo ""

# Find slices that import this slice
echo "Imported by:"
grep -rl "from.*slices/$SLICE" "$PROJECT_ROOT/src/slices" --include="*.ts" --include="*.tsx" 2>/dev/null | \
  grep -v "$SLICE_DIR" | \
  sed "s|.*/slices/||; s|/.*||" | \
  sort -u | \
  while read dep; do echo "  ← $dep"; done
