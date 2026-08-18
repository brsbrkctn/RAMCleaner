@echo off
title Create Desktop Shortcut - RAMCleaner
echo.
echo   RAMCleaner Masaüstü Kısayol Oluşturucu
echo   ────────────────────────────────────────
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ws = New-Object -ComObject WScript.Shell; $desktop = [Environment]::GetFolderPath('Desktop'); $sc = $ws.CreateShortcut(\"$desktop\RAM Temizle.lnk\"); $sc.TargetPath = '%~dp0RAM_Temizle.bat'; $sc.WorkingDirectory = '%~dp0'; $sc.Description = 'RAM ve Sistem Performans Optimizasyonu v1.3.0'; $sc.IconLocation = 'imageres.dll,109'; $sc.Save(); Write-Host '[✓] Masaüstü kısayolu başarıyla oluşturuldu!' -ForegroundColor Green; Write-Host '    Konum: ' -NoNewline -ForegroundColor Gray; Write-Host \"$desktop\RAM Temizle.lnk\" -ForegroundColor White;"

echo.
echo   Bu pencere 3 saniye sonra kapanacak.
timeout /t 3 >nul
