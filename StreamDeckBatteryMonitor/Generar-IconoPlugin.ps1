$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$iconDirectory = Join-Path $PSScriptRoot 'com.red-rood.battery-monitor.sdPlugin\imgs'
[System.IO.Directory]::CreateDirectory($iconDirectory) | Out-Null

foreach ($size in @(256, 512)) {
    $scale = $size / 256
    $bitmap = New-Object System.Drawing.Bitmap $size, $size
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.Clear([System.Drawing.Color]::Transparent)

    $background = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(23, 36, 44))
    $outline = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(101, 196, 236)), (12 * $scale)
    $level = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(90, 191, 144))
    $white = New-Object System.Drawing.Pen ([System.Drawing.Color]::White), (14 * $scale)

    $graphics.FillRectangle($background, 18 * $scale, 38 * $scale, 220 * $scale, 180 * $scale)
    $graphics.DrawRectangle($outline, 34 * $scale, 50 * $scale, 184 * $scale, 156 * $scale)
    $graphics.FillRectangle($level, 54 * $scale, 70 * $scale, 110 * $scale, 116 * $scale)
    $graphics.FillRectangle((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(101, 196, 236))), 218 * $scale, 100 * $scale, 20 * $scale, 58 * $scale)
    $graphics.DrawLine($white, 87 * $scale, 128 * $scale, 132 * $scale, 128 * $scale)

    $filename = if ($size -eq 256) { 'plugin.png' } else { 'plugin@2x.png' }
    $bitmap.Save((Join-Path $iconDirectory $filename), [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $bitmap.Dispose()
    $background.Dispose()
    $outline.Dispose()
    $level.Dispose()
    $white.Dispose()
}
