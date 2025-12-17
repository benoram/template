# template
Repository template with a standard tool set

## Scripts

### create-repo.sh

Creates a new GitHub repository from the benoram/template repository and automatically configures it with standard settings.

**Location:** `/scripts/create-repo.sh`

**Usage:**
```bash
./scripts/create-repo.sh <owner> <name>
```

**Example:**
```bash
./scripts/create-repo.sh myorg myrepo
```

**What it does:**
- Creates a new private repository from the benoram/template template
- Automatically runs configure-repo.sh to apply standard settings
- Provides next steps for cloning and using the new repository

**Requirements:**
- [GitHub CLI](https://cli.github.com/) must be installed
- You must be authenticated with GitHub CLI (`gh auth login`)
- You must have permissions to create repositories for the specified owner
- The benoram/template repository must be accessible

**Note:** After running this script, you'll still need to enable Copilot code review manually through the GitHub UI. See the script output for instructions.

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

