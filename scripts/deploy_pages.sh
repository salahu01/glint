#!/usr/bin/env bash
# Builds the static export and publishes it to the `gh-pages` branch (Pages: "Deploy from a branch").
# Works without GitHub Actions. Usage: npm run deploy
set -euo pipefail
cd "$(dirname "$0")/.."
URL="${PAGES_SITE_URL:-https://salahu01.github.io/glint}"
BASE="${PAGES_BASE_PATH:-/glint}"
echo "→ building static export for $URL"
rm -rf out .next
NEXT_PUBLIC_SITE_URL="$URL" NEXT_PUBLIC_BASE_PATH="$BASE" npm run build
touch out/.nojekyll
echo "→ publishing out/ to gh-pages"
REMOTE="$(git remote get-url origin)"
( cd out && git init -q -b gh-pages && git add -A && git commit -q -m "deploy: static export" && git push -f -q "$REMOTE" gh-pages )
rm -rf out/.git
echo "✔ pushed. Live at $URL/ in a minute or two"
