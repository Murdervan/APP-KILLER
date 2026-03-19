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
echo       Created by: Murdervan - Github.com/murdervan
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
echo      [##########] Done.
timeout /t 1 >nul

cls
echo.
echo      =========================================================================
echo       QUICK SPEC INFO
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

:: --- GPU VRAM
set "VRAMGB=Unknown"
for /f "delims=" %%A in ('powershell -NoProfile -Command "try { $gpu = Get-CimInstance Win32_VideoController | Select-Object -First 1; if ($gpu.AdapterRAM) { [math]::Round($gpu.AdapterRAM / 1GB) } } catch { '' }"') do set "VRAMGB=%%A"
if "!VRAMGB!"=="" set "VRAMGB=Unknown"

:: --- Drives ---
for /f "delims=" %%A in ('powershell -NoProfile -Command "(Get-PSDrive C).Used + (Get-PSDrive C).Free"') do set CDRIVE=%%A
set /a CGB=%CDRIVE:~0,-9%
for /f "delims=" %%A in ('powershell -NoProfile -Command "if (Test-Path D:) { (Get-PSDrive D).Used + (Get-PSDrive D).Free } else { 0 }"') do set DDRIVE=%%A
if not %DDRIVE%==0 set /a DGB=%DDRIVE:~0,-9%

:: --- Output ---
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
echo      [C] Clean Harddisk (Good before sale of PC)
echo      [B] Back to Main Menu
echo.
set /p diskchoice=      Enter selection: 

if /i "%diskchoice%"=="C" (
    cls
    echo.
    echo      [INFO] Cleaning free space on C: and D: drives...
    echo      This may take a long time depending on drive size.
    echo.
    cipher /w:C:
    if exist D: cipher /w:D:
    echo.
    echo      [INFO] Drive cleanup complete.
    pause
    goto SYSINFO
)
if /i "%diskchoice%"=="B" goto MAINMENU

goto SYSINFO

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
echo App List:
echo      [1] See full app list
echo      [B] Back to Main Menu
echo.
echo Supported Platforms:
echo   Windows 10 / 11 (All editions)
    echo.
    echo      =========================================================================
    echo.
set /p diskchoice=      Enter selection: 

)
if /i "%diskchoice%"=="1" (
    cls
echo ===============================================================
echo                      APP lIST OVERVIEW
echo ===============================================================
echo SYSTEM
    echo   - Calculator
    echo   - Paint
    echo   - Clock
    echo   - Windows Store
    echo   - Store Core
    echo   - OneDrive
    echo   - Quick Assist
    echo.
echo MEDIA
    echo   - Media Player
    echo   - Music
    echo   - Camera
    echo   - Voice Recorder
    echo   - Photos
    echo.  
echo XBOX
    echo   - Xbox App
    echo   - Xbox Game Bar
    echo   - Xbox Identity Provider
    echo   - Xbox Speech To Text
    echo   - Xbox TCUI
    echo.
echo COMMUNICATION
    echo   - Teams Personal
    echo   - Skype
    echo   - Mail - Calendar
    echo   - Outlook New
    echo.
echo PRODUCTIVITY
    echo   - To Do
    echo   - Sticky Notes
    echo   - OneNote
    echo   - Office Hub
    echo   - Dev Home
    echo.
echo BLOAT
    echo   - Copilot
    echo   - Clipchamp
    echo   - LinkedIn
    echo   - Cortana
    echo   - Feedback Hub
    echo   - Get Started
    echo   - News
    echo   - Weather
    echo   - Solitaire
    echo.
echo EDGE / WEB
    echo   - Edge WebView2
    echo   - Web Experience Pack
    echo   - Bing Search
    echo.
echo 3D / LEGACY
    echo   - 3D Viewer
    echo   - Mixed Reality Portal
    echo   - Print 3D
    echo   - Paint 3D
    echo.
echo EXTENSIONS
    echo   - HEIF Image Extensions
    echo   - Web Media Extensions
    echo   - Raw Image Extension
    echo.
echo OTHER
    echo   - Phone Link
    echo   - Family Safety
    echo   - Store Ads
    echo   - Advertising XAML
    echo   - Microsoft Wallet
    echo   - Microsoft Pay
    echo.
    pause
)
if /i "%diskchoice%"=="B" goto MAINMENU

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
echo      [See you soon.!]
echo.
timeout /t 3 /nobreak >nul
exit /b 0
