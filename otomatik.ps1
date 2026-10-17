$ErrorActionPreference = 'Continue'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$gdpi = Split-Path -Parent $root
$arch = 'x86'
if ([Environment]::Is64BitOperatingSystem) { $arch = 'x86_64' }
$exe = Join-Path $gdpi "$arch\goodbyedpi.exe"
$blacklist = Join-Path $root 'liste.txt'
$memory = Join-Path $root 'son-ayar.txt'

if (-not (Test-Path -LiteralPath $exe)) {
    Write-Host "goodbyedpi.exe bulunamadi: $exe"
    Write-Host "GoodbyeDPI-Ayar klasoru, GoodbyeDPI-Turkey klasorunun icinde durmali."
    exit 1
}
if (-not (Test-Path -LiteralPath $blacklist)) {
    Write-Host "Liste bulunamadi: $blacklist"
    exit 1
}

$useList = @('--blacklist', $blacklist)

$modes = @(
    @{ Id = 'liste-5'; Title = 'Discord ve Roblox listesi, otomatik TTL'; Args = @('-5') + $useList },
    @{ Id = 'liste-9'; Title = 'Discord ve Roblox listesi, sahte paket'; Args = @('-9') + $useList },
    @{ Id = 'liste-6'; Title = 'Discord ve Roblox listesi, sirasi bozuk paket'; Args = @('-6') + $useList },
    @{ Id = 'liste-ttl5'; Title = 'Discord ve Roblox listesi, sabit TTL 5'; Args = @('-5', '--set-ttl', '5') + $useList }
)

if (Test-Path -LiteralPath $memory) {
    $lastId = (Get-Content -LiteralPath $memory -ErrorAction SilentlyContinue | Select-Object -First 1)
    $lastId = "$lastId".Trim()
    $preferred = @($modes | Where-Object { $_.Id -eq $lastId })
    if ($preferred.Count -eq 1) {
        $modes = @($preferred) + @($modes | Where-Object { $_.Id -ne $lastId })
    }
}

