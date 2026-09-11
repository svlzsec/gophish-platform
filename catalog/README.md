# Catálogo de simulaciones

Cada carpeta contiene un correo Gophish en JSON y su landing page HTML asociada. El campo `landing_page_file` conecta ambos artefactos: la automatización crea primero el email y la landing, y referencia sus IDs al crear la campaña. El enlace del correo debe ser siempre `{{.URL}}`; Gophish añade el identificador del destinatario y sirve la landing correspondiente.

El `sending_profile_id` se configura por cliente en `clients/<cliente>/config.yaml`; el catálogo no contiene servidores SMTP ni credenciales.

| Categoría | Correo | Landing | Escenario |
|---|---|---|---|
| Microsoft 365 | `microsoft365/security-awareness.json` | `microsoft365/landing-page.html` | Revisión de actividad |
| RRHH | `rrhh/policy-update.json` | `rrhh/landing-page.html` | Política pendiente |
| VPN | `vpn/access-review.json` | `vpn/landing-page.html` | Revisión de acceso remoto |
| Service Desk | `servicedesk/ticket-update.json` | `servicedesk/landing-page.html` | Actualización de ticket |

## Variables permitidas

Los ejemplos usan variables nativas de Gophish: `{{.FirstName}}`, `{{.Email}}`, `{{.Company}}`, `{{.URL}}`, `{{.TrackingURL}}` y `{{.RId}}`. No sustituya `{{.URL}}` por el dominio fijo de campaña: hacerlo rompe la correlación entre email, destinatario y landing.

## Salvaguardas

Las plantillas son recreaciones ficticias y no contienen logos, CSS ni recursos remotos de terceros. Las landings incluidas no solicitan contraseñas y se crean con `capture_credentials=false` y `capture_passwords=false`. Conserve el aviso de simulación, use únicamente targets incluidos en una autorización vigente y revise texto, idioma y canal de soporte con el cliente antes del lanzamiento.
