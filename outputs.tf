/*
output "trfm_alb_dns_name" {
  value       = module.alb.dns_name
  description = "The DNS name of the ALB"
}


*/
output "trfm_public_subnet_ids" {
  value       = [module.vpc.public_subnets]
  description = "List of public subnet IDs"
}

/* output "alb_target_group_arn" {
  description = "ALB Target Group ARN"
  value       = module.alb.target_groups[0]
} */
