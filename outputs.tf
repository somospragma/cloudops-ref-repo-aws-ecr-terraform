output "ecr_info" {
  value = {for ecr in aws_ecr_repository.ecr_repository : ecr.tags_all.functionality => {"repository_url" : ecr.repository_url}}
}