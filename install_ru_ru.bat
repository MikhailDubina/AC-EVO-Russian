@echo off
chcp 65001 >nul 2>&1
cd /d "%~dp0"
setlocal enabledelayedexpansion

powershell -NoProfile -ExecutionPolicy Bypass -Command "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; $host.UI.RawUI.WindowTitle = 'Assetto Corsa EVO - Русская локализация (полная установка)'; Write-Host ''; Write-Host '============================================'; Write-Host '  Assetto Corsa EVO - Русская локализация'; Write-Host '  Полная установка (файлы + патч меню)'; Write-Host '============================================'; Write-Host ''"

set "GAME="
set "DEF1=%ProgramFiles(x86)%\Steam\steamapps\common\Assetto Corsa EVO"
set "DEF2=%ProgramFiles%\Steam\steamapps\common\Assetto Corsa EVO"

if exist "%DEF1%\Assetto Corsa EVO.exe" set "GAME=%DEF1%"
if not defined GAME if exist "%DEF2%\Assetto Corsa EVO.exe" set "GAME=%DEF2%"

if not defined GAME (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Write-Host 'Не найден путь к игре по умолчанию.'; Write-Host ''"
  set /p GAME="Вставьте путь к папке игры: "
  set "GAME=!GAME:"=!"
  if not defined GAME (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Write-Host ''; Write-Host 'Путь не введён. Завершение.'; Write-Host ''"
    pause
    exit /b 1
  )
)

set "TGT=%GAME%\uiresources\localization"
if not exist "%TGT%" (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Write-Host ''; Write-Host 'ОШИБКА: Папка не найдена: %TGT%'; Write-Host 'Проверьте путь к игре.'; Write-Host ''"
  pause
  exit /b 1
)

set "SRC=%~dp0localization"
if not exist "%SRC%\ru.loc" (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Write-Host 'ОШИБКА: В папке с установщиком нет файлов локализации (localization\ru.loc и др.).'; Write-Host 'Запустите install_ru_ru.bat из распакованной папки.'"
  pause
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "Write-Host '[ШАГ 1/2] Копирование файлов локализации...'; Write-Host 'Копирование в: %TGT%'; Write-Host ''"
copy /Y "%SRC%\ru.loc" "%TGT%\" >nul
copy /Y "%SRC%\ru.cars.loc" "%TGT%\" >nul
copy /Y "%SRC%\ru.tooltips.loc" "%TGT%\" >nul
copy /Y "%SRC%\ru.cars.release.loc" "%TGT%\" >nul
powershell -NoProfile -ExecutionPolicy Bypass -Command "Write-Host 'Файлы локализации скопированы.'; Write-Host ''"

powershell -NoProfile -ExecutionPolicy Bypass -Command "Write-Host '[ШАГ 2/2] Патч меню игры (добавление русского языка)...'"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0patch_ru.ps1" -GamePath "%GAME%" 2>nul
if errorlevel 1 (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Write-Host ''; Write-Host 'ВНИМАНИЕ: Не удалось применить патч меню автоматически.'; Write-Host 'Запустите patch_ru.bat вручную после завершения установки.'; Write-Host ''"
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Write-Host 'Патч меню применён успешно.'; Write-Host ''"
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "Write-Host '============================================'; Write-Host '  Установка завершена!'; Write-Host '============================================'; Write-Host ''; Write-Host 'В игре выберите: Настройки - Общие - Язык - Русский.'; Write-Host 'Если шрифт отображается квадратиками или слова переносятся некорректно,'; Write-Host 'см. раздел \"Шрифт и переносы\" в README.'; Write-Host ''"
pause
