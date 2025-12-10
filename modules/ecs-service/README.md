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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecr_lifecycle_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecs_service.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.ecs_task_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.task_custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ecs_task_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_rule.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_deletion_protection"></a> [alb\_deletion\_protection](#input\_alb\_deletion\_protection) | Enable deletion protection on ALB | `bool` | `false` | no |
| <a name="input_alb_internal"></a> [alb\_internal](#input\_alb\_internal) | Make ALB internal | `bool` | `false` | no |
| <a name="input_alb_listener_port"></a> [alb\_listener\_port](#input\_alb\_listener\_port) | ALB listener port | `number` | `80` | no |
| <a name="input_alb_listener_protocol"></a> [alb\_listener\_protocol](#input\_alb\_listener\_protocol) | ALB listener protocol | `string` | `"HTTP"` | no |
| <a name="input_alb_security_group_id"></a> [alb\_security\_group\_id](#input\_alb\_security\_group\_id) | Security group ID for ALB | `string` | `""` | no |
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | Assign public IP to ECS tasks | `bool` | `false` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | Port the container listens on | `number` | `3000` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | CPU units for the task (256 = 0.25 vCPU) | `number` | `256` | no |
| <a name="input_create_alb"></a> [create\_alb](#input\_create\_alb) | Create a new ALB (false = use existing ALB with listener rules) | `bool` | `true` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Desired number of tasks | `number` | `2` | no |
| <a name="input_ecr_image_retention_count"></a> [ecr\_image\_retention\_count](#input\_ecr\_image\_retention\_count) | Number of images to retain in ECR | `number` | `10` | no |
| <a name="input_ecs_cluster_id"></a> [ecs\_cluster\_id](#input\_ecs\_cluster\_id) | ECS cluster ID | `string` | n/a | yes |
| <a name="input_enable_image_scanning"></a> [enable\_image\_scanning](#input\_enable\_image\_scanning) | Enable ECR image scanning | `bool` | `true` | no |
| <a name="input_enable_load_balancer"></a> [enable\_load\_balancer](#input\_enable\_load\_balancer) | Enable Application Load Balancer | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | n/a | yes |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Environment variables for the container | `map(string)` | `{}` | no |
| <a name="input_existing_listener_arn"></a> [existing\_listener\_arn](#input\_existing\_listener\_arn) | ARN of existing ALB listener (when create\_alb=false) | `string` | `null` | no |
| <a name="input_health_check_command"></a> [health\_check\_command](#input\_health\_check\_command) | Container health check command | `list(string)` | `null` | no |
| <a name="input_health_check_interval"></a> [health\_check\_interval](#input\_health\_check\_interval) | Health check interval in seconds | `number` | `30` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Target group health check path | `string` | `"/health"` | no |
| <a name="input_health_check_retries"></a> [health\_check\_retries](#input\_health\_check\_retries) | Health check retries | `number` | `3` | no |
| <a name="input_health_check_start_period"></a> [health\_check\_start\_period](#input\_health\_check\_start\_period) | Health check start period in seconds | `number` | `60` | no |
| <a name="input_health_check_timeout"></a> [health\_check\_timeout](#input\_health\_check\_timeout) | Health check timeout in seconds | `number` | `5` | no |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | Docker image tag to deploy | `string` | `"latest"` | no |
| <a name="input_listener_rule_host_headers"></a> [listener\_rule\_host\_headers](#input\_listener\_rule\_host\_headers) | Host headers for listener rule routing | `list(list(string))` | `[]` | no |
| <a name="input_listener_rule_path_patterns"></a> [listener\_rule\_path\_patterns](#input\_listener\_rule\_path\_patterns) | Path patterns for listener rule routing | `list(list(string))` | `[]` | no |
| <a name="input_listener_rule_priority"></a> [listener\_rule\_priority](#input\_listener\_rule\_priority) | Priority for listener rule (when using shared ALB) | `number` | `100` | no |
| <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name) | CloudWatch log group name | `string` | n/a | yes |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory for the task in MB | `number` | `512` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | List of private subnet IDs for ECS tasks | `list(string)` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name | `string` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | List of public subnet IDs for ALB (if enabled) | `list(string)` | `[]` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Secrets from SSM/Secrets Manager for the container | <pre>list(object({<br/>    name      = string<br/>    valueFrom = string<br/>  }))</pre> | `[]` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs for ECS tasks | `list(string)` | n/a | yes |
| <a name="input_service_discovery_arn"></a> [service\_discovery\_arn](#input\_service\_discovery\_arn) | Service discovery registry ARN for service mesh | `string` | `null` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the microservice (e.g., 'auth', 'api', 'worker') | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags | `map(string)` | `{}` | no |
| <a name="input_target_group_deregistration_delay"></a> [target\_group\_deregistration\_delay](#input\_target\_group\_deregistration\_delay) | Deregistration delay in seconds | `number` | `30` | no |
| <a name="input_target_group_health_check_healthy_threshold"></a> [target\_group\_health\_check\_healthy\_threshold](#input\_target\_group\_health\_check\_healthy\_threshold) | Healthy threshold for target group | `number` | `2` | no |
| <a name="input_target_group_health_check_interval"></a> [target\_group\_health\_check\_interval](#input\_target\_group\_health\_check\_interval) | Health check interval | `number` | `30` | no |
| <a name="input_target_group_health_check_matcher"></a> [target\_group\_health\_check\_matcher](#input\_target\_group\_health\_check\_matcher) | HTTP response codes for successful health checks | `string` | `"200"` | no |
| <a name="input_target_group_health_check_timeout"></a> [target\_group\_health\_check\_timeout](#input\_target\_group\_health\_check\_timeout) | Health check timeout | `number` | `5` | no |
| <a name="input_target_group_health_check_unhealthy_threshold"></a> [target\_group\_health\_check\_unhealthy\_threshold](#input\_target\_group\_health\_check\_unhealthy\_threshold) | Unhealthy threshold for target group | `number` | `3` | no |
| <a name="input_task_role_policy_json"></a> [task\_role\_policy\_json](#input\_task\_role\_policy\_json) | Custom IAM policy JSON for the task role | `string` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | ARN of the ALB (if created) |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | DNS name of the ALB (if created) |
| <a name="output_ecr_repository_arn"></a> [ecr\_repository\_arn](#output\_ecr\_repository\_arn) | ARN of the ECR repository |
| <a name="output_ecr_repository_url"></a> [ecr\_repository\_url](#output\_ecr\_repository\_url) | URL of the ECR repository |
| <a name="output_service_id"></a> [service\_id](#output\_service\_id) | ID of the ECS service |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | Name of the ECS service |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | ARN of the target group |
| <a name="output_task_definition_arn"></a> [task\_definition\_arn](#output\_task\_definition\_arn) | ARN of the task definition |
| <a name="output_task_role_arn"></a> [task\_role\_arn](#output\_task\_role\_arn) | ARN of the task IAM role |
| <a name="output_task_role_name"></a> [task\_role\_name](#output\_task\_role\_name) | Name of the task IAM role |
<!-- END_TF_DOCS -->
