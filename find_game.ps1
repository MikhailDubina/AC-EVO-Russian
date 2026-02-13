# Output game folder path safe for batch (no parentheses). Writes to a file so batch does not parse (x86).
function SafePath { param([string]$Path)
    $p = $Path -replace '\\Program Files \\(x86\\)', '\\PROGRA~2' -replace '\\Program Files$', '\\PROGRA~1'
    return $p
}
$outFile = Join-Path $env:TEMP "acevo_gamepath.txt"
$result = ""
$vdf = "${env:ProgramFiles(x86)}\\Steam\\steamapps\\libraryfolders.vdf"
$def1 = "${env:ProgramFiles(x86)}\\Steam\\steamapps\\common\\Assetto Corsa EVO"
$def2 = "${env:ProgramFiles}\\Steam\\steamapps\\common\\Assetto Corsa EVO"
if (Test-Path "$def1\\Assetto Corsa EVO.exe") { $result = SafePath $def1 }
elseif (Test-Path "$def2\\Assetto Corsa EVO.exe") { $result = SafePath $def2 }
elseif (Test-Path $vdf) {
    $content = Get-Content $vdf -Raw
    $parts = $content -split '"path"'
    for ($i = 1; $i -lt $parts.Count; $i++) {
        if ($parts[$i] -match '\\s+"([^"]+)"') {
            $p = $matches[1].Trim().TrimEnd('\\').Replace('\\\\', '\\') + '\\steamapps\\common\\Assetto Corsa EVO'
            if (Test-Path "$p\\Assetto Corsa EVO.exe") { $result = SafePath $p; break }
        }
    }
}
if ($result) { [System.IO.File]::WriteAllText($outFile, $result.Trim(), [System.Text.Encoding]::ASCII) }
else { [System.IO.File]::WriteAllText($outFile, "", [System.Text.Encoding]::ASCII) }
