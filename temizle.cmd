@ECHO OFF
sc stop "GoodbyeDPI" >nul 2>&1
taskkill /F /IM goodbyedpi.exe >nul 2>&1
ping -n 6 127.0.0.1 >nul
sc stop "GoodbyeDPI" >nul 2>&1
taskkill /F /IM goodbyedpi.exe >nul 2>&1
