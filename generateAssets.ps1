$ErrorActionPreference = "Stop"

$AsepriteBin = "aseprite"
$SourceDir = "aseprite"
$OutputDir = "assets"

$sourceRoot = (Resolve-Path $SourceDir).Path

Get-ChildItem -Path $SourceDir -Filter "*.aseprite" -File -Recurse | ForEach-Object {
    $file = $_.FullName

    $relPath = $file.Substring($sourceRoot.Length).TrimStart('\', '/')
    $relNoExt = $relPath -replace '\.aseprite$', ''

    $pngFile = Join-Path $OutputDir "$relNoExt.png"
    $jsonFile = Join-Path $OutputDir "$relNoExt.json"

    $pngDir = Split-Path -Parent $pngFile
    if (-not (Test-Path $pngDir)) {
        New-Item -ItemType Directory -Force -Path $pngDir | Out-Null
    }

    Write-Host "Exporting $file"

    $proc = Start-Process -FilePath $AsepriteBin -ArgumentList @(
        "--batch", "`"$file`"",
        "--sheet", "`"$pngFile`"",
        "--data", "`"$jsonFile`"",
        "--format", "json-array"
    ) -NoNewWindow -Wait -PassThru

    if ($proc.ExitCode -ne 0) {
        throw "aseprite failed on $file with exit code $($proc.ExitCode)"
    }
}

Write-Host "Done."
