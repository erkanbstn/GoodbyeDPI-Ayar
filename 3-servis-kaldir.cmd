@ECHO OFF
chcp 65001 >nul
net session >nul 2>&1
if not %errorlevel%==0 (
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo Hizmet siliniyor ve calisan kopya kapatiliyor.
call "%~dp0temizle.cmd"
sc delete "GoodbyeDPI"
sc stop "WinDivert" >nul 2>&1
sc delete "WinDivert" >nul 2>&1
sc stop "WinDivert14" >nul 2>&1
sc delete "WinDivert14" >nul 2>&1
echo.
echo Hizmet kaldirildi. Bilgisayar acilinca kendiliginden baslamaz.
echo Pencere ile kullanmak icin 1-pencere-ile-baslat.cmd calistir.
echo.
pause
