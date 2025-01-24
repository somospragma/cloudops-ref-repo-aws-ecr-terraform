# **Módulo Terraform: cloudops-ref-repo-aws-ecr-terraform**

## Descripción:

Este módulo facilita la creación de los siguientes recursos en AWS:

- Elastic Container Registry (ECR)
- Life Cycle Policy

Consulta CHANGELOG.md para la lista de cambios de cada versión. *Recomendamos encarecidamente que en tu código fijes la versión exacta que estás utilizando para que tu infraestructura permanezca estable y actualices las versiones de manera sistemática para evitar sorpresas.*

## Estructura del Módulo
El módulo cuenta con la siguiente estructura:

```bash
cloudops-ref-repo-aws-vpc-terraform/
└── sample/ecr
    ├── data.tf
    ├── main.tf
    ├── outputs.tf
    ├── providers.tf
    ├── terraform.tfvars.sample
    └── variables.tf
├── .gitignore
├── CHANGELOG.md
├── data.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── README.md
├── variables.tf
```

- Los archivos principales del módulo (`data.tf`, `main.tf`, `outputs.tf`, `variables.tf`, `providers.tf`) se encuentran en el directorio raíz.
- `CHANGELOG.md` y `README.md` también están en el directorio raíz para fácil acceso.
- La carpeta `sample/` contiene un ejemplo de implementación del módulo.

## Seguridad & Cumplimiento
 
Consulta a continuación la fecha y los resultados de nuestro escaneo de seguridad y cumplimiento.
 
<!-- BEGIN_BENCHMARK_TABLE -->
| Benchmark | Date | Version | Description | 
| --------- | ---- | ------- | ----------- | 
| ![checkov](https://img.shields.io/badge/checkov-passed-green) | 2023-09-20 | 3.2.232 | Escaneo profundo del plan de Terraform en busca de problemas de seguridad y cumplimiento |
<!-- END_BENCHMARK_TABLE -->

## Provider Configuration

Este módulo requiere la configuración de un provider específico para el proyecto. Debe configurarse de la siguiente manera:

```hcl
sample/ecr/providers.tf
provider "aws" {
  alias = "alias01"
  # ... otras configuraciones del provider
}

sample/ecr/main.tf
module "ecr" {
  source = ""
  providers = {
    aws.project = aws.alias01
  }
  # ... resto de la configuración
}
```

## Uso del Módulo:

```hcl
module "ecr" {
  source = ""
  
  providers = {
    aws.project = aws.project
  }

  # Common configuration
  client        = "example"
  project       = "example"
  environment   = "dev"
  aws_region    = "us-east-1"
  common_tags = {
      environment   = "dev"
      project-name  = "proyecto01"
      cost-center   = "xxx"
      owner         = "xxx"
      area          = "xxx"
      provisioned   = "xxx"
      datatype      = "xxx"
  }

  # ECR configuration
  ecr_config = [
    {
      application_id           = "app01"
      force_delete             = true
      image_tag_mutability     = "MUTABLE"
      encryption_configuration = []
      image_scanning_configuration = [
        {
          scan_on_push = "true"
        }
      ]
      accessclass = "private"
      # Lifecycle policy to remove old images
      lifecycle_rules = [
        {
          rulePriority = 1
          description  = "Remove images older than 180 days"
          selection = {
            tagStatus   = "any"
            countType   = "sinceImagePushed"
            countUnit   = "days"
            countNumber = 180
          }
          action = {
            type = "expire"
          }
        }
      ]
    }
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.31.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.project"></a> [aws.project](#provider\_aws) | >= 4.31.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ecr_repository.ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_lifecycle_policy.lifecycle_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="force_delete"></a> [force_delete](#input\force_delete) | Borrar repositorio (Incluso si contiene imágenes) | `bool` | n/a | yes |
| <a name="image_tag_mutability"></a> [image_tag_mutability](#input\image_tag_mutability) | Configuración de mutabilidad de etiquetas para el repositorio | `string` | n/a | yes |
| <a name="encryption_configuration.encryption_type"></a> [encryption_configuration.encryption_type](#input\encryption_configuration.encryption_type) | Tipo de cifrado | `string` | n/a | yes |
| <a name="encryption_configuration.kms_key"></a> [encryption_configuration.kms_key](#input\encryption_configuration.kms_key) | ARN of the KMS | `string` | n/a | yes |
| <a name="image_scanning_configuration.scan_on_push"></a> [image_scanning_configuration.scan_on_push](#input\image_scanning_configuration.scan_on_push) | Scan images after being pushed | `string` | n/a | yes |
| <a name="application_id"></a> [application_id](#input\application_id) | Application name | `string` | n/a | yes |
| <a name="accessclass"></a> [accessclass](#input\accessclass) | Acceso al repositorio | `string` | n/a | yes |
| <a name="lifecycle_rules.rulePriority"></a> [lifecycle_rules.rulePriority](#input\lifecycle_rules.rulePriority) | Orden de aplicación de regla | `number` | n/a | no |
| <a name="lifecycle_rules.description"></a> [lifecycle_rules.description](#input\lifecycle_rules.description) | Descripción de la regla | `string` | n/a | no |
| <a name="lifecycle_rules.selection.tagStatus"></a> [lifecycle_rules.selection.tagStatus](#input\lifecycle_rules.selection.tagStatus) | Aplicar regla con un tag específico | `string` | n/a | no |
| <a name="lifecycle_rules.selection.countType"></a> [lifecycle_rules.selection.countType](#input\lifecycle_rules.selection.countType) | Tipo de conteo | `string` | n/a | no |
| <a name="lifecycle_rules.selection.contUnit"></a> [lifecycle_rules.selection.contUnit](#input\lifecycle_rules.selection.contUnit) | Unidad de días a contar | `string` | n/a | no |
| <a name="lifecycle_rules.selection.countNumber"></a> [lifecycle_rules.selection.countNumber](#input\lifecycle_rules.selection.countNumber) | Número de conteo | `number` | n/a | no |



## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecr_info_repository_url"></a> [ecr_info.repository_url](#output\_ecr_info_repository_url) | URL del repositorio creado |
