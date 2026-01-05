@echo off
set IP=192.168.32.2

echo =====================================
echo TrackerBoard Sniffer Activity Monitor
echo =====================================

:loop
echo.
echo [%TIME%] Checking sniffer status...

curl.exe -s http://%IP%/status > status.txt

if %ERRORLEVEL% neq 0 (
    echo TrackerBoard OFFLINE
) else (
    find "frames" status.txt
)

timeout /t 5 >nul
goto loop
