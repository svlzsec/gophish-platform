# Arquitectura

Cada workspace crea una VPC, subred, SG, EC2/EIP y DNS exclusivos del cliente. EC2 recupera SecureStrings con su rol en el arranque. EventBridge Scheduler invoca una Lambda que termina la instancia exactamente en `scope_end`, con independencia de CI; Terraform destroy retira después todos los recursos restantes.
