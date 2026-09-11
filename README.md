# gophish-platform

Plataforma interna para campañas **autorizadas** de concienciación con Gophish. El proyecto convierte una campaña aprobada en un entorno temporal y reproducible: valida el alcance, despliega Gophish en AWS, permite medir clics y resultados de simulación, y apaga la instancia cuando termina la autorización.

No es una herramienta para obtener contraseñas reales. Las campañas deben usar destinatarios autorizados, datos ficticios y landing pages educativas. Los informes deben limitarse a la información necesaria para el ejercicio.

## Qué resuelve

Sin este repositorio habría que crear manualmente la red, la instancia, DNS, permisos, secretos, Gophish y el apagado posterior. La plataforma centraliza ese flujo:

```text
autorización aprobada
        -> Terraform y GitHub Actions
        -> VPC, EC2, DNS, SSM y Gophish temporal
        -> campaña autorizada y métricas
        -> apagado automático en scope_end
        -> destroy y auditoría
```

Terraform crea una VPC, una instancia EC2, una Elastic IP, DNS Route53, parámetros SSM, roles IAM y un EventBridge Scheduler que invoca una Lambda para terminar la instancia al finalizar la ventana autorizada. El paquete Python contiene el cliente REST y servicios para automatizar campañas y reportes.

## Estructura

```text
clients/<cliente>/       Autorización y configuración de campaña
catalog/                  Plantillas de correo y catálogo por temática
automation/               Cliente REST, servicios, modelos y pruebas Python
scripts/                  Gate de autorización, despliegue, destroy y checks
terraform/                Módulos AWS y entornos por cliente
.github/workflows/        Terraform plan y apply con OIDC
docs/                     Arquitectura, despliegue y seguridad
```

La creación automática de landing pages todavía no está conectada al servicio Python. Por ahora se crean desde la interfaz de Gophish; el repositorio automatiza principalmente infraestructura, autorización, cliente REST y reportes.

## Requisitos

