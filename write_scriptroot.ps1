# Writes script folder path in batch-safe form (no parentheses) to %TEMP%\acevo_scriptroot.txt
$safe = $PSScriptRoot -replace '\\Program Files \\(x86\\)', '\\PROGRA~2' -replace '\\Program Files$', '\\PROGRA~1'
$out = Join-Path $env:TEMP "acevo_scriptroot.txt"
[System.IO.File]::WriteAllText($out, $safe.Trim(), [System.Text.Encoding]::ASCII)
