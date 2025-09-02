#!/bin/bash
set -euo pipefail

# Ensure main is clean and up to date
echo ">>> Checking out main and pulling latest..."
git checkout main
git pull origin main

# Delete old demo/gitleaks branch locally and remotely if it exists
if git show-ref --verify --quiet refs/heads/demo/gitleaks; then
  echo ">>> Deleting local branch demo/gitleaks"
  git branch -D demo/gitleaks
fi

echo ">>> Deleting remote branch demo/gitleaks (ignore errors if not exists)..."
git push origin --delete demo/gitleaks || true

# Create fresh branch from main
echo ">>> Creating new branch demo/gitleaks"
git checkout -b demo/gitleaks

# Add secrets.txt with multiple fake secrets
echo ">>> Writing secrets.txt with fake secrets"
cat > secrets.txt <<'EOF'
# Fake AWS keys
AWS_ACCESS_KEY_ID=AKIA1234567890EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

# Fake GitHub token
GH_TOKEN=ghp_example1234567890abcdef1234567890abcdef
EOF

# Commit and push
echo ">>> Committing and pushing secrets.txt"
git add secrets.txt
git commit -m "demo(gitleaks): add fake AWS + GitHub secrets"
git push -u origin demo/gitleaks

# Back to main branch
git checkout main

echo "✅ Done! A new demo/gitleaks branch has been pushed."
echo "👉 Open PR at: https://github.com/<YOUR-USER>/secure-ci-cd/compare/main...demo/gitleaks"

