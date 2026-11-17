# Usage: powershell -ExecutionPolicy Bypass -File scripts/stitch-screenshots.ps1 [-Columns auto|1|2|3]
#            [-ScreenHeight PIXELS] [-Gap PIXELS] -Header TEXT -Footer TEXT -Out OUT.png IN1.png[=caption] IN2.png[=caption] ...
#
# The Windows twin of scripts/stitch-screenshots.swift (same layout, same look; AGENTS.md, "Screenshots of builds and
# CI/CD" and "Stitched screenshots: layout, header and footer"). Every screenshot committed to docs/assets goes through
# one of the two, even a single image. Layout: -Columns auto (the default) stacks the images in one column over several
# rows and switches to two columns when that column would be taller than one phone screen (-ScreenHeight, by default
# the cell width x 19.5 / 9); 1, 2 or 3 force a layout. The header (above every image) and the footer (below every
# image) have bands of their own and never overlap a screenshot; each "=caption" gets its own band above its image.
# Text is bold, red (#FF3B30) for the header and the captions, dark gray for the footer, on white; "\n" starts a new
# line and long lines wrap. Images keep their pixels: every cell has the width of the narrowest image, nothing is
# enlarged. The PNG gets a tEXt chunk "Description" = "CYL header: <header> | CYL footer: <footer>", which
# scripts/check-screenshot-labels.sh looks for. Windows PowerShell 5.1 or later (System.Drawing).
[CmdletBinding(PositionalBinding = $false)]
param(
    [string]$Columns = 'auto',
    [int]$ScreenHeight = 0,
    [int]$Gap = 16,
    [Parameter(Mandatory = $true)][string]$Header,
    [Parameter(Mandatory = $true)][string]$Footer,
    [Parameter(Mandatory = $true)][string]$Out,
    [Parameter(Mandatory = $true, Position = 0, ValueFromRemainingArguments = $true)][string[]]$Inputs
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$Header = $Header -replace '\\n', "`n"
$Footer = $Footer -replace '\\n', "`n"

# "path=caption": the caption is everything after the first "=" that follows the file extension.
$items = foreach ($argument in $Inputs) {
    if ($argument -match '^(.+?\.(png|jpe?g|bmp|gif))=(.*)$') {
        [pscustomobject]@{ Path = $Matches[1]; Caption = $Matches[3] }
    } else {
        [pscustomobject]@{ Path = $argument; Caption = $null }
    }
}
$images = foreach ($item in $items) {
    if (-not (Test-Path -LiteralPath $item.Path)) { throw "cannot read $($item.Path)" }
    [System.Drawing.Image]::FromFile((Resolve-Path -LiteralPath $item.Path).Path)
}
$cellWidth = ($images | ForEach-Object { $_.Width } | Measure-Object -Minimum).Minimum
$heights = @($images | ForEach-Object { [int][Math]::Round($_.Height * $cellWidth / $_.Width) })
$fontSize = [Math]::Max(22.0, $cellWidth * 0.03)
$font = New-Object System.Drawing.Font('Arial', [single]$fontSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$red = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 59, 48))
$gray = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 64, 64, 69))
$measure = [System.Drawing.Graphics]::FromImage((New-Object System.Drawing.Bitmap 1, 1))
function Measure-Text([string]$text, [int]$width) {
    if (-not $text) { return 0 }
    [int][Math]::Ceiling($measure.MeasureString($text, $font, $width).Height)
}

function Get-Layout([int]$count) {
    $rows = [Math]::Ceiling($images.Count / $count)
    $rowHeights = @(); $captionHeights = @()
    for ($r = 0; $r -lt $rows; $r++) {
        $indexes = @(($r * $count)..([Math]::Min($images.Count, ($r + 1) * $count) - 1))
        $rowHeights += ($indexes | ForEach-Object { $heights[$_] } | Measure-Object -Maximum).Maximum
        $captionHeights += [int](($indexes | ForEach-Object { Measure-Text $items[$_].Caption $cellWidth } | Measure-Object -Maximum).Maximum)
    }
    $content = 0
    for ($r = 0; $r -lt $rows; $r++) {
        $content += $rowHeights[$r] + $(if ($captionHeights[$r] -gt 0) { $captionHeights[$r] + [int]($Gap / 2) } else { 0 }) + $Gap
    }
    [pscustomobject]@{ Columns = $count; Width = $count * $cellWidth + ($count + 1) * $Gap; RowHeights = $rowHeights; CaptionHeights = $captionHeights; Content = $content }
}

