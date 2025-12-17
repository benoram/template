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

echo "Configuring repository: ${REPO_FULL}"
echo "========================================"

# Step 1: Configure repository settings using gh repo edit
echo ""
echo "Step 1: Configuring repository settings..."

gh repo edit "${REPO_FULL}" \
    --enable-merge-commit=false \
    --enable-rebase-merge=false \
    --delete-branch-on-merge=true \
    --allow-update-branch=true

echo "✓ Repository settings configured successfully"

# Step 2: Create ruleset named "default"
echo ""
echo "Step 2: Creating ruleset 'default'..."

# Get the default branch name
DEFAULT_BRANCH=$(gh api "repos/${REPO_FULL}" --jq '.default_branch')
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

