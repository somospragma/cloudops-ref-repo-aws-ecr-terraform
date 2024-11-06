# main.tf
resource "aws_ecr_repository" "ecr_repository" {
  # checkov:skip=CKV_AWS_136: Encryption is sent as a variable
  # checkov:skip=CKV_AWS_51: validation is sent as a variable
  # checkov:skip=CKV_AWS_163: validation is sent as a variable
  for_each = {
    for repo in var.ecr_config : repo.application_id => repo
  }
  
  name                 = join("-", tolist([var.client, var.environment, each.key, "ecr", var.service]))
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
    Name           = join("-", tolist([var.client, var.environment, each.key, "ecr", var.service])),
    application_id = each.value.application_id,
    environment    = var.environment,
    service        = var.service,
    ticket         = each.value.ticket,
    accessclass    = each.value.accessclass
  }
}

resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
  for_each = {
    for repo in var.ecr_config : repo.application_id => repo
    if length(repo.lifecycle_rules) > 0  # Solo crea la política si hay reglas definidas
  }
  
  repository = aws_ecr_repository.ecr_repository[each.key].name
  policy = jsonencode({
    rules = each.value.lifecycle_rules
  })
}