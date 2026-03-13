output "efs_file_system_id" {
  value = aws_efs_file_system.agenthub_data.id
}

output "ecs_service_name" {
  value = aws_ecs_service.agenthub.name
}

output "target_group_arn" {
  value = aws_lb_target_group.agenthub.arn
}

output "agenthub_security_group_id" {
  value = aws_security_group.agenthub.id
}
