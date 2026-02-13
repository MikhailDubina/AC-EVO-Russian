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
set "DID_EXTRACT=0"
echo.
echo ============================================
echo   Assetto Corsa EVO - Russian Localization
echo ============================================
echo.

if not exist "!SRC!ru.loc" (
  echo ERROR: Localization files not found. Need folder "localization" with ru.loc.
  echo Extract the full archive and run again.
  echo.
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
  echo.
  set /p GAME="Enter game folder path: "
  set "GAME=!GAME:"=!"
  if not defined GAME ( echo Path not entered. & pause & exit /b 1 )
  if not exist "!GAME!\AssettoCorsaEVO.exe" (
    echo ERROR: AssettoCorsaEVO.exe not found there.
    pause
    exit /b 1
  )
)

REM --- Determine layout: content\uiresources, uiresources, or extract from kspkg ---
set "KSPKG=!GAME!\content.kspkg"
if exist "!GAME!\content\uiresources\js\components.js" (
  set "UIROOT=!GAME!\content"
  echo Using content\uiresources\ (full content layout).
) else if exist "!GAME!\uiresources\js\components.js" (
  set "UIROOT=!GAME!"
  echo Using uiresources\ in game root.
) else if exist "!KSPKG!" (
  REM Only content.kspkg, no uiresources: try extract into content\
  set "UIROOT=!GAME!\content"
  set "UIRES=!UIROOT!\uiresources"
  if not exist "!UIRES!\js\components.js" (
    echo.
    echo uiresources not found. Extracting from content.kspkg into content\...
    if not exist "!UIROOT!" mkdir "!UIROOT!" 2>nul
    set "PYSCRIPT=%~dp0parse_kspkg.py"
    if not exist "!PYSCRIPT!" (
      echo.
      echo parse_kspkg.py not found. Place it next to this bat ^(see README, ace-kspkg^).
      echo Creating uiresources in game root with fallback components.js instead.
      echo To use content from package later: add parse_kspkg.py and run install again.
      echo.
      set "UIROOT=!GAME!"
      set "DID_EXTRACT=0"
    ) else (
      python --version >nul 2>&1
      if errorlevel 1 (
        echo Python not found. Creating uiresources in game root with fallback.
        set "UIROOT=!GAME!"
      ) else (
        python "!PYSCRIPT!" -i "!KSPKG!" --extract-dir uiresources -o "!UIROOT!"
        if errorlevel 1 (
          echo Extraction failed. Creating uiresources in game root with fallback.
          set "UIROOT=!GAME!"
        ) else (
          if not exist "!UIRES!\js\components.js" (
            echo Extract incomplete. Using game root + fallback.
            set "UIROOT=!GAME!"
          ) else (
            echo Extracted content\uiresources\.
            set "DID_EXTRACT=1"
          )
        )
      )
    )
  ) else (
    echo Using content\uiresources\.
  )
) else (
  set "UIROOT=!GAME!"
  echo Using game root ^(uiresources created if missing^).
)

set "TGT=!UIROOT!\uiresources\localization"
if not exist "!TGT!" (
  echo Creating: !TGT!
  mkdir "!TGT!" 2>nul
  if not exist "!TGT!" (
    echo ERROR: Could not create folder.
    pause
    exit /b 1
  )
)
echo.

echo [1/2] Copying localization...
echo To: !TGT!
copy /Y "!SRC!ru.loc" "!TGT!\" >nul
if errorlevel 1 ( echo ERROR: copy ru.loc failed. & pause & exit /b 1 )
copy /Y "!SRC!ru.cars.loc" "!TGT!\" >nul
copy /Y "!SRC!ru.tooltips.loc" "!TGT!\" >nul
copy /Y "!SRC!ru.cars.release.loc" "!TGT!\" >nul
echo Done.
echo.

echo [2/2] Patching menu ^(Russian in Language list^)...
if exist "!SAFEROOT!\patch_ru.ps1" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "!SAFEROOT!\patch_ru.ps1" -GamePath "!UIROOT!" -PackRoot "!SAFEROOT!"
  if errorlevel 1 (
    echo WARNING: Patch had errors. In Steam: Verify integrity, then run again.
  ) else (
    echo Patch OK.
  )
) else (
  echo WARNING: patch_ru.ps1 not found.
)
echo.

echo ============================================
echo   Installation complete.
echo ============================================
echo.
if "!DID_EXTRACT!"=="1" (
  echo So the game uses extracted files, rename content.kspkg to content.kspkg.bak
  set /p REN="Rename content.kspkg now? (Y/N): "
  if /i "!REN!"=="Y" (
    if exist "!KSPKG!" (
      ren "!KSPKG!" content.kspkg.bak
      if not errorlevel 1 echo Renamed.
    )
  ) else (
    echo Remember to rename content.kspkg to .bak before starting the game.
  )
  echo.
)
echo In game: Settings - General - Language - Russian
echo.
pause
