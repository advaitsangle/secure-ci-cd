# secure-ci-cd

Python project showcasing a DevSecOps pipeline with GitHub Actions. Integrates Semgrep (SAST), Bandit (Python SAST), Gitleaks (secrets), pip-audit (dependency CVEs), and Trivy (filesystem + container image) to scan every push for insecure code, secrets, and vulnerable dependencies.

Each scanner is configured to emit only high-severity findings and uploads results to GitHub Code Scanning (SARIF). A shared gate ([.github/scripts/sarif_gate.py](.github/scripts/sarif_gate.py)) fails the job when a report contains any finding, so branch protection can require these checks and block merges on high-severity issues.
