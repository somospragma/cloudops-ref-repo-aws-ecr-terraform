# Módulo de Referencia: AWS ECR (Elastic Container Registry)

## Descripción

Este módulo de referencia facilita la creación y gestión de repositorios de Amazon Elastic Container Registry (ECR) siguiendo las mejores prácticas de seguridad y gobernanza definidas en las reglas PC-IAC.

### Características Principales

- ✅ Creación de repositorios ECR con nomenclatura estándar
- ✅ Cifrado en reposo (AES256 o KMS)
- ✅ Escaneo de imágenes habilitado por defecto
- ✅ Políticas de ciclo de vida configurables
- ✅ Etiquetado automático con variables de gobernanza
- ✅ Soporte para múltiples repositorios mediante `map(object)`
- ✅ Políticas de acceso a repositorios (cross-account y fine-grained)

## Estructura del Módulo

```
cloudops-ref-repo-aws-ecr-terraform/
├── .gitignore
├── CHANGELOG.md
├── README.md
├── data.tf
├── locals.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── variables.tf
├── versions.tf
└── sample/
    ├── README.md
    ├── data.tf
    ├── locals.tf
    ├── main.tf
    ├── outputs.tf
    ├── providers.tf
    ├── terraform.tfvars
    └── variables.tf
```

## Requisitos

| Nombre | Versión |
|--------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.31.0 |

## Providers

| Nombre | Alias | Descripción |
|--------|-------|-------------|
| aws | aws.project | Provider inyectado desde el módulo raíz |

## Recursos Creados

| Tipo | Descripción |
|------|-------------|
| `aws_ecr_repository` | Repositorio ECR con configuración de cifrado y escaneo |
| `aws_ecr_repository_policy` | Política IAM de acceso al repositorio (cross-account, fine-grained) |
| `aws_ecr_lifecycle_policy` | Política de ciclo de vida para gestión de imágenes |

## Uso del Módulo

### Ejemplo Básico

```hcl
module "ecr_repositories" {
  source = "git::https://github.com/org/cloudops-ref-repo-aws-ecr-terraform.git?ref=v1.0.0"
  
  providers = {
    aws.project = aws.principal
  }
  
  # Variables de gobernanza (PC-IAC-002)
  client      = "pragma"
  project     = "ecommerce"
  environment = "dev"
  application = "backend"
  
  # Configuración de repositorios
  ecr_config = {
    "api" = {
      functionality            = "api"
      force_delete             = false
      image_tag_mutability     = "MUTABLE"
      encryption_configuration = []  # AES256 por defecto
      image_scanning_configuration = [
        {
          scan_on_push = true
        }
      ]
      access_class    = "private"
      additional_tags = {
        team = "backend"
      }
      lifecycle_rules = [
        {
          rule_priority = 1
          description   = "Remove untagged images older than 30 days"
          selection = {
            tagStatus   = "untagged"
            countType   = "sinceImagePushed"
            countUnit   = "days"
            countNumber = 30
          }
          action = {
            type = "expire"
          }
        }
      ]
    }
  }
}
```

### Ejemplo con Cifrado KMS

```hcl
module "ecr_repositories" {
  source = "git::https://github.com/org/cloudops-ref-repo-aws-ecr-terraform.git?ref=v1.1.0"
  
  providers = {
    aws.project = aws.principal
  }
  
  client      = "pragma"
  project     = "ecommerce"
  environment = "pdn"
  application = "backend"
  
  ecr_config = {
    "api" = {
      functionality        = "api"
      force_delete         = false
      image_tag_mutability = "IMMUTABLE"  # Inmutable para producción
      
      # Cifrado con KMS
      encryption_configuration = [
        {
          encryption_type = "KMS"
          kms_key         = data.aws_kms_key.ecr.arn
        }
      ]
      
      image_scanning_configuration = [
        {
          scan_on_push = true
        }
      ]
      
      access_class = "private"
      additional_tags = {
        criticality = "high"
      }
      
      lifecycle_rules = []
    }
  }
}
```

