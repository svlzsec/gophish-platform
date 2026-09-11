# Despliegue y retirada

Configure backend, DNS, parámetros SSM y el environment protegido. Abra un PR para obtener plan y escaneo. Un aprobador lanza Apply dentro de la ventana. Compruebe la programación de Scheduler y la salud del endpoint. Al cierre, Lambda termina EC2; ejecute Destroy para limpiar red, DNS, IAM, parámetros y scheduler, y conserve `lifecycle.log` como auditoría.

## SES opcional

El módulo `gophish-instance` incluye una integración opt-in con Amazon SES. Con `enable_ses = false` no crea identidad SES ni registros de correo. Para activarla, complete `mail_domain`, `mail_from` y `mail_smtp_port` en el entorno del cliente, confirme que la zona Route53 corresponde al dominio y revise el plan.

Terraform crea la identidad de dominio, el registro TXT de verificación, los tres registros DKIM y un parámetro SSM no secreto con host, puerto, remitente y TLS. Los parámetros `smtp-user` y `smtp-password` se crean como marcadores `PROVISION_EXTERNALLY`; cargue las credenciales SMTP de SES fuera del repositorio:

```bash
aws ssm put-parameter --name /gophish-platform/acme-corp/smtp-user \
	--type SecureString --value '<valor-proporcionado-por-el-equipo-de-correo>' --overwrite
aws ssm put-parameter --name /gophish-platform/acme-corp/smtp-password \
	--type SecureString --value '<valor-proporcionado-por-el-equipo-de-correo>' --overwrite
```

Después de que SES verifique el dominio y el equipo de correo publique SPF, DKIM y DMARC, configure el Sending Profile de Gophish con `email-smtp.<region>.amazonaws.com` y puerto `587` o `465`. La activación no debe hacerse hasta tener destinatarios autorizados, límites de envío y aprobación de la campaña.
