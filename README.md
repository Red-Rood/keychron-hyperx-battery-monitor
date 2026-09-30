# Medidores de bateria: Keychron V1 Max y HyperX Cloud III Wireless

Aplicaciones independientes para Windows que muestran el nivel de bateria de cada dispositivo en el area de notificacion.

Autor y propietario: **Red-Rood** (GitHub: CrimsonRood).

## Keychron V1 Max

Los archivos estan en [Keychron-V1-Max/](Keychron-V1-Max/). Ejecuta `Keychron-V1-Max/Iniciar-KeychronBatteryTray.cmd`. La lectura usa el nivel que Windows publica para el dispositivo Bluetooth conectado. El receptor original de 2,4 GHz normalmente no expone la bateria a aplicaciones externas.

No requiere dependencias adicionales; usa Windows PowerShell 5.1.

## HyperX Cloud III Wireless

Los archivos estan en [HyperX-Cloud-III-Wireless/](HyperX-Cloud-III-Wireless/). Ejecuta `HyperX-Cloud-III-Wireless/Instalar-HyperXBatteryTray.cmd` una vez y luego `HyperX-Cloud-III-Wireless/Iniciar-HyperXBatteryTray.cmd`. El monitor consulta directamente el receptor USB HID.

Requiere Python 3 y los paquetes `hidapi`, `Pillow` y `pystray`, que instala el script para el usuario actual.

## Propiedad

El codigo se publica para consulta y uso personal. Todos los derechos permanecen reservados por Red-Rood. Consulta [LICENSE](LICENSE) antes de redistribuir, modificar o incorporar el codigo en otro proyecto.
