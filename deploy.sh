#!/bin/bash
# Fast deploy to GitHub Pages via direct gh-pages branch push
# Deploy speed: ~10-30 seconds (vs 2-5 min with GitHub Actions)
# China access: Yes (github.io is accessible in mainland China)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BRANCH="gh-pages"
REMOTE="origin"

echo "🚀 Deploying to GitHub Pages (direct push)..."

# Get the repo remote URL
REPO_URL=$(git -C "$SCRIPT_DIR" remote get-url "$REMOTE" 2>/dev/null)
if [ -z "$REPO_URL" ]; then
  echo "❌ No git remote '$REMOTE' found. Please add one first."
  exit 1
fi

# Create a temporary directory for the deploy
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

# Copy site files to temp dir
cp "$SCRIPT_DIR/index.html" "$TMPDIR/"
cp "$SCRIPT_DIR/musein-logo.png" "$TMPDIR/" 2>/dev/null || true
cp "$SCRIPT_DIR/musein-mark.png" "$TMPDIR/" 2>/dev/null || true

# Initialize a fresh git repo in temp dir
cd "$TMPDIR"
git init -q
git checkout --orphan "$BRANCH"
git add -A
git commit -q -m "Deploy $(date '+%Y-%m-%d %H:%M:%S')"

# Force push to gh-pages branch
echo "📦 Pushing to $BRANCH branch..."
git push -f "$REPO_URL" "$BRANCH" 2>&1

# Extract owner and repo name from remote URL
OWNER=$(echo "$REPO_URL" | sed 's/.*github.com[:\/]*//' | cut -d'/' -f1)
REPO_NAME=$(echo "$REPO_URL" | sed 's/.*github.com[:\/]*//' | sed 's/\.git$//' | cut -d'/' -f2)

echo "✅ Deployed! Site will be live at:"
echo "   https://${OWNER}.github.io/${REPO_NAME}/"
echo ""
echo "⏱  Note: GitHub Pages may take 1-2 minutes to update after push."
