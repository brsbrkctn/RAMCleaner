# RAMCleaner ⚡

**RAMCleaner** is a lightweight, zero-dependency, open-source Windows performance & RAM cache optimization tool written in Batch, PowerShell, and native C# Win32 APIs (`ntdll.dll` and `psapi.dll`).

Designed to run natively on any **Windows 10** or **Windows 11** machine out of the box without requiring third-party executable downloads, installer setups, or runtime dependencies.

---

## ✨ Key Features

- **🚀 Native Standby List Purge**: Calls native Windows NT API (`NtSetSystemInformation` via `ntdll.dll`) with `SeProfileSingleProcessPrivilege` to safely purge Windows Standby Memory and Modified Page List.
- **⚡ Background Working Set Optimization**: Leverages Win32 PSAPI (`EmptyWorkingSet`) to aggressively reclaim unused working set memory from background processes.
- **📊 Graphical RAM Capacity Bar**: Interactive before/after ASCII memory capacity bars (`[████████░░░░] %40`) showing real-time memory pressure.
- **🔥 Top 5 Memory Consumers**: Displays real-time process list showing top RAM-heavy applications.
- **🔔 Windows Desktop Toast Notifications**: Native zero-dependency Windows balloon/toast notifications showing total freed memory upon completion.
- **🌐 Network & DNS Cache Flush**: Clears stale DNS resolver entries using `ipconfig /flushdns` to reduce latency and prevent micro-stutters.
- **🗑️ Temp & Thumbnail Cleaning**: Safely cleans temporary user files, system temp, and Windows Explorer thumbnail databases (`thumbcache_*.db`).
- **📋 Clipboard Flush**: Empties memory-bound clipboard contents using native PowerShell.
- **🔤 Dynamic 16pt Font Scaling**: Automatically forces 16pt Bold Consolas font via Win32 API (`SetCurrentConsoleFontEx`) for crisp readability on high-DPI displays.
- **🤫 Headless Silent Mode**: Run silent optimizations in the background with `--silent` flag.
- **⏰ One-Click Auto-Scheduler**: Schedule automatic background cleaning on user login (`OtoTemizle_Kur.bat`).
- **🔐 Automatic UAC Elevation**: Automatically prompts for Administrator privileges via Windows UAC with anti-loop protection.

---

## 🛠️ How It Works

Windows Memory Manager holds cached files in the **Standby List** and allocates memory for active processes in **Working Sets**.

`RAMCleaner` performs a 5-step optimization sequence:
1. **DNS Resolver Flush**: Flushes Windows DNS cache to clear socket pools.
2. **Temporary & Thumbnail Cache Wipe**: Cleans `%TEMP%`, `C:\Windows\Temp`, and Explorer thumbnail databases.
3. **Clipboard Purge**: Clears memory-resident clipboard data.
4. **Working Set Trimming**: Reclaims idle pages from background processes via `psapi.dll!EmptyWorkingSet`.
5. **Standby Memory Purge**: Purges Standby and Modified Page lists directly via `ntdll.dll!NtSetSystemInformation`.

---

## 🚀 Getting Started

### Quick Start
1. Download the latest release from [GitHub Releases](https://github.com/brsbrkctn/RAMCleaner/releases).
2. Extract the zip file to any directory.
3. Double-click `RAM_Temizle.bat` (or run `CreateDesktopShortcut.bat` to place a shortcut on your Desktop).

### Running via Command Line
```cmd
# Standard interactive mode
RAM_Temizle.bat

# Silent background mode (with Windows Toast Notification)
RAM_Temizle.bat --silent
```

### Automatic Scheduling
- Run `OtoTemizle_Kur.bat` to register an automated background task on Windows startup.
- Run `OtoTemizle_Kaldir.bat` to remove the scheduled task at any time.

---

## 📂 Repository Structure

```
RAMCleaner/
├── RAM_Temizle.bat           # Launcher script with auto-UAC elevation & silent mode
├── ClearMemory.ps1           # Visual engine, Win32 API Standby Purge & Working Set Trim
├── CreateDesktopShortcut.bat # Utility script to create a Desktop shortcut
├── OtoTemizle_Kur.bat        # Windows Task Scheduler setup script
├── OtoTemizle_Kaldir.bat     # Windows Task Scheduler removal script
├── README.md                 # Project documentation
├── CHANGELOG.md              # Version release history
└── LICENSE                   # MIT License
```

---

## 📜 Requirements

- **OS**: Windows 10 or Windows 11 (64-bit)
- **Privileges**: Administrator Rights (UAC prompt is handled automatically)
- **Dependencies**: None (Uses built-in PowerShell 5.1 & Windows APIs)

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
