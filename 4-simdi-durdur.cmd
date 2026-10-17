@ECHO OFF
chcp 65001 >nul
net session >nul 2>&1
if not %errorlevel%==0 (
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

call "%~dp0temizle.cmd"
echo GoodbyeDPI durdu.
echo Hizmet kuruluyse silinmedi. Bilgisayar yeniden acilinca yine baslar.
echo Hizmeti tamamen kaldirmak icin 3-servis-kaldir.cmd calistir.
echo.
pause
