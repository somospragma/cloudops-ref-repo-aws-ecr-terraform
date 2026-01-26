###########################################
# Local Transformations for Sample
###########################################

# PC-IAC-026: Transformaciones e inyección de IDs dinámicos

locals {
  # Prefijo de gobernanza
  governance_prefix = "${var.client}-${var.project}-${var.environment}"
  
  # PC-IAC-009: Transformar configuración inyectando KMS key ARN dinámico
  # Si encryption_type es KMS y kms_key está vacío, inyectar desde data source
  ecr_config_transformed = {
    for key, config in var.ecr_config : key => merge(config, {
      encryption_configuration = [
        for enc in config.encryption_configuration : merge(enc, {
          # Inyectar KMS key ARN si está vacío y el tipo es KMS
          kms_key = enc.encryption_type == "KMS" && length(enc.kms_key) == 0 ? data.aws_kms_key.ecr.arn : enc.kms_key
        })
      ]
    })
  }
}
