# Generic ECS Fargate Microservice Module

Deploys a containerized microservice on ECS Fargate with optional ALB, service discovery, and custom IAM policies.

## Features

- ✅ ECR repository with lifecycle policies
- ✅ ECS Fargate service with configurable CPU/memory
- ✅ Optional Application Load Balancer (create new or use existing)
- ✅ Flexible health checks (container and target group)
- ✅ Custom IAM policies for application permissions
- ✅ Environment variables and secrets support
- ✅ Service discovery integration
- ✅ CloudWatch logging

## Usage Examples

### Basic Microservice with New ALB

```hcl
module "auth_service" {
  source = "git::https://github.com/h3ow3d/h3ow3d-infra.git//modules/ecs-service?ref=v1.0.0"

  project_name  = "h3ow3d"
  environment   = "production"
  service_name  = "auth"
  aws_region    = "eu-west-2"
  
  ecs_cluster_id     = module.ecs_cluster.cluster_id
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  public_subnet_ids  = module.networking.public_subnet_ids
  security_group_ids = [module.networking.ecs_tasks_security_group_id]
  alb_security_group_id = module.networking.alb_security_group_id
  
  log_group_name = module.ecs_cluster.log_group_name
  
  container_port = 3001
  desired_count  = 2
  cpu            = 256
  memory         = 512
  
  environment_variables = {
    NODE_ENV              = "production"
    COGNITO_USER_POOL_ID  = "..."
    COGNITO_CLIENT_ID     = "..."
  }
  
  health_check_command = ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:3001/health || exit 1"]
  health_check_path    = "/health"
  
  tags = local.common_tags
}
```

### Worker Service (No Load Balancer)

```hcl
module "worker_service" {
  source = "git::https://github.com/h3ow3d/h3ow3d-infra.git//modules/ecs-service?ref=v1.0.0"

  service_name       = "worker"
  enable_load_balancer = false
  
  # ... other config
}
```

### Multiple Services Behind Shared ALB

```hcl
# First service creates the ALB
module "api_service" {
  source = "..."
  service_name = "api"
  create_alb   = true
  # ...
}

# Second service uses existing ALB
module "admin_service" {
  source = "..."
  service_name  = "admin"
  create_alb    = false
  enable_load_balancer = true
  existing_listener_arn = module.api_service.alb_listener_arn
  listener_rule_priority = 200
  listener_rule_path_patterns = [["/admin/*"]]
  # ...
}
```

### With Custom IAM Permissions

```hcl
module "data_service" {
  source = "..."
  service_name = "data"
  
  task_role_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject"
      ]
      Resource = "arn:aws:s3:::my-bucket/*"
    }]
  })
  # ...
}
```

## Inputs

### Required
- `project_name`, `environment`, `service_name`, `aws_region`
- `ecs_cluster_id`, `vpc_id`, `private_subnet_ids`, `security_group_ids`
- `log_group_name`

### Common Optional
- `desired_count` (default: 2)
- `cpu` (default: 256)
- `memory` (default: 512)
- `container_port` (default: 3000)
- `environment_variables` (default: {})
- `enable_load_balancer` (default: true)
- `create_alb` (default: true)

See `variables.tf` for complete list.

## Outputs

- `service_name`, `ecr_repository_url`, `alb_dns_name`, `target_group_arn`, `task_role_arn`
