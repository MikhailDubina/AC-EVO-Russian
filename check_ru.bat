@echo off
setlocal enabledelayedexpansion
title Assetto Corsa EVO - Check Russian
cd /d "%~dp0"
set "GAME="
set "DEF1=%ProgramFiles(x86)%\Steam\steamapps\common\Assetto Corsa EVO"
set "DEF2=%ProgramFiles%\Steam\steamapps\common\Assetto Corsa EVO"
if exist "!DEF1!\AssettoCorsaEVO.exe" set "GAME=!DEF1!"
if not defined GAME if exist "!DEF2!\AssettoCorsaEVO.exe" set "GAME=!DEF2!"
if not defined GAME (
  set "GPFILE=%TEMP%\acevo_gamepath.txt"
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0find_game.ps1" >nul 2>&1
  if exist "%GPFILE%" for /f "usebackq delims=" %%a in ("%GPFILE%") do set "GAME=%%a"
  if exist "%GPFILE%" del /q "%GPFILE%" 2>nul
)
if not defined GAME (
  echo Game folder not found.
  pause
  exit /b 1
)
if exist "!GAME!\content\uiresources\localization" (
  set "LOC=!GAME!\content\uiresources\localization"
  echo Layout: content\uiresources\
) else (
  set "LOC=!GAME!\uiresources\localization"
  echo Layout: uiresources\
)
echo Game: !GAME!
echo Localization: !LOC!
echo.
if not exist "!LOC!" (
  echo Folder not found: !LOC!
  pause
  exit /b 1
)
dir "!LOC!\ru.loc" "!LOC!\ru.cars.loc" "!LOC!\ru.tooltips.loc" "!LOC!\ru.cars.release.loc" 2>nul
if errorlevel 1 (echo One or more .loc files missing.) else (echo All 4 files present.)
echo.
pause
