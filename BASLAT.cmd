@ECHO OFF
chcp 65001 >nul
title GoodbyeDPI Turkiye
net session >nul 2>&1
if not %errorlevel%==0 (
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

set "BETIK=%~dp0gdpi.ps1"
if not exist "%BETIK%" (
    echo gdpi.ps1 bulunamadi. Bu dosya GoodbyeDPI-Ayar klasorunde durmali.
    pause
    exit /b 1
)

:menu
cls
echo ==========================================
echo   GoodbyeDPI Turkiye  -  Discord / Roblox
echo ==========================================
echo.
echo   1  Kur / yeniden kur   (acilista kendiliginden baslar)
echo   2  Durum               (calisiyor mu, DNS dogru mu, test)
echo   3  Durdur              (simdilik kapat)
echo   4  Kaldir              (hizmeti tamamen sil)
echo   5  Otomatik dene       (calisan ayari bul, kaydet)
echo   6  DNS duzelt          (Cloudflare 1.1.1.1)
echo   7  DNS'i eski haline al (otomatik)
echo   0  Cikis
echo.
set "SEC="
set /p "SEC=Secimin: "

if "%SEC%"=="1" powershell -NoProfile -ExecutionPolicy Bypass -File "%BETIK%" -Islem kur
if "%SEC%"=="2" powershell -NoProfile -ExecutionPolicy Bypass -File "%BETIK%" -Islem durum
if "%SEC%"=="3" powershell -NoProfile -ExecutionPolicy Bypass -File "%BETIK%" -Islem durdur
if "%SEC%"=="4" powershell -NoProfile -ExecutionPolicy Bypass -File "%BETIK%" -Islem kaldir
if "%SEC%"=="5" powershell -NoProfile -ExecutionPolicy Bypass -File "%BETIK%" -Islem dene
if "%SEC%"=="6" powershell -NoProfile -ExecutionPolicy Bypass -File "%BETIK%" -Islem dns
if "%SEC%"=="7" powershell -NoProfile -ExecutionPolicy Bypass -File "%BETIK%" -Islem dnsgeri
if "%SEC%"=="0" exit /b 0

echo.
pause
goto menu
