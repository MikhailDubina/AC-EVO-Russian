# Writes script folder path in batch-safe form (no parentheses) to %TEMP%\acevo_scriptroot.txt
# Use 8.3 short path so folders like "AC evo (rus)" don't break batch if exist "!VAR!..."
$safe = $null
try {
  $fso = New-Object -ComObject Scripting.FileSystemObject
  $safe = $fso.GetFolder($PSScriptRoot).ShortPath
} catch { $safe = $null }

# If FSO failed or path still contains ( ) — try cmd (current dir short path)
if (-not $safe -or $safe -match '[()]') {
  try {
    Push-Location $PSScriptRoot
    $short = (cmd /c "for %I in (.) do @echo %~sI").Trim().TrimEnd('\')
    Pop-Location
    if ($short -and $short -notmatch '[()]') { $safe = $short }
  } catch { }
}

# If still has ( ) — try kernel32 GetShortPathName (another way to get 8.3)
if (-not $safe -or $safe -match '[()]') {
  try {
    $sig = '[DllImport("kernel32.dll", CharSet=CharSet.Auto)] public static extern uint GetShortPathName(string path, System.Text.StringBuilder sb, int cap);'
    $t = Add-Type -MemberDefinition $sig -Name ShortPathHelper -PassThru -ErrorAction Stop
    $sb = New-Object System.Text.StringBuilder 500
    $t::GetShortPathName($PSScriptRoot, $sb, 500) | Out-Null
    $short = $sb.ToString().Trim().TrimEnd('\')
    if ($short -and $short -notmatch '[()]') { $safe = $short }
  } catch { }
}

if (-not $safe -or $safe -match '[()]') {
  $safe = $PSScriptRoot -replace '\\Program Files \(x86\)', '\PROGRA~2' -replace '\\Program Files$', '\PROGRA~1'
}

# If path still has brackets (e.g. 8.3 disabled on drive), write marker so batch can show clear error
if ($safe -match '[()]') {
  $safe = 'ERROR_PAREN_PATH'
}

$out = Join-Path $env:TEMP "acevo_scriptroot.txt"
[System.IO.File]::WriteAllText($out, $safe.Trim(), [System.Text.Encoding]::ASCII)
