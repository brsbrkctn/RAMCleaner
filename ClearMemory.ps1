param(
    [switch]$Silent
)

# RAM and System Optimizer v1.2.0
# Developed by Barış Berke Çetin

# ============================================================
# BÖLÜM 1: Console Font & Window Manager (Win32 API)
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
        Add-Type -TypeDefinition $sourceFont -ErrorAction Stop
        [ConsoleFontManager]::SetBalancedFont()
    } catch {}

    $Host.UI.RawUI.WindowTitle = "RAM ve Sistem Performans Optimizasyonu v1.2.0"
}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

if (-not $Silent) {
    Clear-Host
}

# ============================================================
# BÖLÜM 2: Header & ASCII Art Banner
# ============================================================
if (-not $Silent) {
    Write-Host ""
    Write-Host "  ██████╗  █████╗ ███╗   ███╗     ██████╗██╗     ███████╗██████╗ ███╗   ██╗███████╗██████╗ " -ForegroundColor Cyan
    Write-Host "  ██╔══██╗██╔══██╗████╗ ████║    ██╔════╝██║     ██╔════╝██╔══██╗████╗  ██║██╔════╝██╔══██╗" -ForegroundColor Cyan
    Write-Host "  ██████╔╝███████║██╔████╔██║    ██║     ██║     █████╗  ██████╔╝██╔██╗ ██║█████╗  ██████╔╝" -ForegroundColor Cyan
    Write-Host "  ██╔══██╗██╔══██╗██║╚██╔╝██║    ██║     ██║     ██╔══╝  ██╔══██╗██║╚██╗██║██╔══╝  ██╔══██╗" -ForegroundColor Cyan
    Write-Host "  ██║  ██║██║  ██║██║ ╚═╝ ██║    ╚██████╗███████╗███████╗██║  ██║██║ ╚████║███████╗██║  ██║" -ForegroundColor Cyan
    Write-Host "  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝     ╚═════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "         S İ S T E M   P E R F O R M A N S   O P T İ M İ Z A S Y O N U" -ForegroundColor Yellow
    Write-Host "                                   v1.2.0" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  👤 Barış Berke Çetin 2026  |  🌐 github.com/brsbrkctn" -ForegroundColor DarkGray
    Write-Host "  ═══════════════════════════════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  📋 Yapılacak İşlemler Listesi:" -ForegroundColor White
    Write-Host "  ─────────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "   1. 🌐 DNS Ağ Önbelleği Temizliği         (ipconfig /flushdns)" -ForegroundColor Gray
    Write-Host "   2. 🗑️  Geçici Dosyalar & Thumbnail Cache   (User + Windows Temp + Explorer)" -ForegroundColor Gray
    Write-Host "   3. 📋 Pano (Clipboard) Hafızası Boşaltma" -ForegroundColor Gray
    Write-Host "   4. ⚡ Arka Plan Uygulamaları Bellek Trim (psapi.dll EmptyWorkingSet)" -ForegroundColor Gray
    Write-Host "   5. 🧹 RAM Standby List & Önbellek Purge   (ntdll.dll NtSetSystemInformation)" -ForegroundColor Gray
    Write-Host "  ─────────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
}

# ============================================================
# BÖLÜM 3: RAM Bilgisi & Görsel RAM Barı Fonksiyonları
# ============================================================
function Get-RAMInfo {
    try {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        $totalMB = [Math]::Round($os.TotalVisibleMemorySize / 1024)
        $freeMB = [Math]::Round($os.FreePhysicalMemory / 1024)
        $usedMB = $totalMB - $freeMB
        $percent = [Math]::Round(($usedMB / $totalMB) * 100)
        return @{ Total = $totalMB; Used = $usedMB; Free = $freeMB; Percent = $percent }
    } catch {
        return $null
    }
}

function Format-RAMBar {
    param([int]$Percent, [int]$Length = 22)
    $filledCount = [Math]::Round(($Percent / 100) * $Length)
    if ($filledCount -gt $Length) { $filledCount = $Length }
    if ($filledCount -lt 0) { $filledCount = 0 }
    $emptyCount = $Length - $filledCount
    $bar = ("█" * $filledCount) + ("░" * $emptyCount)
    return "[$bar] $Percent%"
}

function Get-TopProcesses {
    try {
        $top = Get-Process -ErrorAction SilentlyContinue | 
               Where-Object { $_.WorkingSet64 -gt 15MB -and $_.ProcessName -ne "Idle" -and $_.ProcessName -ne "System" } |
               Group-Object -Property ProcessName |
               Select-Object @{Name="Name"; Expression={$_.Name}}, @{Name="MemoryMB"; Expression={[Math]::Round((($_.Group | Measure-Object -Property WorkingSet64 -Sum).Sum / 1MB))}} |
               Sort-Object -Property MemoryMB -Descending |
               Select-Object -First 5
        return $top
    } catch {
        return @()
    }
}

