@ECHO OFF
chcp 65001 >nul
net session >nul 2>&1
if not %errorlevel%==0 (
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

tasklist /FI "IMAGENAME eq goodbyedpi.exe" | find /I "goodbyedpi.exe" >nul
if %errorlevel%==0 (
    echo GoodbyeDPI zaten calisiyor. Ikinci kopya acilmadi.
    echo Kapatmak icin 4-simdi-durdur.cmd calistir.
    echo.
    pause
    exit /b 1
)

set "GDP=%~dp0.."
set "EXE=%GDP%\x86_64\goodbyedpi.exe"
if not exist "%EXE%" set "EXE=%GDP%\x86\goodbyedpi.exe"
if not exist "%EXE%" (
    echo goodbyedpi.exe bulunamadi.
    echo Bu klasor, GoodbyeDPI-Turkey klasorunun icinde durmali.
    echo.
    pause
    exit /b 1
)

start "GoodbyeDPI" "%EXE%" -5 --blacklist "%~dp0liste.txt"
echo Pencere acildi. Bu pencere acik kaldikca GoodbyeDPI calisir.
echo Pencereyi kapatmak programi durdurur. Acilista kendiliginden baslamaz.
echo.
pause
