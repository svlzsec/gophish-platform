# Seguridad

La autorización contractual es obligatoria y valida identidad, campos y ventana. El listener público solo usa 443; 3333 requiere allowlist. Secretos reales se cargan fuera de Terraform y se resuelven en runtime. El rol de despliegue solo confía en tokens OIDC del repositorio asociados al environment protegido `production`; no hay usuarios IAM ni claves locales.

Los informes contienen datos sensibles y no deben versionarse. Limite su acceso, retención y tratamiento al contrato aplicable.
