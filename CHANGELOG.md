# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-08-18

### Added
- **Visual ASCII RAM Usage Bar**: Interactive before/after graphical memory capacity bars (`[████████░░░░] %40`).
- **Top 5 Memory Consumers Table**: Real-time process memory consumption list showing top 5 RAM-heavy processes before optimization.
- **Process Working Set Trim (`EmptyWorkingSet`)**: Native Win32 API (`psapi.dll`) integration to aggressively reclaim unused working set memory from background applications.
- **Windows Desktop Toast Notification**: Native zero-dependency balloon/toast notification displaying freed RAM metrics upon completion.
- **Silent Mode (`--silent`)**: Headless execution mode for background optimizations.
- **Auto-Cleaner Scheduler Scripts**: `OtoTemizle_Kur.bat` and `OtoTemizle_Kaldir.bat` for one-click Windows Task Scheduler integration.
- **Thumbnail Cache Cleanup**: Purges Windows Explorer thumbnail database (`thumbcache_*.db`) without affecting user files.

### Fixed
- Improved progress bar execution speed with per-step millisecond diagnostics.
- Enhanced temp file counter and byte calculation precision.

## [1.1.0] - 2026-08-18

### Added
- RAM usage statistics display before and after cleaning (Total, Used, Free MB, and freed RAM amount).
- Temporary files count and size calculation report.
- Anti-infinite-loop UAC elevation check in `RAM_Temizle.bat` using `--elevated` argument verification.
- Improved PowerShell progress bar execution speed and error handling.

### Fixed
- Fixed PowerShell syntax and UTF-8 encoding corruption in `ClearMemory.ps1`.
- Fixed endless window opening loop in `RAM_Temizle.bat` when Administrator rights request fails or is cancelled.
- Fixed clipboard clearing logic.

## [1.0.0] - 2026-08-04

### Added
- Native Windows Standby Memory and Modified Page List purging via `ntdll.dll` API `NtSetSystemInformation`.
- Automatic Windows UAC elevation handling in `RAM_Temizle.bat`.
- Interactive PowerShell console UI featuring step-by-step execution and real-time progress bars (`ClearMemory.ps1`).
- Automatic font height override to 16pt Bold Consolas via Win32 API (`SetCurrentConsoleFontEx`).
- DNS Cache flushing (`ipconfig /flushdns`), temporary files cleanup (`%TEMP%`, `C:\Windows\Temp`), and clipboard clearing.
- Desktop shortcut creation helper script (`CreateDesktopShortcut.bat`).
