###########################################
# Module Outputs
###########################################

# PC-IAC-007: Outputs granulares con Splat Expressions
# PC-IAC-014: Uso de Splat Expressions para extracción de colecciones

output "repository_urls" {
  description = "Map of repository URLs by repository key"
  value       = { for key, repo in aws_ecr_repository.this : key => repo.repository_url }
}

output "repository_arns" {
  description = "Map of repository ARNs by repository key"
  value       = { for key, repo in aws_ecr_repository.this : key => repo.arn }
}

output "repository_names" {
  description = "Map of repository names by repository key"
  value       = { for key, repo in aws_ecr_repository.this : key => repo.name }
}

output "repository_registry_ids" {
  description = "Map of registry IDs by repository key"
  value       = { for key, repo in aws_ecr_repository.this : key => repo.registry_id }
}

output "repository_policy_registry_ids" {
  description = "Map of registry IDs for repositories with access policies"
  value       = { for key, policy in aws_ecr_repository_policy.this : key => policy.registry_id }
}