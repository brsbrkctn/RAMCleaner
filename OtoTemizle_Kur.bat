@echo off
setlocal EnableDelayedExpansion

title RAMCleaner - Otomatik Temizleme Zamanlayici Kurulumu
color 0A

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
echo     RAMCleaner v1.3.0 - Otomatik Zamanlayici Kurulumu
echo   ==============================================================
echo.
echo   Bu islem, her kullanici girisinde RAMCleaner'in arka planda
echo   SESSIZ (sifir pencere, masaustu bildirimli) calismasini saglar.
echo.

schtasks /create /tn "RAMCleaner_AutoClean" /tr "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File %~dp0ClearMemory.ps1 -Silent" /sc onlogon /rl highest /f >nul 2>&1

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