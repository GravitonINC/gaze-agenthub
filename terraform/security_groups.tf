# AgentHub ECS task security group
resource "aws_security_group" "agenthub" {
  name        = "gaze-agenthub"
  description = "AgentHub ECS task"
  vpc_id      = var.vpc_id

  # Inbound: port 8080 from internal ALB only
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [var.internal_alb_security_group_id]
    description     = "HTTP from internal ALB"
  }

  # Outbound: all (EFS, ECR, CloudWatch, internet for git)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound"
  }

  tags = {
    Name = "gaze-agenthub"
  }
}

# EFS security group — NFS access from AgentHub tasks
resource "aws_security_group" "efs_agenthub" {
  name        = "gaze-agenthub-efs"
  description = "EFS for AgentHub data"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.agenthub.id]
    description     = "NFS from AgentHub tasks"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "gaze-agenthub-efs"
  }
}
