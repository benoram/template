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
echo "Repository configuration completed successfully!"
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

