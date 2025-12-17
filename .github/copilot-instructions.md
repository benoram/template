# GitHub Copilot Instructions

This document provides instructions and context for GitHub Copilot when working on this repository and related projects in the ORAM ecosystem.

## Related Repositories

### New Repositories
- `template-codespaces-copilot-actions`
- `oram-platform`
- `oram-gitops`
- `oram-homelab`

### oram-core-platform Setup
1. Start with Orb Stack Kubernetes
2. Install Flux

### oram-gitops Components
1. 1Password Operator
2. NFS CSI driver
3. Tailscale Operator
4. Linkerd service mesh
5. Kube-prometheus-stack monitoring
6. Loki log aggregation
7. Velero backup system

### oram-homelab Components
1. Homepage
2. N8N

## Development Workflow

All development is done by GitHub Copilot either through assignment of GitHub issues or through use within GitHub Codespaces.

### Standard Development Process
1. Create a GitHub issue
2. Create a branch using the branch naming conventions
3. Write code
4. Test locally
5. Commit tested code
6. Create a pull request (update the GitHub issue appropriately)
7. Review code
8. Merge to default branch

### Development Platform
Development is done on:
- Mac (Apple Silicon)
- Ubuntu-based Codespaces

### Deployment Platforms
Deployments are supported on:
- Mac (Apple Silicon)
- Ubuntu
- Docker
- Kubernetes

**Supported architectures:** x64 and ARM64

## Branch Naming Conventions

Follow these conventions for all branch names:

1. **Lowercase and Hyphen-separated**: Use lowercase for branch names and hyphens to separate words
   - Example: `feature/new-login`, `bugfix/header-styling`

2. **Alphanumeric Characters**: Use only lowercase alphanumeric characters (a-z, 0-9) and hyphens
   - Avoid punctuation, spaces, underscores, uppercase letters, or any other characters

3. **Descriptive**: Names should be descriptive and concise, reflecting the work done on the branch

4. **Feature Branches**: For developing new features
   - Prefix: `feature/`
   - Example: `feature/login-system`

5. **Bugfix Branches**: For fixing bugs in the code
   - Prefix: `bugfix/`
   - Example: `bugfix/header-styling`

6. **Documentation Branches**: For writing, updating, or fixing documentation (e.g., README.md)
   - Prefix: `docs/`
   - Example: `docs/api-endpoints`

## Secrets Management

**CRITICAL**: Secrets are never allowed in the repository.

Secrets must be stored in:
- GitHub Secrets (for GitHub Actions or GitHub Codespaces)
- 1Password

Never commit secrets, API keys, passwords, or sensitive data to the repository.

## Project Structure

The repository follows this standard structure:

```
.
├── scripts/     # Development, deployment and testing scripts
├── docs/        # Project documentation (kept in sync at all times)
├── infra/       # Infrastructure-as-code (Terraform, etc.)
├── src/         # Source code for projects/apps
└── README.md    # Clean & concise table of contents
```

### Directory Purposes

- **scripts/**: Contains all development, deployment, and testing scripts
- **docs/**: All project documentation that must be kept in sync with code
- **infra/**: Source code for Terraform and other infrastructure-as-code tools
- **src/**: Source code for projects and applications

## Project and Code Guidelines

### Security
- Always follow good security practices
- Never commit secrets or sensitive data
- Validate user inputs
- Follow principle of least privilege

### Automation
- Use scripts to perform actions when available
- Automate repetitive tasks
- Prefer existing tools over manual processes

### Documentation
- Always keep documentation up to date with the code
- Update docs in the same PR as code changes
- Keep README.md clean and concise as a table of contents

## Documentation Guidelines

### README.md
The project README.md should be:
- Clean and concise
- Act as a table of contents for documentation stored in the `docs/` directory
- Provide quick overview and links to detailed documentation

### Detailed Documentation
- Store detailed documentation in the `docs/` directory
- Keep documentation synchronized with code changes
- Include examples and usage instructions where appropriate

## Tech Stack

### Development
- **Primary Tool**: GitHub Copilot
- **Environments**: GitHub Codespaces, Mac (Apple Silicon), Ubuntu

### Infrastructure
- Kubernetes (Orb Stack)
- Flux (GitOps)
- Terraform (Infrastructure-as-Code)

### Operators and Tools
- 1Password Operator (secrets management)
- Tailscale Operator (networking)
- Linkerd (service mesh)

### Monitoring and Observability
- Kube-prometheus-stack (metrics)
- Loki (log aggregation)

### Backup and Storage
- Velero (backup system)
- NFS CSI driver (storage)

### Applications
- Homepage (dashboard)
- N8N (workflow automation)

## Best Practices

1. **Small, Focused Commits**: Keep commits small and focused on a single concern
2. **Test Before Commit**: Always test code locally before committing
3. **PR Descriptions**: Write clear PR descriptions and link to related issues
4. **Code Review**: All code must be reviewed before merging
5. **Keep Main Stable**: Never merge broken code to the default branch
6. **Update Documentation**: Documentation changes should accompany code changes
7. **Follow Conventions**: Adhere to branch naming and project structure conventions
