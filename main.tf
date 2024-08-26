module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "5.11.4"

  cluster_name = "ecs-integrated"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

 services = {
    jenkins-service = {
      cpu    = 1024
      memory = 4096

      # Container definition(s)
      container_definitions = jsonencode([
        {
          name      = "jenkins"
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "jenkins/jenkins:lts"
          portMappings = [
            {
              containerPort = 80
              protocol      = "tcp"
            }
          ]
          readonlyRootFilesystem = false
          mountPoints = [
            {
              sourceVolume  = "jenkins-data"
              containerPath = "/var/jenkins_home"
              readOnly      = false
            }
          ]
          serviceConnectConfiguration = {
            namespace = "jenkins-namespace"
            services = [
              {
                port_name      = "ecs-jenkins-service"
                discovery_name = "ecs-jenkins-service"
                client_aliases = [
                  {
                    port     = 80
                    dns_name = "ecs-jenkins-service"
                  }
                ]
              }
            ]
          }
        }
      ])

      # Load balancer configuration
      load_balancer = {
        service = {
          target_group_arn = aws_lb_target_group.ecs.arn
          container_name   = "jenkins"
          container_port   = 80
        }
      }

      subnet_ids = module.vpc.private_subnets

      security_groups = [aws_security_group.ecs_service_sg.id]

      autoscaling = {
        min_capacity = 1
        max_capacity = 3

        target_cpu_utilization = 75
        scale_in_cooldown      = 300
        scale_out_cooldown     = 300
      }

    }
  }

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}