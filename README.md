# h3ow3d-infra

Reusable Terraform modules for h3ow3d platform infrastructure.

## Purpose

This repository contains **reusable, composable Terraform modules** that can be used across multiple environments and deployments. It does NOT manage state or deployed infrastructure directly.

## Module Structure

```
h3ow3d-infra/
└── modules/
    ├── networking/          # VPC, subnets, security groups
    ├── ecs-cluster/         # ECS cluster configuration
    ├── auth-service/        # Auth service (Fargate, ECR, ALB)
    ├── frontend/            # S3, CloudFront, artifacts bucket
    ├── cognito/             # Cognito User Pool & OAuth
    └── monitoring/          # CloudWatch RUM
```

## Usage

These modules are consumed by the [h3ow3d-deployment](../h3ow3d-deployment) repository:

```hcl
module "networking" {
  source = "../h3ow3d-infra/modules/networking"

  project_name       = "h3ow3d"
  environment        = "production"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["eu-west-2a", "eu-west-2b"]
}
```

## Module Versioning

For production use, reference modules by git tag:

```hcl
module "networking" {
  source = "git::https://github.com/h3ow3d/h3ow3d-infra.git//modules/networking?ref=v1.0.0"
  # ...
}
```

## Available Modules

### networking
VPC with public/private subnets, NAT gateways, security groups for ALB and ECS tasks.

**Inputs:**
- `project_name` - Project identifier
- `environment` - Environment name
- `vpc_cidr` - VPC CIDR block
- `availability_zones` - List of AZs

**Outputs:**
- `vpc_id`
- `public_subnet_ids`
- `private_subnet_ids`
- `alb_security_group_id`
- `ecs_tasks_security_group_id`

### ecs-cluster
ECS cluster with CloudWatch logs and container insights.

**Inputs:**
- `project_name`
- `environment`

**Outputs:**
- `cluster_id`
- `cluster_name`
- `cluster_arn`

### auth-service
Complete auth service infrastructure: ECR, ECS service, task definition, ALB, target groups.

**Inputs:**
- `project_name`, `environment`
- `vpc_id`, `subnet_ids`
- `ecs_cluster_id`
- `cognito_user_pool_id`, `cognito_client_id`
- `desired_count`, `cpu`, `memory`

**Outputs:**
- `ecr_repository_url`
- `alb_dns_name`
- `service_name`

### frontend
S3 bucket for static site, CloudFront distribution, artifacts bucket.

**Inputs:**
- `project_name`, `environment`
- `domain_name` (optional)

**Outputs:**
- `s3_bucket_name`
- `cloudfront_domain_name`
- `cloudfront_distribution_id`
- `artifacts_bucket_name`

### cognito
Cognito User Pool with Google OAuth provider.

**Inputs:**
- `project_name`, `environment`
- `google_client_id`, `google_client_secret`
- `callback_urls`

**Outputs:**
- `user_pool_id`
- `client_id`
- `domain`
- `identity_pool_id`

### monitoring
CloudWatch RUM for real user monitoring.

**Inputs:**
- `project_name`, `environment`
- `cloudfront_domain`

**Outputs:**
- `app_monitor_id`
- `identity_pool_id`

## Development

### Testing Modules Locally

```bash
cd modules/networking
terraform init
terraform plan -var-file=../../examples/networking.tfvars
```

### Module Guidelines

1. **Single Responsibility** - Each module does one thing well
2. **No Hard-Coded Values** - Use variables
3. **Sensible Defaults** - Where possible
4. **Complete Documentation** - README per module
5. **Outputs** - Export all useful values
6. **Tags** - Accept and apply tags consistently

## Migration from Monolithic Structure

The existing `.tf` files in the root will be refactored into modules:

- `networking.tf` → `modules/networking/`
- `ecs-cluster.tf` + `ecs-auth-service.tf` → `modules/auth-service/`
- `main.tf` (S3/CloudFront) + `artifacts.tf` → `modules/frontend/`
- `cognito.tf` → `modules/cognito/`
- `cloudwatch-rum.tf` → `modules/monitoring/`

## Related Repositories

- [h3ow3d-deployment](../h3ow3d-deployment): Deployment orchestration (uses these modules)
- [h3ow3d-frontend](../h3ow3d-frontend): Frontend application
- [h3ow3d-auth](../h3ow3d-auth): Authentication service

## Contributing

1. Create feature branch
2. Make changes to modules
3. Test with example configurations
4. Update module README
5. Submit PR
6. Tag release after merge

## License

MIT
