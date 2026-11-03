#!/usr/bin/env bash
# Lives at the repo root on purpose: mirrors the owner's apple-design-skills repo layout.
# Install the sigma-designs skill family for BOTH Claude Code (~/.claude/skills)
# and Codex (~/.agents/skills) on macOS / Linux, via symlinks (so `git pull` propagates).
# Re-runnable. Upgrades an old copied `sigma-designs` folder (moved to a backup OUTSIDE the
# skills dir, since backups inside a skills dir still load as skills); never touches other files.
set -euo pipefail

SCRIPT_DIR="$(dirname "$0")"
[ -d "$SCRIPT_DIR/skills" ] || { echo "skills/ folder not found next to this script." >&2; exit 1; }
REPO_SKILLS="$(cd "$SCRIPT_DIR/skills" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

# True for the pre-family skill: name: sigma-designs frontmatter + orb-recipe.md beside it.
is_old_family_copy() {
  [ -f "$1/SKILL.md" ] && [ -f "$1/orb-recipe.md" ] && grep -qE '^name:[[:space:]]*sigma-designs[[:space:]]*$' "$1/SKILL.md"
}

for T in "$HOME/.claude/skills" "$HOME/.agents/skills"; do
  BACKUP_ROOT="$(dirname "$T")/skills-backup"
  mkdir -p "$T"
  echo
  echo "Target: $T"
  for d in "$REPO_SKILLS"/*/; do
    name="$(basename "$d")"
    src="${d%/}"
    link="$T/$name"
    if [ -L "$link" ]; then
      old="$(readlink "$link")"
      if [ "$old" = "$src" ]; then
        echo "  ok (linked): $name"
      else
        rm "$link"
        ln -s "$src" "$link"
        echo "  relinked (was -> $old): $name"
      fi
    elif [ -d "$link" ] && [ "$name" = "sigma-designs" ] && is_old_family_copy "$link"; then
      mkdir -p "$BACKUP_ROOT"
      dest="$BACKUP_ROOT/$name.pre-family-$STAMP"
      mv "$link" "$dest"
      ln -s "$src" "$link"
      echo "  upgraded: moved old copy $link -> $dest"
      echo "  linked: $name"
    elif [ -e "$link" ]; then
      echo "  skip (not ours): $link" >&2
    else
      ln -s "$src" "$link"
      echo "  linked: $name"
    fi
  done
done

echo
echo "Done. Restart Claude Code / Codex to load the skills. Update later with: git pull"
