

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}
locals {
  extra_tag = "extra-tag"
}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  name         = "jenkins-ecs-cluster"
  cluster_name = "jenkins-cluster"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  services = [
    {
      name = "jenkins-service"
      task_definition = {
        container_definitions = jsonencode([{
          name      = "jenkins"
          image     = "jenkins/jenkins:lts"
          cpu       = 256
          memory    = 512
          essential = true
          portMappings = [{
            containerPort = 8080
            hostPort      = 8080
            protocol      = "tcp"
          }]
        }])
        family                   = "jenkins-task"
        requires_compatibilities = ["FARGATE"]
        cpu                      = 512
        memory                   = 1024
        network_mode             = "awsvpc"
      }
      desired_count = 2
      launch_type   = "FARGATE"
      network_configuration = {
        security_groups = [module.terraform-sg.security_group_id]
      }

      load_balancer = {
        target_group_arn = module.alb.target_group_arns[0]
        container_name   = "jenkins"
        container_port   = 8080
      }

      # Auto Scaling Configuration
      autoscaling = {
        min_capacity = 1
        max_capacity = 3

        target_cpu_utilization = 75
        scale_in_cooldown      = 300
        scale_out_cooldown     = 300
      }
    }
  ]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
