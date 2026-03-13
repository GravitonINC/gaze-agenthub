resource "aws_cloudwatch_log_group" "agenthub" {
  name              = "/ecs/gaze-agenthub"
  retention_in_days = 30
}

resource "aws_ecs_task_definition" "agenthub" {
  family                   = "gaze-agenthub"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  volume {
    name = "agenthub-data"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.agenthub_data.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.agenthub.id
        iam             = "ENABLED"
      }
    }
  }

  container_definitions = jsonencode([{
    name  = "agenthub"
    image = "${var.ecr_repo_url}:latest"

    portMappings = [{
      containerPort = 8080
      protocol      = "tcp"
    }]

    mountPoints = [{
      sourceVolume  = "agenthub-data"
      containerPath = "/data"
      readOnly      = false
    }]

    command = [
      "--data", "/data",
      "--listen", ":8080"
    ]

    environment = []

    secrets = [{
      name      = "AGENTHUB_ADMIN_KEY"
      valueFrom = "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:gaze-agents/agenthub-admin-key"
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.agenthub.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "agenthub"
      }
    }

    healthCheck = {
      command     = ["CMD-SHELL", "wget -qO- http://localhost:8080/api/health || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 10
    }
  }])
}

resource "aws_ecs_service" "agenthub" {
  name            = "gaze-agenthub"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.agenthub.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.agenthub.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.agenthub.arn
    container_name   = "agenthub"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener_rule.agenthub]
}
