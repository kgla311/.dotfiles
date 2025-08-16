#!/usr/bin/env bash
set -e

cd ~/.dotfiles

# Copy changes from ~/.config into repo
rsync -a --delete ~/.config/ .config/

git add -A
if ! git diff --cached --quiet; then
    git commit -m "update: $(date '+%Y-%m-%d %H:%M:%S')"
    git push --set-upstream origin main
else
    echo "No changes to commit."
fi
