# Generic ECS Fargate Microservice Module

locals {
  service_name = "${var.project_name}-${var.environment}-${var.service_name}"
}

# ECR Repository
resource "aws_ecr_repository" "main" {
  name                 = local.service_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = var.enable_image_scanning
  }

  tags = merge(var.tags, {
    Name    = local.service_name
    Service = var.service_name
  })
}

# ECR Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last ${var.ecr_image_retention_count} images"
      selection = {
        tagStatus     = "any"
        countType     = "imageCountMoreThan"
        countNumber   = var.ecr_image_retention_count
      }
      action = {
        type = "expire"
      }
    }]
  })
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution" {
  name = "${local.service_name}-task-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM Role for Service Task (application permissions)
resource "aws_iam_role" "task" {
  name = "${local.service_name}-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

# Optional custom IAM policies for the task role
resource "aws_iam_role_policy" "task_custom" {
  count = var.task_role_policy_json != null ? 1 : 0
  
  name   = "${local.service_name}-custom-policy"
  role   = aws_iam_role.task.id
  policy = var.task_role_policy_json
}

# ECS Task Definition
resource "aws_ecs_task_definition" "main" {
  family                   = local.service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([{
    name      = var.service_name
    image     = "${aws_ecr_repository.main.repository_url}:${var.image_tag}"
    essential = true

    portMappings = [{
      containerPort = var.container_port
      protocol      = "tcp"
    }]

    environment = [for k, v in var.environment_variables : {
      name  = k
      value = v
    }]

    secrets = var.secrets

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = var.log_group_name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = var.service_name
      }
    }

    healthCheck = var.health_check_command != null ? {
      command     = var.health_check_command
      interval    = var.health_check_interval
      timeout     = var.health_check_timeout
      retries     = var.health_check_retries
      startPeriod = var.health_check_start_period
    } : null
  }])

  tags = var.tags
}

# ECS Service
resource "aws_ecs_service" "main" {
  name            = local.service_name
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = var.assign_public_ip
  }

  dynamic "load_balancer" {
    for_each = var.enable_load_balancer ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.main[0].arn
      container_name   = var.service_name
      container_port   = var.container_port
    }
  }

  dynamic "service_registries" {
    for_each = var.service_discovery_arn != null ? [1] : []
    content {
      registry_arn = var.service_discovery_arn
    }
  }

  depends_on = [aws_lb_listener.main]

  tags = var.tags
}

# Application Load Balancer (optional)
resource "aws_lb" "main" {
  count = var.enable_load_balancer && var.create_alb ? 1 : 0

  name               = "${local.service_name}-alb"
  internal           = var.alb_internal
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.alb_deletion_protection

  tags = merge(var.tags, {
    Name = "${local.service_name}-alb"
  })
}

# Target Group
resource "aws_lb_target_group" "main" {
  count = var.enable_load_balancer ? 1 : 0

  name        = "${substr(local.service_name, 0, 32)}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = var.health_check_path
    healthy_threshold   = var.target_group_health_check_healthy_threshold
    unhealthy_threshold = var.target_group_health_check_unhealthy_threshold
    timeout             = var.target_group_health_check_timeout
    interval            = var.target_group_health_check_interval
    matcher             = var.target_group_health_check_matcher
  }

  deregistration_delay = var.target_group_deregistration_delay

  tags = merge(var.tags, {
    Name = "${local.service_name}-tg"
  })
}

# ALB Listener
resource "aws_lb_listener" "main" {
  count = var.enable_load_balancer && var.create_alb ? 1 : 0

  load_balancer_arn = aws_lb.main[0].arn
  port              = var.alb_listener_port
  protocol          = var.alb_listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[0].arn
  }
}

# Optional ALB Listener Rule (for shared ALB)
resource "aws_lb_listener_rule" "main" {
  count = var.enable_load_balancer && !var.create_alb && var.existing_listener_arn != null ? 1 : 0

  listener_arn = var.existing_listener_arn
  priority     = var.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[0].arn
  }

  dynamic "condition" {
    for_each = var.listener_rule_path_patterns
    content {
      path_pattern {
        values = condition.value
      }
    }
  }

  dynamic "condition" {
    for_each = var.listener_rule_host_headers
    content {
      host_header {
        values = condition.value
      }
    }
  }
}
