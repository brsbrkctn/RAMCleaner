# RAMCleaner ⚡

**RAMCleaner**, Windows 10 ve Windows 11 için geliştirilmiş, harici hiçbir üçüncü parti yazılım veya kütüphaneye ihtiyaç duymayan (**sıfır bağımlılık**), açık kaynaklı bir RAM önbelleği ve sistem performansı optimizasyon aracıdır.

Batch, PowerShell ve doğrudan yerel C# Win32 NT Kernel API (`ntdll.dll`) çağrıları ile doğrudan Windows bellek yöneticisiyle iletişim kurarak çalışır.

---

## ✨ Öne Çıkan Özellikler

- **🚀 Yerel Standby List & Önbellek Purge**: Windows NT çekirdek API'si (`ntdll.dll!NtSetSystemInformation`) ve `SeProfileSingleProcessPrivilege` ayrıcalığı ile Windows Standby Memory ve Modified Page List alanlarını takılma/lag yaratmadan doğrudan sıfırlar.
- **📊 Görsel ASCII RAM Kapasite Göstergesi**: Optimizasyon öncesi ve sonrası bellek doluluk oranını terminal üzerinde grafiksel bar ile (`[######--------------] %30`) anlık olarak gösterir.
- **🔔 Windows Masaüstü Bildirimi (Toast Notification)**: Temizlik tamamlandığında sağ alt köşeden serbest bırakılan RAM miktarını gösteren yerel Windows bildirimi sunar.
- **🌐 DNS Ağ Önbelleği Sıfırlama**: `ipconfig /flushdns` komutu ile ağ soket önbelleğini temizler, bağlantı gecikmelerini ve takılmaları azaltır.
- **🗑️ Geçici Dosyalar & Thumbnail Cache Temizliği**: `%TEMP%`, `C:\Windows\Temp` dizinlerindeki çöp dosyaları ve bozulmuş Windows Explorer küçük resim veritabanlarını (`thumbcache_*.db`) güvenle siler.
- **📋 Pano (Clipboard) Boşaltma**: Hafızada asılı kalan pano kopyalama verilerini sıfırlar.
- **🖤 Şık Siyah Terminal Teması & ASCII Logo**: Mavi ekran yanıp sönmesi olmadan doğrudan siyah arka plan ve okunaklı 16pt Consolas fontuyla açılır.
- **🤫 Sessiz Arka Plan Modu (`--silent`)**: Konsol penceresi açılmadan arka planda sessizce çalıştırılabilme desteği.
- **⏰ Tek Tıkla Otomatik Zamanlayıcı**: Bilgisayar her açıldığında arka planda otomatik temizlik yapacak Windows Görev Zamanlayıcısı betiği (`OtoTemizle_Kur.bat`).
- **🔐 Otomatik Yönetici Yetkisi (UAC)**: Yönetici haklarını tek adımda, sonsuz döngü korumasıyla otomatik olarak talep eder.

---

## 🛠️ Nasıl Çalışır?

Windows Bellek Yöneticisi, açılan dosya ve uygulamaları daha sonra hızlı açmak için **Standby List** (Bekleme Belleği) üzerinde tutar. Zamanla bu alanlar GB'larca boyuta ulaşarak şişer ve özellikle yüksek bellek gerektiren oyunlarda veya ağır programlarda ani takılmalara (micro-stuttering) ve FPS düşüşlerine yol açabilir.

`RAMCleaner` 4 aşamalı temiz ve akıcı bir optimizasyon uygular:
1. **DNS Ağ Önbelleği:** DNS çözümleyici önbelleğini sıfırlar.
2. **Geçici Dosyalar & Thumbnail:** Sistem ve kullanıcı temp klasörleri ile Explorer önbelleğini temizler.
3. **Pano Hafızası:** Pano belleğini boşaltır.
4. **Standby Memory Purge:** `ntdll.dll` çekirdek çağrısıyla beklemedeki tüm RAM önbelleğini ve modified listeleri anında serbest bırakır.

---

## 🚀 Kurulum ve Kullanım

### Hızlı Başlangıç
1. En son sürümü [GitHub Releases](https://github.com/brsbrkctn/RAMCleaner/releases) sayfasından indirin (`RAMCleaner-v1.3.0.zip`).
2. Zip arşivini istediğiniz bir klasöre çıkartın.
3. `RAM_Temizle.bat` dosyasına çift tıklayarak çalıştırın *(Masaüstüne kısayol eklemek için `CreateDesktopShortcut.bat` dosyasını çalıştırabilirsiniz)*.

### Komut Satırından Çalıştırma
```cmd
# Standart görsel arayüz modu
RAM_Temizle.bat

# Sessiz arka plan modu (yalnızca masaüstü bildirimi verir)
RAM_Temizle.bat --silent
```

### Otomatik Zamanlayıcı Kurulumu
- **Kurmak için:** `OtoTemizle_Kur.bat` dosyasını çalıştırın *(Her kullanıcı girişinde arka planda sessiz optimizasyon yapar)*.
- **Kaldırmak için:** `OtoTemizle_Kaldir.bat` dosyasını çalıştırarak zamanlanmış görevi silebilirsiniz.

---

## 📂 Proje Yapısı

```
RAMCleaner/
├── RAM_Temizle.bat           # Otomatik UAC ve başlatıcı betik
├── ClearMemory.ps1           # Görsel motor, Win32 NT Kernel RAM temizleyici çekirdeği
├── CreateDesktopShortcut.bat # Masaüstü kısayol oluşturma aracı
├── OtoTemizle_Kur.bat        # Windows Görev Zamanlayıcı görev kurulum aracı
├── OtoTemizle_Kaldir.bat     # Windows Görev Zamanlayıcı görev kaldırma aracı
├── README.md                 # Proje dokümantasyonu
├── CHANGELOG.md              # Sürüm geçmişi ve değişiklik notları
└── LICENSE                   # MIT Lisansı
```

---

## 📋 Gereksinimler

- **İşletim Sistemi**: Windows 10 veya Windows 11 (64-bit)
- **Yetki**: Yönetici İzni (UAC penceresi otomatik olarak istenir)
- **Bağımlılık**: Yok (Windows ile gelen yerel PowerShell 5.1 ve dahili API'ler kullanılır)

---

## 📄 Lisans

Bu proje [MIT Lisansı](LICENSE) kapsamında lisanslanmıştır.
