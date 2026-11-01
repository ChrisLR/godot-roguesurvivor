#!/bin/sh
# Full validation: parse-check all scripts and fail on any script error.
# Usage: tests/validate.sh
cd "$(dirname "$0")/.." || exit 2
LOG=$(mktemp)
../godotbin/Godot_v4.7.2-stable_linux.x86_64 --headless --script tests/validate.gd > "$LOG" 2>&1
tail -1 "$LOG"
if grep -qE "SCRIPT ERROR|Parse Error|Compile Error|PARSE_FAIL|VALIDATE_FAILED" "$LOG"; then
  grep -E "SCRIPT ERROR|Parse Error|Compile Error|PARSE_FAIL" "$LOG" | sort -u
  rm -f "$LOG"
  exit 1
fi
rm -f "$LOG"
exit 0
