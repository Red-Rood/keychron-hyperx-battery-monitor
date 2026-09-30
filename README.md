# Medidores de bateria: Keychron V1 Max y HyperX Cloud III Wireless

Aplicaciones independientes para Windows que muestran el nivel de bateria de cada dispositivo en el area de notificacion.

Autor y propietario: **Red-Rood** (GitHub: CrimsonRood).

## Aceptacion de condiciones

Al descargar, instalar, ejecutar o utilizar cualquiera de los programas de este repositorio, declaras que leiste y aceptas sus condiciones, incluido el deslinde de garantia y responsabilidad indicado en [LICENSE](LICENSE). Si no estas de acuerdo, no descargues, instales ni utilices los programas.

En el primer inicio normal de cada medidor aparece un aviso para aceptar estas condiciones. La respuesta se guarda localmente para el usuario actual de Windows; si se rechaza, el programa se cierra. La lectura de diagnostico no muestra este aviso.

## Keychron V1 Max

Los archivos estan en [Keychron-V1-Max/](Keychron-V1-Max/). Ejecuta `Keychron-V1-Max/Iniciar-KeychronBatteryTray.cmd`. La lectura usa el nivel que Windows publica para el dispositivo Bluetooth conectado. El receptor original de 2,4 GHz normalmente no expone la bateria a aplicaciones externas.

No requiere dependencias adicionales; usa Windows PowerShell 5.1.

## HyperX Cloud III Wireless

Los archivos estan en [HyperX-Cloud-III-Wireless/](HyperX-Cloud-III-Wireless/). Ejecuta `HyperX-Cloud-III-Wireless/Instalar-HyperXBatteryTray.cmd` una vez y luego `HyperX-Cloud-III-Wireless/Iniciar-HyperXBatteryTray.cmd`. El monitor consulta directamente el receptor USB HID.

Requiere Python 3 y los paquetes `hidapi`, `Pillow` y `pystray`, que instala el script para el usuario actual.

## Deslinde de responsabilidad

El software puede contener errores, mostrar un nivel de bateria inexacto o dejar de funcionar. Se proporciona "tal cual", sin garantia de exactitud ni funcionamiento ininterrumpido. Su uso es responsabilidad de quien lo ejecuta. El autor no sera responsable por danos derivados de su uso, en la medida permitida por la ley aplicable. El texto completo esta en [LICENSE](LICENSE).

## Propiedad

El codigo se publica para consulta y uso personal. Todos los derechos permanecen reservados por Red-Rood. Consulta [LICENSE](LICENSE) antes de redistribuir, modificar o incorporar el codigo en otro proyecto.
