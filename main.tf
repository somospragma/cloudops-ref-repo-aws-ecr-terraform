# main.tf
resource "aws_ecr_repository" "ecr_repository" {
  provider = aws.project
  # checkov:skip=CKV_AWS_136: Encryption is sent as a variable
  # checkov:skip=CKV_AWS_51: validation is sent as a variable
  # checkov:skip=CKV_AWS_163: validation is sent as a variable
  for_each = {
    for repo in var.ecr_config : repo.application_id => repo
  }
  
  name                 = join("-", tolist([var.client, var.project, var.environment, each.key, "ecr"]))
  force_delete         = each.value.force_delete
  image_tag_mutability = each.value.image_tag_mutability

  dynamic "encryption_configuration" {
    for_each = each.value.encryption_configuration
    content {
      encryption_type = encryption_configuration.value.encryption_type
      kms_key         = encryption_configuration.value.kms_key
    }
  }

  dynamic "image_scanning_configuration" {
    for_each = each.value.image_scanning_configuration
    content {
      scan_on_push = image_scanning_configuration.value.scan_on_push
    }
  }

  tags = {
    Name           = join("-", tolist([var.client, var.project, var.environment, each.key, "ecr"])),
    application_id = each.value.application_id,
    environment    = var.environment,
    service        = var.service,
    accessclass    = each.value.accessclass
  }
}

resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
  for_each = {
    for repo in var.ecr_config : repo.application_id => repo
    if length(repo.lifecycle_rules) > 0
  }
  
  repository = aws_ecr_repository.ecr_repository[each.key].name
  
  policy = jsonencode({
    rules = [
      for rule in each.value.lifecycle_rules : {
        rulePriority = rule.rulePriority
        description  = rule.description
        selection = {
          tagStatus      = rule.selection.tagStatus
          countType      = rule.selection.countType
          countUnit      = "days"           # Agregamos esta unidad requerida
          countNumber    = rule.selection.countNumber
        }
        action = {
          type = rule.action.type
        }
      }
    ]
  })
}
