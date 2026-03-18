@echo off
chcp 65001 >nul
title APP KILLER v2.1 - Main Control Panel
color 0A
cls

:MAINMENU
cls
echo.
echo      █████╗ ██████╗ ██████╗     ██╗  ██╗██╗██╗     ██╗     ███████╗██████╗ 
echo     ██╔══██╗██╔══██╗██╔══██╗    ██║ ██╔╝██║██║     ██║     ██╔════╝██╔══██╗
echo     ███████║██████╔╝██████╔╝    █████╔╝ ██║██║     ██║     █████╗  ██████╔╝
echo     ██╔══██║██╔═══╝ ██╔═══╝     ██╔═██╗ ██║██║     ██║     ██╔══╝  ██╔══██╗
echo     ██║  ██║██║     ██║         ██║  ██╗██║███████╗███████╗███████╗██║  ██║
echo     ╚═╝  ╚═╝╚═╝     ╚═╝         ╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
echo.
echo      =========================================================================
echo       APP KILLER v2.1 - MAIN CONTROL PANEL
echo       Created by: Murdervan
echo      =========================================================================
echo.
echo      [1] Launch APP KILLER Terminal (Admin)
echo      [2] View Activity Logs
echo      [3] System Information
echo      [4] About APP KILLER
echo      [Q] Exit Panel
echo.
echo      =========================================================================
echo.

set /p choice=      [CONTROL PANEL] Enter selection: 

if /i "%choice%"=="1" goto LAUNCH
if /i "%choice%"=="2" goto LOGS
if /i "%choice%"=="3" goto SYSINFO
if /i "%choice%"=="4" goto ABOUT
if /i "%choice%"=="Q" goto EXIT
if /i "%choice%"=="q" goto EXIT

echo.
echo      [ERROR] Invalid selection
echo.
timeout /t 2 /nobreak >nul
goto MAINMENU

:LAUNCH
cls
echo.
echo      [INFO] Launching APP KILLER with Admin Privileges...
echo.

set "SCRIPT=%~dp0Windows-App-Remover.ps1"

