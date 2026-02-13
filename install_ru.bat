@echo off
chcp 65001 >nul 2>&1
cd /d "%~dp0"
setlocal enabledelayedexpansion
title Assetto Corsa EVO - Russian Localization
echo.
echo ============================================
echo   Assetto Corsa EVO - Russian Localization
echo   Full Installation (files + menu patch)
echo ============================================
echo.

set "GAME="
set "DEF1=%ProgramFiles(x86)%\Steam\steamapps\common\Assetto Corsa EVO"
set "DEF2=%ProgramFiles%\Steam\steamapps\common\Assetto Corsa EVO"

if exist "%DEF1%\Assetto Corsa EVO.exe" set "GAME=%DEF1%"
if not defined GAME if exist "%DEF2%\Assetto Corsa EVO.exe" set "GAME=%DEF2%"

if not defined GAME (
  echo Game path not found at default location.
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
  echo Run install_ru.bat from extracted folder.
  pause
  exit /b 1
)

echo [STEP 1/2] Copying localization files...
echo Copying to: %TGT%
echo.
copy /Y "%SRC%\ru.loc" "%TGT%\" >nul
copy /Y "%SRC%\ru.cars.loc" "%TGT%\" >nul
copy /Y "%SRC%\ru.tooltips.loc" "%TGT%\" >nul
copy /Y "%SRC%\ru.cars.release.loc" "%TGT%\" >nul
echo Localization files copied.
echo.

echo [STEP 2/2] Patching game menu (adding Russian language)...
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

echo ============================================
echo   Installation Complete!
echo ============================================
echo.
echo In game, select: Settings - General - Language - Russian.
echo If font shows squares or words break incorrectly,
echo see "Font and line breaks" section in README.
echo.
pause
