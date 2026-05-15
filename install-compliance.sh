#!/usr/bin/env bash

# FILE_NAME: install-compliance.sh
# DESCRIPTION: Global Git Compliance Installer (Local Enforcement Only).
# VERSION: 1.2.0
# EXIT_CODES/SIGNALS: 0 on success, 1 on failure.
# AUTHORS: Vyom Platform Team

# [T-01] Initializing defensive bash environment.
set -euo pipefail

echo "================================================================="
echo "   Global Git Compliance Installer (Local Enforcement Only)"
echo "================================================================="

GLOBAL_HOOKS_DIR="$HOME/.git-global-compliance"
INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"
OS_TYPE="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH_TYPE="$(uname -m)"

if [ "$ARCH_TYPE" = "x86_64" ]; then ARCH_TYPE="amd64"; fi
if [ "$ARCH_TYPE" = "aarch64" ] || [ "$ARCH_TYPE" = "arm64" ]; then ARCH_TYPE="arm64"; fi

# [T-02] System Verification Checklist
# _log("[T-02] Checking for required dependencies.")
if ! command -v git &> /dev/null; then echo "Error: git is required."; exit 1; fi
if ! command -v python3 &> /dev/null; then echo "Error: python3 is required."; exit 1; fi
if ! command -v node &> /dev/null; then echo "Error: Node.js/NPM is required."; exit 1; fi

# Optional but recommended DevOps tools
for tool in tflint hadolint kube-linter; do
    if ! command -v "$tool" &> /dev/null; then
        echo "Warning: $tool is missing. Some specialized DevOps hooks may run slower via Docker/auto-install."
    fi
done

# [T-03] Setup Framework Managers
echo "Installing/Updating official pre-commit and checkov core engines..."
python3 -m pip install --upgrade --user pre-commit checkov

# [T-04] Secure Gitleaks Engine Installation
if ! command -v gitleaks &> /dev/null; then
    echo "Gitleaks binary missing. Pulling official execution engine..."
    if [ "$OS_TYPE" = "darwin" ] && command -v brew &> /dev/null; then
        brew install gitleaks
    else
        GITLEAKS_VERSION="8.18.2"
        URL="https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_${OS_TYPE}_${ARCH_TYPE}.tar.gz"
        curl -sSfL "$URL" -o "/tmp/gitleaks.tar.gz"
        tar -xzf "/tmp/gitleaks.tar.gz" -C "$INSTALL_DIR" gitleaks
        chmod +x "$INSTALL_DIR/gitleaks"
    fi
fi

# [T-05] Sync All Configuration Rules From Central Repo
mkdir -p "$GLOBAL_HOOKS_DIR/hooks"
echo "Syncing master configuration files from central repository..."
CENTRAL_REPO_URL="https://raw.githubusercontent.com/your-org/git-compliance-shared/main"

curl -sSf "$CENTRAL_REPO_URL/master-pre-commit-config.yaml" -o "$GLOBAL_HOOKS_DIR/pre-commit-config.yaml"
curl -sSf "$CENTRAL_REPO_URL/commitlint.config.js" -o "$GLOBAL_HOOKS_DIR/commitlint.config.js"
curl -sSf "$CENTRAL_REPO_URL/gitleaks.toml" -o "$GLOBAL_HOOKS_DIR/gitleaks.toml"

# [T-06] Inject Pre-Commit Enforcement (Content Guard)
cat << 'EOF' > "$GLOBAL_HOOKS_DIR/hooks/pre-commit"
#!/usr/bin/env bash
GLOBAL_CONFIG="$HOME/.git-global-compliance/pre-commit-config.yaml"
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"

if [ -f "$GLOBAL_CONFIG" ]; then
    exec pre-commit run --config "$GLOBAL_CONFIG" --hook-stage commit --staged
fi
EOF
chmod +x "$GLOBAL_HOOKS_DIR/hooks/pre-commit"

# [T-07] Inject Commit-Msg Enforcement (No trailing colon pattern execution)
cat << 'EOF' > "$GLOBAL_HOOKS_DIR/hooks/commit-msg"
#!/usr/bin/env bash
GLOBAL_CONFIG="$HOME/.git-global-compliance/pre-commit-config.yaml"
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"

if [ -f "$GLOBAL_CONFIG" ]; then
    if [ ! -f "commitlint.config.js" ] && [ ! -f ".commitlintrc.js" ]; then
        cp "$HOME/.git-global-compliance/commitlint.config.js" ./commitlint.config.js 2>/dev/null || true
    fi
    exec pre-commit run --config "$GLOBAL_CONFIG" --hook-stage commit-msg --commit-msg-filename "$1"
fi
EOF
chmod +x "$GLOBAL_HOOKS_DIR/hooks/commit-msg"

# [T-08] Bind Git Globally
echo "Binding global Git hook pathways..."
git config --global core.hooksPath "$GLOBAL_HOOKS_DIR/hooks"

echo "================================================================="
echo "SUCCESS: Global Git Quality Gates & Rulesets Active!"
echo "   Formats allowed: TICKET: type() message OR TICKET: type(scope) message"
echo "================================================================="
