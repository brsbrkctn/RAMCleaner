@echo off
setlocal EnableDelayedExpansion

title RAMCleaner - Otomatik Zamanlayici Kaldirma
color 0C

if /i "%~1"=="--elevated" goto :main
if /i "%~2"=="--elevated" goto :main

net session >nul 2>&1
if %errorlevel% equ 0 goto :main

echo.
echo   [!] Yonetici yetkisi gerekli - UAC onay penceresi aciliyor...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -ArgumentList '--elevated' -Verb RunAs"
exit /b

:main
cd /d "%~dp0"

echo.
echo   ==============================================================
echo     RAMCleaner v1.3.0 - Otomatik Zamanlayici Kaldirma
echo   ==============================================================
echo.

schtasks /delete /tn "RAMCleaner_AutoClean" /f >nul 2>&1

if %errorlevel% equ 0 (
    echo   [OK] Otomatik temizleme gorevi basariyla kaldirildi!
) else (
    echo   [i] Kayitli gorev bulunamadi veya zaten silinmis.
)

echo.
echo   Pencere 3 saniye sonra kapanacak.
ping -n 3 127.0.0.1 >nul