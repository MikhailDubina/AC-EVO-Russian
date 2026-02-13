@echo off
if "%~1"=="" (
  start "AC EVO Russian" cmd /k "%~f0" run
  exit /b 0
)
title Assetto Corsa EVO - Russian Localization
chcp 65001 >nul 2>&1
cd /d "%~dp0"
setlocal enabledelayedexpansion
set "ROOTFILE=%TEMP%\acevo_scriptroot.txt"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0write_scriptroot.ps1" >nul 2>&1
set "SAFEROOT="
if exist "%ROOTFILE%" for /f "usebackq delims=" %%a in ("%ROOTFILE%") do set "SAFEROOT=%%a"
if exist "%ROOTFILE%" del /q "%ROOTFILE%" 2>nul
if not defined SAFEROOT set "SAFEROOT=%~dp0"
set "SRC=!SAFEROOT!\localization\"
echo.
echo ============================================
echo   Assetto Corsa EVO - Russian Localization
echo   Full Installation (files + menu patch)
echo ============================================
echo.

REM Check if running from correct folder
if not exist "!SRC!ru.loc" (
  echo ERROR: Localization files not found! Installation stopped.
  echo.
  echo Open the installation folder in Explorer.
  echo Check: there must be a "localization" folder with ru.loc, ru.cars.loc inside.
  echo.
  echo If "localization" is missing or empty:
  echo   - Download the ZIP again from GitHub ^(Code - Download ZIP^)
  echo   - Extract ALL files ^(right-click ZIP - Extract All^)
  echo   - If the folder is on OneDrive: right-click "localization" - "Always keep on this device"
  echo.
  echo Looking for file: !SRC!ru.loc
  echo.
  pause
  exit /b 1
)

echo Searching for game installation...
set "GAME="
set "GPFILE=%TEMP%\acevo_gamepath.txt"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0find_game.ps1" >nul 2>&1
if exist "%GPFILE%" (
  for /f "usebackq delims=" %%a in ("%GPFILE%") do set "GAME=%%a"
  del /q "%GPFILE%" 2>nul
)
if defined GAME echo Found at: !GAME!

if not defined GAME (
  echo.
  echo Game not found at default Steam locations.
  echo.
  set /p GAME="Enter game folder path: "
  set "GAME=!GAME:"=!"
  if not defined GAME (
    echo.
    echo Path not entered. Exiting.
    echo.
    pause
    exit /b 1
  )
  if not exist "!GAME!\AssettoCorsaEVO.exe" (
    echo.
    echo ERROR: Game executable not found at: !GAME!
    echo Check the path and try again.
    echo.
    pause
    exit /b 1
  )
)

set "TGT=!GAME!\uiresources\localization"
if not exist "!TGT!" (
  echo.
  echo Folder not found, creating: !TGT!
  mkdir "!TGT!" 2>nul
  if not exist "!TGT!" (
    echo ERROR: Could not create folder. Check path and permissions.
    echo.
    pause
    exit /b 1
  )
  echo Folder created.
  echo.
)

echo.
echo [STEP 1/2] Copying localization files...
echo From: !SRC!
echo To: !TGT!
echo.
copy /Y "!SRC!ru.loc" "!TGT!\" >nul
if errorlevel 1 (
  echo ERROR: Failed to copy ru.loc
  pause
  exit /b 1
)
copy /Y "!SRC!ru.cars.loc" "!TGT!\" >nul
copy /Y "!SRC!ru.tooltips.loc" "!TGT!\" >nul
copy /Y "!SRC!ru.cars.release.loc" "!TGT!\" >nul
echo Localization files copied successfully.
echo.

echo [STEP 2/2] Patching game menu (adding Russian language)...
if not exist "!SAFEROOT!\patch_ru.ps1" (
  echo WARNING: patch_ru.ps1 not found. Skipping menu patch.
  echo You may need to run patch_ru.bat manually.
  echo.
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "!SAFEROOT!\patch_ru.ps1" -GamePath "!GAME!"
  if errorlevel 1 (
    echo.
    echo WARNING: Failed to apply menu patch automatically.
    echo.
    echo If uiresources\js or uiresources\css are missing: game files are incomplete.
    echo In Steam: right-click game - Manage - Verify integrity of game files.
    echo Then run install_ru.bat again. This pack can restore components.js only.
    echo.
    echo Otherwise run patch_ru.bat manually after installation.
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
echo One run is enough. In game: Settings - General - Language - Russian
echo.
pause
