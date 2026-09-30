$ErrorActionPreference = 'SilentlyContinue'

Write-Host '=== Keychron / Bluetooth diagnostic ===' -ForegroundColor Cyan
Write-Host "Fecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host ''

$devices = @(Get-PnpDevice -ErrorAction SilentlyContinue | Where-Object {
    $_.FriendlyName -match '(?i)keychron|v1\s*max'
})

if ($devices.Count -eq 0) {
    Write-Host 'No se encontro una entrada PnP con nombre Keychron o V1 Max.' -ForegroundColor Yellow
} else {
    foreach ($device in $devices) {
        Write-Host "Nombre:       $($device.FriendlyName)"
        Write-Host "Estado:       $($device.Status)"
        Write-Host "Clase:        $($device.Class)"
        Write-Host "InstanceId:   $($device.InstanceId)"

        foreach ($key in @(
            'DEVPKEY_Device_IsPresent',
            'DEVPKEY_Device_BatteryLevel',
            'DEVPKEY_Device_Connected',
            '{49CD1F76-5626-4B17-A4E8-18B4AA1A2213} 11',
            '{49CD1F76-5626-4B17-A4E8-18B4AA1A2213} 22',
            '{49CD1F76-5626-4B17-A4E8-18B4AA1A2213} 23',
            '{104EA319-6EE2-4701-BD47-8DDBF425BBE5} 2'
        )) {
            $property = Get-PnpDeviceProperty -InstanceId $device.InstanceId -KeyName $key -ErrorAction SilentlyContinue
            if ($null -ne $property) {
                Write-Host ("  {0}: {1}" -f $key, $property.Data)
            }
        }
        Write-Host ''
    }
}

Write-Host '=== Bluetooth entries marked PresentOnly ===' -ForegroundColor Cyan
$present = @(Get-PnpDevice -Class Bluetooth -PresentOnly -ErrorAction SilentlyContinue | Where-Object {
    $_.FriendlyName -match '(?i)keychron|v1\s*max'
})
if ($present.Count -eq 0) {
    Write-Host 'No hay una entrada Keychron presente segun PnP.' -ForegroundColor Yellow
} else {
    $present | Select-Object Status, FriendlyName, InstanceId | Format-List
}

Write-Host '=== Fin del diagnostico ===' -ForegroundColor Cyan
Read-Host 'Presiona Enter para cerrar'
