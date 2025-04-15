# Konteyner Takip Uygulaması

Bu uygulama, gelen ve giden konteynerlerin numaralarını ve diğer önemli bilgilerini otomatik olarak tanıyıp kaydetmenizi sağlar. Konteyner fotoğraflarını çekip, OCR teknolojisi ile konteyner numaralarını, tip kodlarını ve diğer bilgileri otomatik olarak algılar.

## Özellikler

- **Gelen ve Giden Konteyner Kaydı:** Her konteyner gelen veya giden olarak kategorize edilir
- **Otomatik OCR Tanıma:** Konteyner fotoğrafından numara, tip kodu, yükseklik ve uyarı bilgilerini otomatik tanıma
- **Detaylı Kayıt Görüntüleme:** Tüm konteyner bilgilerini görüntüleme ve paylaşma
- **Arama Özelliği:** Konteyner numarasına göre arama yapabilme
- **Filtreleme:** Gelen, giden ve tüm konteynerleri ayrı ayrı listeleyebilme

## Kurulum

1. Flutter'ı bilgisayarınıza yükleyin: [Flutter Kurulum Kılavuzu](https://flutter.dev/docs/get-started/install)
2. Projeyi indirin:
   ```
   git clone https://github.com/kullanici/container-tracker.git
   cd container-tracker
   ```
3. Bağımlılıkları yükleyin:
   ```
   flutter pub get
   ```
4. Uygulamayı çalıştırın:
   ```
   flutter run
   ```

## Uygulama Kullanımı

1. Ana ekranda "Gelen Konteyner" veya "Giden Konteyner" seçeneğini seçin
2. Kamera açıldığında, konteyner numarasını çerçeve içine alın ve fotoğraf çekin
3. Uygulama otomatik olarak OCR işlemini gerçekleştirecek ve bilgileri algılayacaktır
4. Algılanan bilgiler, konteyner detay ekranında gösterilecektir
5. Bu ekrandan bilgileri paylaşabilir veya kaydı silebilirsiniz
6. Ana ekrandaki listelerden geçmiş kayıtlara ulaşabilir ve filtreleyebilirsiniz

## Ekran Görüntüleri

![Ana Ekran](images/screenshot1.png)
![Kamera Ekranı](images/screenshot2.png)
![Detay Ekranı](images/screenshot3.png)
![Liste Ekranı](images/screenshot4.png)

## Gereksinimler

- Flutter 3.0.0 veya üstü
- Dart 2.17.0 veya üstü
- Android 5.0+ (API level 21+)
- iOS 11.0+

## Kullanılan Teknolojiler

- Flutter
- Camera API
- Google ML Kit (OCR için)
- SQLite (Yerel veritabanı)
- Provider (Durum yönetimi)

## Sorun Giderme

**Kamera açılmıyor:** Uygulamanın kamera izinlerine sahip olduğundan emin olun.

**OCR düzgün çalışmıyor:** Fotoğraf çekerken yeterli ışık olduğundan ve konteyner numarasının odakta olduğundan emin olun.

## Geliştirici

Bu uygulama, lojistik ve konteyner yönetimi süreçlerini kolaylaştırmak için geliştirilmiştir. 