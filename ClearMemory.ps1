param(
    [switch]$Silent
)

$ConfirmPreference = 'None'
$ErrorActionPreference = 'SilentlyContinue'

# RAM and System Optimizer v1.3.0
# Developed by Barış Berke Çetin

# ============================================================
# BÖLÜM 1: Console Background, Font & Window Manager
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

    public static void SetBalancedFont() {
        try {
            IntPtr hOut = GetStdHandle(-11);
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
    } catch {}

    $Host.UI.RawUI.WindowTitle = "RAM ve Sistem Performans Optimizasyonu v1.3.0"
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
    Write-Host "                                   v1.3.0" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  [i] Barış Berke Çetin 2026  |  github.com/brsbrkctn" -ForegroundColor DarkGray
    Write-Host "  ─────────────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
}

# ============================================================
# BÖLÜM 3: Win32 Memory & Process Cleaner API
# ============================================================
$sourceCleaner = @"
using System;
using System.Runtime.InteropServices;
using System.Diagnostics;

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

    [DllImport("psapi.dll", SetLastError = true)]
    public static extern bool EmptyWorkingSet(IntPtr hProcess);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr OpenProcess(uint processAccess, bool bInheritHandle, int processId);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool CloseHandle(IntPtr hObject);

    public static bool EnablePrivilege(string privilege) {
        IntPtr token;
        if (OpenProcessToken(Process.GetCurrentProcess().Handle, 0x0020, out token)) {
            TOKEN_PRIVILEGES tp = new TOKEN_PRIVILEGES();
            tp.PrivilegeCount = 1;
            tp.Attributes = 2;
            LookupPrivilegeValue(null, privilege, out tp.Luid);
            AdjustTokenPrivileges(token, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
            return true;
        }
        return false;
    }

    public static int TrimAllProcessesWorkingSet() {
        int trimmedCount = 0;
        Process[] processes = Process.GetProcesses();
        foreach (Process p in processes) {
            try {
                if (p.Id == 0 || p.Id == 4) continue;
                IntPtr hProcess = OpenProcess(0x001F0FFF, false, p.Id);
                if (hProcess != IntPtr.Zero) {
                    if (EmptyWorkingSet(hProcess)) {
                        trimmedCount++;
                    }
                    CloseHandle(hProcess);
                }
            } catch {}
        }
        return trimmedCount;
    }

    public static uint ClearStandbyMemory() {
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
# BÖLÜM 4: RAM Bilgisi & Görsel Formatlama
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
# BÖLÜM 5: Temizlik Adımları
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

# 2. Temp & Thumbnail Cache
Execute-Step -Title "Geçici Dosyalar & Thumbnail Cache   " -Action {
    $tempCleaned = 0
    $tempBytes = 0

    $userTemp = [System.IO.Path]::GetTempPath()
    if (Test-Path $userTemp) {
        $files = Get-ChildItem $userTemp -Recurse -Force -ErrorAction SilentlyContinue
        if ($files) {
            $tempBytes += ($files | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            $tempCleaned += $files.Count
            $files | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
        }
    }

    $winTemp = "$env:SystemRoot\Temp"
    if (Test-Path $winTemp) {
        $winFiles = Get-ChildItem $winTemp -Recurse -Force -ErrorAction SilentlyContinue
        if ($winFiles) {
            $tempBytes += ($winFiles | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            $tempCleaned += $winFiles.Count
            $winFiles | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
        }
    }

    $thumbPath = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
    if (Test-Path $thumbPath) {
        $thumbFiles = Get-ChildItem $thumbPath -Filter "thumbcache_*.db" -Force -ErrorAction SilentlyContinue
        if ($thumbFiles) {
            $tempBytes += ($thumbFiles | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            $tempCleaned += $thumbFiles.Count
            $thumbFiles | Remove-Item -Force -Confirm:$false -ErrorAction SilentlyContinue
        }
    }

    $freedDiskMB = [Math]::Round($tempBytes / 1MB, 1)
    if ($freedDiskMB -gt 0) {
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

# 4. Working Set Trim
Execute-Step -Title "Arka Plan Uygulama Bellek Trim       " -Action {
    $count = [MemoryCleaner]::TrimAllProcessesWorkingSet()
    return @{ Detail = "($count işlem optimize edildi)" }
}

# 5. Standby List Purge
Execute-Step -Title "RAM Standby List & Önbellek Purge   " -Action {
    [MemoryCleaner]::ClearStandbyMemory() | Out-Null
    return @{ Detail = "(Tamamlandı)" }
}

# ============================================================
# BÖLÜM 6: Sonuç Raporu & Kapanış
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
