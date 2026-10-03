# Copyright (c) 2026 Red-Rood (GitHub: CrimsonRood). All rights reserved.
# Keychron V1 Max battery indicator for the Windows notification area.
# Run with Windows PowerShell 5.1 (powershell.exe), not PowerShell 7.

param([switch]$ProbeOnly)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Get-BatterySnapshot {
    try {
        # PresentOnly avoids showing the last cached value of a paired but disconnected device.
        $devices = @(Get-PnpDevice -Class Bluetooth -PresentOnly -ErrorAction SilentlyContinue)
        $devices = @($devices | Where-Object { $_.Status -eq 'OK' -and $_.FriendlyName -match '(?i)keychron|v1\s*max' })
        $candidates = @()

        foreach ($device in $devices) {
            $name = $device.FriendlyName
            if ($name -notmatch '(?i)keychron|v1\s*max') { continue }

            foreach ($keyName in @('DEVPKEY_Device_BatteryLevel', '{104EA319-6EE2-4701-BD47-8DDBF425BBE5} 2')) {
                try {
                    $property = Get-PnpDeviceProperty -InstanceId $device.InstanceId -KeyName $keyName -ErrorAction Stop
                    if ($null -ne $property.Data -and "$($property.Data)" -match '^\d+$') {
                        $percent = [math]::Max(0, [math]::Min(100, [int]$property.Data))
                        $candidates += [pscustomobject]@{ Name = $name; Percent = [int]$percent; Priority = 0 }
                        break
                    }
                } catch {
                    # The property name varies across Windows Bluetooth drivers.
                }
            }
        }

        if ($candidates.Count -eq 0) {
            $receiver = @(Get-PnpDevice -PresentOnly -ErrorAction SilentlyContinue | Where-Object {
                $_.InstanceId -match '(?i)VID_3434&PID_D0(30|31)'
            })
            if ($receiver.Count -gt 0) {
                return [pscustomobject]@{ State = 'DongleNoBattery'; Name = 'Receptor Keychron 2,4 GHz'; Percent = $null }
            }
            return [pscustomobject]@{ State = 'Unavailable'; Name = ''; Percent = $null }
        }

        $chosen = $candidates | Sort-Object Priority, Name | Select-Object -First 1
        return [pscustomobject]@{ State = 'Ready'; Name = $chosen.Name; Percent = $chosen.Percent }
    } catch {
        return [pscustomobject]@{ State = 'Error'; Name = ''; Percent = $null }
    }
}

if ($ProbeOnly) {
    Get-BatterySnapshot | ConvertTo-Json -Compress
    exit 0
}


$noticePath = 'Software\Red-Rood\KeychronV1MaxBatteryTray'
$noticeSeen = $false
try {
    $noticeKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($noticePath)
    if ($null -ne $noticeKey) {
        $noticeSeen = ($noticeKey.GetValue('NoticeVersion', 0) -eq 2)
        $noticeKey.Dispose()
    }
} catch {
    # If registry access fails, show the notice again next time.
}

if (-not $noticeSeen) {
    $message = "PROYECTO PERSONAL`r`n`r`nCreado para uso propio. Que el repositorio sea publico no significa que este programa se ofrezca como producto o servicio. No es oficial ni cuenta con soporte. Puede mostrar datos incorrectos o dejar de funcionar. No lo uses como unica referencia para decisiones importantes. No se prometen actualizaciones.`r`n`r`nPulsa Aceptar para continuar."
    $answer = [System.Windows.Forms.MessageBox]::Show(
        $message,
        'Aviso - Keychron V1 Max',
        [System.Windows.Forms.MessageBoxButtons]::OKCancel,
        [System.Windows.Forms.MessageBoxIcon]::Information,
        [System.Windows.Forms.MessageBoxDefaultButton]::Button2
    )
    if ($answer -ne [System.Windows.Forms.DialogResult]::OK) { exit 0 }
    try {
        $noticeKey = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($noticePath)
        $noticeKey.SetValue('NoticeVersion', 2, [Microsoft.Win32.RegistryValueKind]::DWord)
        $noticeKey.Dispose()
    } catch {
        # The app can still run; the notice will appear again next time.
    }
}

function New-TrayIcon {
    param([int]$Percent)
    $bitmap = New-Object System.Drawing.Bitmap 32, 32
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.Clear([System.Drawing.Color]::Transparent)
    $outline = New-Object System.Drawing.Pen ([System.Drawing.Color]::White), 2
    $graphics.DrawRectangle($outline, 4, 8, 22, 16)
    $graphics.FillRectangle((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)), 26, 13, 3, 6)
    $fillColor = if ($Percent -le 20) { [System.Drawing.Color]::Tomato } elseif ($Percent -le 50) { [System.Drawing.Color]::Gold } else { [System.Drawing.Color]::LimeGreen }
    $fillWidth = [math]::Max(1, [math]::Floor(18 * $Percent / 100))
    $graphics.FillRectangle((New-Object System.Drawing.SolidBrush $fillColor), 6, 10, $fillWidth, 12)
    $icon = [System.Drawing.Icon]::FromHandle($bitmap.GetHicon())
    $graphics.Dispose()
    $outline.Dispose()
    return $icon
}

