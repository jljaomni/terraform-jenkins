resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-integrated"
}

resource "aws_ecs_task_definition" "jenkins_sonarqube_task" {
  family                   = "jenkins-sonarqube-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"

  container_definitions = jsonencode([{
    name      = "jenkins"
    image     = "jenkins/jenkins:lts-jdk17"
    essential = true
    cpu       = 512
    memory    = 1024

    portMappings = [
      {
        containerPort = 8080
        protocol      = "tcp"
      }
    ]

    environment = [
      {
        name  = "JENKINS_OPTS"
        value = "--prefix=/jenkins"
      }
    ]

    mountPoints = [
      {
        sourceVolume  = "jenkins-data"
        containerPath = "/var/jenkins_home"
        readOnly      = false
      }
    ] 

    readonlyRootFilesystem = false

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs_log_group.name
        awslogs-region        = "us-east-1" 
        awslogs-stream-prefix = "ecs"
      }
    }
  },
  {
      name      = "sonarqube"
      image     = "sonarqube:lts-community"
      essential = true
      cpu       = 512
      memory    = 1024

      portMappings = [
        {
          containerPort = 9000
          protocol      = "tcp"
        }
      ]

      mountPoints = [
        {
          sourceVolume  = "sonarqube-data"
          containerPath = "/opt/sonarqube/data"
          readOnly      = false
        }
      ]

      environment = [
        {
          name  = "SONARQUBE_JDBC_USERNAME"
          value = "sonar"
        },
        {
          name  = "SONARQUBE_JDBC_PASSWORD"
          value = "sonar_password"
        },
        {
          name  = "SONARQUBE_JDBC_URL"
          value = "jdbc:postgresql://db_host:5432/sonar"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_log_group.name
          awslogs-region        = "us-east-1" 
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])


   volume {
    name = "jenkins-data"

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.jenkins_efs.id
      root_directory = "/"
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.jenkins_ap.id
        iam = "ENABLED"
      }
    }
  }

  volume {
    name = "sonarqube-data"
    efs_volume_configuration {
      file_system_id    = aws_efs_file_system.jenkins_efs.id
      root_directory    = "/"
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.sonarqube_ap.id
        iam = "ENABLED"
      }
    }
  }
 
  execution_role_arn = aws_iam_role.ecs_task_execution_role_tf.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn
}

resource "aws_ecs_service" "jenkins_sonarqube_service" {
  name            = "jenkins-sonarqube-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.jenkins_sonarqube_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.ecs_service_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.jenkins_tg.arn
    container_name   = "jenkins"
    container_port   = 8080
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.sonarqube_tg.arn
    container_name   = "sonarqube"
    container_port   = 9000
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 300

  depends_on = [
    aws_lb_listener.http
  ]
}

