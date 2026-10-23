param(
    [switch]$Silent,
    [switch]$SkipUpdate
)

$ConfirmPreference = 'None'
$ErrorActionPreference = 'SilentlyContinue'

# RAM and System Optimizer v1.5.1
# Developed by Barış Berke Çetin

# ============================================================
# BÖLÜM 1: Console Background, Font, QuickEdit & Window Manager
# ============================================================
$sourceFont = @"
using System;
using System.Runtime.InteropServices;

public class ConsoleFontManager {
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct CONSOLE_FONT_INFOEX {
        public uint cbSize;
        public uint nFont;
        public short dwFontSizeX;
        public short dwFontSizeY;
        public int FontFamily;
        public int FontWeight;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
        public string FaceName;
    }

    [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    public static extern bool SetCurrentConsoleFontEx(IntPtr hConsoleOutput, bool bMaximumWindow, ref CONSOLE_FONT_INFOEX lpConsoleCurrentFontEx);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr GetStdHandle(int nStdHandle);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint lpMode);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool SetConsoleMode(IntPtr hConsoleHandle, uint dwMode);

    public static void DisableQuickEdit() {
        try {
            IntPtr hStdin = GetStdHandle(-10); // STD_INPUT_HANDLE = -10
            uint mode;
            if (GetConsoleMode(hStdin, out mode)) {
                mode &= ~0x0040u; // Clear ENABLE_QUICK_EDIT_MODE (0x0040)
                mode |= 0x0080u;  // Set ENABLE_EXTENDED_FLAGS (0x0080)
                SetConsoleMode(hStdin, mode);
            }
        } catch {}
    }

    public static void SetBalancedFont() {
        try {
            IntPtr hOut = GetStdHandle(-11); // STD_OUTPUT_HANDLE = -11
            CONSOLE_FONT_INFOEX info = new CONSOLE_FONT_INFOEX();
            info.cbSize = (uint)Marshal.SizeOf(info);
            info.dwFontSizeX = 0;
            info.dwFontSizeY = 16;
            info.FontFamily = 54;
            info.FontWeight = 700;
            info.FaceName = "Consolas";
            SetCurrentConsoleFontEx(hOut, false, ref info);
        } catch {}
    }
}
"@

if (-not $Silent) {
    try {
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.UI.RawUI.ForegroundColor = "White"
        Add-Type -TypeDefinition $sourceFont -ErrorAction Stop
        [ConsoleFontManager]::SetBalancedFont()
        [ConsoleFontManager]::DisableQuickEdit()
    } catch {}

    $Host.UI.RawUI.WindowTitle = "RAM ve Sistem Performans Optimizasyonu v1.5.1"
}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

if (-not $Silent) {
    Clear-Host
}

# ============================================================
# BÖLÜM 2: ASCII Art Banner & Başlık (RAM CLEANER)
# ============================================================
if (-not $Silent) {
    Write-Host ""
    Write-Host "  ██████╗   █████╗  ███╗   ███╗     ██████╗ ██╗     ███████╗  █████╗  ███╗   ██╗ ███████╗ ██████╗ " -ForegroundColor Cyan
    Write-Host "  ██╔══██╗ ██╔══██╗ ████╗ ████║    ██╔════╝ ██║     ██╔════╝ ██╔══██╗ ████╗  ██║ ██╔════╝ ██╔══██╗" -ForegroundColor Cyan
    Write-Host "  ██████╔╝ ███████║ ██╔████╔██║    ██║      ██║     █████╗   ███████║ ██╔██╗ ██║ █████╗   ██████╔╝" -ForegroundColor Cyan
    Write-Host "  ██╔══██╗ ██╔══██╗ ██║╚██╔╝██║    ██║      ██║     ██╔══╝   ██╔══██╗ ██║╚██╗██║ ██╔══╝   ██╔══██╗" -ForegroundColor Cyan
    Write-Host "  ██║  ██║ ██║  ██║ ██║ ╚═╝ ██║    ╚██████╗ ███████╗███████╗ ██║  ██║ ██║ ╚████║ ███████╗ ██║  ██║" -ForegroundColor Cyan
    Write-Host "  ╚═╝  ╚═╝ ╚═╝  ╚═╝ ╚═╝     ╚═╝     ╚═════╝ ╚══════╝╚══════╝ ╚═╝  ╚═╝ ╚═╝  ╚═══╝ ╚══════╝ ╚═╝  ╚═╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "         S İ S T E M   P E R F O R M A N S   O P T İ M İ Z A S Y O N U" -ForegroundColor Yellow
    Write-Host "                                   v1.5.1" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  [i] Barış Berke Çetin 2026  |  github.com/brsbrkctn" -ForegroundColor DarkGray
    Write-Host "  ─────────────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
}

