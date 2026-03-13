variable "aws_region" {
  default = "us-east-1"
}

variable "account_id" {
  default = "862974744285"
}

variable "ecs_cluster_id" {
  default = "gaze-cluster-production"
}

variable "vpc_id" {
  default = "vpc-073bfb3fea4bf6c6e"
}

variable "private_subnet_ids" {
  type = list(string)
  default = [
    "subnet-048fa741545cd5571",
    "subnet-09fdbcba9b85fee5c",
    "subnet-095e4d44d6ab976c6"
  ]
}

variable "ecs_execution_role_arn" {
  default = "arn:aws:iam::862974744285:role/gaze-agents-task-execution-production"
}

variable "ecs_task_role_arn" {
  default = "arn:aws:iam::862974744285:role/gaze-agents-task-production"
}

variable "internal_alb_arn" {
  default = "arn:aws:elasticloadbalancing:us-east-1:862974744285:loadbalancer/app/gaze-internal-production/d2f9b8aef6fb4359"
}

variable "internal_alb_https_listener_arn" {
  default = "arn:aws:elasticloadbalancing:us-east-1:862974744285:listener/app/gaze-internal-production/d2f9b8aef6fb4359/f279a71e47eda18c"
}

variable "internal_alb_security_group_id" {
  description = "Security group of the internal ALB (for inbound rules)"
  type        = string
}

variable "ecr_repo_url" {
  default = "862974744285.dkr.ecr.us-east-1.amazonaws.com/gaze-agenthub"
}
