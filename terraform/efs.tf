resource "aws_efs_file_system" "agenthub_data" {
  creation_token = "gaze-agenthub-data"
  encrypted      = true

  tags = {
    Name = "gaze-agenthub-data"
  }
}

resource "aws_efs_mount_target" "agenthub" {
  for_each        = toset(var.private_subnet_ids)
  file_system_id  = aws_efs_file_system.agenthub_data.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs_agenthub.id]
}

resource "aws_efs_access_point" "agenthub" {
  file_system_id = aws_efs_file_system.agenthub_data.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/agenthub"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }
}
