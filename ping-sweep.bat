@echo off
setlocal enabledelayedexpansion

rem ping-sweep.bat
if "%~1"=="" (
    echo Usage: %~nx0 <CIDR>
    exit /b 1
)

set "Cidr=%~1"
set "liveHosts="
set "deadHosts="

for /f %%a in ('powershell -Command "(Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias * | Where-Object { $_.IPv4Address -like %Cidr% }).IPV4Address"') do (
    set "ip=%%a"
    ping -n 1 !ip! >nul 2>&1
    if errorlevel 1 (
        echo !ip!,Dead >> ping_sweep_results.csv
    ) else (
        echo !ip!,Live >> ping_sweep_results.csv
    )
)

echo Results saved to ping_sweep_results.csv
