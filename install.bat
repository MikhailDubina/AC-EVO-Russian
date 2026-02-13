@echo off
chcp 65001 >nul 2>&1
cd /d "%~dp0"
setlocal enabledelayedexpansion
title Assetto Corsa EVO - Russian Localization
echo.
echo ============================================
echo   Assetto Corsa EVO - Russian Localization
echo ============================================
echo.

set "GAME="
set "DEF1=%ProgramFiles(x86)%\Steam\steamapps\common\Assetto Corsa EVO"
set "DEF2=%ProgramFiles%\Steam\steamapps\common\Assetto Corsa EVO"

if exist "%DEF1%\Assetto Corsa EVO.exe" set "GAME=%DEF1%"
if not defined GAME if exist "%DEF2%\Assetto Corsa EVO.exe" set "GAME=%DEF2%"
if not defined GAME for /f "delims=" %%a in ('powershell -NoProfile -Command "$vdf='%ProgramFiles(x86)%\Steam\steamapps\libraryfolders.vdf'; if (Test-Path $vdf) { (Get-Content $vdf -Raw) -split '\"path\"' | Select-Object -Skip 1 | ForEach-Object { if ($_ -match '\s+\"([^\"]+)\"') { $p = $matches[1].Trim().TrimEnd('\\') -replace '\\\\','\\' + '\steamapps\common\Assetto Corsa EVO'; if (Test-Path \"$p\Assetto Corsa EVO.exe\") { Write-Output $p; break } } } }" 2^>nul') do set "GAME=%%a"

if not defined GAME (
  echo Game path not found at default or Steam library locations.
  echo.
  set /p GAME="Enter game folder path (e.g. C:\Steam\steamapps\common\Assetto Corsa EVO): "
  set "GAME=!GAME:"=!"
  if not defined GAME (
    echo.
    echo Path not entered. Exiting.
    echo.
    pause
    exit /b 1
  )
)

set "TGT=%GAME%\uiresources\localization"
if not exist "%TGT%" (
  echo.
  echo ERROR: Folder not found: %TGT%
  echo Check game path.
  echo.
  pause
  exit /b 1
)

set "SRC=%~dp0localization"
if not exist "%SRC%\ru.loc" (
  echo ERROR: Localization files not found in installer folder (localization\ru.loc etc.).
  echo Run install.bat from extracted folder.
  pause
  exit /b 1
)

echo Copying files to:
echo %TGT%
echo.
copy /Y "%SRC%\ru.loc" "%TGT%\"
copy /Y "%SRC%\ru.cars.loc" "%TGT%\"
copy /Y "%SRC%\ru.tooltips.loc" "%TGT%\"
copy /Y "%SRC%\ru.cars.release.loc" "%TGT%\"

echo.
echo Done.
echo.
echo In game, select: Settings - General - Language - Russian.
echo If font shows squares or words break incorrectly,
echo see "Font and line breaks" section in README.
echo.
pause
