resource "aws_efs_file_system" "jenkins_efs" {
    creation_token = "jenkins-efs"
    performance_mode = "generalPurpose"
    throughput_mode = "bursting"

    tags = {
        Name = "jenkins-efs"
    }
}

locals {
  private_subnets = toset(module.vpc.private_subnets)
}

resource "aws_efs_mount_target" "jenkins_efs_mount" {
    for_each = local.private_subnets
    file_system_id = aws_efs_file_system.jenkins_efs.id
    subnet_id = each.value
    security_groups = [aws_security_group.efs_sg.id]
}