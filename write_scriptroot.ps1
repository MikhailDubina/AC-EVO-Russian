# Writes script folder path in batch-safe form (no parentheses) to %TEMP%\acevo_scriptroot.txt
# Use 8.3 short path so folders like "AC evo (rus)" don't break batch if exist "!VAR!..."
try {
  $fso = New-Object -ComObject Scripting.FileSystemObject
  $safe = $fso.GetFolder($PSScriptRoot).ShortPath
} catch {
  $safe = $PSScriptRoot -replace '\\Program Files \(x86\)', '\PROGRA~2' -replace '\\Program Files$', '\PROGRA~1'
}
$out = Join-Path $env:TEMP "acevo_scriptroot.txt"
[System.IO.File]::WriteAllText($out, $safe.Trim(), [System.Text.Encoding]::ASCII)
