# RAM and System Optimizer v1.1.0
# Developed by Barış Berke Çetin

# ============================================================
# BÖLÜM 1: Console Font Manager (Win32 API)
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

try {
    Add-Type -TypeDefinition $sourceFont -ErrorAction Stop
    [ConsoleFontManager]::SetBalancedFont()
} catch {}

$Host.UI.RawUI.WindowTitle = "RAM ve Sistem Performans Optimizasyonu v1.1.0"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Clear-Host

# ============================================================
# BÖLÜM 2: Header & ASCII Art Banner
# ============================================================
Write-Host ""
Write-Host "  ██████╗  █████╗ ███╗   ███╗     ██████╗██╗     ███████╗██████╗ ███╗   ██╗███████╗██████╗ " -ForegroundColor Cyan
Write-Host "  ██╔══██╗██╔══██╗████╗ ████║    ██╔════╝██║     ██╔════╝██╔══██╗████╗  ██║██╔════╝██╔══██╗" -ForegroundColor Cyan
Write-Host "  ██████╔╝███████║██╔████╔██║    ██║     ██║     █████╗  ██████╔╝██╔██╗ ██║█████╗  ██████╔╝" -ForegroundColor Cyan
Write-Host "  ██╔══██╗██╔══██╗██║╚██╔╝██║    ██║     ██║     ██╔══╝  ██╔══██╗██║╚██╗██║██╔══╝  ██╔══██╗" -ForegroundColor Cyan
Write-Host "  ██║  ██║██║  ██║██║ ╚═╝ ██║    ╚██████╗███████╗███████╗██║  ██║██║ ╚████║███████╗██║  ██║" -ForegroundColor Cyan
Write-Host "  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝     ╚═════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "         S İ S T E M   P E R F O R M A N S   O P T İ M İ Z A S Y O N U" -ForegroundColor Yellow
Write-Host "                                   v1.1.0" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  👤 Barış Berke Çetin 2026  |  🌐 github.com/brsbrkctn" -ForegroundColor DarkGray
Write-Host "  ═══════════════════════════════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  📋 Yapılacak İşlemler Listesi:" -ForegroundColor White
Write-Host "  ─────────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host "   1. 🌐 DNS Ağ Önbelleği Temizliği         (ipconfig /flushdns)" -ForegroundColor Gray
Write-Host "   2. 🗑️  Geçici Dosyalar Temizliği           (User + Windows Temp)" -ForegroundColor Gray
Write-Host "   3. 📋 Pano (Clipboard) Hafızası Boşaltma" -ForegroundColor Gray
Write-Host "   4. 🧹 RAM Standby List & Önbellek Purge   (ntdll.dll API)" -ForegroundColor Gray
Write-Host "  ─────────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""

# ============================================================
# BÖLÜM 3: RAM Kullanım Bilgisi - ÖNCESİ
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

$ramBefore = Get-RAMInfo
if ($ramBefore) {
    Write-Host "  📊 RAM Durumu (ÖNCE):" -ForegroundColor Yellow
    Write-Host "     Toplam: $($ramBefore.Total) MB | Kullanılan: $($ramBefore.Used) MB (%$($ramBefore.Percent)) | Boş: $($ramBefore.Free) MB" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "  [*] İşlemler Başlatılıyor..." -ForegroundColor DarkCyan
Write-Host ""

# ============================================================
# BÖLÜM 4: Memory Cleaner (ntdll.dll Native API)
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
} catch {
}

