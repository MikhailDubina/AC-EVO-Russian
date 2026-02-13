@echo off
REM Launcher: keeps window open after check_ru_installed.bat finishes
cd /d "%~dp0"
call check_ru_installed.bat
echo.
echo Window will stay open. Close it when done or press any key.
pause >nul
