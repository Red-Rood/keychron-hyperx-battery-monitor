# Stream Deck Battery Monitor

Plugin de Windows para mostrar en el Stream Deck el nivel que publican los medidores de Keychron V1 Max y HyperX Cloud III Wireless.

## Requisitos

- Stream Deck 7.1 o posterior, Node.js 24 para desarrollo y Windows 10 o posterior.
- Tener en ejecucion los medidores correspondientes. Estos publican lecturas en `%LOCALAPPDATA%\Red-Rood\BatteryMonitor`.
- Para HyperX, instalar sus dependencias siguiendo las instrucciones de `../HyperX-Cloud-III-Wireless/README.md`.

El plugin no consulta dispositivos por su cuenta ni transmite datos por la red. Si el medidor no esta activo, el dato falta o tiene mas de tres minutos, la tecla muestra `-- / SIN DATOS`.

## Desarrollo y empaquetado

En Windows, instala Node.js 24 o posterior y ejecuta `Crear-StreamDeckPlugin.cmd`. El paquete `.streamDeckPlugin` generado se instala abriendolo con Stream Deck. Agrega una accion para cada dispositivo.

El codigo del SDK puede compilarse sin un Stream Deck fisico, pero el funcionamiento visual final debe validarse en Stream Deck o Stream Deck Mobile. El plugin necesita que el medidor de cada dispositivo este corriendo para recibir actualizaciones.
