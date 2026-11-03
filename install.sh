#!/usr/bin/env bash
# Install the sigma-designs skill family for BOTH Claude Code (~/.claude/skills)
# and Codex (~/.agents/skills) on macOS / Linux, via symlinks (so `git pull` propagates).
# Re-runnable: SKIPS any skill name that already exists in a target (never clobbers).
set -euo pipefail

REPO_SKILLS="$(cd "$(dirname "$0")/skills" && pwd)"
[ -d "$REPO_SKILLS" ] || { echo "skills/ folder not found next to this script." >&2; exit 1; }

for T in "$HOME/.claude/skills" "$HOME/.agents/skills"; do
  mkdir -p "$T"
  echo
  echo "Target: $T"
  for d in "$REPO_SKILLS"/*/; do
    name="$(basename "$d")"
    link="$T/$name"
    if [ -e "$link" ] || [ -L "$link" ]; then
      echo "  skip (exists): $name"
    else
      ln -s "${d%/}" "$link"
      echo "  linked: $name"
    fi
  done
done

echo
echo "Done. Restart Claude Code / Codex to load the skills. Update later with: git pull"
