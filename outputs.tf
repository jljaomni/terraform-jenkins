
output "trfm_public_subnet_ids" {
  value       = [module.vpc.public_subnets]
  description = "List of public subnet IDs"
}

output "trfm_private_subnet_ids" {
  value       = [module.vpc.private_subnets]
  description = "List of private subnet IDs"
}


# alb.tf outputs
output "alb_arn" {
  value = aws_lb.this.arn
}

output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.ecs.arn
}
