variable "ecr_config" {
  type = list(object({
    force_delete = bool
    image_tag_mutability = string
    encryption_configuration = list(object({
      encryption_type = string
      kms_key = string
    }))
    image_scanning_configuration = list(object({
      scan_on_push = string
    }))
    application_id = string
    accessclass    = string
    lifecycle_rules = optional(list(object({
      rulePriority = number
      description  = string
      selection = object({
        tagStatus     = string
        countType     = string
        countNumber   = number
        tagPrefixList = optional(list(string))
      })
      action = object({
        type = string
      })
    })), [])
  }))
}

variable "service" {
  type        = string
  description = "Nombre del servicio"
}

variable "client" {
  type        = string
  description = "Nombre del cliente"
}

variable "environment" {
  type        = string
  description = "Ambiente de despliegue"
  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "environment must be dev, qa, or prod"
  }
}

variable "project" {
    description = "Nombre de Projecto"
    type = string
}