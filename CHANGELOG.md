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
- Soporte para políticas de permisos de repositorio
- Integración con AWS Organizations
- Soporte para replicación cross-region


