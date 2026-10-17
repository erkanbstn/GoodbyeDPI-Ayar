@ECHO OFF
chcp 65001 >nul
net session >nul 2>&1
if not %errorlevel%==0 (
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo Ethernet ve Wi-Fi DNS adresleri Cloudflare olarak ayarlaniyor.
netsh interface ipv4 set dnsservers "Ethernet" static 1.1.1.1 primary
netsh interface ipv4 add dnsservers "Ethernet" 1.0.0.1 index=2
netsh interface ipv6 set dnsservers "Ethernet" static 2606:4700:4700::1111 primary
netsh interface ipv6 add dnsservers "Ethernet" 2606:4700:4700::1001 index=2
netsh interface ipv4 set dnsservers "Wi-Fi" static 1.1.1.1 primary
netsh interface ipv4 add dnsservers "Wi-Fi" 1.0.0.1 index=2
netsh interface ipv6 set dnsservers "Wi-Fi" static 2606:4700:4700::1111 primary
netsh interface ipv6 add dnsservers "Wi-Fi" 2606:4700:4700::1001 index=2
ipconfig /flushdns
echo.
echo DNS ayarlandi. Modem artik Discord adresini sahte siteye ceviremez.
echo.
pause