### Ejemplo con Política de Acceso Cross-Account

```hcl
module "ecr_repositories" {
  source = "git::https://github.com/org/cloudops-ref-repo-aws-ecr-terraform.git?ref=v1.1.0"
  
  providers = {
    aws.project = aws.principal
  }
  
  client      = "pragma"
  project     = "ecommerce"
  environment = "pdn"
  application = "backend"
  
  ecr_config = {
    "api" = {
      functionality        = "api"
      image_tag_mutability = "IMMUTABLE"
      
      # Política de acceso cross-account
      repository_policy = {
        principals = [
          "arn:aws:iam::111111111111:root",
          "arn:aws:iam::222222222222:root"
        ]
        # actions usa el default: GetDownloadUrlForLayer, BatchGetImage, BatchCheckLayerAvailability
      }
      
      lifecycle_rules = []
    }
    
    "worker" = {
      functionality = "worker"
      
      # Política con condiciones (solo desde la organización)
      repository_policy = {
        principals = ["*"]
        actions = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        conditions = [
          {
            test     = "StringEquals"
            variable = "aws:PrincipalOrgID"
            values   = ["o-xxxxxxxxxxxx"]
          }
        ]
      }
      
      lifecycle_rules = []
    }
    
    "cron" = {
      functionality = "cron"
      # Sin repository_policy → no se crea política de acceso
      lifecycle_rules = []
    }
  }
}
```

## Inputs

| Nombre | Descripción | Tipo | Requerido | Default |
|--------|-------------|------|-----------|---------|
| `client` | Nombre del cliente o unidad de negocio | `string` | Sí | - |
| `project` | Nombre del proyecto | `string` | Sí | - |
| `environment` | Ambiente de despliegue (dev, qa, pdn) | `string` | Sí | - |
| `application` | Nombre de la aplicación | `string` | Sí | - |
| `ecr_config` | Mapa de configuraciones de repositorios ECR | `map(object)` | Sí | - |

### Estructura de `ecr_config`

```hcl
map(object({
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
```

## Outputs

| Nombre | Descripción | Tipo |
|--------|-------------|------|
| `repository_urls` | Mapa de URLs de repositorios por clave | `map(string)` |
| `repository_arns` | Mapa de ARNs de repositorios por clave | `map(string)` |
| `repository_names` | Mapa de nombres de repositorios por clave | `map(string)` |
| `repository_registry_ids` | Mapa de IDs de registro por clave | `map(string)` |
| `repository_policy_registry_ids` | Mapa de IDs de registro para repositorios con políticas de acceso | `map(string)` |

## Nomenclatura

Los repositorios ECR siguen el patrón de nomenclatura estándar (PC-IAC-003):

```
{client}-{project}-{environment}-ecr-{application}-{functionality}
```

**Ejemplo:** `pragma-ecommerce-dev-ecr-backend-api`

## Seguridad y Cumplimiento

### Hardenizado de Seguridad (PC-IAC-020)

Este módulo implementa las siguientes medidas de seguridad por defecto:

- ✅ **Cifrado en reposo**: AES256 por defecto, con soporte para KMS
- ✅ **Escaneo de imágenes**: Habilitado por defecto (`scan_on_push = true`)
- ✅ **Acceso privado**: Repositorios privados por defecto
- ✅ **Políticas de ciclo de vida**: Soporte para eliminación automática de imágenes antiguas
- ✅ **Políticas de acceso**: Control de acceso cross-account y fine-grained con soporte para condiciones IAM

### Validaciones

El módulo incluye validaciones para:
- Longitud de nombres de variables de gobernanza
- Valores válidos para `environment` (dev, qa, pdn, prod)
- Valores válidos para `image_tag_mutability` (MUTABLE, IMMUTABLE)
- Presencia de `functionality` en cada configuración

## Cumplimiento de Reglas PC-IAC