if ($Columns -eq 'auto') {
    $screen = if ($ScreenHeight -gt 0) { $ScreenHeight } else { [int]($cellWidth * 19.5 / 9) }
    $one = Get-Layout 1
    $layout = if ($images.Count -gt 1 -and $one.Content -gt $screen) { Get-Layout 2 } else { $one }
} else {
    $layout = Get-Layout ([Math]::Max(1, [Math]::Min(3, [int]$Columns)))
}
$textWidth = $layout.Width - 2 * $Gap
$headerHeight = Measure-Text $Header $textWidth
$footerHeight = Measure-Text $Footer $textWidth
$height = $Gap + ($headerHeight + $Gap) + $layout.Content + ($footerHeight + $Gap)

$bitmap = New-Object System.Drawing.Bitmap ([int]$layout.Width), ([int]$height)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.Clear([System.Drawing.Color]::White)
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$top = $Gap
$graphics.DrawString($Header, $font, $red, (New-Object System.Drawing.RectangleF $Gap, $top, $textWidth, $headerHeight))
$top += $headerHeight + $Gap
for ($r = 0; $r -lt $layout.RowHeights.Count; $r++) {
    $captionHeight = $layout.CaptionHeights[$r]
    for ($c = 0; $c -lt $layout.Columns; $c++) {
        $i = $r * $layout.Columns + $c
        if ($i -ge $images.Count) { break }
        $x = $Gap + $c * ($cellWidth + $Gap)
        if ($items[$i].Caption) {
            $graphics.DrawString($items[$i].Caption, $font, $red, (New-Object System.Drawing.RectangleF $x, $top, $cellWidth, $captionHeight))
        }
        $imageTop = $top + $(if ($captionHeight -gt 0) { $captionHeight + [int]($Gap / 2) } else { 0 })
        $graphics.DrawImage($images[$i], $x, $imageTop, $cellWidth, $heights[$i])
    }
    $top += $(if ($captionHeight -gt 0) { $captionHeight + [int]($Gap / 2) } else { 0 }) + $layout.RowHeights[$r] + $Gap
}
$graphics.DrawString($Footer, $font, $gray, (New-Object System.Drawing.RectangleF $Gap, $top, $textWidth, $footerHeight))
$graphics.Dispose()
$images | ForEach-Object { $_.Dispose() }

$stream = New-Object System.IO.MemoryStream
$bitmap.Save($stream, [System.Drawing.Imaging.ImageFormat]::Png)
$bitmap.Dispose()
$png = $stream.ToArray()

# tEXt chunk before IEND: length, "tEXt", "Description" NUL text, CRC-32 of type + data.
$crcTable = New-Object 'uint32[]' 256
for ($n = 0; $n -lt 256; $n++) {
    $c = [uint32]$n
    for ($k = 0; $k -lt 8; $k++) { if ($c -band 1) { $c = [uint32]([uint32]3988292384 -bxor ($c -shr 1)) } else { $c = [uint32]($c -shr 1) } }
    $crcTable[$n] = $c
}
$text = 'CYL header: ' + ($Header -replace "`n", ' ') + ' | CYL footer: ' + ($Footer -replace "`n", ' ')
$latin1 = [System.Text.Encoding]::GetEncoding(28591)
$body = [byte[]]([System.Text.Encoding]::ASCII.GetBytes('tEXt') + $latin1.GetBytes('Description') + [byte[]](0) + $latin1.GetBytes($text))
$crc = [uint32]::MaxValue
foreach ($b in $body) { $crc = [uint32]($crcTable[($crc -bxor $b) -band 0xFF] -bxor ($crc -shr 8)) }
$crc = [uint32]($crc -bxor [uint32]::MaxValue)
function Get-BigEndian([uint32]$value) { $bytes = [BitConverter]::GetBytes($value); [Array]::Reverse($bytes); $bytes }
$chunk = [byte[]]((Get-BigEndian ([uint32]($body.Length - 4))) + $body + (Get-BigEndian $crc))
$iend = $png.Length - 12
$result = [byte[]]($png[0..($iend - 1)] + $chunk + $png[$iend..($png.Length - 1)])
$outPath = [System.IO.Path]::GetFullPath($Out)
[System.IO.File]::WriteAllBytes($outPath, $result)
"${Out}: $($layout.Columns) column(s), $($layout.Width)x$height px"
