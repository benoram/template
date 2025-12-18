#!/usr/bin/env bash

# configure-repo.sh
# Script to configure GitHub repository settings and rulesets
# Usage: ./configure-repo.sh <owner> <repository>

set -euo pipefail

# Check if required parameters are provided
if [ $# -ne 2 ]; then
    echo "Error: Missing required parameters"
    echo "Usage: $0 <owner> <repository>"
    echo "Example: $0 myorg myrepo"
    exit 1
fi

OWNER="$1"
REPO="$2"
REPO_FULL="${OWNER}/${REPO}"

# Ensure GitHub CLI is installed
if ! command -v gh >/dev/null 2>&1; then
    echo "Error: GitHub CLI (gh) is not installed or not found in PATH."
    echo "Please install GitHub CLI from https://cli.github.com/ and try again."
    exit 1
fi

# Ensure the user is authenticated with GitHub CLI
if ! gh auth status >/dev/null 2>&1; then
    echo "Error: GitHub CLI (gh) is not authenticated."
    echo "Please run 'gh auth login' to authenticate, then re-run this script."
    exit 1
fi

echo "Configuring repository: ${REPO_FULL}"
echo "========================================"

# Step 1: Configure repository settings using gh repo edit
echo ""
echo "Step 1: Configuring repository settings..."

if ! gh repo edit "${REPO_FULL}" \
    --enable-merge-commit=false \
    --enable-rebase-merge=false \
    --delete-branch-on-merge=true \
    --allow-update-branch=true; then
    echo "✗ Failed to configure repository settings for ${REPO_FULL}"
    echo "  This may happen if:"
    echo "  - The repository doesn't exist or the name is incorrect"
    echo "  - You don't have sufficient permissions to edit this repository"
    echo "  - Your GitHub CLI version doesn't support one of the specified flags"
    exit 1
fi

echo "✓ Repository settings configured successfully"

# Step 2: Create ruleset named "default"
echo ""
echo "Step 2: Creating ruleset 'default'..."

# Get the default branch name
if ! DEFAULT_BRANCH=$(gh api "repos/${REPO_FULL}" --jq '.default_branch'); then
    echo "Error: Failed to fetch default branch for repository '${REPO_FULL}'." >&2
    echo "       Ensure the repository exists and that you have the necessary permissions." >&2
    exit 1
fi

if [ -z "${DEFAULT_BRANCH}" ]; then
    echo "Error: Default branch name for repository '${REPO_FULL}' is empty or could not be determined." >&2
    exit 1
fi
echo "  Default branch: ${DEFAULT_BRANCH}"

# Create the ruleset JSON payload
# Note: Copilot code review auto-request should be added via GitHub UI
# Settings → Rules → Rulesets → "Automatically request Copilot code review"
# as the API structure for this feature is not fully documented
RULESET_PAYLOAD=$(cat <<EOF
{
  "name": "default",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["refs/heads/${DEFAULT_BRANCH}"],
      "exclude": []
    }
  },
  "rules": [
    {
      "type": "pull_request",
      "parameters": {
        "dismiss_stale_reviews_on_push": true,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_approving_review_count": 0,
        "required_review_thread_resolution": false
      }
    }
  ],
  "bypass_actors": []
}
EOF
)

# Create the ruleset
if ! gh api \
    --method POST \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "repos/${REPO_FULL}/rulesets" \
    --input - <<< "${RULESET_PAYLOAD}"; then
    echo "✗ Failed to create ruleset 'default'"
    echo "  This may happen if:"
    echo "  - A ruleset with this name already exists"
    echo "  - You don't have sufficient permissions"
    echo "  - The repository doesn't exist"
    exit 1
fi

echo "✓ Ruleset 'default' created successfully"

# Add Copilot code review to the ruleset
echo ""
echo "Step 3: Configuring Copilot code review..."
echo "  Note: Copilot code review must be enabled through GitHub UI"
echo "  1. Go to repository Settings → Rules → Rulesets"
echo "  2. Edit the 'default' ruleset"
echo "  3. Enable 'Automatically request Copilot code review'"
echo "  4. Optionally enable review on each push or for draft PRs"

echo ""
echo "========================================"
echo "Repository configuration completed!"
echo ""
echo "Summary:"
echo "  - Merge commits: disabled"
echo "  - Rebase merging: disabled"
echo "  - Squash merging: enabled (default)"
echo "  - Delete head branch on merge: enabled"
echo "  - Allow updating PR branches: enabled"
echo "  - Ruleset 'default': created and active"
echo "    - Target: ${DEFAULT_BRANCH} branch"
echo "    - Requires: pull request before merging"
echo "    - Dismisses: stale reviews on new commits"
echo ""
echo "Next steps:"
echo "  - Enable Copilot code review in the ruleset via GitHub UI"
echo "  - Review and test the configuration"

# Step 4: Configure GitHub Codespaces secrets for dotfiles
echo ""
echo "Step 4: Configuring GitHub Codespaces secrets for dotfiles..."
echo ""

# Function to prompt for input with a default value
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local value
    
    echo "  ${prompt}" >&2
    echo "  Default: ${default}" >&2
    read -r -p "  Enter value (or press Enter to accept default): " value
    
    # If no value entered, use the default
    if [ -z "${value}" ]; then
        echo "${default}"
    else
        echo "${value}"
    fi
}

# Prompt for DOTFILES_REPOSITORY
DOTFILES_REPO=$(prompt_with_default "DOTFILES_REPOSITORY - URL of your dotfiles repository" "https://github.com/benoram/dotfiles")
echo ""

# Prompt for DOTFILES_INSTALL_COMMAND
DOTFILES_CMD=$(prompt_with_default "DOTFILES_INSTALL_COMMAND - Command to run to install dotfiles" "bash bootstrap.sh")
echo ""

# Set the secrets using gh secret set
echo "  Setting DOTFILES_REPOSITORY secret..."
if ! printf "%s" "${DOTFILES_REPO}" | gh secret set DOTFILES_REPOSITORY --user --app codespaces --body -; then
    echo "✗ Failed to set DOTFILES_REPOSITORY secret"
    echo "  This may happen if:"
    echo "  - You don't have sufficient permissions"
    echo "  - GitHub CLI is not properly authenticated"
    exit 1
fi
echo "✓ DOTFILES_REPOSITORY secret set successfully"

echo "  Setting DOTFILES_INSTALL_COMMAND secret..."
if ! printf "%s" "${DOTFILES_CMD}" | gh secret set DOTFILES_INSTALL_COMMAND --user --app codespaces --body -; then
    echo "✗ Failed to set DOTFILES_INSTALL_COMMAND secret"
    echo "  This may happen if:"
    echo "  - You don't have sufficient permissions"
    echo "  - GitHub CLI is not properly authenticated"
    exit 1
fi
echo "✓ DOTFILES_INSTALL_COMMAND secret set successfully"

echo ""
echo "========================================"
echo "GitHub Codespaces dotfiles configuration completed successfully!"
echo ""
echo "Configured secrets:"
echo "  - DOTFILES_REPOSITORY: ${DOTFILES_REPO}"
echo "  - DOTFILES_INSTALL_COMMAND: ${DOTFILES_CMD}"
echo ""
echo "These secrets will be available in all your GitHub Codespaces."

