###########################################
# Sample Outputs
###########################################

output "repository_urls" {
  description = "URLs of the created ECR repositories"
  value       = module.ecr_repositories.repository_urls
}

output "repository_arns" {
  description = "ARNs of the created ECR repositories"
  value       = module.ecr_repositories.repository_arns
}

output "repository_names" {
  description = "Names of the created ECR repositories"
  value       = module.ecr_repositories.repository_names
}