if not exist "%SCRIPT%" (
    echo      [ERROR] Script not found: %SCRIPT%
    echo.
    pause
    goto MAINMENU
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process PowerShell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -WindowStyle Maximized -NoExit -File \"%SCRIPT%\"'"

timeout /t 2 /nobreak >nul
goto MAINMENU

:LOGS
cls
echo.
echo      =========================================================================
echo       ACTIVITY LOG VIEWER
echo      =========================================================================
echo.

setlocal enabledelayedexpansion
set "LOGDIR=%~dp0"

if exist "%LOGDIR%AppKiller_LOG*.txt" (
    echo      Available logs:
    echo.
    for /f "tokens=*" %%A in ('dir /b "%LOGDIR%AppKiller_LOG*.txt"') do (
        echo        - %%A
    )
    echo.
    set /p logname=      Enter log filename: 
    
    if exist "%LOGDIR%!logname!" (
        cls
        echo.
        echo      =========================================================================
        echo       LOG: !logname!
        echo      =========================================================================
        echo.
        type "%LOGDIR%!logname!"
        echo.
        pause
    ) else (
        echo      [ERROR] Not found
        pause
    )
) else (
    echo      [INFO] No logs found yet
    pause
)

goto MAINMENU

:SYSINFO
setlocal enabledelayedexpansion
cls
echo.
echo      =========================================================================
echo       LOADING SYSTEM INFO...
echo      =========================================================================
echo.

:: Loading animation
echo      [#         ] Loading OS...
timeout /t 1 >nul
echo      [##        ] Loading CPU...
timeout /t 1 >nul
echo      [###       ] Loading RAM...
timeout /t 1 >nul
echo      [####      ] Loading GPU...
timeout /t 1 >nul
echo      [#####     ] Loading Storage...
timeout /t 1 >nul
echo      [##########] Done.!
timeout /t 1 >nul

cls
echo.
echo      =========================================================================
echo       QUICK SPEC INFO - WAIT IT CAN TAKE SOME TIME!
echo      =========================================================================
echo.

:: --- OS ---
for /f "delims=" %%A in ('powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).Caption"') do set OSNAME=%%A
for /f "delims=" %%A in ('powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).Version"') do set OSVER=%%A

:: --- CPU ---
for /f "delims=" %%A in ('powershell -NoProfile -Command "(Get-CimInstance Win32_Processor | Select-Object -First 1 -ExpandProperty Name)"') do set CPU=%%A

:: --- RAM ---
for /f "delims=" %%A in ('powershell -NoProfile -Command "(Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory"') do set RAM=%%A
set /a RAMGB=%RAM:~0,-9%

:: --- GPU ---
for /f "delims=" %%A in ('powershell -NoProfile -Command "(Get-CimInstance Win32_VideoController | Where-Object {$_.Status -eq 'OK'} | Select-Object -First 1 -ExpandProperty Name)"') do set GPU=%%A

:: --- GPU VRAM (safe fallback)
set "VRAMGB=Unknown"
for /f "delims=" %%A in ('powershell -NoProfile -Command "try { $gpu = Get-CimInstance Win32_VideoController | Select-Object -First 1; if ($gpu.AdapterRAM) { [math]::Round($gpu.AdapterRAM / 1GB) } } catch { '' }"') do set "VRAMGB=%%A"
if "!VRAMGB!"=="" set "VRAMGB=Unknown"

:: --- C: Drive ---
for /f "delims=" %%A in ('powershell -NoProfile -Command "(Get-PSDrive C).Used + (Get-PSDrive C).Free"') do set CDRIVE=%%A
set /a CGB=%CDRIVE:~0,-9%

:: --- D: Drive ---
for /f "delims=" %%A in ('powershell -NoProfile -Command "if (Test-Path D:) { (Get-PSDrive D).Used + (Get-PSDrive D).Free } else { 0 }"') do set DDRIVE=%%A
if not %DDRIVE%==0 set /a DGB=%DDRIVE:~0,-9%

:: --- OUTPUT (Korrekt rækkefølge)
echo      - OS: %OSNAME% - Version %OSVER%
echo      - CPU: %CPU%
echo      - GPU: %GPU%
echo      - GPU VRAM: !VRAMGB! GB
echo      - RAM: %RAMGB% GB
echo      - C: Drive: %CGB% GB
if not %DDRIVE%==0 echo      - D: Drive: %DGB% GB
echo.
echo      =========================================================================
echo.

pause
endlocal
goto MAINMENU

:ABOUT
cls
    echo.
echo ===============================================================
echo                     APP KILLER v2.1
echo ===============================================================
echo Version  : 2.1.0
echo Author   : Murdervan / github.com/murdervan
echo Type     : Professional Windows App REVOMER Terminator
echo.
echo Description:
echo   APP KILLER is an advanced Windows utility designed to
echo   clean up your system and remove unwanted apps.
echo   Works seamlessly on Windows 10 and Windows 11.
echo.
echo Features:
echo   - Safely remove bloatware and unnecessary apps
echo   - Nuclear deletion mode: wipe entire categories at once
echo   - Activity logging: track removed or missing apps
echo   - Admin check: automatically verifies elevated rights
echo   - Multi-category app management: System, Media, Xbox, Edge, etc.
echo   - System scan: see which apps are currently installed
echo.
echo Supported Platforms:
echo   Windows 10 / 11 (All editions)
    echo.
    echo      =========================================================================
    echo.
    pause
)

goto MAINMENU

:EXIT
cls
echo.
echo        █████╗  ██╗   ██╗   ███████╗
echo       ██╔══██╗ ╚██╗ ██╔╝  ██╔════╝
echo       ██████╔╝  ╚████╔╝   █████╗
echo       ██╔══██╗   ╚██╔╝    ██╔══╝
echo       ██████╔╝    ██║     ███████╗
echo       ╚═════╝     ╚═╝     ╚══════╝
echo.
echo      [BYE. Visit Github.com/murdervan]
echo.
timeout /t 3 /nobreak >nul
exit /b 0
