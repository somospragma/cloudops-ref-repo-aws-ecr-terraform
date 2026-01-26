###########################################
# Local Values and Transformations
###########################################

locals {
  # Prefijo de gobernanza para nomenclatura estándar (PC-IAC-003)
  governance_prefix = "${var.client}-${var.project}-${var.environment}"
  
  # Construcción de nombres de repositorios ECR con nomenclatura estándar
  # Patrón: {client}-{project}-{environment}-ecr-{application}-{functionality}
  ecr_repository_names = {
    for key, config in var.ecr_config : key => "${local.governance_prefix}-ecr-${var.application}-${config.functionality}"
  }
}
