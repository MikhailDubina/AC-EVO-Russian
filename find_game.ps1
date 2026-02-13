# Output Assetto Corsa EVO game folder path (one line) or nothing.
$vdf = "${env:ProgramFiles(x86)}\Steam\steamapps\libraryfolders.vdf"
$def1 = "${env:ProgramFiles(x86)}\Steam\steamapps\common\Assetto Corsa EVO"
$def2 = "${env:ProgramFiles}\Steam\steamapps\common\Assetto Corsa EVO"
if (Test-Path "$def1\Assetto Corsa EVO.exe") { Write-Output $def1; exit }
if (Test-Path "$def2\Assetto Corsa EVO.exe") { Write-Output $def2; exit }
if (Test-Path $vdf) {
    $content = Get-Content $vdf -Raw
    $parts = $content -split '"path"'
    for ($i = 1; $i -lt $parts.Count; $i++) {
        if ($parts[$i] -match '\s+"([^"]+)"') {
            $p = $matches[1].Trim().TrimEnd('\').Replace('\\', '\') + '\steamapps\common\Assetto Corsa EVO'
            if (Test-Path "$p\Assetto Corsa EVO.exe") { Write-Output $p; exit }
        }
    }
}
