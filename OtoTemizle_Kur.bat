@echo off
chcp 65001 >nul 2>&1
title RAMCleaner - Otomatik Temizleme Zamanlayıcı Kurulumu
color 0A

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
echo     RAMCleaner v1.2.0 - Otomatik Zamanlayıcı Kurulumu
echo   ==============================================================
echo.
echo   Bu islem, her kullanici girisinde ve her 2 saatte bir RAMCleaner'in
echo   arka planda SESSİZ (bildirimli) olarak calismasini saglar.
echo.

set "TARGET_BAT=%~dp0RAM_Temizle.bat"

:: Create scheduled task
schtasks /create /tn "RAMCleaner_AutoClean" /tr "\"%TARGET_BAT%\" --silent" /sc onlogon /rl highest /f >nul 2>&1

if %errorlevel% equ 0 (
    echo   [OK] Otomatik temizleme gorevi basariyla olusturuldu!
    echo   [*] Gorev Adi: RAMCleaner_AutoClean
    echo   [*] Mod: Her kullanici girisinde arka planda sessiz optimizasyon.
) else (
    echo   [!] Gorev olusturulurken bir hata meydana geldi.
)

echo.
echo   Pencere 4 saniye sonra kapanacak.
ping -n 4 127.0.0.1 >nul