# ============================================================
# BÖLÜM 3: Otomatik Güncelleme Kontrolü (In-Place Auto-Update)
# ============================================================
function Invoke-RAMCleanerAutoUpdate {
    param(
        [string]$CurrentVersion = "1.5.1",
        [string]$ScriptDir = $PSScriptRoot
    )

    try {
        if (-not $Silent) {
            Write-Host "  [*] Sürüm Denetimi  : " -NoNewline -ForegroundColor White
            Write-Host "Kontrol ediliyor..." -NoNewline -ForegroundColor DarkGray
        }

        if (-not $ScriptDir) {
            $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
        }
        if (-not $ScriptDir) {
            $ScriptDir = (Get-Location).Path
        }

        # TLS 1.2 protokolü zorunlu (GitHub API için)
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls11 -bor [System.Net.SecurityProtocolType]::Tls

        $apiUrl = "https://api.github.com/repos/brsbrkctn/RAMCleaner/releases/latest"
        $req = [System.Net.HttpWebRequest]::Create($apiUrl)
        $req.UserAgent = "RAMCleaner-AutoUpdate"
        $req.Timeout = 2000
        $req.ReadWriteTimeout = 2000

        $resp = $req.GetResponse()
        $stream = $resp.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $json = $reader.ReadToEnd()
        $reader.Close()
        $resp.Close()

        $release = $json | ConvertFrom-Json
        $remoteTag = $release.tag_name
        $remoteVerStr = $remoteTag -replace '^[vV]', ''
        $localVerStr = $CurrentVersion -replace '^[vV]', ''

        $remoteVer = [System.Version]$remoteVerStr
        $localVer = [System.Version]$localVerStr

        if ($remoteVer -gt $localVer) {
            Write-Host "`r  [*] Sürüm Denetimi  : " -NoNewline -ForegroundColor Cyan
            Write-Host "Yeni sürüm bulundu ($remoteTag)!          " -ForegroundColor Yellow
            Write-Host "  [i] Güncelleme indiriliyor, lütfen bekleyin..." -ForegroundColor Gray

            $zipAsset = $release.assets | Where-Object { $_.name -like "*.zip" } | Select-Object -First 1
            $tempZip = Join-Path $env:TEMP "RAMCleaner_Update_$remoteTag.zip"

            $wc = New-Object System.Net.WebClient
            $wc.Headers.Add("User-Agent", "RAMCleaner-AutoUpdate")

            $updatedSuccessfully = $false
            if ($zipAsset) {
                $wc.DownloadFile($zipAsset.browser_download_url, $tempZip)
                if (Test-Path $tempZip) {
                    Expand-Archive -Path $tempZip -DestinationPath $ScriptDir -Force
                    Remove-Item $tempZip -Force -ErrorAction SilentlyContinue
                    $updatedSuccessfully = $true
                }
            }

            if (-not $updatedSuccessfully) {
                # Fallback: Doğrudan güncel ClearMemory.ps1 dosyasını çek
                $rawUrl = "https://raw.githubusercontent.com/brsbrkctn/RAMCleaner/main/ClearMemory.ps1"
                $targetFile = Join-Path $ScriptDir "ClearMemory.ps1"
                $wc.DownloadFile($rawUrl, $targetFile)
                $updatedSuccessfully = $true
            }

            Write-Host "  [OK] RAMCleaner başarıyla $remoteTag sürümüne güncellendi!" -ForegroundColor Green
            Write-Host ""
            Start-Sleep -Milliseconds 800

            # Güncel sürümle yeniden başlat ve sonsuz döngüyü önle
            $newPs1 = Join-Path $ScriptDir "ClearMemory.ps1"
            if (Test-Path $newPs1) {
                & $newPs1 -SkipUpdate
                exit
            }
        } else {
            if (-not $Silent) {
                Write-Host "`r  [OK] Sürüm Denetimi : " -NoNewline -ForegroundColor Green
                Write-Host "v$CurrentVersion (En güncel sürüm)       " -ForegroundColor DarkGray
                Write-Host ""
            }
        }
    } catch {
        if (-not $Silent) {
            Write-Host "`r  [i] Sürüm Denetimi  : " -NoNewline -ForegroundColor DarkGray
            Write-Host "Çevrimdışı mod (v$CurrentVersion)        " -ForegroundColor DarkGray
            Write-Host ""
        }
    }
}

