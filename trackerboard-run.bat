@echo off
:: Check for admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit
)

:: Run the PowerShell script
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\user\Desktop\custom by niko\trackerboard_auto.ps1"

pause
