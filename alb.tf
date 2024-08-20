module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.0.0" # Verifica que esté actualizado según la última versión disponible

  name               = "jenkins-alb"
  load_balancer_type = "application"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  security_groups = [module.terraform-sg.security_group_id]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name_prefix      = "jenkins-tg"
      backend_protocol = "HTTP"
      backend_port     = 8080
      target_type      = "ip"
      health_check = {
        path                = "/login"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 5
        unhealthy_threshold = 2
        matcher             = "200"
      }
    }
  ]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
