###########################################
# Data Sources for Sample
###########################################

# PC-IAC-026: Data sources para obtener IDs dinámicos

# Obtener la región actual
data "aws_region" "current" {
  provider = aws.principal
}

# Obtener la cuenta AWS actual
data "aws_caller_identity" "current" {
  provider = aws.principal
}

# Obtener KMS key para cifrado de ECR (si existe)
# Nota: Este data source fallará si la key no existe
# En un entorno real, la key debería existir previamente
data "aws_kms_key" "ecr" {
  provider = aws.principal
  key_id   = "alias/${var.client}-${var.project}-${var.environment}-kms-ecr"
}