function Set-StartupEnabled {
    param([bool]$Enabled)
    $runKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Software\Microsoft\Windows\CurrentVersion\Run', $true)
    if ($Enabled) {
        $scriptPath = (Resolve-Path $PSCommandPath).Path
        $command = "powershell.exe -NoLogo -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`""
        $runKey.SetValue('KeychronBatteryTray', $command)
    } else {
        $runKey.DeleteValue('KeychronBatteryTray', $false)
    }
    $runKey.Dispose()
}

function Test-StartupEnabled {
    $runKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Software\Microsoft\Windows\CurrentVersion\Run', $false)
    $value = $runKey.GetValue('KeychronBatteryTray', $null)
    $runKey.Dispose()
    return $null -ne $value
}

function Publish-BatterySnapshot {
    param($Snapshot)
    try {
        $directory = Join-Path $env:LOCALAPPDATA 'Red-Rood\BatteryMonitor'
        [System.IO.Directory]::CreateDirectory($directory) | Out-Null
        $payload = [ordered]@{
            state = [string]$Snapshot.State
            name = [string]$Snapshot.Name
            percent = $Snapshot.Percent
            updatedAtUtc = [DateTime]::UtcNow.ToString('o')
        }
        $target = Join-Path $directory 'keychron.json'
        $temporary = "$target.tmp"
        [System.IO.File]::WriteAllText($temporary, ($payload | ConvertTo-Json -Compress), [System.Text.UTF8Encoding]::new($false))
        Move-Item -LiteralPath $temporary -Destination $target -Force
    } catch {
        # Battery display remains usable if publishing for Stream Deck fails.
    }
}

$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$notifyIcon.Visible = $true
$notifyIcon.Text = 'Keychron: buscando bateria...'
$notifyIcon.Icon = [System.Drawing.SystemIcons]::Information

$menu = New-Object System.Windows.Forms.ContextMenuStrip
$statusItem = $menu.Items.Add('Keychron: buscando bateria...')
$statusItem.Enabled = $false
$menu.Items.Add('-') | Out-Null
$refreshItem = $menu.Items.Add('Actualizar ahora')
$startupItem = $menu.Items.Add('Iniciar con Windows')
$startupItem.CheckOnClick = $true
$startupItem.Checked = Test-StartupEnabled
$menu.Items.Add('-') | Out-Null
$exitItem = $menu.Items.Add('Salir')
$notifyIcon.ContextMenuStrip = $menu

$update = {
    $snapshot = Get-BatterySnapshot
    Publish-BatterySnapshot -Snapshot $snapshot
    if ($snapshot.State -eq 'Ready') {
        $label = "Keychron: $($snapshot.Percent)%"
        $notifyIcon.Text = "$label - $($snapshot.Name)"
        $newIcon = New-TrayIcon -Percent $snapshot.Percent
        $oldIcon = $notifyIcon.Icon
        $notifyIcon.Icon = $newIcon
        if ($null -ne $oldIcon -and $oldIcon -ne [System.Drawing.SystemIcons]::Information) { $oldIcon.Dispose() }
        $statusItem.Text = "$($snapshot.Name): $($snapshot.Percent)%"
    } elseif ($snapshot.State -eq 'DongleNoBattery') {
        $notifyIcon.Text = 'Keychron: 2,4 GHz no expone bateria'
        $notifyIcon.Icon = [System.Drawing.SystemIcons]::Warning
        $statusItem.Text = 'El firmware no expone bateria por el receptor 2,4 GHz'
    } else {
        $notifyIcon.Text = 'Keychron: bateria no disponible'
        $notifyIcon.Icon = [System.Drawing.SystemIcons]::Information
        $statusItem.Text = 'No se encontro un nivel de bateria legible'
    }
}

$refreshItem.Add_Click($update)
$startupItem.Add_Click({ Set-StartupEnabled -Enabled $startupItem.Checked })
$exitItem.Add_Click({ $notifyIcon.Visible = $false; $applicationContext.ExitThread() })

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 60000
$timer.Add_Tick($update)
$timer.Start()

$applicationContext = New-Object System.Windows.Forms.ApplicationContext
& $update
[System.Windows.Forms.Application]::Run($applicationContext)

$timer.Stop()
$timer.Dispose()
$notifyIcon.Dispose()
$menu.Dispose()