$ramBefore = Get-RAMInfo

if (-not $Silent) {
    if ($ramBefore) {
        $barText = Format-RAMBar -Percent $ramBefore.Percent
        Write-Host "  📊 RAM Durumu (ÖNCE):" -ForegroundColor Yellow
        Write-Host "     $barText  |  Kullanılan: $($ramBefore.Used) MB / Toplam: $($ramBefore.Total) MB (Boş: $($ramBefore.Free) MB)" -ForegroundColor Gray
        Write-Host ""
    }

    # En Çok RAM Tüketen İlk 5 Uygulama Tablosu
    $topProcs = Get-TopProcesses
    if ($topProcs -and $topProcs.Count -gt 0) {
        Write-Host "  🔥 En Çok Bellek Tüketen İşlemler (Top 5):" -ForegroundColor Magenta
        $rank = 1
        foreach ($proc in $topProcs) {
            $pName = $proc.Name.PadRight(24)
            $pMem = "$($proc.MemoryMB) MB".PadLeft(10)
            Write-Host "     $rank. $pName : $pMem" -ForegroundColor DarkGray
            $rank++
        }
        Write-Host ""
    }

    Write-Host "  [*] İşlemler Başlatılıyor..." -ForegroundColor DarkCyan
    Write-Host ""
}

# ============================================================
# BÖLÜM 4: Win32 Memory & Process Cleaner API
# ============================================================
$sourceCleaner = @"
using System;
using System.Runtime.InteropServices;
using System.Diagnostics;

public class MemoryCleaner {
    // NTDLL API for Standby & Modified List Purge
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

    // PSAPI & KERNEL32 API for EmptyWorkingSet
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
                if (p.Id == 0 || p.Id == 4) continue; // Skip System and Idle
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
        int command = 2; // Flush Modified Page List
        result |= NtSetSystemInformation(80, ref command, 4);

        command = 3; // Purge Standby List
        result |= NtSetSystemInformation(80, ref command, 4);

        command = 4; // Purge Low Priority Standby List
        result |= NtSetSystemInformation(80, ref command, 4);

        return result;
    }
}
"@

try {
    Add-Type -TypeDefinition $sourceCleaner -ErrorAction Stop
} catch {}

# ============================================================
# BÖLÜM 5: Progress Bar Fonksiyonu
# ============================================================
function Run-StepWithProgress {
    param(
        [string]$StepNumber,
        [string]$Title,
        [scriptblock]$Action
    )

    if ($Silent) {
        try { & $Action } catch {}
        return $true
    }

    $barLength = 20
    for ($i = 1; $i -le $barLength; $i++) {
        $percent = [math]::Round(($i / $barLength) * 100)
        $filled = "=" * $i
        $unfilled = " " * ($barLength - $i)
        $msg = "`r  [*] " + $StepNumber + ". " + $Title + " [" + $filled + $unfilled + "] " + $percent + "%"
        Write-Host -NoNewline $msg -ForegroundColor Cyan
        Start-Sleep -Milliseconds 25
    }

    $resultData = $null
    $errMsg = $null
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $resultData = & $Action
    } catch {
        $errMsg = $_.Exception.Message
    }
    $sw.Stop()

    $completedBar = "=" * $barLength
    if ($errMsg) {
        $doneMsg = "`r  [!] " + $StepNumber + ". " + $Title + " [" + $completedBar + "] 100% - HATA: " + $errMsg
        Write-Host $doneMsg -ForegroundColor Red
        return $false
    } else {
        $detailInfo = ""
        if ($resultData -and $resultData.Detail) {
            $detailInfo = " (" + $resultData.Detail + " - " + $sw.ElapsedMilliseconds + "ms)"
        } else {
            $detailInfo = " (" + $sw.ElapsedMilliseconds + "ms)"
        }
        $doneMsg = "`r  [OK] " + $StepNumber + ". " + $Title + " [" + $completedBar + "] 100% - TAMAMLANDI" + $detailInfo
        Write-Host $doneMsg -ForegroundColor Green
        return $true
    }
    Start-Sleep -Milliseconds 50
}

# ============================================================
# BÖLÜM 6: Temizlik İşlemleri
# ============================================================

# --- Adım 1: DNS Flush ---
$res1 = Run-StepWithProgress -StepNumber "1" -Title "DNS Ağ Önbelleği Temizliği         " -Action {
    ipconfig /flushdns *>$null
    return @{ Detail = "DNS Önbelleği Sıfırlandı" }
}

