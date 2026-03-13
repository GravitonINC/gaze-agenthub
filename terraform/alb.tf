resource "aws_lb_target_group" "agenthub" {
  name        = "gaze-agenthub"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/api/health"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name = "gaze-agenthub"
  }
}

resource "aws_lb_listener_rule" "agenthub" {
  listener_arn = var.internal_alb_https_listener_arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.agenthub.arn
  }

  condition {
    host_header {
      values = ["agenthub-internal.graviton.xyz", "agenthub.graviton.xyz"]
    }
  }
}
