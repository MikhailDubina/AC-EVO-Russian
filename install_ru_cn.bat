@echo off
if "%~1"=="" (
  start "AC EVO Russian (as Chinese)" cmd /k "%~f0" run
  exit /b 0
)
title Assetto Corsa EVO - Russian as Chinese (no menu patch)
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
echo   Russian as Chinese (no kspkg unpack)
echo   In game: select language "中文"
echo ============================================
echo.

if not exist "!SRC!ru.loc" (
  echo ERROR: localization\ru.loc not found. Extract archive and run again.
  pause
  exit /b 1
)

echo Searching for game...
set "GAME="
set "GPFILE=%TEMP%\acevo_gamepath.txt"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0find_game.ps1" >nul 2>&1
if exist "%GPFILE%" (
  for /f "usebackq delims=" %%a in ("%GPFILE%") do set "GAME=%%a"
  del /q "%GPFILE%" 2>nul
)
if defined GAME echo Found: !GAME!
if not defined GAME (
  set /p GAME="Enter game folder: "
  set "GAME=!GAME:"=!"
  if not defined GAME ( pause & exit /b 1 )
  if not exist "!GAME!\AssettoCorsaEVO.exe" ( echo AssettoCorsaEVO.exe not found. & pause & exit /b 1 )
)

REM Same layout detection as install_ru.bat
if exist "!GAME!\content\uiresources\js\components.js" ( set "UIROOT=!GAME!\content" ) else ( set "UIROOT=!GAME!" )
set "TGT=!UIROOT!\uiresources\localization"
if not exist "!TGT!" (
  echo Creating: !TGT!
  mkdir "!TGT!" 2>nul
  if not exist "!TGT!" ( echo ERROR: Cannot create folder. & pause & exit /b 1 )
)

echo.
echo Copying Russian text as cn.*.loc (game will show it when you select "中文")...
copy /Y "!SRC!ru.loc" "!TGT!\cn.loc" >nul
if errorlevel 1 ( echo ERROR: copy failed. & pause & exit /b 1 )
copy /Y "!SRC!ru.cars.loc" "!TGT!\cn.cars.loc" >nul
copy /Y "!SRC!ru.tooltips.loc" "!TGT!\cn.tooltips.loc" >nul
if exist "!SRC!ru.cars.release.loc" copy /Y "!SRC!ru.cars.release.loc" "!TGT!\cn.cars.release.loc" >nul
echo Done. No menu patch applied.
echo.
echo In game: Settings - General - Language - 中文 (Chinese). Interface will be in Russian.
echo.
pause