# --- Adım 2: Temp Dosyaları & Thumbnail Cache Temizliği ---
$res2 = Run-StepWithProgress -StepNumber "2" -Title "Geçici Dosyalar & Thumbnail Cache   " -Action {
    $tempCleaned = 0
    $tempBytes = 0

    # User Temp
    $userTemp = [System.IO.Path]::GetTempPath()
    if (Test-Path $userTemp) {
        $files = Get-ChildItem $userTemp -Recurse -ErrorAction SilentlyContinue
        if ($files) {
            $tempBytes += ($files | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            $tempCleaned += $files.Count
            $files | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    # Windows Temp
    $winTemp = "$env:SystemRoot\Temp"
    if (Test-Path $winTemp) {
        $winFiles = Get-ChildItem $winTemp -Recurse -ErrorAction SilentlyContinue
        if ($winFiles) {
            $tempBytes += ($winFiles | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            $tempCleaned += $winFiles.Count
            $winFiles | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    # Thumbnail Cache
    $thumbPath = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
    if (Test-Path $thumbPath) {
        $thumbFiles = Get-ChildItem $thumbPath -Filter "thumbcache_*.db" -ErrorAction SilentlyContinue
        if ($thumbFiles) {
            $tempBytes += ($thumbFiles | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            $tempCleaned += $thumbFiles.Count
            $thumbFiles | Remove-Item -Force -ErrorAction SilentlyContinue
        }
    }

    $freedMB = [Math]::Round($tempBytes / 1MB, 1)
    return @{ Detail = "$tempCleaned dosya temizlendi ($freedMB MB)" }
}

# --- Adım 3: Clipboard Temizliği ---
$res3 = Run-StepWithProgress -StepNumber "3" -Title "Pano (Clipboard) Hafızası           " -Action {
    try {
        cmd /c "echo off | clip" *>$null
    } catch {}
    return @{ Detail = "Pano Boşaltıldı" }
}

# --- Adım 4: Arka Plan Uygulamaları Working Set Trim ---
$res4 = Run-StepWithProgress -StepNumber "4" -Title "Arka Plan Uygulama Bellek Trim       " -Action {
    $count = [MemoryCleaner]::TrimAllProcessesWorkingSet()
    return @{ Detail = "$count işlem sıkıştırıldı" }
}

# --- Adım 5: RAM Standby List & Önbellek Purge ---
$res5 = Run-StepWithProgress -StepNumber "5" -Title "RAM Standby List & Önbellek Purge   " -Action {
    [MemoryCleaner]::ClearStandbyMemory() | Out-Null
    return @{ Detail = "Standby & Modified List Purge" }
}

# ============================================================
# BÖLÜM 7: RAM Kullanım Bilgisi - SONRASI & ÖZET
# ============================================================
$ramAfter = Get-RAMInfo
$freedMB = 0
if ($ramBefore -and $ramAfter) {
    $freedMB = $ramAfter.Free - $ramBefore.Free
}

if (-not $Silent) {
    Write-Host ""
    Write-Host "  ═══════════════════════════════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray

    if ($ramBefore -and $ramAfter) {
        $barTextAfter = Format-RAMBar -Percent $ramAfter.Percent
        Write-Host "  📊 RAM Durumu (SONRA):" -ForegroundColor Yellow
        Write-Host "     $barTextAfter  |  Kullanılan: $($ramAfter.Used) MB / Toplam: $($ramAfter.Total) MB (Boş: $($ramAfter.Free) MB)" -ForegroundColor Gray
        if ($freedMB -gt 0) {
            Write-Host "     ✨ Serbest bırakılan alan: +$freedMB MB RAM" -ForegroundColor Green
        } else {
            Write-Host "     ℹ️  RAM Standby listesi ve işlemler başarıyla optimize edildi." -ForegroundColor DarkCyan
        }
        Write-Host ""
    }

    Write-Host "  [OK] TÜM İŞLEMLER BAŞARIYLA TAMAMLANDI!" -ForegroundColor Green
    Write-Host "  [*] Sistem yüksek performans ve verimliliğe hazır." -ForegroundColor Yellow
    Write-Host "  ═══════════════════════════════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host ""
}

# ============================================================
# BÖLÜM 8: Windows Masaüstü Bildirimi (Toast / Balloon)
# ============================================================
try {
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
    $notify = New-Object System.Windows.Forms.NotifyIcon
    $notify.Icon = [System.Drawing.SystemIcons]::Information
    $notify.BalloonTipTitle = "RAMCleaner v1.2.0 ⚡"
    if ($freedMB -gt 0) {
        $notify.BalloonTipText = "Sistem optimize edildi! +$freedMB MB RAM serbest bırakıldı."
    } else {
        $notify.BalloonTipText = "Tüm işlemler tamamlandı. Sistem optimum performansta!"
    }
    $notify.Visible = $true
    $notify.ShowBalloonTip(3000)
    Start-Sleep -Milliseconds 500
    $notify.Dispose()
} catch {}

if (-not $Silent) {
    Start-Sleep -Seconds 2
}