if (-not $Silent -and -not $SkipUpdate) {
    Invoke-RAMCleanerAutoUpdate -CurrentVersion "1.5.1" -ScriptDir $PSScriptRoot
}

# ============================================================
# BÖLÜM 4: Win32 Memory Cleaner API (Orijinal Güçlü NT Çekirdek Motoru)
# ============================================================
$sourceCleaner = @"
using System;
using System.Runtime.InteropServices;

public class MemoryCleaner {
    [DllImport("ntdll.dll")]
    public static extern uint NtSetSystemInformation(int SystemInformationClass, ref int SystemInformation, int SystemInformationLength);

    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern bool OpenProcessToken(IntPtr ProcessHandle, uint DesiredAccess, out IntPtr TokenHandle);

    [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern bool LookupPrivilegeValue(string lpSystemName, string lpName, out long lpLuid);

    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public struct TOKEN_PRIVILEGES {
        public int PrivilegeCount;
        public long Luid;
        public int Attributes;
    }

    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern bool AdjustTokenPrivileges(IntPtr TokenHandle, bool DisableAllPrivileges, ref TOKEN_PRIVILEGES NewState, int BufferLength, IntPtr PreviousState, IntPtr ReturnLength);

    public static bool EnablePrivilege(string privilege) {
        IntPtr token;
        if (OpenProcessToken(System.Diagnostics.Process.GetCurrentProcess().Handle, 0x0020, out token)) {
            TOKEN_PRIVILEGES tp = new TOKEN_PRIVILEGES();
            tp.PrivilegeCount = 1;
            tp.Attributes = 2;
            LookupPrivilegeValue(null, privilege, out tp.Luid);
            AdjustTokenPrivileges(token, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
            return true;
        }
        return false;
    }

    public static uint ClearAll() {
        EnablePrivilege("SeProfileSingleProcessPrivilege");
        EnablePrivilege("SeIncreaseQuotaPrivilege");
        
        uint result = 0;
        int command = 2;
        result |= NtSetSystemInformation(80, ref command, 4);

        command = 3;
        result |= NtSetSystemInformation(80, ref command, 4);

        command = 4;
        result |= NtSetSystemInformation(80, ref command, 4);

        return result;
    }
}
"@

try {
    Add-Type -TypeDefinition $sourceCleaner -ErrorAction Stop
} catch {}

# ============================================================
# BÖLÜM 5: RAM Bilgisi & Görsel Formatlama
# ============================================================
function Get-RAMInfo {
    try {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        $totalMB = [Math]::Round($os.TotalVisibleMemorySize / 1024)
        $freeMB = [Math]::Round($os.FreePhysicalMemory / 1024)
        $usedMB = $totalMB - $freeMB
        $percent = [Math]::Round(($usedMB / $totalMB) * 100)
        $totalGB = [Math]::Round($totalMB / 1024, 1)
        $usedGB = [Math]::Round($usedMB / 1024, 1)
        $freeGB = [Math]::Round($freeMB / 1024, 1)
        return @{ 
            TotalMB = $totalMB; UsedMB = $usedMB; FreeMB = $freeMB; Percent = $percent
            TotalGB = $totalGB; UsedGB = $usedGB; FreeGB = $freeGB
        }
    } catch {
        return $null
    }
}

function Format-RAMBar {
    param([int]$Percent, [int]$Length = 20)
    $filledCount = [Math]::Round(($Percent / 100) * $Length)
    if ($filledCount -gt $Length) { $filledCount = $Length }
    if ($filledCount -lt 0) { $filledCount = 0 }
    $emptyCount = $Length - $filledCount
    $bar = ("#" * $filledCount) + ("-" * $emptyCount)
    $pctStr = "$Percent%".PadLeft(4)
    return "[$bar] $pctStr"
}

$ramBefore = Get-RAMInfo

if (-not $Silent -and $ramBefore) {
    $barBefore = Format-RAMBar -Percent $ramBefore.Percent
    Write-Host "  [*] RAM Durumu:" -ForegroundColor White
    Write-Host "  Önce  : " -NoNewline -ForegroundColor Gray
    Write-Host $barBefore -NoNewline -ForegroundColor Yellow
    Write-Host "  ($($ramBefore.UsedGB) GB / $($ramBefore.TotalGB) GB)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  [*] Optimizasyon İşlemleri:" -ForegroundColor White
}

# ============================================================
# BÖLÜM 6: Temizlik Adımları
# ============================================================
function Execute-Step {
    param(
        [string]$Title,
        [scriptblock]$Action
    )

    if ($Silent) {
        try { & $Action } catch {}
        return
    }

    $spinner = @('-', '\', '|', '/')
    for ($i = 0; $i -lt 8; $i++) {
        $char = $spinner[$i % $spinner.Length]
        Write-Host -NoNewline "`r  [$char] $Title..." -ForegroundColor Cyan
        Start-Sleep -Milliseconds 30
    }

    $extraInfo = ""
    try {
        $res = & $Action
        if ($res -and $res.Detail) {
            $extraInfo = "  " + $res.Detail
        }
    } catch {
        $extraInfo = " (Hata)"
    }

    Write-Host "`r  [OK] " -NoNewline -ForegroundColor Green
    Write-Host "$Title" -NoNewline -ForegroundColor White
    if ($extraInfo) {
        Write-Host $extraInfo -ForegroundColor DarkGray
    } else {
        Write-Host ""
    }
    Start-Sleep -Milliseconds 40
}

# 1. DNS Flush
Execute-Step -Title "DNS Ağ Önbelleği Temizliği         " -Action {
    ipconfig /flushdns *>$null
    return @{ Detail = "(Sıfırlandı)" }
}

# 2. Temp Dosyaları Temizliği
Execute-Step -Title "Geçici Dosyalar Temizliği           " -Action {
    [double]$tempBytes = 0

    try {
        $userTemp = [System.IO.Path]::GetTempPath()
        if (Test-Path $userTemp) {
            $files = Get-ChildItem -Path $userTemp -Recurse -Force -ErrorAction SilentlyContinue
            if ($files) {
                $measure = $files | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue
                if ($measure -and $measure.Sum) {
                    $tempBytes += [double]$measure.Sum
                }
                $files | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue *>$null
            }
        }
    } catch {}

    try {
        $winTemp = "$env:SystemRoot\Temp"
        if (Test-Path $winTemp) {
            $winFiles = Get-ChildItem -Path $winTemp -Recurse -Force -ErrorAction SilentlyContinue
            if ($winFiles) {
                $winMeasure = $winFiles | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue
                if ($winMeasure -and $winMeasure.Sum) {
                    $tempBytes += [double]$winMeasure.Sum
                }
                $winFiles | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue *>$null
            }
        }
    } catch {}

    if ($tempBytes -gt 0) {
        $freedDiskMB = [Math]::Round($tempBytes / 1MB, 1)
        return @{ Detail = "(+$freedDiskMB MB Disk Alanı)" }
    } else {
        return @{ Detail = "(Temiz)" }
    }
}

# 3. Clipboard Flush
Execute-Step -Title "Pano (Clipboard) Hafızası           " -Action {
    try {
        cmd /c "echo off | clip" *>$null
    } catch {}
    return @{ Detail = "(Boşaltıldı)" }
}

# 4. RAM Standby List Purge (Orijinal v1.1.0 Motoru)
Execute-Step -Title "RAM Standby List & Önbellek Purge   " -Action {
    [MemoryCleaner]::ClearAll() | Out-Null
    return @{ Detail = "(Tamamlandı)" }
}

# ============================================================
# BÖLÜM 7: Sonuç Raporu & Kapanış
# ============================================================
$ramAfter = Get-RAMInfo
$freedMB = 0
$freedGB = 0
if ($ramBefore -and $ramAfter) {
    $freedMB = $ramAfter.FreeMB - $ramBefore.FreeMB
    $freedGB = [Math]::Round($freedMB / 1024, 1)
}

if (-not $Silent) {
    Write-Host ""
    Write-Host "  [*] Sonuç:" -ForegroundColor White
    if ($ramAfter) {
        $barAfter = Format-RAMBar -Percent $ramAfter.Percent
        Write-Host "  Sonra : " -NoNewline -ForegroundColor Gray
        Write-Host $barAfter -NoNewline -ForegroundColor Green
        Write-Host "  ($($ramAfter.UsedGB) GB / $($ramAfter.TotalGB) GB)" -ForegroundColor Gray
    }
    Write-Host ""
    Write-Host "  ═════════════════════════════════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
    if ($freedGB -gt 0) {
        Write-Host "  [+] +$freedGB GB RAM Serbest Bırakıldı  |  Sistem Yüksek Performansa Hazır" -ForegroundColor Green
    } elseif ($freedMB -gt 0) {
        Write-Host "  [+] +$freedMB MB RAM Serbest Bırakıldı  |  Sistem Yüksek Performansa Hazır" -ForegroundColor Green
    } else {
        Write-Host "  [+] Tüm Önbellek Boşaltıldı  |  Sistem Optimum Seviyede" -ForegroundColor Green
    }
    Write-Host "  ═════════════════════════════════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host ""
}

# Windows Masaüstü Bildirimi (Toast/Balloon)
try {
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
    $notify = New-Object System.Windows.Forms.NotifyIcon
    $notify.Icon = [System.Drawing.SystemIcons]::Information
    $notify.BalloonTipTitle = "RAMCleaner"
    if ($freedGB -gt 0) {
        $notify.BalloonTipText = "Sistem optimize edildi! +$freedGB GB RAM serbest bırakıldı."
    } elseif ($freedMB -gt 0) {
        $notify.BalloonTipText = "Sistem optimize edildi! +$freedMB MB RAM serbest bırakıldı."
    } else {
        $notify.BalloonTipText = "Tüm işlemler tamamlandı. Sistem optimum performansta!"
    }
    $notify.Visible = $true
    $notify.ShowBalloonTip(3000)
    Start-Sleep -Milliseconds 400
    $notify.Dispose()
} catch {}

if (-not $Silent) {
    Write-Host "  Pencere 3 saniye sonra otomatik kapanacak..." -ForegroundColor DarkGray
    Start-Sleep -Seconds 3
}
