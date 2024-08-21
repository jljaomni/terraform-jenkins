module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name = "terraform-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["us-east-1a", "us-east-1b"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_vpn_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

/* module "terraform-sg" {
  source = "terraform-aws-modules/security-group/aws"

  name                = "terraform-sg"
  description         = "terraform security group"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["https-443-tcp"]
} */


resource "aws_security_group" "ecs_service_sg" {
  name        = "ecs_service_sg"
  description = "Security group for ECS service"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "ecs_service_sg"
  }
}

resource "aws_security_group_rule" "allow_alb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow inbound traffic from ALB to ECS service"
  security_group_id = aws_security_group.ecs_service_sg.id
}

resource "aws_security_group_rule" "allow_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic from ECS service"
  security_group_id = aws_security_group.ecs_service_sg.id
}