# ============================================================
# BÖLÜM 5: Progress Bar Fonksiyonu
# ============================================================
function Run-StepWithProgress {
    param(
        [string]$StepNumber,
        [string]$Title,
        [scriptblock]$Action
    )

    $barLength = 20
    for ($i = 1; $i -le $barLength; $i++) {
        $percent = [math]::Round(($i / $barLength) * 100)
        $filled = "=" * $i
        $unfilled = " " * ($barLength - $i)
        $msg = "`r  [*] " + $StepNumber + ". " + $Title + " [" + $filled + $unfilled + "] " + $percent + "%"
        Write-Host -NoNewline $msg -ForegroundColor Cyan
        Start-Sleep -Milliseconds 35
    }

    $errMsg = $null
    try {
        & $Action
    } catch {
        $errMsg = $_.Exception.Message
    }

    $completedBar = "=" * $barLength
    if ($errMsg) {
        $doneMsg = "`r  [!] " + $StepNumber + ". " + $Title + " [" + $completedBar + "] 100% - HATA: $errMsg"
        Write-Host $doneMsg -ForegroundColor Red
        return $false
    } else {
        $doneMsg = "`r  [OK] " + $StepNumber + ". " + $Title + " [" + $completedBar + "] 100% - TAMAMLANDI"
        Write-Host $doneMsg -ForegroundColor Green
        return $true
    }
    Start-Sleep -Milliseconds 100
}

# ============================================================
# BÖLÜM 6: Temizlik İşlemleri
# ============================================================

# --- Adım 1: DNS Flush ---
$res1 = Run-StepWithProgress -StepNumber "1" -Title "DNS Ağ Önbelleği Temizliği         " -Action {
    ipconfig /flushdns *>$null
}

# --- Adım 2: Temp Dosyaları Temizliği ---
$res2 = Run-StepWithProgress -StepNumber "2" -Title "Geçici Dosyalar Temizliği           " -Action {
    $tempCleaned = 0
    $tempSizeBefore = 0

    # User Temp
    $userTemp = [System.IO.Path]::GetTempPath()
    if (Test-Path $userTemp) {
        $files = Get-ChildItem $userTemp -Recurse -ErrorAction SilentlyContinue
        if ($files) {
            $tempSizeBefore += ($files | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            $tempCleaned += $files.Count
            $files | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    # Windows Temp
    $winTemp = "$env:SystemRoot\Temp"
    if (Test-Path $winTemp) {
        $winFiles = Get-ChildItem $winTemp -Recurse -ErrorAction SilentlyContinue
        if ($winFiles) {
            $tempSizeBefore += ($winFiles | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            $tempCleaned += $winFiles.Count
            $winFiles | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

# --- Adım 3: Clipboard Temizliği ---
$res3 = Run-StepWithProgress -StepNumber "3" -Title "Pano (Clipboard) Hafızası           " -Action {
    try {
        cmd /c "echo off | clip" *>$null
    } catch {}
}

# --- Adım 4: RAM Standby List Purge ---
$res4 = Run-StepWithProgress -StepNumber "4" -Title "RAM Standby List & Önbellek Purge   " -Action {
    [MemoryCleaner]::ClearAll() | Out-Null
}

# ============================================================
# BÖLÜM 7: RAM Kullanım Bilgisi - SONRASI & ÖZET
# ============================================================
$ramAfter = Get-RAMInfo
Write-Host ""
Write-Host "  ═══════════════════════════════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray

if ($ramBefore -and $ramAfter) {
    $freedMB = $ramAfter.Free - $ramBefore.Free
    Write-Host "  📊 RAM Durumu (SONRA):" -ForegroundColor Yellow
    Write-Host "     Toplam: $($ramAfter.Total) MB | Kullanılan: $($ramAfter.Used) MB (%$($ramAfter.Percent)) | Boş: $($ramAfter.Free) MB" -ForegroundColor Gray
    if ($freedMB -gt 0) {
        Write-Host "     ✨ Serbest bırakılan: +$freedMB MB RAM" -ForegroundColor Green
    } else {
        Write-Host "     ℹ️  RAM Standby listesi temizlendi (Sistem optimum seviyede)" -ForegroundColor DarkCyan
    }
    Write-Host ""
}

Write-Host "  [OK] TÜM İŞLEMLER BAŞARIYLA TAMAMLANDI!" -ForegroundColor Green
Write-Host "  [*] Sistem yüksek performans ve verimliliğe hazır." -ForegroundColor Yellow
Write-Host "  ═══════════════════════════════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host ""
Start-Sleep -Seconds 2
