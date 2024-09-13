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

resource "aws_lb_target_group" "jenkins_tg" {
  name     = "jenkins-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  target_type = "ip"


  health_check {
    interval            = 60
    path                = "/jenkins/login"
    timeout             = 10
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-499"
  }

  tags = {
    Name = "ecs-tg"
  }
}

/* resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }
}
 */
#LISTENERS

 resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/css"
      message_body = "404: Not Found But 200 OK to test"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener_rule" "jenkins_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_tg.arn
  }

   condition {
    path_pattern {
      values = ["/jenkins/*", "/jenkins/", "/jenkins*"]
      }
    }
}

resource "aws_lb_listener_rule" "sonarqube_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sonarqube_tg.arn
  }

  condition {
    path_pattern {
      values = ["/sonarqube/*", "/sonarqube/", "/sonarqube*"]
      }
    }
}


#SONARQUBE ALB

resource "aws_lb_target_group" "sonarqube_tg" {
  name     = "sonarqube-tg"
  port     = 9000
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    interval            = 60
    path                = "/sonarqube/api/system/health"  # Ruta de salud para SonarQube
    timeout             = 10
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-499"
  }

  tags = {
    Name = "sonarqube-tg"
  }
}

