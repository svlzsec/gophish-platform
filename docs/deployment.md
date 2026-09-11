# Despliegue y retirada

Configure backend, DNS, parámetros SSM y el environment protegido. Abra un PR para obtener plan y escaneo. Un aprobador lanza Apply dentro de la ventana. Compruebe la programación de Scheduler y la salud del endpoint. Al cierre, Lambda termina EC2; ejecute Destroy para limpiar red, DNS, IAM, parámetros y scheduler, y conserve `lifecycle.log` como auditoría.
