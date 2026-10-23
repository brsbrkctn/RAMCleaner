@echo off
title Create Desktop Shortcut - RAMCleaner
echo.
echo   RAMCleaner Masaustu Kisayol Olusturucu
echo   ----------------------------------------
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ws = New-Object -ComObject WScript.Shell; $desktop = [Environment]::GetFolderPath('Desktop'); $lnkPath = Join-Path $desktop 'RAM Temizle.lnk'; $sc = $ws.CreateShortcut($lnkPath); $sc.TargetPath = '%~dp0RAM_Temizle.bat'; $sc.WorkingDirectory = '%~dp0'; $sc.Description = 'RAM ve Sistem Performans Optimizasyonu v1.5.1'; $sc.IconLocation = 'imageres.dll,109'; $sc.Save(); $bytes = [System.IO.File]::ReadAllBytes($lnkPath); $bytes[0x15] = $bytes[0x15] -bor 0x20; [System.IO.File]::WriteAllBytes($lnkPath, $bytes); Write-Host '[OK] Masaustu kisayolu basariyla olusturuldu (Yonetici yetkili)!' -ForegroundColor Green; Write-Host '     Konum: ' -NoNewline -ForegroundColor Gray; Write-Host $lnkPath -ForegroundColor White;"

echo.
echo   Bu pencere 3 saniye sonra kapanacak.
ping -n 4 127.0.0.1 >nul
