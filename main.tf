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
      container_definitions = {
        jenkins = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "jenkins/jenkins:lts"
          port_mappings = [
            {
              containerPort = 80
              protocol      = "tcp"
            }
          ]
          readonly_root_filesystem = false
         
          service_connect_configuration = {
            namespace = "jenkins-namespace"
            service = {
              client_alias = {
                port     = 80
                dns_name = "ecs-jenkins-service"
              }
              port_name      = "ecs-jenkins-service"
              discovery_name = "ecs-jenkins-service"
            }
          }
        }
      }

      /*  load_balancer = {
        service = {
          target_group_arn = [module.alb.target_groups]
          container_name   = "jenkins"
          container_port   = 80
        }
      } */

      subnet_ids = module.vpc.public_subnets

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
