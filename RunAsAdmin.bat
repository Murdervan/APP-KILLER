@echo off
set SCRIPT=%~dp0Windows-App-Remover.ps1

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
 "Start-Process PowerShell -Verb RunAs -ArgumentList '-NoExit -ExecutionPolicy Bypass -File ""%SCRIPT%""'"

exit