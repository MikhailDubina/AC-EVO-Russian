# Patch Assetto Corsa EVO components.js to add Russian to the language list.
# Run from the same folder as install.bat, or pass -GamePath "C:\...\Assetto Corsa EVO".

param(
    [string] $GamePath
)

$ErrorActionPreference = "Stop"

if (-not $GamePath) {
    $def1 = "${env:ProgramFiles(x86)}\\Steam\\steamapps\\common\\Assetto Corsa EVO"
    $def2 = "${env:ProgramFiles}\\Steam\\steamapps\\common\\Assetto Corsa EVO"
    if (Test-Path "$def1\\AssettoCorsaEVO.exe") { $GamePath = $def1 }
    elseif (Test-Path "$def2\\AssettoCorsaEVO.exe") { $GamePath = $def2 }
    else {
        Write-Host "Game not found at default paths. Run: .\\patch_ru.ps1 -GamePath 'C:\\path\\to\\Assetto Corsa EVO'"
        exit 1
    }
}

$jsPath = Join-Path $GamePath "uiresources\\js\\components.js"
if (-not (Test-Path $jsPath)) {
    Write-Host "ERROR: File not found: $jsPath"
    exit 1
}

$bakPath = $jsPath + ".bak"
if (-not (Test-Path $bakPath)) {
    Copy-Item $jsPath $bakPath -Force
    Write-Host "Backup created: $bakPath"
}

$content = Get-Content $jsPath -Raw -Encoding UTF8
$modified = $false

# Patch 1: add "ru": "РУССКИЙ" to languages object (if missing)
if ($content.IndexOf('"ru": "РУССКИЙ"') -lt 0) {
    $content = $content -replace '("cn":\\s*"简体中文")\\r?\\n(\\s+\\};)', "`$1,`n        `"ru`": `"РУССКИЙ`"`n`$2"
    if ($content.IndexOf('"ru": "РУССКИЙ"') -ge 0) {
        $modified = $true
        Write-Host "Patch 1 OK: added Russian to languages list."
    } else {
        Write-Host "Patch 1 failed: could not find the languages block. File may have changed."
    }
} else {
    Write-Host "Patch 1 skipped: Russian already in languages list."
}

# Patch 2: add injectRussian so the in-game settings slider shows "Русский" (if missing)
if ($content -notmatch 'injectRussian') {
    $assignLine = '                ksUI$1.assignModel(response.personal_settings, "GameplaySettings");'
    $closeLine = '            });'
    $oldBlock = $assignLine + "`n" + $closeLine
    $newBlock = @"
                ksUI`$1.assignModel(response.personal_settings, "GameplaySettings");
                const injectRussian = () => {
                    const el = this.sliderLanguage;
                    if (!el) return;
                    let arr = el.valuesArray;
                    if (!arr && el.slider && el.slider._values) arr = el.slider._values;
                    if (!arr && el.hasAttribute && el.getAttribute("values")) try { arr = JSON.parse(el.getAttribute("values")); } catch (e) {}
                    if (Array.isArray(arr) && arr.length && !arr.includes("ru")) {
                        arr = [...arr, "ru"];
                        if (typeof el.values !== "undefined") el.values = JSON.stringify(arr);
                        else if (el.setAttribute) el.setAttribute("values", JSON.stringify(arr));
                    }
                };
                ksUI`$1.waitForFrames(injectRussian, 12);
                ksUI`$1.waitForFrames(injectRussian, 30);
            });
"@
    $content = $content.Replace($oldBlock, $newBlock)
    if ($content.IndexOf('injectRussian') -ge 0) {
        $modified = $true
        Write-Host "Patch 2 OK: added Russian to in-game language selector."
    } else {
        Write-Host "Patch 2 failed: could not find the PersonalSettings callback. File may have changed."
    }
} else {
    Write-Host "Patch 2 skipped: injectRussian already present."
}

if ($modified) {
    [System.IO.File]::WriteAllText($jsPath, $content, [System.Text.UTF8Encoding]::new($false))
    Write-Host "components.js patched. Start the game and choose Russian in Settings -> General -> Language."
} else {
    Write-Host "No changes needed."
}
