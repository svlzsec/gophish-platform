# gophish-platform

Plataforma interna para campañas **autorizadas** de concienciación con Gophish. Cada cliente tiene una VPC y un workspace efímeros; la autorización vigente es un gate obligatorio y EventBridge Scheduler apaga la instancia al terminar el alcance.

## Requisitos

Terraform 1.7+, AWS CLI, Python 3.11+, Docker y [`uv`](https://docs.astral.sh/uv/). Elegimos `uv` por sus instalaciones reproducibles y rápidas; el proyecto sigue siendo instalable con cualquier frontend PEP 517.

## Primeras pruebas locales

Las pruebas unitarias no necesitan una cuenta AWS, credenciales, Docker ni una instancia de Gophish. Las llamadas HTTP y la ejecución de `destroy.sh` se sustituyen por dobles de prueba.

Desde la raíz del repositorio:

```bash
# Consulte todos los objetivos disponibles.
make help

# Cree automation/.venv e instale exactamente las versiones de uv.lock.
make setup

# Ejecute la suite completa de Python.
make test
```

El resultado esperado actualmente es `12 passed`. Para aislar fallos puede ejecutar:

```bash
make test-authorization  # existencia, campos, ventana vencida y caso válido
make test-automation     # cliente REST, informes y lifecycle
```

También puede ejecutar una sola prueba, con salida detallada:

```bash
uv run --project automation --extra dev pytest -vv \
  scripts/tests/test_authorization.py::test_valid
```

### Comprobaciones estáticas

```bash
make terraform-fmt
make terraform-validate CLIENT=acme-corp
make shell-check
make yaml-check
```

`terraform-validate` usa `-backend=false`: no toca el state remoto ni crea recursos, aunque la primera ejecución necesita acceso a `registry.terraform.io` para descargar providers. `make check` reúne toda la suite local.

### Probar el gate real de autorización

```bash
python scripts/check_authorization.py --client acme-corp
echo $?  # 0 = autorizado; cualquier otro valor = despliegue bloqueado
```

Este comando usa la hora real. Por eso el ejemplo puede fallar legítimamente fuera de `scope_start`/`scope_end`; no cambie las fechas solo para conseguir un resultado verde. Las pruebas unitarias usan una hora fija y son la forma correcta de probar escenarios de ventana sin debilitar el gate.

No use `scripts/deploy.sh` como prueba local: rechaza deliberadamente credenciales locales y solo permite apply desde GitHub Actions con OIDC. Para validar AWS de extremo a extremo, abra un PR, revise el workflow **Terraform plan** y, durante una autorización vigente, ejecute manualmente **Terraform apply** en el environment protegido `production`.

## Alta de un cliente

1. Copie `clients/acme-corp` y `terraform/environments/acme-corp` usando el identificador nuevo.
2. Complete `authorization.yaml`, conserve el documento firmado fuera del repositorio y configure `terraform.tfvars` (sin secretos).
3. Cree previamente el bucket de state, la tabla de locking, la zona Route53 y los parámetros SecureString. Terraform solo crea marcadores vacíos; cargue sus valores con `aws ssm put-parameter --overwrite`.
4. Configure el environment protegido `production` y los secrets/variables GitHub `AWS_DEPLOY_ROLE_ARN` y `AWS_REGION`. La confianza del rol debe limitar `sub` al workflow/environment del repositorio.
5. Ejecute `python scripts/check_authorization.py --client <cliente>` y abra un PR. Tras revisión, lance el workflow Apply.

Para desarrollo también puede trabajar dentro de `automation/` con `uv sync --extra dev --locked` y `uv run pytest ../automation/tests ../scripts/tests`.

## Catálogo de emails y landings

El directorio `catalog/` incluye pares reutilizables para Microsoft 365, RRHH, VPN y Service Desk. Cada JSON de email declara su `landing_page_file`; `launch_campaign` crea ambos recursos en Gophish y enlaza la campaña con sus IDs. Consulte `catalog/README.md` para el inventario, las variables soportadas y las salvaguardas. Las landings de ejemplo no piden contraseñas ni habilitan captura de credenciales.

## Operación

`scripts/deploy.sh acme-corp` selecciona el workspace, valida autorización y aplica. `scripts/destroy.sh acme-corp` destruye y audita. La Lambda programada termina EC2 aun si CI deja de funcionar; el destroy posterior limpia el resto. Consulte `docs/` para arquitectura, seguridad y runbooks.
