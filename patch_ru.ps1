# Patch Assetto Corsa EVO: components.js (Russian in menu) + optional CSS (font/nowrap).
# Run from the same folder as install.bat, or pass -GamePath "C:\...\Assetto Corsa EVO".

param(
    [string] $GamePath,
    [string] $PackRoot
)

$ErrorActionPreference = "Stop"

function Get-FallbackPath {
    if ($PackRoot -and (Test-Path (Join-Path $PackRoot "fallback\components.js"))) {
        return (Join-Path $PackRoot "fallback\components.js")
    }
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $fp = Join-Path $scriptDir "fallback\components.js"
    if (Test-Path $fp) { return $fp }
    return $null
}

function Add-RussianCssIfNeeded {
    param([string] $GameRoot)
    $cssMarker = "AC-EVO Russian"
    $uiCss = Join-Path $GameRoot "uiresources\css\ui.css"
    $uiCompCss = Join-Path $GameRoot "uiresources\css\uicomponents.css"
    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    $added = $false

    if (Test-Path $uiCss) {
        $txt = [System.IO.File]::ReadAllText($uiCss)
        if ($txt.IndexOf($cssMarker) -lt 0) {
            $block = @"

/* ${cssMarker}: font and nowrap */
@font-face {
  font-family: 'roboto';
  src: url('/fonts/roboto-regular.ttf');
  font-weight: 400;
}
@font-face {
  font-family: 'roboto';
  src: url('/fonts/roboto-medium.ttf');
  font-weight: 500;
}
@font-face {
  font-family: 'roboto';
  src: url('/fonts/roboto-bold.ttf');
  font-weight: 600;
}
html[lang="ru"]:root {
  --font-family-main: 'roboto';
  overflow-wrap: break-word;
}
html[lang="ru"] ks-page-main #panelMenu ks-btnbasic,
html[lang="ru"] ks-page-main #panelMenu ks-btnbasic > div {
  white-space: nowrap;
  overflow-wrap: normal;
  word-break: normal;
}
"@
            [System.IO.File]::AppendAllText($uiCss, $block, $utf8NoBom)
            Write-Host "ui.css: added Russian font and nowrap."
            $added = $true
        }
    }
    if (Test-Path $uiCompCss) {
        $txt = [System.IO.File]::ReadAllText($uiCompCss)
        if ($txt.IndexOf($cssMarker) -lt 0) {
            $block = @"

/* ${cssMarker}: font and nowrap */
html[lang="ru"]:root {
  --font-family-main: 'roboto';
  overflow-wrap: break-word;
}
html[lang="ru"] ks-page-main #panelMenu ks-btnbasic,
html[lang="ru"] ks-page-main #panelMenu ks-btnbasic > div {
  white-space: nowrap;
  overflow-wrap: normal;
  word-break: normal;
}
html[lang="ru"] ks-page-paintshop .paintshop-body .row.controls .categoryselector .category span.label {
  white-space: nowrap;
  overflow-wrap: normal;
  word-break: normal;
}
"@
            [System.IO.File]::AppendAllText($uiCompCss, $block, $utf8NoBom)
            Write-Host "uicomponents.css: added Russian font and nowrap."
            $added = $true
        }
    }
    if (-not $added -and (Test-Path $uiCss)) { Write-Host "CSS: Russian styles already present." }
}

if (-not $GamePath) {
    $def1 = "${env:ProgramFiles(x86)}\Steam\steamapps\common\Assetto Corsa EVO"
    $def2 = "${env:ProgramFiles}\Steam\steamapps\common\Assetto Corsa EVO"
    if (Test-Path "$def1\AssettoCorsaEVO.exe") { $GamePath = $def1 }
    elseif (Test-Path "$def2\AssettoCorsaEVO.exe") { $GamePath = $def2 }
    else {
        Write-Host "Game not found at default paths. Run: .\patch_ru.ps1 -GamePath 'C:\path\to\Assetto Corsa EVO'"
        exit 1
    }
}

