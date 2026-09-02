#!/usr/bin/env bash
set -uo pipefail

GIT=(git --git-dir="$HOME/.cfg" --work-tree="$HOME")

DOCS=(README.md)
while IFS= read -r f; do
  DOCS+=("$f")
done < <("${GIT[@]}" ls-files 'wiki/*' 2>/dev/null)

show() {
  "${GIT[@]}" update-index --no-skip-worktree "${DOCS[@]}"
  "${GIT[@]}" checkout HEAD -- "${DOCS[@]}"
  echo "Docs materialized in \$HOME. Edit, commit, then run: docs-edit.sh hide"
}

hide() {
  "${GIT[@]}" update-index --skip-worktree "${DOCS[@]}"
  rm -rf "$HOME/README.md" "$HOME/wiki"
  echo "Docs removed from \$HOME (still tracked in the repo)."
}

case "${1:-}" in
  show) show ;;
  hide) hide ;;
  *) echo "usage: $0 {show|hide}" >&2; exit 1 ;;
esac
