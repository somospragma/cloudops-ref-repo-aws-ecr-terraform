###########################################
# Sample Module Invocation
###########################################

# PC-IAC-026: Invocación del módulo padre con configuración transformada

module "ecr_repositories" {
  source = "../"  # Módulo padre
  
  # PC-IAC-005: Inyección de provider
  providers = {
    aws.project = aws.principal
  }
  
  # PC-IAC-002: Variables de gobernanza
  client      = var.client
  project     = var.project
  environment = var.environment
  
  # PC-IAC-026: Consumir configuración transformada desde locals
  ecr_config = local.ecr_config_transformed
}
