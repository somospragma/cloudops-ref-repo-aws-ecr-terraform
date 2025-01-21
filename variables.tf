###########################################
########## Common variables ###############
###########################################

variable "environment" {
  type = string
  description = "Environment where resources will be deployed"
}

variable "client" {
  type = string
  description = "Client name"
}

variable "project" {
  type = string  
    description = "Project name"
}

variable "application" {
  type = string  
  description = "Application name"
}

###########################################
############ ECR variables ################
###########################################

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
    functionality = string
    access_type    = string
    lifecycle_rules = optional(list(object({
      rulePriority = number
      description  = string
      selection = object({
        tagStatus   = string
        countType   = string
        countUnit   = string
        countNumber = number
      })
      action = object({
        type = string
      })
    })), [])
  }))
  description = <<EOF
    - force_delete: (bool) If true, will delete the repository even if it contains images. Defaults to false.
    - image_tag_mutability: (string) The tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE. 
    - encryption_configuration:
      - encryption_type: (string) The encryption type to use for the repository. Valid values are AES256 or KMS. Defaults to AES256.
      - kms_key: (string) To use when encryption_type is The ARN of the KMS key KMS. If not specified, uses the default AWS managed key for ECR.
    - image_scanning_configuration:
      - scan_on_push: (string) Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false).
    - functionality: (string) Functionality name.
    - access_type: (string) Repository access type.
    - lifecycle_rules: (optional, (list(object))) Policy to remove old images
      - rulePriority: (number) The AWS ECR API seems to reorder rules based on rulePriority. If you define multiple rules that are not sorted in ascending rulePriority order in the Terraform code, the resource will be flagged for recreation every terraform plan.
      - description: (string) Policy description
      - selection: (object)
        - tagStatus: (string) Determines whether the lifecycle policy rule that you are adding specifies a tag for an image. Acceptable options are tagged, untagged, or any. If you specify any, then all images have the rule evaluated against them. If you specify tagged, then you must also specify a tagPrefixList value. If you specify untagged, then you must omit tagPrefixList.
        - countType: (string) If countType is set to imageCountMoreThan, you also specify countNumber to create a rule that sets a limit on the number of images that exist in your repository. If countType is set to sinceImagePushed, you also specify countUnit and countNumber to specify a time limit on the images that exist in your repository.
        - contUnit: (string) Specify a count unit of days to indicate that as the unit of time, in addition to countNumber, which is the number of days. This should only be specified when countType is sinceImagePushed; an error will occur if you specify a count unit when countType is any other value.
        - countNumber: (number) Specify a count number. Acceptable values are positive integers (0 is not an accepted value).If the countType used is imageCountMoreThan, then the value is the maximum number of images that you want to retain in your repository. If the countType used is sinceImagePushed, then the value is the maximum age limit for your images.
  EOF
}