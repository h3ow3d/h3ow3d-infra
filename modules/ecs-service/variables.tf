variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "service_name" {
  description = "Name of the microservice (e.g., 'auth', 'api', 'worker')"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

# ECS Configuration
variable "ecs_cluster_id" {
  description = "ECS cluster ID"
  type        = string
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 2
}

variable "cpu" {
  description = "CPU units for the task (256 = 0.25 vCPU)"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory for the task in MB"
  type        = number
  default     = 512
}

# Networking
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB (if enabled)"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of security group IDs for ECS tasks"
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Assign public IP to ECS tasks"
  type        = bool
  default     = false
}

# Container Configuration
variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 3000
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secrets from SSM/Secrets Manager for the container"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

# Logging
variable "log_group_name" {
  description = "CloudWatch log group name"
  type        = string
}

# Health Checks
variable "health_check_command" {
  description = "Container health check command"
  type        = list(string)
  default     = null
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_retries" {
  description = "Health check retries"
  type        = number
  default     = 3
}

variable "health_check_start_period" {
  description = "Health check start period in seconds"
  type        = number
  default     = 60
}

variable "health_check_path" {
  description = "Target group health check path"
  type        = string
  default     = "/health"
}

# Load Balancer
variable "enable_load_balancer" {
  description = "Enable Application Load Balancer"
  type        = bool
  default     = true
}

variable "create_alb" {
  description = "Create a new ALB (false = use existing ALB with listener rules)"
  type        = bool
  default     = true
}

variable "alb_security_group_id" {
  description = "Security group ID for ALB"
  type        = string
  default     = ""
}

variable "alb_internal" {
  description = "Make ALB internal"
  type        = bool
  default     = false
}

variable "alb_deletion_protection" {
  description = "Enable deletion protection on ALB"
  type        = bool
  default     = false
}

variable "alb_listener_port" {
  description = "ALB listener port"
  type        = number
  default     = 80
}

variable "alb_listener_protocol" {
  description = "ALB listener protocol"
  type        = string
  default     = "HTTP"
}

# Target Group
variable "target_group_health_check_healthy_threshold" {
  description = "Healthy threshold for target group"
  type        = number
  default     = 2
}

variable "target_group_health_check_unhealthy_threshold" {
  description = "Unhealthy threshold for target group"
  type        = number
  default     = 3
}

variable "target_group_health_check_timeout" {
  description = "Health check timeout"
  type        = number
  default     = 5
}

variable "target_group_health_check_interval" {
  description = "Health check interval"
  type        = number
  default     = 30
}

variable "target_group_health_check_matcher" {
  description = "HTTP response codes for successful health checks"
  type        = string
  default     = "200"
}

variable "target_group_deregistration_delay" {
  description = "Deregistration delay in seconds"
  type        = number
  default     = 30
}

# Shared ALB Configuration
variable "existing_listener_arn" {
  description = "ARN of existing ALB listener (when create_alb=false)"
  type        = string
  default     = null
}

variable "listener_rule_priority" {
  description = "Priority for listener rule (when using shared ALB)"
  type        = number
  default     = 100
}

variable "listener_rule_path_patterns" {
  description = "Path patterns for listener rule routing"
  type        = list(list(string))
  default     = []
}

variable "listener_rule_host_headers" {
  description = "Host headers for listener rule routing"
  type        = list(list(string))
  default     = []
}

# Service Discovery
variable "service_discovery_arn" {
  description = "Service discovery registry ARN for service mesh"
  type        = string
  default     = null
}

# IAM
variable "task_role_policy_json" {
  description = "Custom IAM policy JSON for the task role"
  type        = string
  default     = null
}

# ECR
variable "enable_image_scanning" {
  description = "Enable ECR image scanning"
  type        = bool
  default     = true
}

variable "ecr_image_retention_count" {
  description = "Number of images to retain in ECR"
  type        = number
  default     = 10
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
