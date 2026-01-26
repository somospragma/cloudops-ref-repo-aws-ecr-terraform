###########################################
########### ECR Resources #################
###########################################

# ECR Repository
# Referencia: PC-IAC-010 (for_each), PC-IAC-020 (Hardenizado de Seguridad)
resource "aws_ecr_repository" "this" {
  provider = aws.project
  
  # PC-IAC-010: Uso de for_each con map para estabilidad
  for_each = var.ecr_config
  
  # PC-IAC-003: Nomenclatura estándar desde locals
  name                 = local.ecr_repository_names[each.key]
  force_delete         = each.value.force_delete
  image_tag_mutability = each.value.image_tag_mutability

  # PC-IAC-014: Bloques dinámicos para configuración de cifrado
  # PC-IAC-020: Cifrado en reposo (Hardenizado de Seguridad)
  dynamic "encryption_configuration" {
    for_each = length(each.value.encryption_configuration) > 0 ? each.value.encryption_configuration : [
      {
        encryption_type = "AES256"
        kms_key         = ""
      }
    ]
    content {
      encryption_type = encryption_configuration.value.encryption_type
      kms_key         = encryption_configuration.value.encryption_type == "KMS" ? encryption_configuration.value.kms_key : null
    }
  }

  # PC-IAC-014: Bloques dinámicos para configuración de escaneo
  # PC-IAC-020: Escaneo de imágenes habilitado por defecto (Hardenizado de Seguridad)
  dynamic "image_scanning_configuration" {
    for_each = length(each.value.image_scanning_configuration) > 0 ? each.value.image_scanning_configuration : [
      {
        scan_on_push = true
      }
    ]
    content {
      scan_on_push = image_scanning_configuration.value.scan_on_push
    }
  }

  # PC-IAC-004: Etiquetas con merge de Name y additional_tags
  tags = merge(
    {
      Name          = local.ecr_repository_names[each.key]
      functionality = each.value.functionality
      environment   = var.environment
      application   = var.application
      access_class  = each.value.access_class
    },
    each.value.additional_tags
  )
}

# ECR Lifecycle Policy
# Referencia: PC-IAC-010 (for_each condicional)
resource "aws_ecr_lifecycle_policy" "this" {
  provider = aws.project
  
  # PC-IAC-010: for_each condicional solo para repositorios con lifecycle_rules
  for_each = {
    for key, config in var.ecr_config : key => config
    if length(config.lifecycle_rules) > 0
  }
  
  repository = aws_ecr_repository.this[each.key].name
  
  # Construcción de política de ciclo de vida
  policy = jsonencode({
    rules = [
      for rule in each.value.lifecycle_rules : {
        rulePriority = rule.rule_priority
        description  = rule.description
        selection = {
          tagStatus   = rule.selection.tagStatus
          countType   = rule.selection.countType
          countUnit   = rule.selection.countUnit != "" ? rule.selection.countUnit : null
          countNumber = rule.selection.countNumber
        }
        action = {
          type = rule.action.type
        }
      }
    ]
  })
}
