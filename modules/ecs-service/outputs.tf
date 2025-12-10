output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.main.name
}

output "service_id" {
  description = "ID of the ECS service"
  value       = aws_ecs_service.main.id
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.main.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.main.arn
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.main.arn
}

output "task_role_arn" {
  description = "ARN of the task IAM role"
  value       = aws_iam_role.task.arn
}

output "task_role_name" {
  description = "Name of the task IAM role"
  value       = aws_iam_role.task.name
}

output "alb_dns_name" {
  description = "DNS name of the ALB (if created)"
  value       = var.enable_load_balancer && var.create_alb ? aws_lb.main[0].dns_name : null
}

output "alb_arn" {
  description = "ARN of the ALB (if created)"
  value       = var.enable_load_balancer && var.create_alb ? aws_lb.main[0].arn : null
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = var.enable_load_balancer ? aws_lb_target_group.main[0].arn : null
}
