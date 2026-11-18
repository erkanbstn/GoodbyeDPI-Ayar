# GoodbyeDPI Turkiye - tek betik. BASLAT.cmd menusu bunu cagirir.
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('kur', 'kaldir', 'durdur', 'durum', 'dene', 'dns', 'dnsgeri')]
    [string]$Islem
)

$ErrorActionPreference = 'Continue'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ServisAdi = 'GoodbyeDPI'
$Ayar = Split-Path -Parent $MyInvocation.MyCommand.Path
$Kok = Split-Path -Parent $Ayar
$Hedef = Join-Path $env:ProgramData 'GoodbyeDPI'
$Liste = Join-Path $Ayar 'liste.txt'
$Hafiza = Join-Path $Ayar 'son-ayar.txt'
if ([Environment]::Is64BitOperatingSystem) { $Mimari = 'x86_64' } else { $Mimari = 'x86' }
$Kaynak = Join-Path $Kok $Mimari
$KaynakExe = Join-Path $Kaynak 'goodbyedpi.exe'
$DnsAdresleri = @('1.1.1.1', '1.0.0.1', '2606:4700:4700::1111', '2606:4700:4700::1001')

$Modlar = @(
    @{ Id = 'liste-5';    Baslik = 'otomatik TTL (-5)';             Args = '-5' },
    @{ Id = 'liste-9';    Baslik = 'sahte paket (-9)';              Args = '-9' },
    @{ Id = 'liste-6';    Baslik = 'sirasi bozuk paket (-6)';       Args = '-6' },
    @{ Id = 'liste-ttl5'; Baslik = 'sabit TTL 5 (-5 --set-ttl 5)';  Args = '-5 --set-ttl 5' }
)

