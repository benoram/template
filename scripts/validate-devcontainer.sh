#!/usr/bin/env bash
#
# validate-devcontainer.sh
# Validates the devcontainer.json configuration
# Usage: ./validate-devcontainer.sh
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEVCONTAINER_JSON="$REPO_ROOT/.devcontainer/devcontainer.json"

echo "Validating devcontainer configuration..."

# Check if devcontainer.json exists
if [[ ! -f "$DEVCONTAINER_JSON" ]]; then
    echo "❌ Error: devcontainer.json not found at $DEVCONTAINER_JSON"
    exit 1
fi

# Validate JSON syntax
if ! python3 -m json.tool "$DEVCONTAINER_JSON" > /dev/null 2>&1; then
    echo "❌ Error: devcontainer.json is not valid JSON"
    exit 1
fi

echo "✅ devcontainer.json is valid JSON"

# Check for required dotfiles configuration
if ! grep -q '"dotfilesRepository"' "$DEVCONTAINER_JSON"; then
    echo "❌ Error: dotfilesRepository not found in devcontainer.json"
    exit 1
fi

echo "✅ dotfilesRepository is configured"

# Check for dotfilesInstallCommand
if ! grep -q '"dotfilesInstallCommand"' "$DEVCONTAINER_JSON"; then
    echo "❌ Error: dotfilesInstallCommand not found in devcontainer.json"
    exit 1
fi

echo "✅ dotfilesInstallCommand is configured"

# Verify dotfiles repository URL
if command -v jq >/dev/null 2>&1; then
    DOTFILES_REPO=$(jq -r '.dotfilesRepository // empty' "$DEVCONTAINER_JSON")
else
    DOTFILES_REPO=$(python3 -c "import json; print(json.load(open('$DEVCONTAINER_JSON'))['dotfilesRepository'])" 2>/dev/null || echo "")
fi

if [[ "$DOTFILES_REPO" != "https://github.com/benoram/dotfiles" ]]; then
    echo "❌ Error: dotfilesRepository URL is not correct. Expected: https://github.com/benoram/dotfiles, Got: $DOTFILES_REPO"
    exit 1
fi

echo "✅ dotfilesRepository URL is correct"

# Check if post-create.sh exists and is executable
POST_CREATE="$REPO_ROOT/.devcontainer/post-create.sh"
if [[ ! -f "$POST_CREATE" ]]; then
    echo "❌ Error: post-create.sh not found"
    exit 1
fi

if [[ ! -x "$POST_CREATE" ]]; then
    echo "❌ Error: post-create.sh is not executable"
    exit 1
fi

echo "✅ post-create.sh exists and is executable"

# Verify post-create.sh does not duplicate Starship configuration
if grep -q 'starship init' "$POST_CREATE"; then
    echo "❌ Error: post-create.sh contains Starship initialization, which conflicts with dotfiles"
    echo "   Starship should be configured via the dotfiles repository only"
    exit 1
fi

echo ""
echo "✅ All validations passed!"
echo ""
echo "Devcontainer configuration is correctly set up to:"
echo "  - Clone dotfiles from: $DOTFILES_REPO"
echo "  - Run bootstrap.sh to apply configurations"
echo "  - Execute post-create.sh for additional setup"
