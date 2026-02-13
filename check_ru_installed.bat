@echo off
title Assetto Corsa EVO - Check Russian localization
echo.
chcp 65001 >nul 2>&1
cd /d "%~dp0"
setlocal enabledelayedexpansion
echo ============================================
echo   Check: Russian localization in game folder
echo ============================================
echo.

set "GAME="
set "LOC="
set "DEF1=%ProgramFiles(x86)%\Steam\steamapps\common\Assetto Corsa EVO"
set "DEF2=%ProgramFiles%\Steam\steamapps\common\Assetto Corsa EVO"

if exist "%DEF1%\Assetto Corsa EVO.exe" set "GAME=%DEF1%"
if not defined GAME if exist "%DEF2%\Assetto Corsa EVO.exe" set "GAME=%DEF2%"
if not defined GAME for /f "delims=" %%a in ('powershell -NoProfile -Command "try { $vdf='%ProgramFiles(x86)%\Steam\steamapps\libraryfolders.vdf'; if (Test-Path $vdf) { (Get-Content $vdf -Raw) -split '\"path\"' | Select-Object -Skip 1 | ForEach-Object { if ($_ -match '\s+\"([^\"]+)\"') { $p = $matches[1].Trim().TrimEnd('\\') -replace '\\\\','\\' + '\steamapps\common\Assetto Corsa EVO'; if (Test-Path \"$p\Assetto Corsa EVO.exe\") { Write-Output $p; break } } } } } catch {}" 2^>nul') do set "GAME=%%a"

if not defined GAME (
  echo Game folder not found. Enter path to game (where Assetto Corsa EVO.exe is):
  set /p GAME="Path: "
  set "GAME=!GAME:"=!"
  if not defined GAME (
    echo Not entered.
    echo Press any key to close...
    pause >nul
    exit /b 1
  )
)

set "LOC=%GAME%\uiresources\localization"
if not exist "%LOC%" (
  echo ERROR: Folder not found: %LOC%
  echo.
  echo Press any key to close...
  pause >nul
  exit /b 1
)

echo Game folder: %GAME%
echo Localization folder: %LOC%
echo.
echo Russian .loc files:
echo ----------------------------------------
dir "%LOC%\ru.loc" "%LOC%\ru.cars.loc" "%LOC%\ru.tooltips.loc" "%LOC%\ru.cars.release.loc" 2>nul
if errorlevel 1 (
  echo One or more files missing. Run install_ru.bat to install.
) else (
  echo ----------------------------------------
  echo All 4 files present. In game: Settings - General - Language - Russian.
  echo Main menu should show: Vozhdenie, Avtomobili, Akademiya, Nastrojki (in Russian).
)
echo.
echo Press any key to close...
pause >nul
