# Medidores de bateria: Keychron V1 Max y HyperX Cloud III Wireless

Herramientas personales para Windows que muestran el nivel de bateria de estos dispositivos en el area de notificacion.

Autor y propietario: **Red-Rood** (GitHub: CrimsonRood).

## Sobre este repositorio

Es un proyecto personal publicado para consulta y transparencia del codigo. Aunque el repositorio es publico, no se ofrece como producto, servicio comercial ni distribucion con soporte. No hay afiliacion con Keychron, HyperX o HP.

## Keychron V1 Max

Los archivos estan en [Keychron-V1-Max/](Keychron-V1-Max/). El medidor lee el nivel que Windows publica para el dispositivo Bluetooth conectado. El receptor original de 2,4 GHz normalmente no expone la bateria a aplicaciones externas.

Ejecuta `Keychron-V1-Max/Iniciar-KeychronBatteryTray.cmd`. No requiere dependencias adicionales; usa Windows PowerShell 5.1.

## HyperX Cloud III Wireless

Los archivos estan en [HyperX-Cloud-III-Wireless/](HyperX-Cloud-III-Wireless/). El monitor consulta directamente el receptor USB HID.

Ejecuta `HyperX-Cloud-III-Wireless/Instalar-HyperXBatteryTray.cmd` una vez y luego `HyperX-Cloud-III-Wireless/Iniciar-HyperXBatteryTray.cmd`. Requiere Python 3 y los paquetes `hidapi`, `Pillow` y `pystray`, que instala el script para el usuario actual.

## Limitaciones

Los medidores pueden mostrar datos inexactos, no detectar el dispositivo o dejar de funcionar. Se proporcionan tal cual, sin promesa de soporte, mantenimiento ni actualizaciones. No los uses como unica referencia para decisiones importantes. El aviso que aparece al iniciar informa de estas limitaciones; no pretende reemplazar asesoramiento juridico ni eliminar responsabilidades que la ley no permita excluir.

## Propiedad

Todos los derechos permanecen reservados por Red-Rood. El repositorio publico permite consultar el codigo, pero no concede una licencia general para redistribuirlo, modificarlo o incorporarlo en otros proyectos. Consulta [LICENSE](LICENSE).

## Stream Deck

El plugin independiente esta en [StreamDeckBatteryMonitor/](StreamDeckBatteryMonitor/). Requiere Stream Deck 7.1 o posterior y Node.js 24 para generar el instalador. Ejecuta `StreamDeckBatteryMonitor/Crear-StreamDeckPlugin.cmd` en Windows y abre el archivo `.streamDeckPlugin` generado.

Para ver niveles actualizados, deja en ejecucion el medidor correspondiente. Ambos publican su lectura localmente en `%LOCALAPPDATA%\Red-Rood\BatteryMonitor`; el plugin no usa red. Agrega las acciones Keychron e HyperX como teclas separadas.
