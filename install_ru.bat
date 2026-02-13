@echo off
if "%~1"=="" (
  start "AC EVO Russian" cmd /k "%~f0" run
  exit /b 0
)
title Assetto Corsa EVO - Russian Localization
chcp 65001 >nul 2>&1
cd /d "%~dp0"
setlocal enabledelayedexpansion
echo.
echo ============================================
echo   Assetto Corsa EVO - Russian Localization
echo   Full Installation (files + menu patch)
echo ============================================
echo.

REM Check if running from correct folder
set "SRC=%~dp0localization"
if not exist "%SRC%\ru.loc" (
  echo ERROR: Localization files not found! Installation stopped.
  echo.
  echo Open this folder in Explorer: %~dp0
  echo Check: there must be a "localization" folder with ru.loc, ru.cars.loc inside.
  echo.
  echo If "localization" is missing or empty:
  echo   - Download the ZIP again from GitHub ^(Code - Download ZIP^)
  echo   - Extract ALL files ^(right-click ZIP - Extract All^)
  echo   - If the folder is on OneDrive: right-click "localization" - "Always keep on this device"
  echo.
  echo Looking for file: %SRC%\ru.loc
  echo.
  pause
  exit /b 1
)

echo Searching for game installation...
set "GAME="
set "DEF1=%ProgramFiles(x86)%\Steam\steamapps\common\Assetto Corsa EVO"
set "DEF2=%ProgramFiles%\Steam\steamapps\common\Assetto Corsa EVO"

if exist "%DEF1%\Assetto Corsa EVO.exe" (
  set "GAME=%DEF1%"
  echo Found at: %GAME%
) else if exist "%DEF2%\Assetto Corsa EVO.exe" (
  set "GAME=%DEF2%"
  echo Found at: %GAME%
) else (
  echo Checking Steam library folders...
  for /f "delims=" %%a in ('powershell -NoProfile -Command "try { $vdf='%ProgramFiles(x86)%\Steam\steamapps\libraryfolders.vdf'; if (Test-Path $vdf) { (Get-Content $vdf -Raw) -split '\"path\"' | Select-Object -Skip 1 | ForEach-Object { if ($_ -match '\s+\"([^\"]+)\"') { $p = $matches[1].Trim().TrimEnd('\\') -replace '\\\\','\\' + '\steamapps\common\Assetto Corsa EVO'; if (Test-Path \"$p\Assetto Corsa EVO.exe\") { Write-Output $p; break } } } } } catch {}" 2^>nul') do (
    set "GAME=%%a"
    echo Found at: !GAME!
  )
)

if not defined GAME (
  echo.
  echo Game not found at default Steam locations.
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
  if not exist "%GAME%\Assetto Corsa EVO.exe" (
    echo.
    echo ERROR: Game executable not found at: %GAME%
    echo Check the path and try again.
    echo.
    pause
    exit /b 1
  )
)

set "TGT=%GAME%\uiresources\localization"
if not exist "%TGT%" (
  echo.
  echo ERROR: Folder not found: %TGT%
  echo Check game path. Make sure this is the correct Assetto Corsa EVO folder.
  echo.
  pause
  exit /b 1
)

echo.
echo [STEP 1/2] Copying localization files...
echo From: %SRC%
echo To: %TGT%
echo.
copy /Y "%SRC%\ru.loc" "%TGT%\" >nul
if errorlevel 1 (
  echo ERROR: Failed to copy ru.loc
  pause
  exit /b 1
)
copy /Y "%SRC%\ru.cars.loc" "%TGT%\" >nul
copy /Y "%SRC%\ru.tooltips.loc" "%TGT%\" >nul
copy /Y "%SRC%\ru.cars.release.loc" "%TGT%\" >nul
echo Localization files copied successfully.
echo.

echo [STEP 2/2] Patching game menu (adding Russian language)...
if not exist "%~dp0patch_ru.ps1" (
  echo WARNING: patch_ru.ps1 not found. Skipping menu patch.
  echo You may need to run patch_ru.bat manually.
  echo.
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0patch_ru.ps1" -GamePath "%GAME%" 2>nul
  if errorlevel 1 (
    echo.
    echo WARNING: Failed to apply menu patch automatically.
    echo Run patch_ru.bat manually after installation.
    echo.
  ) else (
    echo Menu patch applied successfully.
    echo.
  )
)

echo ============================================
echo   Installation Complete!
echo ============================================
echo.
echo In game, select: Settings - General - Language - Russian
echo.
echo If Russian does not appear in the language list, run patch_ru.bat once.
echo.
pause
