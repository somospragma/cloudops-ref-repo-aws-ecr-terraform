###########################################
# Sample Variables
###########################################

variable "client" {
  type        = string
  description = "Client name or business unit identifier"
}

variable "project" {
  type        = string
  description = "Project name identifier"
}

variable "environment" {
  type        = string
  description = "Environment where resources will be deployed (dev, qa, pdn)"
}

variable "ecr_config" {
  type = map(object({
    force_delete             = optional(bool, false)
    image_tag_mutability     = optional(string, "MUTABLE")
    encryption_configuration = optional(list(object({
      encryption_type = string
      kms_key         = optional(string, "")
    })), [])
    image_scanning_configuration = optional(list(object({
      scan_on_push = bool
    })), [])
    functionality   = optional(string, "")
    access_class    = optional(string, "private")
    additional_tags = optional(map(string), {})
    lifecycle_rules = optional(list(object({
      rule_priority = number
      description   = string
      selection = object({
        tagStatus   = string
        countType   = string
        countUnit   = optional(string, "")
        countNumber = number
      })
      action = object({
        type = string
      })
    })), [])
    repository_policy = optional(object({
      principals = list(string)
      actions    = optional(list(string), [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ])
      conditions = optional(list(object({
        test     = string
        variable = string
        values   = list(string)
      })), [])
    }), null)
  }))
  description = "Map of ECR repository configurations"
}
