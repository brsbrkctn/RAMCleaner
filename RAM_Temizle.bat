@echo off
chcp 65001 >nul 2>&1
title RAM ve Sistem Performans Optimizasyonu v1.2.0
color 0A

set "SILENT_FLAG="
if /i "%~1"=="--silent" set "SILENT_FLAG=-Silent"
if /i "%~2"=="--silent" set "SILENT_FLAG=-Silent"

if "%~1"=="--elevated" goto RUN_ELEVATED

net session >nul 2>&1
if %errorlevel% neq 0 (
    if defined SILENT_FLAG (
        powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process '%~f0' -ArgumentList '--elevated --silent' -Verb RunAs -WindowStyle Hidden"
        exit /b
    )
    echo   [!] Yonetici yetkisi gerekli - UAC istegi gonderiliyor...
    echo   [i] Lutfen acilan UAC penceresinde 'Evet' secenegini onaylayin.
    echo.
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process '%~f0' -ArgumentList '--elevated' -Verb RunAs"
    exit /b
)

:RUN_ELEVATED
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo   [!] Yonetici yetkisi alinamadi.
    echo   [i] Lutfen RAM_Temizle.bat dosyasina sag tiklayip 'Yonetici olarak calistir' secenegini kullanin.
    echo.
    pause
    exit /b 1
)

if defined SILENT_FLAG goto RUN_SILENT

echo   [OK] Yonetici yetkisi dogrulandi.
echo   [*] RAMCleaner motoru baslatiliyor...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0ClearMemory.ps1"

echo.
echo   [OK] RAMCleaner islemleri tamamlandi. Pencere 3 saniye sonra kapanacak.
ping -n 3 127.0.0.1 >nul
exit /b

:RUN_SILENT
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0ClearMemory.ps1" -Silent
exit /b
