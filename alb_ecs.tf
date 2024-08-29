# alb.tf
resource "aws_lb" "this" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false
  idle_timeout               = 60

  tags = {
    Name = "my-alb"
  }
}

resource "aws_lb_target_group" "ecs" {
  name     = "ecs-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  target_type = "ip"

  health_check {
    interval            = 60
    path                = "/login"
    timeout             = 10
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-299"
  }

  tags = {
    Name = "ecs-tg"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }
}