function Stop-GoodbyeDpi {
    & sc.exe stop GoodbyeDPI | Out-Null
    Get-Process goodbyedpi -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5
    & sc.exe stop GoodbyeDPI | Out-Null
    Get-Process goodbyedpi -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

function Test-Https {
    param([string]$Url)
    $code = & curl.exe --ipv4 -sS -o NUL --connect-timeout 5 --max-time 8 -w "%{http_code}" $Url 2>$null
    if ($code -is [System.Array]) { $code = $code[-1] }
    $code = "$code".Trim()
    $ok = ($LASTEXITCODE -eq 0 -and $code -match '^\d{3}$' -and $code -ne '000')
    return @{ Ok = $ok; Code = $code }
}

function Repair-RouterDns {
    $system = @(Resolve-DnsName discord.com -Type A -DnsOnly -ErrorAction SilentlyContinue | Where-Object { $_.Type -eq 'A' } | Select-Object -ExpandProperty IPAddress)
    $direct = @(Resolve-DnsName discord.com -Type A -Server 1.1.1.1 -DnsOnly -ErrorAction SilentlyContinue | Where-Object { $_.Type -eq 'A' } | Select-Object -ExpandProperty IPAddress)
    if ($system.Count -gt 0 -and $direct.Count -gt 0 -and (@($system | Where-Object { $direct -contains $_ })).Count -gt 0) {
        return
    }
    $alias = (Get-NetIPConfiguration | Where-Object { $_.NetAdapter.Status -eq 'Up' -and $_.IPv4DefaultGateway } | Select-Object -First 1).InterfaceAlias
    if (-not $alias) { return }
    Write-Host "Modem, Discord adresini sahte siteye ceviriyor. DNS Cloudflare olarak ayarlaniyor."
    & netsh.exe interface ipv4 set dnsservers "$alias" static 1.1.1.1 primary | Out-Null
    & netsh.exe interface ipv4 add dnsservers "$alias" 1.0.0.1 index=2 | Out-Null
    & netsh.exe interface ipv6 set dnsservers "$alias" static 2606:4700:4700::1111 primary | Out-Null
    & netsh.exe interface ipv6 add dnsservers "$alias" 2606:4700:4700::1001 index=2 | Out-Null
    & ipconfig.exe /flushdns | Out-Null
}

function Test-ServiceInstalled {
    $query = & sc.exe query GoodbyeDPI 2>&1 | Out-String
    return ($query -notmatch '1060')
}

function Test-Targets {
    $names = @(
        @{ Name = 'Discord'; Url = 'https://discord.com' },
        @{ Name = 'Roblox'; Url = 'https://www.roblox.com' },
        @{ Name = 'Roblox resim listesi'; Url = 'https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=1&size=150x150&format=Png&isCircular=false' },
        @{ Name = 'Roblox resim'; Url = 'https://tr.rbxcdn.com/' },
        @{ Name = 'Genel internet'; Url = 'https://www.google.com/generate_204' }
    )
    $allOk = $true
    foreach ($item in $names) {
        $result = Test-Https $item.Url
        if (-not $result.Ok) {
            $result = Test-Https $item.Url
        }
        if ($result.Ok) {
            Write-Host ("  {0}: acildi ({1})" -f $item.Name, $result.Code)
        } else {
            Write-Host ("  {0}: acilmadi" -f $item.Name)
            $allOk = $false
        }
    }
    return $allOk
}

Write-Host "Onceki GoodbyeDPI kapatiliyor. Deneme sirasinda baglanti birkac saniye kesilebilir."
Write-Host ""
Stop-GoodbyeDpi
Repair-RouterDns
& ipconfig.exe /flushdns | Out-Null

Write-Host "GoodbyeDPI kapaliyken genel internet kontrol ediliyor..."
$baseline = Test-Https 'https://www.google.com/generate_204'
if (-not $baseline.Ok) {
    Write-Host "Genel internet su an cevap vermiyor. Ayar denemesi baslatilmadi."
    exit 1
}
Write-Host "Genel internet cevap veriyor."
Write-Host ""

$winner = $null
foreach ($mode in $modes) {
    Write-Host ("Deneniyor: {0}" -f $mode.Title)
    Stop-GoodbyeDpi
    $proc = Start-Process -FilePath $exe -ArgumentList $mode.Args -WorkingDirectory (Split-Path -Parent $exe) -PassThru -WindowStyle Hidden
    Start-Sleep -Seconds 2
    if ($proc.HasExited) {
        Write-Host "  GoodbyeDPI bu ayarla acilamadi."
        Write-Host ""
        continue
    }
    & ipconfig.exe /flushdns | Out-Null
    Start-Sleep -Seconds 1
    $ok = Test-Targets
    if ($ok) {
        $winner = $mode
        Stop-GoodbyeDpi
        break
    }
    Write-Host ""
}

Stop-GoodbyeDpi

if (-not $winner) {
    Write-Host "Denenen ayarlarin hicbiri Discord, Roblox resmi ve genel interneti ayni anda acamadi."
    Write-Host "GoodbyeDPI kapali birakildi."
    exit 1
}

Set-Content -LiteralPath $memory -Value $winner.Id -Encoding ASCII
if ((Test-ServiceInstalled) -and $winner.Id -eq 'liste-5') {
    & sc.exe start GoodbyeDPI | Out-Null
    Write-Host ""
    Write-Host ("Acik birakilan ayar: {0}" -f $winner.Title)
    Write-Host "Kurulu hizmet tek kopya olarak baslatildi. Ayrica pencere acma."
    Write-Host "Kapatmak icin 4-simdi-durdur.cmd kullan."
} else {
    Start-Process -FilePath $exe -ArgumentList $winner.Args -WorkingDirectory (Split-Path -Parent $exe) -WindowStyle Normal | Out-Null
    Write-Host ""
    Write-Host ("Acik birakilan ayar: {0}" -f $winner.Title)
    Write-Host "Tek siyah pencere acik. Bunu kapatinca GoodbyeDPI durur."
    if (Test-ServiceInstalled) {
        Write-Host "Hizmet bu denemede baslatilmadi. Bilgisayar yeniden acilinca hizmet yine gelir."
    }
}
exit 0
