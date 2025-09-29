@echo off
echo ========================================
echo BeeKeeperTD - Local Web Server
echo ========================================
echo.
echo Starting HTTP server on http://localhost:8060
echo Press Ctrl+C to stop the server
echo.

cd builds\web
python -m http.server 8060

pause