$jsPath = Join-Path $GamePath "uiresources\js\components.js"
if (-not (Test-Path $jsPath)) {
    # Try to find components.js under game folder (e.g. after game update path might differ)
    $found = Get-ChildItem -Path $GamePath -Filter "components.js" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) {
        $jsPath = $found.FullName
        Write-Host "Found: $jsPath"
    } else {
        # Fallback: use pre-patched components.js from the pack (for users with missing uiresources\js)
        $fallbackPath = Get-FallbackPath
        if ($fallbackPath) {
            $jsDir = Join-Path $GamePath "uiresources\js"
            if (-not (Test-Path $jsDir)) {
                New-Item -ItemType Directory -Path $jsDir -Force | Out-Null
                Write-Host "Created folder: $jsDir"
            }
            Copy-Item $fallbackPath $jsPath -Force
            Write-Host "Installed components.js from fallback (Russian already in menu)."
            Write-Host "Path: $jsPath"
            Add-RussianCssIfNeeded -GameRoot $GamePath
            exit 0
        }
        Write-Host "ERROR: File not found: $jsPath"
        Write-Host ""
        Write-Host "Without this file the game will not show 'Russian' in the language list."
        Write-Host "Translation files (ru.loc) are already installed; the patch only adds the menu entry."
        Write-Host ""
        Write-Host "If the uiresources folder is empty: In Steam - right-click Assetto Corsa EVO - Manage - Verify integrity of game files. Then run install_ru.bat again."
        Write-Host ""
        exit 1
    }
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
    $content = $content -replace '("cn":\s*"简体中文")\s*,?\r?\n(\s+\};)', "`$1,`n        `"ru`": `"РУССКИЙ`"`n`$2"
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
                        if (el.slider && el.slider.values) el.slider.values = arr;
                    }
                };
                ksUI`$1.waitForFrames(injectRussian, 12);
                ksUI`$1.waitForFrames(injectRussian, 30);
                ksUI`$1.waitForFrames(injectRussian, 60);
                ksUI`$1.waitForFrames(injectRussian, 120);
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
    # Patch 2b: strengthen existing injectRussian — sync inner slider + retries at 60, 120 (if not already)
    if ($content -match 'waitForFrames\(injectRussian, 30\)' -and $content -notmatch 'waitForFrames\(injectRussian, 60\)') {
        $LF = "`n"
        $content = $content.Replace("else if (el.setAttribute) el.setAttribute(""values"", JSON.stringify(arr));$LF                    }$LF                };", "else if (el.setAttribute) el.setAttribute(""values"", JSON.stringify(arr));$LF                        if (el.slider && el.slider.values) el.slider.values = arr;$LF                    }$LF                };")
        if ($content -notmatch 'el\.slider\.values = arr') {
            $content = $content.Replace("else if (el.setAttribute) el.setAttribute(""values"", JSON.stringify(arr));`r`n                    }`r`n                };", "else if (el.setAttribute) el.setAttribute(""values"", JSON.stringify(arr));`r`n                        if (el.slider && el.slider.values) el.slider.values = arr;`r`n                    }`r`n                };")
        }
        $content = $content.Replace("ksUI`$1.waitForFrames(injectRussian, 30);$LF            });", "ksUI`$1.waitForFrames(injectRussian, 30);$LF                ksUI`$1.waitForFrames(injectRussian, 60);$LF                ksUI`$1.waitForFrames(injectRussian, 120);$LF            });")
        if ($content -notmatch 'waitForFrames\(injectRussian, 60\)') {
            $content = $content.Replace("ksUI`$1.waitForFrames(injectRussian, 30);`r`n            });", "ksUI`$1.waitForFrames(injectRussian, 30);`r`n                ksUI`$1.waitForFrames(injectRussian, 60);`r`n                ksUI`$1.waitForFrames(injectRussian, 120);`r`n            });")
        }
        if ($content -match 'waitForFrames\(injectRussian, 60\)') { $modified = $true; Write-Host "Patch 2b OK: strengthened injectRussian (retries 60,120 + inner slider sync)." }
    }
}