Este módulo cumple con las siguientes reglas de gobernanza:

| Regla | Descripción | Implementación |
|-------|-------------|----------------|
| PC-IAC-001 | Estructura de Módulo | 18 archivos obligatorios (10 raíz + 8 sample/) |
| PC-IAC-002 | Variables | Validaciones, tipos explícitos, uso de `map(object)` |
| PC-IAC-003 | Nomenclatura Estándar | Construcción en `locals.tf` con patrón estándar |
| PC-IAC-004 | Etiquetas (Tagging) | Merge de Name y additional_tags |
| PC-IAC-005 | Providers | Alias `aws.project` consumido desde el Root |
| PC-IAC-006 | Versiones | `required_version >= 1.0.0`, provider >= 4.31.0 |
| PC-IAC-007 | Outputs | Outputs granulares (URLs, ARNs, nombres) |
| PC-IAC-009 | Tipos y Conversiones | Uso de `optional()`, validaciones de tipo |
| PC-IAC-010 | For_Each | Uso de `for_each` con `map` para estabilidad |
| PC-IAC-011 | Data Sources | Data sources solo en el Root (sample/) |
| PC-IAC-012 | Locals | Centralización de nomenclatura y transformaciones |
| PC-IAC-014 | Bloques Dinámicos | Uso de `dynamic` para configuraciones anidadas |
| PC-IAC-020 | Hardenizado | Cifrado y escaneo habilitados por defecto |
| PC-IAC-023 | Responsabilidad Única | Solo crea recursos ECR intrínsecos |
| PC-IAC-026 | Patrón sample/ | Flujo tfvars → locals → main |

## Decisiones de Diseño

### Uso de `map(object)` en lugar de `list(object)`

Se utiliza `map(object)` para la variable `ecr_config` (PC-IAC-002) para garantizar la estabilidad del estado de Terraform. Esto previene la destrucción y recreación de recursos cuando se modifica o elimina un elemento intermedio.

### Cifrado por Defecto

Si no se especifica `encryption_configuration`, el módulo aplica cifrado AES256 por defecto. Para usar KMS, se debe especificar explícitamente el tipo y el ARN de la clave.

### Escaneo de Imágenes

El escaneo de imágenes está habilitado por defecto (`scan_on_push = true`) como medida de seguridad. Esto puede deshabilitarse explícitamente si es necesario.

### Políticas de Ciclo de Vida

Las políticas de ciclo de vida son opcionales. Si no se especifican, no se crea el recurso `aws_ecr_lifecycle_policy`.

### Políticas de Acceso a Repositorios

Las políticas de acceso (`repository_policy`) son opcionales. Si no se especifican, no se crea el recurso `aws_ecr_repository_policy`. Esto permite:
- Acceso cross-account a repositorios específicos
- Control fine-grained con condiciones IAM (por ejemplo, restringir por organización con `aws:PrincipalOrgID`)
- Acciones por defecto limitadas a lectura de imágenes (`GetDownloadUrlForLayer`, `BatchGetImage`, `BatchCheckLayerAvailability`)

## Ejemplo Completo

Para un ejemplo funcional completo, consulta el directorio `sample/` que incluye:
- Configuración de ejemplo en `terraform.tfvars`
- Inyección dinámica de KMS key ARN
- Múltiples repositorios con diferentes configuraciones
- Políticas de ciclo de vida

## Versionamiento

Este módulo sigue [Semantic Versioning](https://semver.org/). Consulta el [CHANGELOG.md](./CHANGELOG.md) para ver el historial de cambios.

## Contribución

Para contribuir a este módulo, por favor:
1. Asegúrate de que todos los cambios cumplan con las reglas PC-IAC
2. Actualiza el CHANGELOG.md
3. Ejecuta `terraform fmt` y `terraform validate`
4. Actualiza la documentación si es necesario

## Licencia

Copyright © 2025 Pragma S.A.

## Soporte

Para soporte o preguntas, contacta al equipo de CloudOps.