- Windows 10/11, macOS o Linux.
- Python 3.11 o superior.
- Terraform 1.7 o superior.
- [`uv`](https://docs.astral.sh/uv/).
- AWS CLI para operaciones AWS.
- Docker solo si se necesita ejecutar servicios localmente; Terraform instala Docker en la instancia EC2.
- Git y acceso al repositorio.

En Windows se pueden instalar `uv` y Terraform con WinGet:

```powershell
winget install --id astral-sh.uv -e
winget install --id Hashicorp.Terraform -e
```

Después de instalar herramientas desde WinGet, cierre y vuelva a abrir VS Code para actualizar el `PATH`:

```powershell
uv --version
terraform version
```

Si `uv` todavía no aparece en una terminal integrada, reinicie completamente VS Code o actualice el `PATH` de esa sesión:

```powershell
$env:Path = [Environment]::GetEnvironmentVariable("Path", "User") + ";" + [Environment]::GetEnvironmentVariable("Path", "Machine")
```

## Preparación local

Desde la raíz del repositorio, `uv` crea `automation/.venv` e instala las versiones fijadas en `uv.lock`:

```powershell
uv sync --project automation --extra dev --locked
```

En Linux/macOS se usan los mismos comandos. El `Makefile` ofrece atajos si GNU Make está instalado, pero no es obligatorio.

## Pruebas Python

Las pruebas no necesitan cuenta AWS, credenciales, Docker ni una instancia de Gophish. Las llamadas HTTP y el destroy se sustituyen por dobles de prueba.

Suite completa:

```powershell
uv run --project automation --extra dev pytest -q automation/tests scripts/tests
```

Resultado esperado actual:

```text
9 passed
```

Pruebas por grupo:

```powershell
uv run --project automation --extra dev pytest -q automation/tests
$env:PYTHONPATH = (Get-Location).Path
uv run --project automation --extra dev pytest -q scripts/tests
```

Prueba individual:

```powershell
uv run --project automation --extra dev pytest -vv scripts/tests/test_authorization.py::test_valid
```

## Validación de Terraform y scripts

Estas comprobaciones son locales y no crean infraestructura:

```powershell
terraform fmt -check -recursive terraform
terraform -chdir=terraform/environments/acme-corp init -backend=false
terraform -chdir=terraform/environments/acme-corp validate
uv run --project automation --extra dev python scripts/check_yaml.py
bash -n scripts/*.sh
git diff --check
```

`init -backend=false` descarga los providers desde `registry.terraform.io`, pero no toca el state remoto. Terraform genera `terraform/environments/acme-corp/.terraform.lock.hcl`; ese archivo debe conservarse y versionarse para fijar las versiones de providers.

El comando equivalente con GNU Make es:

```bash
make check
```

`make check` reúne pruebas Python, formato y validación Terraform, sintaxis Bash y YAML.

## Autorización

Cada cliente tiene un archivo `clients/<cliente>/authorization.yaml` con:

- `scope_start` y `scope_end`: ventana temporal permitida.
- `approved_by`: responsable que aprobó el ejercicio.
- `signed_doc_ref`: referencia al documento firmado, almacenado fuera del repositorio.
- `included_targets` y `excluded_targets`: alcance autorizado.

Comprobar el gate usando la hora real:

```powershell
python scripts/check_authorization.py --client acme-corp
```

El código `0` significa autorizado; cualquier otro código bloquea el despliegue. Puede fallar correctamente cuando la hora actual está fuera de la ventana. No se deben cambiar las fechas solo para conseguir un resultado verde; las pruebas unitarias usan una hora fija para probar esos escenarios.

## Configurar una PoC en Gophish

Después de desplegar Gophish, el flujo mínimo es:

1. Crear un grupo pequeño con destinatarios autorizados.
2. Crear un email template ficticio desde el catálogo o desde la interfaz.
3. Crear una landing page educativa que no solicite ni almacene contraseñas reales.
4. Configurar un sending profile SMTP de prueba.
5. Crear una campaña asociando grupo, email template, landing page y URL.
6. Enviar primero a una cuenta de prueba.
7. Revisar clics y resultados mínimos necesarios.
8. Cerrar la campaña y destruir el entorno al terminar la autorización.

La pantalla de Landing Pages vacía es normal en una instalación nueva. La landing page se configura actualmente desde la interfaz de Gophish; los archivos HTML reutilizables y su creación mediante API son una mejora pendiente.

## Despliegue controlado

No se debe ejecutar `scripts/deploy.sh` desde un equipo local. El script exige GitHub Actions con OIDC y el despliegue se realiza desde el environment protegido `production`.

Flujo recomendado:

1. Crear o actualizar la autorización y la configuración del cliente.
2. Crear una rama distinta de `main`.
3. Ejecutar las validaciones locales.
4. Abrir un Pull Request.
5. Revisar el workflow **Terraform plan** y su plan de cambios.
6. Obtener la aprobación requerida del environment `production`.
7. Ejecutar manualmente **Terraform apply**.
8. Verificar DNS, health check, acceso administrativo y campaña de prueba.

El workflow necesita los secretos o variables `AWS_DEPLOY_ROLE_ARN` y `AWS_REGION`. La confianza del rol debe limitar el `sub` de OIDC al repositorio, workflow y environment esperados.

Antes del primer apply deben existir el bucket de state, la tabla de locking, la zona Route53 y los parámetros SecureString requeridos. Terraform crea marcadores vacíos para los parámetros; sus valores se cargan fuera del repositorio con AWS CLI.

## Alta de un cliente

1. Copiar `clients/acme-corp` y `terraform/environments/acme-corp` con el nuevo identificador.
2. Completar `authorization.yaml` y conservar el documento firmado fuera del repositorio.
3. Configurar `terraform.tfvars` sin secretos.
4. Crear previamente los recursos de backend, DNS y SSM.
5. Revisar el rol OIDC y el environment protegido de GitHub.
6. Ejecutar el gate de autorización y abrir un Pull Request.
7. Revisar el plan y aplicar solo tras la aprobación correspondiente.

## Retirada y seguridad

La Lambda programada termina la instancia aunque CI deje de funcionar. Después, el destroy limpia los recursos restantes:

```bash
scripts/destroy.sh acme-corp
```

Los informes pueden contener datos sensibles y no deben versionarse. Limite su acceso y retención al contrato aplicable. No coloque API keys, contraseñas ni documentos firmados en Git.

Consulte [docs/architecture.md](docs/architecture.md), [docs/deployment.md](docs/deployment.md) y [docs/security.md](docs/security.md) para detalles adicionales.