function YoneticiMi {
    $kimlik = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    return $kimlik.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function ServisVarMi {
    return [bool](Get-Service -Name $ServisAdi -ErrorAction SilentlyContinue)
}

function SeciliMod {
    $id = ''
    if (Test-Path -LiteralPath $Hafiza) {
        $id = ('' + (Get-Content -LiteralPath $Hafiza -TotalCount 1)).Trim()
    }
    foreach ($m in $Modlar) {
        if ($m.Id -eq $id) { return $m }
    }
    return $Modlar[0]
}

function KopyalariKapat {
    if (ServisVarMi) { & sc.exe stop $ServisAdi | Out-Null }
    Get-Process goodbyedpi -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
    Get-Process goodbyedpi -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

function SurucuyuTemizle {
    foreach ($ad in @('WinDivert', 'WinDivert14')) {
        & sc.exe stop $ad 2>&1 | Out-Null
        & sc.exe delete $ad 2>&1 | Out-Null
    }
    Start-Sleep -Seconds 2
}

function ServisiSil {
    if (-not (ServisVarMi)) { return $true }
    & sc.exe delete $ServisAdi | Out-Null
    for ($i = 0; $i -lt 15; $i++) {
        if (-not (ServisVarMi)) { return $true }
        Start-Sleep -Seconds 1
    }
    return $false
}

function TestHttps {
    param([string]$Url)
    $kod = & curl.exe --ipv4 -sS -o NUL --connect-timeout 5 --max-time 8 -w '%{http_code}' $Url 2>$null
    if ($kod -is [System.Array]) { $kod = $kod[-1] }
    $kod = ('' + $kod).Trim()
    $tamam = ($LASTEXITCODE -eq 0 -and $kod -match '^\d{3}$' -and $kod -ne '000')
    return @{ Ok = $tamam; Code = $kod }
}

function HedefleriTestEt {
    $hedefler = @(
        @{ Ad = 'Discord';              Url = 'https://discord.com' },
        @{ Ad = 'Roblox';               Url = 'https://www.roblox.com' },
        @{ Ad = 'Roblox resim listesi'; Url = 'https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=1&size=150x150&format=Png&isCircular=false' },
        @{ Ad = 'Roblox resim';         Url = 'https://tr.rbxcdn.com/' },
        @{ Ad = 'Genel internet';       Url = 'https://www.google.com/generate_204' }
    )
    $hepsi = $true
    foreach ($h in $hedefler) {
        $sonuc = TestHttps $h.Url
        if (-not $sonuc.Ok) { $sonuc = TestHttps $h.Url }
        if ($sonuc.Ok) {
            Write-Host ('  {0}: acildi ({1})' -f $h.Ad, $sonuc.Code)
        } else {
            Write-Host ('  {0}: ACILMADI' -f $h.Ad)
            $hepsi = $false
        }
    }
    return $hepsi
}

function DnsSahteMi {
    # Superonline: modem discord.com'u 195.175.254.2'ye cevirirdi.
    # Turk Telekom: duz DNS sorgusu (1.1.1.1 dahil) cevapsiz kaliyor; dogru cevap yalniz sifreli DNS (DoH) ile geliyor.
    $sistem = @(Resolve-DnsName discord.com -Type A -DnsOnly -ErrorAction SilentlyContinue | Where-Object { $_.Type -eq 'A' } | Select-Object -ExpandProperty IPAddress)
    if ($sistem -contains '195.175.254.2') { return $true }
    $dogru = @()
    try {
        $doh = Invoke-RestMethod -Uri 'https://cloudflare-dns.com/dns-query?name=discord.com&type=A' -Headers @{ accept = 'application/dns-json' } -TimeoutSec 8
        $dogru = @($doh.Answer | Where-Object { $_.type -eq 1 } | ForEach-Object { $_.data })
    } catch { }
    if ($dogru.Count -eq 0) { return $false }
    if ($sistem.Count -eq 0) { return $true }
    $a = @($sistem | ForEach-Object { ($_ -split '\.')[0..1] -join '.' })
    $b = @($dogru | ForEach-Object { ($_ -split '\.')[0..1] -join '.' })
    foreach ($x in $a) { if ($b -contains $x) { return $false } }
    return $true
}

function DnsAyarla {
    $kartlar = @(Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' })
    if ($kartlar.Count -eq 0) {
        Write-Host 'Bagli bir ag karti bulunamadi.'
        return 1
    }
    foreach ($k in $kartlar) {
        try {
            Set-DnsClientServerAddress -InterfaceIndex $k.ifIndex -ServerAddresses $DnsAdresleri -ErrorAction Stop
            Write-Host ('DNS ayarlandi: ' + $k.Name)
        } catch {
            try {
                Set-DnsClientServerAddress -InterfaceIndex $k.ifIndex -ServerAddresses @('1.1.1.1', '1.0.0.1') -ErrorAction Stop
                Write-Host ('DNS ayarlandi (yalniz IPv4): ' + $k.Name)
            } catch {
                Write-Host ('DNS ayarlanamadi: ' + $k.Name + ' - ' + $_.Exception.Message)
            }
        }
    }
    foreach ($a in $DnsAdresleri) {
        try { Set-DnsClientDohServerAddress -ServerAddress $a -DohTemplate 'https://cloudflare-dns.com/dns-query' -AutoUpgrade $true -AllowFallbackToUdp $false -ErrorAction Stop }
        catch { Add-DnsClientDohServerAddress -ServerAddress $a -DohTemplate 'https://cloudflare-dns.com/dns-query' -AutoUpgrade $true -AllowFallbackToUdp $false -ErrorAction SilentlyContinue }
    }
    Write-Host 'Sifreli DNS (DoH) acildi. Turk Telekom duz DNS sorgusunu dusuruyor.'
    Clear-DnsClientCache
    Write-Host 'DNS onbellegi temizlendi.'
    return 0
}

function DnsGeriAl {
    $kartlar = @(Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' })
    foreach ($k in $kartlar) {
        Set-DnsClientServerAddress -InterfaceIndex $k.ifIndex -ResetServerAddresses
        Write-Host ('DNS otomatige alindi: ' + $k.Name)
    }
    Clear-DnsClientCache
    return 0
}

function Kur {
    if (-not (Test-Path -LiteralPath $KaynakExe)) {
        Write-Host ('goodbyedpi.exe bulunamadi: ' + $KaynakExe)
        Write-Host 'GoodbyeDPI-Ayar klasoru, GoodbyeDPI-Turkey klasorunun icinde durmali.'
        return 1
    }
    if (-not (Test-Path -LiteralPath $Liste)) {
        Write-Host ('Liste bulunamadi: ' + $Liste)
        return 1
    }

    Write-Host 'Eski kopya kapatiliyor...'
    KopyalariKapat
    if (-not (ServisiSil)) {
        Write-Host 'Eski hizmet silinemedi (silinmek uzere isaretli kalmis).'
        Write-Host 'Bilgisayari yeniden baslat ve Kur secenegini tekrar calistir.'
        return 1
    }
    SurucuyuTemizle

    Write-Host ('Dosyalar kopyalaniyor: ' + $Hedef)
    try {
        New-Item -ItemType Directory -Force -Path $Hedef | Out-Null
        foreach ($dosya in @('goodbyedpi.exe', 'WinDivert.dll', 'WinDivert64.sys', 'WinDivert32.sys')) {
            $k = Join-Path $Kaynak $dosya
            if (Test-Path -LiteralPath $k) {
                Copy-Item -LiteralPath $k -Destination $Hedef -Force -ErrorAction Stop
            }
        }
        Copy-Item -LiteralPath $Liste -Destination (Join-Path $Hedef 'liste.txt') -Force -ErrorAction Stop
    } catch {
        Write-Host ('Dosyalar kopyalanamadi: ' + $_.Exception.Message)
        Write-Host 'Windows Guvenligi WinDivert dosyasini engellemis olabilir. Koruma gecmisine bak.'
        return 1
    }

    $mod = SeciliMod
    $exe = Join-Path $Hedef 'goodbyedpi.exe'
    $hedefListe = Join-Path $Hedef 'liste.txt'
    $bin = '"' + $exe + '" ' + $mod.Args + ' --blacklist "' + $hedefListe + '"'

    try {
        New-Service -Name $ServisAdi -BinaryPathName $bin -DisplayName 'GoodbyeDPI' -Description 'Discord ve Roblox icin. Yalnizca liste.txt icindeki adreslere dokunur.' -StartupType Automatic -ErrorAction Stop | Out-Null
    } catch {
        Write-Host ('Hizmet kurulamadi: ' + $_.Exception.Message)
        return 1
    }
    & sc.exe failure $ServisAdi reset= 86400 actions= restart/5000/restart/5000/restart/5000 | Out-Null

    try {
        Start-Service -Name $ServisAdi -ErrorAction Stop
    } catch {
        Write-Host ('Hizmet baslatilamadi: ' + $_.Exception.Message)
        Write-Host 'Windows Guvenligi WinDivert64.sys dosyasini karantinaya almis olabilir.'
        Write-Host 'Koruma gecmisine bak, dosyayi geri yukle ve Kur secenegini tekrar calistir.'
        return 1
    }
    Start-Sleep -Seconds 2
    $s = Get-Service -Name $ServisAdi -ErrorAction SilentlyContinue
    if ($s -and $s.Status -eq 'Running') {
        Write-Host ''
        Write-Host ('Hizmet kuruldu ve calisiyor. Ayar: ' + $mod.Baslik)
        Write-Host 'Bilgisayar acilinca kendiliginden baslar. Pencere yoktur.'
        Write-Host 'Discord ve Roblox acikse saat yanindaki simgeden tamamen kapatip yeniden ac.'
        if (DnsSahteMi) {
            Write-Host ''
            Write-Host 'UYARI: Modem Discord adresini sahte siteye cevirmeye devam ediyor.'
            Write-Host 'Menuden DNS duzelt secenegini calistir.'
        }
        return 0
    }
    Write-Host 'Hizmet kuruldu ama calismiyor. Durum secenegine bak.'
    return 1
}

function Kaldir {
    Write-Host 'Calisan kopya kapatiliyor...'
    KopyalariKapat
    if (-not (ServisiSil)) {
        Write-Host 'Hizmet silinemedi. Bilgisayari yeniden baslatman gerekebilir.'
    } else {
        Write-Host 'Hizmet silindi.'
    }
    SurucuyuTemizle
    if (Test-Path -LiteralPath $Hedef) {
        try {
            Remove-Item -LiteralPath $Hedef -Recurse -Force -ErrorAction Stop
            Write-Host ('Silindi: ' + $Hedef)
        } catch {
            Write-Host ('Klasor silinemedi: ' + $Hedef + ' (yeniden baslatinca elle sil)')
        }
    }
    Write-Host 'Bilgisayar acilinca kendiliginden baslamaz.'
    return 0
}

function Durdur {
    KopyalariKapat
    Write-Host 'GoodbyeDPI durduruldu.'
    if (ServisVarMi) {
        Write-Host 'Hizmet kayitli kaldi: bilgisayar yeniden acilinca yine baslar.'
        Write-Host 'Tamamen silmek icin Kaldir secenegini kullan.'
    }
    return 0
}

function Durum {
    Write-Host '--- Hizmet ---'
    $s = Get-Service -Name $ServisAdi -ErrorAction SilentlyContinue
    if (-not $s) {
        Write-Host 'Kurulu degil.'
    } else {
        $cim = Get-CimInstance Win32_Service -Filter "Name='$ServisAdi'" -ErrorAction SilentlyContinue
        Write-Host ('Durum    : ' + $s.Status)
        if ($cim) {
            Write-Host ('Baslangic: ' + $cim.StartMode)
            Write-Host ('Komut    : ' + $cim.PathName)
            if ($cim.PathName -notlike ('*' + $Hedef + '*')) {
                Write-Host 'UYARI: Hizmet eski bir konumdan kurulmus. Kur secenegiyle yeniden kur.'
            }
            if ($cim.PathName -match '--dns-addr') {
                Write-Host 'UYARI: Hizmet orijinal dnsredir ayariyla kurulmus. Kur secenegiyle yeniden kur.'
            }
        }
    }
    Write-Host ''
    Write-Host '--- Calisan kopyalar ---'
    $sayi = @(Get-Process goodbyedpi -ErrorAction SilentlyContinue).Count
    Write-Host ('goodbyedpi.exe sayisi: ' + $sayi)
    if ($sayi -gt 1) { Write-Host 'UYARI: Birden fazla kopya var, internet bozulabilir. Durdur secenegini calistir, sonra Kur.' }
    if ($sayi -eq 1 -and -not $s) { Write-Host 'Not: Hizmet yok ama bir kopya calisiyor (elle acilmis).' }
    Write-Host ''
    Write-Host '--- DNS ---'
    if (DnsSahteMi) {
        Write-Host 'UYARI: Modem Discord adresini sahte siteye cevirmis. DNS duzelt secenegini calistir.'
    } else {
        Write-Host 'Discord adresi dogru cozuluyor.'
    }
    Write-Host ''
    Write-Host '--- Baglanti testi ---'
    HedefleriTestEt | Out-Null
    return 0
}

function Dene {
    $servisVardi = ServisVarMi
    Write-Host 'Onceki kopya kapatiliyor. Deneme sirasinda baglanti birkac saniye kesilebilir.'
    KopyalariKapat
    if (-not (Test-Path -LiteralPath $KaynakExe) -or -not (Test-Path -LiteralPath $Liste)) {
        Write-Host 'goodbyedpi.exe veya liste.txt bulunamadi.'
        if ($servisVardi) { Start-Service -Name $ServisAdi -ErrorAction SilentlyContinue }
        return 1
    }
    if (DnsSahteMi) {
        Write-Host 'UYARI: Modem DNS cevirisi sahte. Once DNS duzelt secenegini calistirman gerekir.'
    }
    Write-Host 'GoodbyeDPI kapaliyken genel internet kontrol ediliyor...'
    $temel = TestHttps 'https://www.google.com/generate_204'
    if (-not $temel.Ok) {
        Write-Host 'Genel internet cevap vermiyor. Deneme baslatilmadi.'
        if ($servisVardi) { Start-Service -Name $ServisAdi -ErrorAction SilentlyContinue }
        return 1
    }

    $secili = SeciliMod
    $sirali = @($secili) + @($Modlar | Where-Object { $_.Id -ne $secili.Id })
    $kazanan = $null
    foreach ($m in $sirali) {
        Write-Host ''
        Write-Host ('Deneniyor: ' + $m.Baslik)
        KopyalariKapat
        $arg = $m.Args + ' --blacklist "' + $Liste + '"'
        $p = Start-Process -FilePath $KaynakExe -ArgumentList $arg -WorkingDirectory $Kaynak -PassThru -WindowStyle Hidden
        Start-Sleep -Seconds 2
        if ($p.HasExited) {
            Write-Host '  Bu ayarla acilamadi.'
            continue
        }
        Clear-DnsClientCache
        Start-Sleep -Seconds 1
        if (HedefleriTestEt) {
            $kazanan = $m
            break
        }
    }
    KopyalariKapat

    if (-not $kazanan) {
        Write-Host ''
        Write-Host 'Hicbir ayar Discord, Roblox resmi ve genel interneti ayni anda acamadi.'
        if (DnsSahteMi) { Write-Host 'Neden: DNS hala sahte. DNS duzelt secenegini calistir.' }
        if ($servisVardi) { Start-Service -Name $ServisAdi -ErrorAction SilentlyContinue }
        return 1
    }

    Set-Content -LiteralPath $Hafiza -Value $kazanan.Id -Encoding ASCII
    Write-Host ''
    Write-Host ('Calisan ayar bulundu: ' + $kazanan.Baslik)
    if ($servisVardi) {
        Write-Host 'Hizmet bu ayarla yeniden kuruluyor...'
        return (Kur)
    }
    Write-Host 'Ayar kaydedildi. Kalici yapmak icin Kur secenegini calistir.'
    return 0
}

if (-not (YoneticiMi)) {
    Write-Host 'Bu islem icin yonetici izni gerekiyor. BASLAT.cmd dosyasini yonetici olarak ac.'
    exit 1
}

switch ($Islem) {
    'kur'     { $kod = Kur }
    'kaldir'  { $kod = Kaldir }
    'durdur'  { $kod = Durdur }
    'durum'   { $kod = Durum }
    'dene'    { $kod = Dene }
    'dns'     { $kod = DnsAyarla }
    'dnsgeri' { $kod = DnsGeriAl }
}
if ($kod -is [System.Array]) { $kod = $kod[-1] }
if ($kod -eq $null) { $kod = 0 }
exit ([int]$kod)
