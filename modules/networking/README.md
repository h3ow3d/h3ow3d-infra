# Networking Module

VPC infrastructure with public/private subnets, NAT gateways, and security groups.

## Resources Created

- VPC with DNS support
- Public subnets (for ALB)
- Private subnets (for Fargate tasks)
- Internet Gateway
- NAT Gateways (one per AZ)
- Route tables and associations
- Security groups for ALB and ECS tasks

## Usage

```hcl
module "networking" {
  source = "git::https://github.com/h3ow3d/h3ow3d-infra.git//modules/networking?ref=v1.0.0"

  project_name       = "h3ow3d"
  environment        = "production"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["eu-west-2a", "eu-west-2b"]
  
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
| vpc_cidr | CIDR block for VPC | string | - | yes |
| availability_zones | List of availability zones | list(string) | - | yes |
| tags | Additional tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the VPC |
| vpc_cidr | CIDR block of the VPC |
| public_subnet_ids | IDs of public subnets |
| private_subnet_ids | IDs of private subnets |
| alb_security_group_id | ID of ALB security group |
| ecs_tasks_security_group_id | ID of ECS tasks security group |
| nat_gateway_ids | IDs of NAT gateways |
