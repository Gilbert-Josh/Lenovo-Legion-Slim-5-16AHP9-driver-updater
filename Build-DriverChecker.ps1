$ErrorActionPreference='Stop'
Install-Module ps2exe -Scope CurrentUser -Force -AllowClobber
Invoke-ps2exe -InputFile "$PSScriptRoot\DriverChecker.ps1" -OutputFile "$PSScriptRoot\DriverChecker.exe" -NoConsole -STA -DPIAware -WinFormsDPIAware -SupportOS -Title "Driver Checker" -Description "Official-source Windows driver checker" -Product "Driver Checker" -Company "Gilbert-Josh" -Version "1.0.0.0"
Write-Host "Built DriverChecker.exe"