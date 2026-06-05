#!/bin/bash
set -euo pipefail

# Make sure we're on main and up to date
git checkout main
git pull origin main

# ---------------------------
# Step 1: Delete old branches
# ---------------------------
# These are the branches this script (re)creates — delete any leftovers so
# `git checkout -b` below starts from a clean state on every run. The legacy
# test/* names are kept so older demo runs get cleaned up too.
OLD_BRANCHES=(
  demo/gitleaks
  demo/pip-audit
  demo/semgrep
  demo/bandit
  demo/trivy
  demo/artifact-test
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

# D) Bandit branch
git checkout main
git checkout -b demo/bandit
cat > src/insecure.py <<'EOF'
import subprocess


def run(user_cmd):
    # Insecure: shell=True with untrusted input -> Bandit B602 (HIGH severity)
    return subprocess.call(user_cmd, shell=True)
EOF
git add src/insecure.py
git commit -m "demo(bandit): subprocess with shell=True (insecure)"
git push -u origin demo/bandit

# E) Trivy branch (outdated base image with known OS-level CVEs)
git checkout main
git checkout -b demo/trivy
sed -i.bak 's|^FROM python:3.11-slim$|FROM python:3.11.0-slim|' Dockerfile
rm -f Dockerfile.bak
git add Dockerfile
git commit -m "demo(trivy): pin outdated base image with OS CVEs"
git push -u origin demo/trivy

# Back to main
git checkout main

# Build clickable compare URLs from the actual origin remote
REMOTE_URL=$(git remote get-url origin | sed -E 's#git@github.com:#https://github.com/#; s#\.git$##')

echo "✅ Demo branches created and pushed!"
echo "Each branch trips exactly one scanner. Open PRs at:"
echo "  Gitleaks  : $REMOTE_URL/compare/main...demo/gitleaks"
echo "  pip-audit : $REMOTE_URL/compare/main...demo/pip-audit"
echo "  Semgrep   : $REMOTE_URL/compare/main...demo/semgrep"
echo "  Bandit    : $REMOTE_URL/compare/main...demo/bandit"
echo "  Trivy     : $REMOTE_URL/compare/main...demo/trivy"

