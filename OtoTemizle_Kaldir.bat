@echo off
chcp 65001 >nul 2>&1
title RAMCleaner - Otomatik Zamanlayıcı Kaldırma
color 0C

:: UAC Elevation check
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo   [!] Yonetici yetkisi gerekli - UAC istegi gonderiliyor...
    echo   [i] Lutfen acilan UAC penceresinde 'Evet' secenegini onaylayin.
    echo.
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo   ==============================================================
echo     RAMCleaner v1.3.0 - Otomatik Zamanlayıcı Kaldırma
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
