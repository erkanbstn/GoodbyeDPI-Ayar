@ECHO OFF
chcp 65001 >nul
net session >nul 2>&1
if not %errorlevel%==0 (
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
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

echo Eski kopya kapatiliyor ve hizmet kuruluyor.
call "%~dp0temizle.cmd"
sc delete "GoodbyeDPI" >nul 2>&1
sc create "GoodbyeDPI" binPath= "\"%EXE%\" -5 --blacklist \"%~dp0liste.txt\"" start= "auto"
if not %errorlevel%==0 (
    echo Hizmet kurulamadi.
    pause
    exit /b 1
)
sc description "GoodbyeDPI" "Discord ve Roblox icin. Resim sunucularina dokunmaz."
sc failure "GoodbyeDPI" reset= 86400 actions= restart/5000/restart/5000/restart/5000
sc start "GoodbyeDPI"
echo.
echo Hizmet kuruldu ve calisiyor. Pencere yok.
echo Bilgisayar acilinca kendiliginden baslar.
echo 1-pencere-ile-baslat.cmd dosyasini ayrica calistirma.
echo Kapatmak icin 4-simdi-durdur.cmd, tamamen silmek icin 3-servis-kaldir.cmd.
echo.
pause
