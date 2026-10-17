GoodbyeDPI Ayar
================

Bu klasör, GoodbyeDPI-Turkey içindeki kendi ayarımızdır.
Program goodbyedpi.exe bir üst klasörde durur. Burada yalnız
başlatma dosyaları ve Discord / Roblox adres listesi vardır.

  Masaüstü\GoodbyeDPI-Turkey\              program
  Masaüstü\GoodbyeDPI-Turkey\GoodbyeDPI-Ayar\   bu klasör

Bu klasörü dışarı taşırsan yol bozulur. Taşıdıktan sonra
2-servis-kur.cmd dosyasını yeniden çalıştır.

Başka bilgisayar
----------------

Bu depoda yalnız bizim dosyalar vardır. goodbyedpi.exe yoktur.
Önce o bilgisayara GoodbyeDPI-Turkey klasörünü koy. Sonra onun
içine bu depoyu indir:

  cd Masaüstü\GoodbyeDPI-Turkey
  git clone https://github.com/erkanbstn/GoodbyeDPI-Ayar.git

Ardından 6-dns-duzelt.cmd, sonra ya 1-pencere-ile-baslat.cmd
ya da 2-servis-kur.cmd dosyasını yönetici olarak çalıştır.


Ne işe yarıyor
--------------

Discord ve Roblox açılsın, Roblox'taki resimler beyaz kalmasın diye
kuruldu. GoodbyeDPI bütün internete karışmıyor. Yalnızca liste.txt
içindeki adreslerin bağlantı başlangıcına dokunuyor.

Steam, Epic Games ve tarayıcıdan yapılan indirmeler bu listede yok.
Onların hızına dokunulmaz. Genel internet de yavaşlamaz. Bu bir VPN
değil; trafik başka bir sunucuya uğramıyor.


Hangisini kullanmalısın
-----------------------

İkisinden birini seç. İkisini birden çalıştırma.
Servis kurmak zorunda değilsin.

Pencere ile kullanmak istiyorsan:

  1-pencere-ile-baslat.cmd

  Sağ tık, Yönetici olarak çalıştır.
  Siyah pencere açık kaldığı sürece çalışır.
  Pencereyi kapatmak durdurur.
  Bilgisayar açılınca kendiliğinden gelmez.

Her açılışta kendiliğinden gelsin, ortada pencere durmasın istiyorsan:

  2-servis-kur.cmd

  Bunu bir kez yönetici olarak çalıştırman yeter.
  Bundan sonra 1-pencere dosyasını ayrıca açma.


Dosyalar
--------

1-pencere-ile-baslat.cmd
  Tek siyah pencere açar. Zaten çalışan bir kopya varsa ikinciyi açmaz.
  Servis kurmaz.

2-servis-kur.cmd
  Windows hizmeti kurar. Açılışta başlar. Pencere yoktur.
  Daha önce kurulu bir hizmet varsa onu silip bunu yazar.
  Açıkta kalmış eski kopyayı da kapatır, üst üste iki tane bırakmaz.

3-servis-kaldir.cmd
  Hizmeti Windows'tan tamamen siler.
  O anda çalışan kopyayı da kapatır.
  Bilgisayar açılınca kendiliğinden gelmez.
  Bundan sonra istersen 1-pencere ile kullanırsın.

4-simdi-durdur.cmd
  Şu an çalışan kopyayı kapatır. Hizmet kayıtlıysa silmez.
  Hizmet kuruluysa bilgisayar yeniden açılınca yine başlar.
  Hizmeti tamamen silmek için 3. dosyayı kullan.

5-otomatik-dene.cmd
  Discord, Roblox veya resimler yine bozulursa bunu çalıştır.
  Birkaç ayarı sırayla dener. Discord, Roblox, Roblox resim listesi,
  resim sunucusu ve genel internet aynı anda açılan ilk ayarı bırakır.
  Deneme sırasında internet birkaç saniye kesilebilir.
  Hizmet kurulu değilse sonucu siyah pencere olarak bırakır.
  Hizmet kuruluysa ve bilinen ayar tuttuysa hizmeti yeniden başlatır.
  İkinci bir pencere açmaz.

6-dns-duzelt.cmd
  Modem, Discord ve Roblox adlarını sahte bir siteye çeviriyordu
  (195.175.254.2). Bu yüzden launcher açılıyor ama resimler beyaz kalıyordu.
  Bu dosya Ethernet ve Wi-Fi için DNS'i Cloudflare yapar:
  1.1.1.1, 1.0.0.1 ve bunların IPv6 karşılıkları.
  Bunu bir kez ayarladık. Modem ayarı geri gelirse yeniden çalıştır.

liste.txt
  GoodbyeDPI'nin dokunacağı adresler. Satır başına bir alan adı.
  Alt adresler kendiliğinden dahildir: discord.com yazmak
  cdn.discordapp.com için yetmez, o yüzden discordapp.com ayrı durur.
  roblox.com yazmak thumbnails.roblox.com adresini de kapsar.

  rbxcdn.com bu listede bilerek yok. Resimlerin indiği sunucu engelli
  değil. Onu listeye ekleyince GoodbyeDPI resim bağlantısını bozuyor
  ve launcher beyaz kalıyor.

  Yeni satır eklerken http:// yazma, yıldız koyma.
  Listeyi değiştirdikten sonra çalışan kopyayı 4 ile durdurup
  seçtiğin yöntemle (1 veya 2) yeniden başlat. Açık program eski
  listeyi okumaya devam eder.


Ne yapmamalısın
---------------

GoodbyeDPI-Turkey içindeki turkey_dnsredir.cmd ve alternatif cmd
dosyalarını, bu klasördekiler çalışırken açma. İkinci kopya interneti
bozar. Eskiden pencere kapanmış gibi görünüp arkada kalan kopyanın
üstüne bir tane daha açılınca bağlantı bozuluyordu. Buradaki dosyalar
çalışan kopya varken yenisini açmaz.

Aynı anda hem 1 hem 2 kullanma. Servis kurduysan pencere açma.
Pencere kullanacaksan önce 3 ile hizmeti kaldır.

İki klasörü masaüstünden ayrı yerlere taşıma.


Durdurmak
---------

Pencere yönteminde siyah pencereyi kapatmak yeter.
Servis yönteminde kapatılacak pencere yoktur. 4 şimdilik durdurur,
3 hizmeti siler.


Bir şey bozulursa
-----------------

Discord açılmıyor veya Roblox resimleri yine beyaz:
  5-otomatik-dene.cmd çalıştır.
  Bitince Discord ve Roblox'u saat yanındaki simgeden tamamen kapat,
  sonra yeniden aç.

İnternet genel olarak bozuldu:
  4-simdi-durdur.cmd çalıştır.
  Düzelirse ikinci bir kopya kalmış demektir.
  Sonra yalnız 1 veya yalnız 2 ile yeniden başlat.

DNS yine modemden geliyorsa:
  6-dns-duzelt.cmd çalıştır.
