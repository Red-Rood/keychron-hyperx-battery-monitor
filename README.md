# Keychron + HyperX Battery Monitor

Aplicaciones para Windows que muestran el nivel de bateria de dispositivos inalambricos en el area de notificacion.

Autor y propietario: **Red-Rood** (`CrimsonRood` en GitHub).

## Keychron V1 Max

Ejecutar `Iniciar-KeychronBatteryTray.cmd`. La utilidad usa la propiedad de bateria que Windows publica para el dispositivo Bluetooth conectado. El receptor 2,4 GHz original normalmente no expone ese nivel a aplicaciones externas.

No requiere dependencias adicionales: usa Windows PowerShell 5.1.

## HyperX Cloud III Wireless

1. Ejecutar `Instalar-HyperXBatteryTray.cmd` una sola vez.
2. Ejecutar `Iniciar-HyperXBatteryTray.cmd`.
3. Mantener encendidos los auriculares y conectado el receptor USB.

El monitor consulta directamente el receptor HID y muestra el porcentaje en la bandeja. Requiere `hidapi`, `Pillow` y `pystray`, que instala el script para el usuario actual.

## Propiedad

El codigo se publica en un repositorio publico para consulta y uso personal. Todos los derechos permanecen reservados por Red-Rood. Consulta `LICENSE` antes de redistribuir, modificar o incorporar el codigo en otro proyecto.
