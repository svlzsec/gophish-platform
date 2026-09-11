.PHONY: help setup test test-automation test-authorization check terraform-fmt terraform-validate shell-check yaml-check

UV ?= uv
TERRAFORM ?= terraform
CLIENT ?= acme-corp
TF_DIR := terraform/environments/$(CLIENT)

help: ## Muestra los comandos disponibles.
	@awk 'BEGIN {FS = ":.*## "} /^[a-zA-Z_-]+:.*## / {printf "%-24s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup: ## Instala las dependencias Python de desarrollo desde uv.lock.
	$(UV) sync --project automation --extra dev --locked

test: ## Ejecuta todas las pruebas unitarias sin AWS, Docker ni tráfico HTTP real.
	$(UV) run --project automation --extra dev pytest -q automation/tests scripts/tests

test-automation: ## Ejecuta solamente las pruebas del cliente y servicios Python.
	$(UV) run --project automation --extra dev pytest -q automation/tests

test-authorization: ## Ejecuta solamente las pruebas del gate de autorización.
	$(UV) run --project automation --extra dev pytest -q scripts/tests

terraform-fmt: ## Comprueba el formato de todos los archivos Terraform.
	$(TERRAFORM) fmt -check -recursive terraform

terraform-validate: ## Inicializa sin backend y valida el entorno CLIENT.
	$(TERRAFORM) -chdir=$(TF_DIR) init -backend=false
	$(TERRAFORM) -chdir=$(TF_DIR) validate

shell-check: ## Comprueba la sintaxis de los scripts Bash.
	bash -n scripts/*.sh

yaml-check: ## Comprueba que los YAML del repositorio sean parseables.
	$(UV) run --project automation --extra dev python scripts/check_yaml.py

check: test terraform-fmt terraform-validate shell-check yaml-check ## Ejecuta toda la validación local (Terraform requiere red la primera vez).
