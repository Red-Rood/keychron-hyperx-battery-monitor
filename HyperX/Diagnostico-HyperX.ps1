param([switch]$AllHid)

$ErrorActionPreference = 'Continue'
Write-Host '=== HyperX / HID diagnostic ==='
Write-Host "Fecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host ''

Write-Host '=== Dispositivos PnP presentes relacionados ==='
Get-PnpDevice -PresentOnly -ErrorAction SilentlyContinue |
    Where-Object { $_.FriendlyName -match '(?i)hyperx|cloud\s*(ii|iii|3)|headset|auricular' } |
    Select-Object Status, Class, FriendlyName, InstanceId |
    Format-List

Write-Host '=== Hardware IDs relacionados ==='
$devices = Get-PnpDevice -PresentOnly -ErrorAction SilentlyContinue |
    Where-Object { $_.FriendlyName -match '(?i)hyperx|cloud\s*(ii|iii|3)|headset|auricular' }
foreach ($device in $devices) {
    Write-Host "[$($device.FriendlyName)] $($device.InstanceId)"
    Get-PnpDeviceProperty -InstanceId $device.InstanceId -KeyName 'DEVPKEY_Device_HardwareIds' -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Data
}

if ($AllHid) {
    Write-Host '=== Todos los HID presentes ==='
    Get-PnpDevice -Class HIDClass -PresentOnly -ErrorAction SilentlyContinue |
        Select-Object Status, FriendlyName, InstanceId |
        Format-Table -AutoSize
}

Write-Host '=== Fin del diagnostico ==='
Read-Host 'Presiona Enter para cerrar'
