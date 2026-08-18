@echo off
setlocal
chcp 65001 >nul 2>&1

set "SILENT="
if /i "%~1"=="--silent" set "SILENT=-Silent"
if /i "%~2"=="--silent" set "SILENT=-Silent"

:: Check if already running with admin privileges
net session >nul 2>&1
if %errorlevel% equ 0 (
    if defined SILENT (
        powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0ClearMemory.ps1" -Silent
        exit /b
    )
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0ClearMemory.ps1"
    exit /b
)

:: Elevate directly to PowerShell and close this batch window immediately
if defined SILENT (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%~dp0ClearMemory.ps1\" -Silent' -Verb RunAs -WindowStyle Hidden"
    exit /b
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%~dp0ClearMemory.ps1\"' -Verb RunAs"
exit /b
