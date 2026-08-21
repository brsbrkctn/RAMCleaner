@echo off
setlocal EnableDelayedExpansion
color 0F

set SILENT=
if /i %~1==--silent set SILENT=-Silent
if /i %~2==--silent set SILENT=-Silent

if /i %~1==--elevated goto :run_direct
if /i %~2==--elevated goto :run_direct

net session >nul 2>&1
if %errorlevel% equ 0 goto :run_direct

if defined SILENT (
    powershell -NoProfile -ExecutionPolicy Bypass -Command Start-Process powershell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ''%~dp0ClearMemory.ps1'' -Silent' -Verb RunAs -WindowStyle Hidden
    exit /b
)

powershell -NoProfile -ExecutionPolicy Bypass -Command Start-Process -FilePath '%~f0' -ArgumentList '--elevated' -Verb RunAs
exit /b

:run_direct
cd /d %~dp0
if defined SILENT (
    powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File %~dp0ClearMemory.ps1 -Silent
    exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -File %~dp0ClearMemory.ps1
exit /b
