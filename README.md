# gophish-platform

Plataforma interna para campañas **autorizadas** de concienciación con Gophish. Cada cliente tiene una VPC y un workspace efímeros; la autorización vigente es un gate obligatorio y EventBridge Scheduler apaga la instancia al terminar el alcance.

## Requisitos

Terraform 1.7+, AWS CLI, Python 3.11+, Docker y [`uv`](https://docs.astral.sh/uv/). Elegimos `uv` por sus instalaciones reproducibles y rápidas; el proyecto sigue siendo instalable con cualquier frontend PEP 517.

## Alta de un cliente

1. Copie `clients/acme-corp` y `terraform/environments/acme-corp` usando el identificador nuevo.
2. Complete `authorization.yaml`, conserve el documento firmado fuera del repositorio y configure `terraform.tfvars` (sin secretos).
3. Cree previamente el bucket de state, la tabla de locking, la zona Route53 y los parámetros SecureString. Terraform solo crea marcadores vacíos; cargue sus valores con `aws ssm put-parameter --overwrite`.
4. Configure el environment protegido `production` y los secrets/variables GitHub `AWS_DEPLOY_ROLE_ARN` y `AWS_REGION`. La confianza del rol debe limitar `sub` al workflow/environment del repositorio.
5. Ejecute `python scripts/check_authorization.py --client <cliente>` y abra un PR. Tras revisión, lance el workflow Apply.

Para desarrollo: `cd automation && uv sync --dev && uv run pytest`. El despliegue local deliberadamente no puede obtener el rol CI; `scripts/deploy.sh` exige GitHub Actions/OIDC.

## Operación

`scripts/deploy.sh acme-corp` selecciona el workspace, valida autorización y aplica. `scripts/destroy.sh acme-corp` destruye y audita. La Lambda programada termina EC2 aun si CI deja de funcionar; el destroy posterior limpia el resto. Consulte `docs/` para arquitectura, seguridad y runbooks.
