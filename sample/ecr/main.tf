###########################################
############## ECR module #################
###########################################

module "ecr" {
  source = "../../"
  providers = {
    aws.project = aws.alias01              #Write manually alias (the same alias name configured in providers.tf)
  }

  # Common configuration
  client         = var.client
  project        = var.project
  application    = var.application
  environment    = var.environment

  # ECR configuration
  ecr_config = var.ecr_config
}
