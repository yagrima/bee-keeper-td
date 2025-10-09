@echo off
echo Starting BeeKeeperTD Web Server...
echo.
echo Server running at: http://localhost:8060
echo.
echo Press Ctrl+C to stop the server
echo.
cd /d "%~dp0"
python -m http.server 8060
