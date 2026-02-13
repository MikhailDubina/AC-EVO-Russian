@echo off
cd /d "%~dp0"
chcp 65001 >nul
setlocal enabledelayedexpansion
title Assetto Corsa EVO - Русская локализация
echo.
echo ============================================
echo   Assetto Corsa EVO - Русская локализация
echo ============================================
echo.

set "GAME="
set "DEF1=%ProgramFiles(x86)%\Steam\steamapps\common\Assetto Corsa EVO"
set "DEF2=%ProgramFiles%\Steam\steamapps\common\Assetto Corsa EVO"

if exist "%DEF1%\Assetto Corsa EVO.exe" set "GAME=%DEF1%"
if not defined GAME if exist "%DEF2%\Assetto Corsa EVO.exe" set "GAME=%DEF2%"

if not defined GAME (
  echo Не найден путь к игре по умолчанию.
  echo.
  set /p GAME="Вставьте путь к папке игры (например C:\Steam\steamapps\common\Assetto Corsa EVO): "
  set "GAME=!GAME:"=!"
  if not defined GAME (
    echo.
    echo Путь не введён. Завершение.
    echo.
    pause
    exit /b 1
  )
)

set "TGT=%GAME%\uiresources\localization"
if not exist "%TGT%" (
  echo.
  echo ОШИБКА: Папка не найдена: %TGT%
  echo Проверьте путь к игре.
  echo.
  pause
  exit /b 1
)

set "SRC=%~dp0localization"
if not exist "%SRC%\ru.loc" (
  echo ОШИБКА: В папке с установщиком нет файлов локализации (localization\ru.loc и др.).
  echo Запустите install.bat из распакованной папки.
  pause
  exit /b 1
)

echo Копирование файлов в:
echo %TGT%
echo.
copy /Y "%SRC%\ru.loc" "%TGT%\"
copy /Y "%SRC%\ru.cars.loc" "%TGT%\"
copy /Y "%SRC%\ru.tooltips.loc" "%TGT%\"
copy /Y "%SRC%\ru.cars.release.loc" "%TGT%\"

echo.
echo Готово.
echo.
echo В игре выберите: Настройки - Общие - Язык - Русский.
echo Если шрифт отображается квадратиками или слова переносятся некорректно,
echo см. раздел "Шрифт и переносы" в README.
echo.
pause
