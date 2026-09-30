# Monitor HyperX Cloud III Wireless

Este monitor consulta directamente el receptor USB del `HyperX Cloud III Wireless` mediante HID y muestra el porcentaje en el area de notificacion de Windows. Su icono da prioridad al porcentaje numerico y usa un auricular pequeno a la derecha como identificador del dispositivo. No usa un valor almacenado de Bluetooth ni el ultimo porcentaje conocido.

## Instalacion

1. Tener Python 3 instalado.
2. Ejecutar `Instalar-HyperXBatteryTray.cmd` una sola vez.
3. Ejecutar `Iniciar-HyperXBatteryTray.cmd`.
4. En el menu del icono se puede activar `Iniciar con Windows`.

Dependencias: `hidapi`, `Pillow` y `pystray`. El instalador las agrega solo para el usuario actual.

## Comprobacion

Para hacer una lectura puntual sin abrir la bandeja:

```text
py -3 HyperXBatteryTray.py --probe
```

Debe devolver JSON con `state: "ready"` y `percent` entre 0 y 100. Si no encuentra el receptor, devuelve `state: "unavailable"`.

Si el monitor no detecta el dispositivo, ejecutar `Diagnostico-HyperX.cmd` con el receptor conectado y pegar aqui el resultado. El monitor necesita que el auricular este encendido y asociado a su adaptador USB.

## Nota

El protocolo consultado por el receptor no publica de forma confiable el estado de carga; esta version muestra unicamente el nivel de bateria.
