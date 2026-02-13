@echo off
if "%~1"=="" (
  start "AC EVO - Replace Chinese with Russian" cmd /k "%~f0" run
  exit /b 0
)
title Assetto Corsa EVO - Replace Chinese with Russian
chcp 65001 >nul 2>&1
cd /d "%~dp0"
setlocal enabledelayedexpansion
set "ROOTFILE=%TEMP%\acevo_scriptroot.txt"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0write_scriptroot.ps1" >nul 2>&1
set "SAFEROOT="
if exist "%ROOTFILE%" for /f "usebackq delims=" %%a in ("%ROOTFILE%") do set "SAFEROOT=%%a"
if exist "%ROOTFILE%" del /q "%ROOTFILE%" 2>nul
if not defined SAFEROOT set "SAFEROOT=%~dp0"
REM Support both: GitHub repo (localization\ru.*.loc) and kspkg-style (resources\ru_lang\cn.*.loc)
set "SRC_RL=!SAFEROOT!resources\ru_lang\"
set "SRC_LOC=!SAFEROOT!localization\"
if exist "!SRC_RL!cn.loc" (
  set "USECN=1"
  set "SRC=!SRC_RL!"
) else (
  set "USECN="
  set "SRC=!SRC_LOC!"
)
REM Fallback: if path has spaces/parentheses and ru.loc not found, use batch folder
if not defined USECN if not exist "!SRC!ru.loc" set "SRC=%~dp0localization\"
echo.
echo ============================================
echo   Replace Chinese with Russian (no menu patch)
echo   In game: select language "中文" - interface in Russian
echo ============================================
echo.

if defined USECN (
  if not exist "!SRC!cn.loc" ( echo ERROR: resources\ru_lang\cn.loc not found. & pause & exit /b 1 )
) else (
  if not exist "!SRC!ru.loc" (
    echo ERROR: localization\ru.loc not found. Extract archive and run again.
    pause
    exit /b 1
  )
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
echo Replacing Chinese locale with Russian (cn.loc, cn.cars.loc, cn.tooltips.loc, cn_extra strings.loc)...
if defined USECN (
  copy /Y "!SRC!cn.loc" "!TGT!\cn.loc" >nul
  if errorlevel 1 ( echo ERROR: copy failed. & pause & exit /b 1 )
  copy /Y "!SRC!cn.cars.loc" "!TGT!\cn.cars.loc" >nul
  copy /Y "!SRC!cn.tooltips.loc" "!TGT!\cn.tooltips.loc" >nul
  if exist "!SRC!cn.cars.release.loc" copy /Y "!SRC!cn.cars.release.loc" "!TGT!\cn.cars.release.loc" >nul
  if exist "!SRC!cn.loc" copy /Y "!SRC!cn.loc" "!TGT!\cn_extra strings.loc" >nul
) else (
  copy /Y "!SRC!ru.loc" "!TGT!\cn.loc" >nul
  if errorlevel 1 ( echo ERROR: copy failed. & pause & exit /b 1 )
  copy /Y "!SRC!ru.cars.loc" "!TGT!\cn.cars.loc" >nul
  copy /Y "!SRC!ru.tooltips.loc" "!TGT!\cn.tooltips.loc" >nul
  if exist "!SRC!ru.cars.release.loc" copy /Y "!SRC!ru.cars.release.loc" "!TGT!\cn.cars.release.loc" >nul
  copy /Y "!SRC!ru.loc" "!TGT!\cn_extra strings.loc" >nul
)
echo Done. Chinese language slot now shows Russian.
echo.
echo If interface is still Chinese: game may be reading from content.kspkg. Use install_ru.bat to extract uiresources first, then run this again.
echo.
echo In game: Settings - General - Language - 中文. Interface will be in Russian.
echo.
pause
