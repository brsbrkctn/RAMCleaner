# RAMCleaner ⚡

**RAMCleaner** is a lightweight, zero-dependency, open-source Windows performance & RAM cache optimization tool written in Batch, PowerShell, and native C# Win32 APIs (`ntdll.dll`).

Designed to run natively on any **Windows 10** or **Windows 11** machine out of the box without requiring third-party executable downloads, installer setups, or runtime dependencies.

---

## ✨ Key Features

- **🚀 Native Standby List Purge**: Calls native Windows NT API (`NtSetSystemInformation` via `ntdll.dll`) with `SeProfileSingleProcessPrivilege` to safely purge Windows Standby Memory and Modified Page List without stripping active process working sets.
- **🌐 Network & DNS Cache Flush**: Clears stale DNS resolver entries using `ipconfig /flushdns` to reduce latency and prevent micro-stutters during online gaming or network-heavy workloads.
- **🗑️ Temp File Cleaning**: Safely cleans temporary user and system files (`%TEMP%` and `C:\Windows\Temp`).
- **📋 Clipboard Flush**: Empties memory-bound clipboard contents using native PowerShell.
- **📊 RAM Usage Display**: Shows before/after RAM statistics including freed memory.
- **🎨 Interactive Visual Console**: Real-time progress bar animations with Unicode block characters, step-by-step progress tracking, and ANSI/UTF-8 color support.
- **🔤 Dynamic High-DPI Font Scaling**: Automatically forces 16pt Bold Consolas font via Win32 API (`SetCurrentConsoleFontEx`) and Windows Console Registry overrides for crisp readability on high-resolution displays.
- **🔐 Automatic UAC Elevation**: Automatically prompts for Administrator privileges via Windows UAC when executed.
- **📝 Cleanup Reporting**: Displays number of cleaned files and freed disk space.
- **⚠️ Error Reporting**: Shows clear error messages if any operation fails.

---

## 🛠️ How It Works

Windows Memory Manager holds cached files in the **Standby List**. While Windows automatically yields Standby Memory when needed, background applications and SysMain can cause disk I/O spikes when prefetching files.

`RAMCleaner` purges the Standby List and Modified Page List directly via the Windows Native API:
1. `MemoryFlushModifiedList` (Flush modified pages to disk)
2. `MemoryPurgeStandbyList` (Purge Standby Memory Cache)
3. `MemoryPurgeLowPriorityStandbyList` (Purge low-priority cache)

Because it targets Standby Memory directly rather than aggressively evicting active process working sets, running applications remain stable without immediately reloading their memory into the Standby List.

---

## 🚀 Getting Started

### Quick Start
1. Download the latest release from [GitHub Releases](https://github.com/brsbrkctn/ramcleaner/releases).
2. Extract the zip file to any directory.
3. Double-click `RAM_Temizle.bat` (or run `CreateDesktopShortcut.bat` to place a shortcut on your Desktop).

### Running via Command Line
```cmd
RAM_Temizle.bat
```

---

## 📂 Repository Structure

```
RAMCleaner/
├── RAM_Temizle.bat           # Launcher script with auto-UAC elevation
├── ClearMemory.ps1           # Visual engine & Win32 API Standby List purge
├── CreateDesktopShortcut.bat # Utility script to create a Desktop shortcut
├── README.md                 # Project documentation
├── CHANGELOG.md              # Version release history
├── ANALIZ_2026-08-18.md      # Detailed project analysis report
└── LICENSE                   # MIT License
```

---

## 📊 Example Output

```
  [✓] 1. DNS Ağ Önbelleği Temizliği         [█████████████████████████] 100% - TAMAMLANDI
  [✓] 2. Geçici Dosyalar Temizliği           [█████████████████████████] 100% - TAMAMLANDI
     📁 Temizlenen: 142 dosya | 45.23 MB yer açıldı
  [✓] 3. Pano (Clipboard) Hafızası           [█████████████████████████] 100% - TAMAMLANDI
  [✓] 4. RAM Standby List & Önbellek Purge   [█████████████████████████] 100% - TAMAMLANDI

  📊 RAM Durumu (SONRA):
     Toplam: 16384 MB | Kullanılan: 8192 MB (%50) | Boş: 8192 MB
     ✨ Serbest bırakılan: +512 MB RAM

  [✓] TÜM İŞLEMLER BAŞARIYLA TAMAMLANDI!
```

---

## 📜 Requirements

- **OS**: Windows 10 or Windows 11 (64-bit)
- **Privileges**: Administrator Rights (UAC prompt is handled automatically)
- **Dependencies**: None (Uses built-in PowerShell 5.1 & Windows API)

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
