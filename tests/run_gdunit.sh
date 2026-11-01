#!/bin/sh
# Run the gdUnit4 suites headless (same invocation as project-viberl).
# Usage: tests/run_gdunit.sh [extra GdUnitCmdTool args, e.g. -c]
# Reports land in godot/reports/ (gitignored).
cd "$(dirname "$0")/.." || exit 2
GODOT="${GODOT_BIN:-../godotbin/Godot_v4.7.2-stable_linux.x86_64}"
# --remote-debug tcp://127.0.0.1:0 keeps Godot off its interactive CLI
# debugger on parse errors; --ignoreHeadlessMode is required because the
# tool refuses plain headless (our suites don't need InputEvents).
exec "$GODOT" --headless --path . -s -d --remote-debug tcp://127.0.0.1:0 \
  res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a tests/gdunit/ --ignoreHeadlessMode "$@"
