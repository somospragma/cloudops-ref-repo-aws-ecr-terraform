# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-26

### Añadido
- Módulo de referencia completo para AWS ECR
- Soporte para múltiples repositorios mediante `map(object)`
- Cifrado en reposo con AES256 o KMS
- Escaneo de imágenes habilitado por defecto
- Políticas de ciclo de vida configurables
- Nomenclatura estándar según PC-IAC-003
- Validaciones de variables según PC-IAC-002
- Outputs granulares (URLs, ARNs, nombres)
- Directorio `sample/` con ejemplo funcional
- Documentación completa en README.md
- Cumplimiento con 15 reglas PC-IAC

### Características de Seguridad
- Cifrado en reposo por defecto (PC-IAC-020)
- Escaneo de imágenes habilitado por defecto
- Repositorios privados por defecto
- Soporte para KMS customer-managed keys

### Estructura
- Archivos obligatorios según PC-IAC-001 (18 archivos)
- Separación de responsabilidades (locals, variables, outputs)
- Ejemplo funcional en `sample/` siguiendo PC-IAC-026

## [Unreleased]

### Planeado
- Integración con AWS Organizations
- Soporte para replicación cross-region

## [1.2.0] - 2026-04-06

### Changed
- **BREAKING**: Removed `application` variable — naming now uses map key directly
- **BREAKING**: Naming pattern changed from `{client}-{project}-{environment}-ecr-{application}-{functionality}` to `{client}-{project}-{environment}-ecr-{key}`
- Tags cleaned per PC-IAC-004: removed hardcoded `functionality`, `environment`, `application`, `access_class` from resource tags (now come from provider `default_tags` or `additional_tags`)
- `functionality` is now optional (kept for backward compatibility in tfvars but not used in naming)

### Migration Guide
- Remove `application` parameter from module invocation
- Existing ECR repositories will be recreated due to name change
- Move any needed tags (`functionality`, `access_class`) to `additional_tags`

## [1.1.0] - 2025-04-02

### Añadido
- Soporte para `aws_ecr_repository_policy` con control de acceso cross-account y fine-grained
- Campo `repository_policy` en `ecr_config` con principals, actions y conditions
- Output `repository_policy_registry_ids` para repositorios con políticas de acceso
- Ejemplo de uso con política cross-account y condiciones IAM en README.md
- Documentación de decisiones de diseño para políticas de acceso

### Características de Seguridad
- Acciones por defecto limitadas a lectura de imágenes (principio de menor privilegio)
- Soporte para condiciones IAM (e.g., restricción por organización con `aws:PrincipalOrgID`)
- Creación condicional: la política solo se crea cuando se define explícitamente


