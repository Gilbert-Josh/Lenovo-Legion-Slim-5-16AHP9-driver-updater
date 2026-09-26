# Lenovo Legion Slim 5 16AHP9 Driver Updater

Lightweight Windows driver checker/updater for the Lenovo Legion Slim 5 16AHP9 (83DH).

## Features

- Detects Lenovo model, BIOS and Windows build
- Detects NVIDIA RTX 4060 Laptop GPU and AMD Radeon 780M
- Checks the official NVIDIA driver lookup service
- Opens official AMD, Lenovo and Windows Update sources
- NVIDIA update download is verified by Authenticode before launch
- No background service, scheduled task, overlay or telemetry
- AMD updates remain manual because OEM laptop drivers may be customized for the system

## Build

Run `Build-DriverChecker.ps1` on Windows PowerShell. The script installs PS2EXE if needed and builds `DriverChecker.exe`.

GitHub Actions also builds a Windows executable artifact.

## License

MIT
