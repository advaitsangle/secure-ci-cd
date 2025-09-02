#!/bin/bash
set -euo pipefail

# Make sure we're on main and up to date
git checkout main
git pull origin main

# ---------------------------
# Step 1: Delete old branches
# ---------------------------
OLD_BRANCHES=(
  test/pip-audit
  test/pip-audit-2
  test/semgrep
  test/gitleaks
)

for br in "${OLD_BRANCHES[@]}"; do
  if git show-ref --verify --quiet "refs/heads/$br"; then
    git branch -D "$br"
  fi
  git push origin --delete "$br" || true
done

# ---------------------------
# Step 2: Create demo branches
# ---------------------------

# A) Gitleaks branch
git checkout -b demo/gitleaks main
echo "GH_TOKEN=ghp_example1234567890abcdef" > secrets.txt
git add secrets.txt
git commit -m "demo(gitleaks): add dummy secret"
git push -u origin demo/gitleaks

# B) pip-audit branch
git checkout main
git checkout -b demo/pip-audit
echo "urllib3==1.25.8" >> requirements.txt
git add requirements.txt
git commit -m "demo(pip-audit): add vulnerable urllib3"
git push -u origin demo/pip-audit

# C) Semgrep branch
git checkout main
git checkout -b demo/semgrep

# Replace host line in src/app.py (127.0.0.1 → 0.0.0.0)
sed -i.bak 's/app.run(host="127.0.0.1", port=8080)/app.run(host="0.0.0.0", port=8080)/' src/app.py
rm -f src/app.py.bak

git add src/app.py
git commit -m "demo(semgrep): run flask on 0.0.0.0 (insecure)"
git push -u origin demo/semgrep

# Back to main
git checkout main

echo "✅ Demo branches created and pushed!"
echo "Open PRs at:"
echo "  https://github.com/<YOUR-USER>/secure-ci-cd/compare/main...demo/gitleaks"
echo "  https://github.com/<YOUR-USER>/secure-ci-cd/compare/main...demo/pip-audit"
echo "  https://github.com/<YOUR-USER>/secure-ci-cd/compare/main...demo/semgrep"

