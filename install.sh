#!/usr/bin/env bash
# Install herd: scripts to ~/.local/bin (override with HERD_BIN_DIR), skill to ~/.claude/skills/herd.
set -euo pipefail
cd "$(dirname "$0")"
bindir="${HERD_BIN_DIR:-$HOME/.local/bin}"
skilldir="$HOME/.claude/skills/herd"
mkdir -p "$bindir" "$skilldir"
install -m 0755 bin/herd-up bin/herd-spawn "$bindir/"
install -m 0644 skills/herd/SKILL.md "$skilldir/SKILL.md"
echo "installed herd-up, herd-spawn -> $bindir"
echo "installed herd skill       -> $skilldir"
case ":$PATH:" in
  *":$bindir:"*) ;;
  *) echo "note: $bindir is not on your PATH — add it to use herd-up/herd-spawn" ;;
esac
command -v herdr >/dev/null || echo "note: herdr not found on PATH — install it from https://herdr.dev"
command -v jq >/dev/null || echo "note: jq not found on PATH — herd scripts need it"
