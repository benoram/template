# template
Repository template with a standard tool set

## Development Environment

### Devcontainer

This repository includes a devcontainer configuration for GitHub Codespaces and VS Code Remote Containers.

**Location:** `/.devcontainer/devcontainer.json`

**Installed Software:**
- **Shell Environment:**
  - Bash (with Starship prompt)
  - Zsh with Oh My Zsh (with Starship prompt, set as default)
- **Version Control:**
  - Git (latest version from PPA)
- **Package Managers:**
  - Homebrew (for additional tooling)
- **Network Tools:**
  - whois - Domain information lookup
  - wget - File download utility
  - dig (dnsutils) - DNS lookup utility
  - telnet - Telnet client
- **Prompt:**
  - Starship - Cross-shell prompt configured for both bash and zsh

**Features:**
- Automatic package upgrades on container creation
- Starship prompt automatically initialized for both bash and zsh shells
- All network and development tools pre-installed and ready to use

## Scripts

### configure-repo.sh

Automates GitHub repository settings and ruleset configuration using the GitHub CLI.

**Location:** `/scripts/configure-repo.sh`

**Usage:**
```bash
./scripts/configure-repo.sh <owner> <repository>
```

**Example:**
```bash
./scripts/configure-repo.sh myorg myrepo
```

**What it does:**
- Disables merge commits and rebase merging (enforces squash-only workflow)
- Enables automatic deletion of head branches after merge
- Enables pull request branch update suggestions
- Creates a "default" ruleset that:
  - Targets the default branch
  - Requires pull requests before merging
  - Dismisses stale pull request approvals when new commits are pushed

**Requirements:**
- [GitHub CLI](https://cli.github.com/) must be installed
- You must be authenticated with GitHub CLI (`gh auth login`)
- You must have admin permissions on the target repository

**Note:** Automatic Copilot code review must be enabled manually through the GitHub UI after running the script. See the script output for instructions.

