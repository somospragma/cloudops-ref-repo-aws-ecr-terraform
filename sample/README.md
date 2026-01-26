# Ejemplo de Uso del Módulo ECR

Este directorio contiene un ejemplo funcional de cómo usar el módulo de referencia de ECR.

## Estructura

El ejemplo sigue el patrón de transformación definido en PC-IAC-026:

```
terraform.tfvars → variables.tf → data.tf → locals.tf → main.tf → ../
```

## Prerrequisitos

- Terraform >= 1.0.0
- AWS CLI configurado con credenciales válidas
- Acceso a una cuenta AWS con permisos para crear repositorios ECR

## Uso

1. Copiar `terraform.tfvars` y ajustar los valores según tu entorno:
   ```bash
   cp terraform.tfvars terraform.tfvars.local
   ```

2. Inicializar Terraform:
   ```bash
   terraform init
   ```

3. Revisar el plan:
   ```bash
   terraform plan
   ```

4. Aplicar la configuración:
   ```bash
   terraform apply
   ```

## Limpieza

Para eliminar los recursos creados:

```bash
terraform destroy
```

## Notas

- Este ejemplo utiliza cifrado AES256 por defecto
- El escaneo de imágenes está habilitado por defecto
- Las políticas de ciclo de vida son opcionales
