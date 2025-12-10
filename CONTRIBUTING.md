# Contributing to h3ow3d-infra

Thank you for contributing to the h3ow3d infrastructure modules!

## Getting Started

### Prerequisites

- Terraform >= 1.14.1
- Pre-commit (`brew install pre-commit` or `pip install pre-commit`)
- TFLint (`brew install tflint`)
- terraform-docs (`brew install terraform-docs`)

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/h3ow3d/h3ow3d-infra.git
   cd h3ow3d-infra
   ```

2. Install pre-commit hooks:
   ```bash
   pre-commit install
   ```

3. Verify setup:
   ```bash
   pre-commit run --all-files
   ```

## Development Workflow

### Creating/Modifying Modules

1. Create a new branch:
   ```bash
   git checkout -b feat/your-feature-name
   ```

2. Make your changes to the module files

3. Run validation locally:
   ```bash
   # Format code
   terraform fmt -recursive modules/

   # Validate each module
   cd modules/your-module
   terraform init -backend=false
   terraform validate
   ```

4. Update module documentation:
   ```bash
   terraform-docs markdown table modules/your-module > modules/your-module/README.md
   ```

5. Commit your changes:
   ```bash
   git add .
   git commit -m "feat: add new feature to module"
   ```

   Pre-commit hooks will automatically:
   - Format Terraform files
   - Validate syntax
   - Generate documentation
   - Run security scans

### Module Structure

Each module should have:

```
modules/your-module/
├── main.tf          # Main resource definitions
├── variables.tf     # Input variables with descriptions
├── outputs.tf       # Output values with descriptions
└── README.md        # Module documentation (auto-generated)
```

### Commit Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation only
- `refactor:` Code refactoring
- `test:` Adding tests
- `chore:` Maintenance tasks

Examples:
```bash
git commit -m "feat(ecs-service): add support for service discovery"
git commit -m "fix(networking): correct security group rules"
git commit -m "docs(cognito): update usage examples"
```

### Pull Request Process

1. Push your branch to GitHub:
   ```bash
   git push origin feat/your-feature-name
   ```

2. Create a Pull Request with:
   - Clear description of changes
   - Module(s) affected
   - Breaking changes (if any)
   - Testing performed

3. Automated checks will run:
   - Terraform validation
   - TFLint
   - Security scans (tfsec, Checkov)
   - Documentation generation

4. Address any review comments

5. Once approved, squash and merge

## Module Guidelines

### Variables

- Always provide clear descriptions
- Specify types explicitly
- Provide sensible defaults where appropriate
- Mark sensitive variables as `sensitive = true`

Example:
```hcl
variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
```

### Outputs

- Output all resource IDs/ARNs that other modules might need
- Provide clear descriptions
- Mark sensitive outputs appropriately

Example:
```hcl
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}
```

### Naming

- Use descriptive resource names
- Follow pattern: `${var.project_name}-${var.environment}-${resource_type}`
- Use locals for repeated name patterns

### Security

- Never hardcode credentials or secrets
- Use IAM roles with least privilege
- Enable encryption by default
- Follow AWS security best practices

## Breaking Changes

If your change breaks backward compatibility:

1. Mark PR title with `BREAKING CHANGE:`
2. Document the breaking change in PR description
3. Provide migration instructions
4. Update h3ow3d-deployment repository
5. Bump major version on release

## Versioning

We use [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes

To trigger a release, include `[release]` in your commit message to main.

## Testing

Before submitting:

1. Test module in h3ow3d-deployment:
   ```hcl
   module "test" {
     source = "../h3ow3d-infra/modules/your-module"
     # ... configuration
   }
   ```

2. Run `terraform plan` to verify

3. Check for unintended changes

## Questions?

Open an issue or reach out to the maintainers.

## Code of Conduct

Be respectful, collaborative, and constructive.
