# Global Git Compliance & Quality Gates

This repository centralizes and maintains our enterprise-wide code quality linters, security scanners, and commit format definitions.

## Instant Local Installation

To apply these standard formatting and policy configurations to **every repository on your machine** (including existing directories and newly cloned footprints), execute this single command in your terminal:

```bash
curl -sSf https://raw.githubusercontent.com/<your-org>/git-compliance-shared/main/install-compliance.sh | bash
```

## Supported Commit Layout

Every commit message is dynamically validated against our ticketing system using `commitlint`. Commits **must** match one of the following variations (omitting the traditional trailing type colon):

* `SCTASK827164: feat() added cloud infrastructure components`
* `INC002911: fix(api) resolved memory exhaustion errors`
* `DCDT881: chore(infra) realigned deployment hooks`

## DevOps Engineering Features

This toolkit is specifically tuned for DevOps operations:
- **IaC Security**: Checkov and TFLint for Terraform and Kubernetes.
- **Container Auditing**: Hadolint for Dockerfile best practices.
- **Pipeline Linting**: Actionlint (GHA) and Tekton-lint for CI/CD workflows.
- **Secret Protection**: Gitleaks with custom corporate signatures.
- **Global Enforcement**: Single installation protects every repository on your machine.

## Repository Structure

```text
git-compliance-shared/
├── .github/
│   └── workflows/
│       ├── ci.yml               # Unified CI (Compliance & Renovate validation)
│       └── renovate.yml         # Automated Renovate Bot execution
├── .gitleaksignore              # Global baseline secret scanner ignore file
├── commitlint.config.js         # Your TICKET: type() no-colon regex engine
├── gitleaks.toml                # Your custom corporate secret signatures
├── install-compliance.sh        # Developer orchestration single-command script
├── master-pre-commit-config.yaml # Unified linters (Checkov, Shellcheck, etc.)
└── README.md                    # Onboarding execution instructions
```

## Security & Compliance

This repository is aligned with **OWASP SPVS v1.0**. All changes to the `main` branch require:
- Pull Request with at least 1 approval.
- Passing `validate-configs` status check.
- Signed commits.

## Dependency Management

We use automated tools to keep our dependencies and hooks up to date:
- **Dependabot**: Monitors GitHub Actions and NPM dependencies.
- **Renovate Bot**: Handles complex dependency updates and pre-commit hook versioning.
