
resource "aws_efs_file_system" "jenkins_efs" {
    creation_token = "jenkins-efs"
    performance_mode = "generalPurpose"
    throughput_mode = "bursting"

    tags = {
        Name = "jenkins-efs"
    }
}


resource "aws_efs_mount_target" "jenkins_efs_mount" {
    for_each = toset(module.vpc.private_subnets)
    file_system_id = aws_efs_file_system.jenkins_efs.id
    subnet_id = each.value
    security_groups = [aws_security_group.efs_sg.id]
} 

resource "aws_efs_access_point" "jenkins_ap" {
  file_system_id = aws_efs_file_system.jenkins_efs.id

  posix_user {
    uid = 1000
    gid = 1000
  }

  root_directory {
    path = "/jenkins-data"
    creation_info {
      owner_uid   = 1000
      owner_gid   = 1000
      permissions =  "775"
    }
  }
}