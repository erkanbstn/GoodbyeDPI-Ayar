GoodbyeDPI Ayar
================

Discord ve Roblox açılsın, Roblox resimleri beyaz kalmasın diye kuruldu.
GoodbyeDPI bütün internete karışmaz. Yalnızca liste.txt içindeki
adreslerin bağlantı başlangıcına dokunur. Bu bir VPN değildir.

Klasör düzeni
-------------

  GoodbyeDPI-Turkey\
    x86_64\              program (goodbyedpi.exe, WinDivert)
    licenses\            lisanslar (silme)
    GoodbyeDPI-Ayar\     bizim ayar
      BASLAT.cmd         tek giriş, menü
      gdpi.ps1           bütün işi yapan betik
      liste.txt          dokunulacak adresler
      README.txt         bu dosya

Nasıl kullanılır
----------------

1. BASLAT.cmd dosyasına çift tıkla (yönetici izni ister, evet de).
2. İlk kurulumda sırayla:  6 (DNS düzelt)  ->  1 (Kur)
3. Discord ve Roblox'u saat yanındaki simgeden tamamen kapatıp yeniden aç.

Menü
----

1  Kur / yeniden kur
   Programı C:\ProgramData\GoodbyeDPI altına kopyalar ve Windows hizmeti
   olarak kurar. Bilgisayar açılınca kendiliğinden başlar, pencere yoktur.
   Önceki kurulumu, açıkta kalmış kopyaları ve eski sürücü kaydını
   kendisi temizler. Önce kaldırmana gerek yok. Masaüstündeki klasörü
   taşısan veya silsen bile hizmet çalışmaya devam eder.

2  Durum
   Hizmet kurulu mu, çalışıyor mu, kaç kopya açık, DNS doğru mu,
   Discord/Roblox/Roblox resim/genel internet açılıyor mu. Sorun olunca
   ilk buna bak.

3  Durdur
   Şimdilik kapatır. Hizmet silinmez, bilgisayar açılınca yine başlar.

4  Kaldır
   Hizmeti, sürücü kaydını ve C:\ProgramData\GoodbyeDPI klasörünü siler.

5  Otomatik dene
   Discord veya Roblox yine bozulursa çalıştır. Birkaç ayarı sırayla dener,
   hepsini aynı anda açan ilk ayarı kaydeder. Hizmet kuruluysa onu bu
   ayarla yeniden kurar. Deneme sırasında internet birkaç saniye kesilebilir.

6  DNS düzelt
   Modem bazen Discord ve Roblox adlarını sahte bir siteye çevirir
   (195.175.254.2). O zaman launcher açılır ama resimler beyaz kalır.
   Bağlı ağ kartlarının DNS'ini Cloudflare (1.1.1.1, 1.0.0.1) yapar.
   Ethernet veya Wi-Fi adı fark etmez, bağlı olanı kendisi bulur.
   Türk Telekom'da (2026-11-18'den beri) düz DNS sorgusu bu adlara
   cevapsız kalır (1.1.1.1 dahil). Bu seçenek Cloudflare adreslerine
   şifreli DNS'i (DoH) de açar, Windows 11 gerekir. Siteler açılmazsa
   yeniden çalıştır.

7  DNS'i eski haline al
   DNS'i otomatiğe (modemden gelen) geri döndürür.

liste.txt
---------

Satır başına bir alan adı. Alt adresler kendiliğinden dahildir:
roblox.com yazmak thumbnails.roblox.com adresini de kapsar,
ama discord.com yazmak cdn.discordapp.com için yetmez, o yüzden
discordapp.com ayrı satırdadır.

rbxcdn.com bu listede bilerek yok. Resimlerin indiği sunucu engelli değil.
Eklersen GoodbyeDPI resim bağlantısını bozar ve launcher beyaz kalır.

Yeni satır eklerken http:// yazma, yıldız koyma. Listeyi değiştirdikten
sonra 1 (Kur) seçeneğini tekrar çalıştır, hizmet listeyi kurulumda kopyalar.

Sorun giderme
-------------

Hizmet başlamıyor:
  Windows Güvenliği WinDivert64.sys dosyasını karantinaya almış olabilir.
  Koruma geçmişinden dosyayı geri yükle, sonra 1 (Kur).

İnternet bozuldu:
  3 (Durdur). Düzelirse 2 (Durum) ile kopya sayısına bak,
  sonra 1 (Kur).

Eski GoodbyeDPI-Turkey betikleri (turkey_dnsredir.cmd, service_install_*.cmd)
silindi. Bunlar aynı hizmet adını kullanıp bu kurulumu bozuyordu. Geri
indirirsen çalıştırma.
