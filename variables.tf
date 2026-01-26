###########################################
########## Common Variables ###############
###########################################

variable "client" {
  type        = string
  description = "Client name or business unit identifier"
  
  validation {
    condition     = length(var.client) > 0 && length(var.client) <= 10
    error_message = "Client name must be between 1 and 10 characters"
  }
}

variable "project" {
  type        = string
  description = "Project name identifier"
  
  validation {
    condition     = length(var.project) > 0 && length(var.project) <= 15
    error_message = "Project name must be between 1 and 15 characters"
  }
}

variable "environment" {
  type        = string
  description = "Environment where resources will be deployed (dev, qa, pdn)"
  
  validation {
    condition     = contains(["dev", "qa", "pdn", "prod"], var.environment)
    error_message = "Environment must be one of: dev, qa, pdn, prod"
  }
}

variable "application" {
  type        = string
  description = "Application name identifier"
  
  validation {
    condition     = length(var.application) > 0 && length(var.application) <= 20
    error_message = "Application name must be between 1 and 20 characters"
  }
}

###########################################
############ ECR Variables ################
###########################################

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
    functionality   = string
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
  }))
  
  description = <<-EOF
    Map of ECR repository configurations. Key is the repository identifier.
    
    - force_delete: (optional, bool) If true, will delete the repository even if it contains images. Defaults to false.
    - image_tag_mutability: (optional, string) The tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE. Defaults to MUTABLE.
    - encryption_configuration: (optional, list(object)) Encryption configuration for the repository
      - encryption_type: (string) The encryption type to use for the repository. Valid values are AES256 or KMS.
      - kms_key: (optional, string) The ARN of the KMS key to use when encryption_type is KMS.
    - image_scanning_configuration: (optional, list(object)) Image scanning configuration
      - scan_on_push: (bool) Indicates whether images are scanned after being pushed to the repository.
    - functionality: (string) Functionality name for the repository.
    - access_class: (optional, string) Repository access type. Defaults to private.
    - additional_tags: (optional, map(string)) Additional tags to apply to the repository.
    - lifecycle_rules: (optional, list(object)) Policy to remove old images
      - rule_priority: (number) The priority of the rule (lower numbers are evaluated first).
      - description: (string) Policy description
      - selection: (object)
        - tagStatus: (string) Tag status filter. Valid values: tagged, untagged, or any.
        - countType: (string) Count type. Valid values: imageCountMoreThan or sinceImagePushed.
        - countUnit: (optional, string) Count unit (days). Required when countType is sinceImagePushed.
        - countNumber: (number) Count number threshold.
      - action: (object)
        - type: (string) Action type. Valid value: expire.
  EOF
  
  validation {
    condition     = length(var.ecr_config) > 0
    error_message = "At least one ECR repository configuration must be provided"
  }
  
  validation {
    condition = alltrue([
      for key, config in var.ecr_config :
      contains(["MUTABLE", "IMMUTABLE"], config.image_tag_mutability)
    ])
    error_message = "image_tag_mutability must be either MUTABLE or IMMUTABLE"
  }
  
  validation {
    condition = alltrue([
      for key, config in var.ecr_config :
      length(config.functionality) > 0
    ])
    error_message = "functionality must not be empty for any repository"
  }
}