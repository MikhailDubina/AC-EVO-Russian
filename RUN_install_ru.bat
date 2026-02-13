@echo off
REM Launcher: keeps window open after install_ru.bat finishes (or fails)
cd /d "%~dp0"
call install_ru.bat
echo.
echo Window will stay open. Close it when done or press any key.
pause >nul
