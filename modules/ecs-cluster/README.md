# ECS Cluster Module

ECS Fargate cluster with Container Insights and CloudWatch logs.

## Resources Created

- ECS Cluster
- Capacity providers (Fargate and Fargate Spot)
- CloudWatch Log Group

## Usage

```hcl
module "ecs_cluster" {
  source = "git::https://github.com/h3ow3d/h3ow3d-infra.git//modules/ecs-cluster?ref=v1.0.0"

  project_name       = "h3ow3d"
  environment        = "production"
  log_retention_days = 7
  
  tags = {
    Project = "h3ow3d"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_name | Project name for resource naming | string | - | yes |
| environment | Environment name | string | - | yes |
| log_retention_days | CloudWatch log retention in days | number | 7 | no |
| tags | Additional tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | ID of the ECS cluster |
| cluster_name | Name of the ECS cluster |
| cluster_arn | ARN of the ECS cluster |
| log_group_name | Name of the CloudWatch log group |
