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
    },
    {
      "type": "code_scanning",
      "parameters": {
        "code_scanning_tools": [
          {
            "tool": "copilot",
            "security_alerts_threshold": "none",
            "alerts_threshold": "none"
          }
        ]
      }
    }
  ],
  "bypass_actors": []
}
EOF
)

# Create the ruleset
gh api \
    --method POST \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "repos/${REPO_FULL}/rulesets" \
    --input - <<< "${RULESET_PAYLOAD}"

echo "✓ Ruleset 'default' created successfully"

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
echo "    - Copilot code review: automatically requested"
