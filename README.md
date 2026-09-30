# Monitores de bateria Keychron y HyperX

Aplicaciones independientes para Windows que muestran el nivel de bateria de dispositivos inalambricos en el area de notificacion.

Autor y propietario: **Red-Rood** (GitHub: CrimsonRood).

## Keychron V1 Max

Los archivos estan en [Keychron/](Keychron/). Ejecuta `Keychron/Iniciar-KeychronBatteryTray.cmd`. La lectura usa el nivel que Windows publica para el dispositivo Bluetooth conectado. El receptor original de 2,4 GHz normalmente no expone la bateria a aplicaciones externas.

No requiere dependencias adicionales; usa Windows PowerShell 5.1.

## HyperX Cloud III Wireless

Los archivos estan en [HyperX/](HyperX/). Ejecuta `HyperX/Instalar-HyperXBatteryTray.cmd` una vez y luego `HyperX/Iniciar-HyperXBatteryTray.cmd`. Mantiene el nivel en la bandeja consultando el receptor USB HID directamente.

Requiere Python 3 y los paquetes `hidapi`, `Pillow` y `pystray`, que instala el script para el usuario actual.

## Propiedad

El codigo se publica para consulta y uso personal. Todos los derechos permanecen reservados por Red-Rood. Consulta [LICENSE](LICENSE) antes de redistribuir, modificar o incorporar el codigo en otro proyecto.