# Patch 3: add data-tooltip to settings tiles (CONTROLS, VIDEO, AUDIO) for Russian tooltips
if ($content -notmatch 'data-tooltip=\"tooltipSettingsControls\"') {
    $content = $content -replace 'data-submode=\"controls\" data-l10n-id=\"settingsControls\">CONTROLS', 'data-submode=\"controls\" data-l10n-id=\"settingsControls\" data-tooltip=\"tooltipSettingsControls\">CONTROLS'
    $content = $content -replace 'data-submode=\"video\" data-l10n-id=\"settingsVideo\">VIDEO', 'data-submode=\"video\" data-l10n-id=\"settingsVideo\" data-tooltip=\"tooltipSettingsVideo\">VIDEO'
    $content = $content -replace 'data-submode=\"audio\" data-l10n-id=\"settingsAudio\">AUDIO', 'data-submode=\"audio\" data-l10n-id=\"settingsAudio\" data-tooltip=\"tooltipSettingsAudio\">AUDIO'
    if ($content -match 'data-tooltip=\"tooltipSettingsControls\"') {
        $modified = $true
        Write-Host "Patch 3 OK: added tooltips for Controls/Video/Audio tiles."
    } else {
        Write-Host "Patch 3 failed: could not find settings tiles. File may have changed."
    }
} else {
    Write-Host "Patch 3 skipped: settings tile tooltips already present."
}

# Patch 4: add "ru" to language slider values in Settings template (so Russian appears in dropdown)
$patch4Done = $false
# Try exact replace (template has escaped quotes: values='[\"en\", ...]')
$langValuesOld = "values='[\`"en\`", \`"es\`", \`"de\`", \`"fr\`", \`"it\`", \`"cn\`"]'"
$langValuesNew = "values='[\`"en\`", \`"es\`", \`"de\`", \`"fr\`", \`"it\`", \`"cn\`", \`"ru\`"]'"
if ($content.IndexOf($langValuesNew) -ge 0) {
    Write-Host "Patch 4 skipped: language slider already has Russian."
    $patch4Done = $true
} elseif ($content.IndexOf($langValuesOld) -ge 0) {
    $content = $content.Replace($langValuesOld, $langValuesNew)
    $modified = $true
    $patch4Done = $true
    Write-Host "Patch 4 OK: added Russian to language slider template."
}
# Fallback: regex — find sliderLanguage values='[...]' and add , "ru" before ] if ru missing (any order/spacing)
if (-not $patch4Done -and $content -match 'sliderLanguage') {
    $ruInSlider = $content -match 'sliderLanguage[^>]*values=''[^'']*\bru\b'
    if (-not $ruInSlider) {
        $pattern = "(id=\\\\`"sliderLanguage\\\\`"[^>]*values='\\\\[)([^\]]*)(\\\\]')"
        $m = [regex]::Match($content, $pattern)
        if ($m.Success) {
            $content = $content.Remove($m.Index, $m.Length).Insert($m.Index, $m.Groups[1].Value + $m.Groups[2].Value + ", \\`"ru\\`"" + $m.Groups[3].Value)
            $modified = $true
            Write-Host "Patch 4 OK: added Russian to language slider (regex fallback)."
            $patch4Done = $true
        }
    }
}
if (-not $patch4Done -and $content.IndexOf('sliderLanguage') -ge 0) {
    Write-Host "Patch 4 skipped: language slider values not found or already include 'ru'."
}

if ($modified) {
    [System.IO.File]::WriteAllText($jsPath, $content, [System.Text.UTF8Encoding]::new($false))
    Write-Host "components.js patched. Start the game and choose Russian in Settings -> General -> Language."
} else {
    Write-Host "No changes needed."
}

# If Russian still not in file (patch failed e.g. game update), overwrite with fallback so language appears
$hasRussianInList = $content.IndexOf('"ru": "РУССКИЙ"') -ge 0
$hasRuInSlider = $content -match "sliderLanguage[^>]*values='[^']*\\`"ru\\`""
$hasRussian = $hasRussianInList -or $hasRuInSlider
if (-not $hasRussian) {
    $fallbackPath = Get-FallbackPath
    if ($fallbackPath) {
        if (-not (Test-Path ($jsPath + ".bak"))) {
            Copy-Item $jsPath ($jsPath + ".bak") -Force
            Write-Host "Backup created: $jsPath.bak"
        }
        Copy-Item $fallbackPath $jsPath -Force
        Write-Host "Patch did not match game version. Installed fallback components.js (Russian in menu)."
    }
}

Add-RussianCssIfNeeded -GameRoot $GamePath
