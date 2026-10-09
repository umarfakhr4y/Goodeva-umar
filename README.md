# BLE Tracker App

Aplikasi mobile berbasis Flutter untuk melacak kedekatan perangkat Bluetooth menggunakan sinyal *advertising* BLE secara *real-time*.

## Fitur Utama
1. **Pemindaian Perangkat (Scanner Dashboard):** Mendeteksi perangkat BLE aktif, menampilkan MAC Address, nama perangkat, dan RSSI. Dilengkapi dengan filter nama, MAC, dan minimum RSSI.
2. **Pelacakan Target (Radar View):** Tampilan detail yang memvisualisasikan jarak estimasi secara real-time melalui indikator radar dengan 5 zona (Sangat Kuat, Kuat, Cukup, Lemah, Sangat Lemah, Hilang).
3. **Penyimpanan Lokal (History Log):** Menyimpan secara otomatis riwayat perangkat yang dipilih/dipantau menggunakan *database* lokal (SQFLite).

## Teknologi & Arsitektur
- **Framework:** Flutter (Android/iOS target)
- **Arsitektur:** Clean Architecture + MVVM (Model-View-ViewModel)
- **State Management:** Riverpod (`flutter_riverpod`) dipilih karena kemudahan dalam menangani *stream* dan status *asynchronous*, serta memiliki arsitektur provider yang solid.
- **Dependency Injection:** `get_it` + `injectable` digunakan untuk menyuntikkan repository dan service ke seluruh aplikasi secara *lazy-loaded*.
- **Local Persistence:** `sqflite` digunakan sebagai basis relasional sederhana yang handal dan ringan untuk riwayat.
- **BLE Library:** `flutter_blue_plus` (andal dan sering diperbarui untuk Android 12+).
- **Permissions:** `permission_handler`

## Prasyarat (Requirements)
- Flutter SDK `^3.10.0` atau lebih tinggi
- Perangkat Android fisik (Emulator *tidak mendukung* pemindaian Bluetooth)
- Android API Minimum: 21 (Lollipop), dengan izin Bluetooth dan Lokasi Aktif.

## Cara Menjalankan
1. *Clone* *repository* ini.
2. Jalankan `flutter pub get` untuk mengunduh dependensi.
3. Jalankan `flutter pub run build_runner build` (jika mengubah kode DI).
4. Sambungkan perangkat fisik Android via USB Debugging.
5. Jalankan aplikasi dengan perintah:
   ```bash
   flutter run
   ```

## Build Artifact (APK)
APK dapat ditemukan di direktori `build/app/outputs/flutter-apk/app-release.apk` jika melakukan build release (`flutter build apk`).

## Catatan Tambahan (Known Issues & Asumsi)
- Izin Bluetooth dan Lokasi wajib diberikan secara runtime untuk menggunakan aplikasi.
- Kalkulasi jarak menggunakan kategori RSSI murni dan dapat dipengaruhi oleh interferensi gelombang di dunia nyata.

## Generative AI Disclosure
Sesuai dengan ketentuan pengumpulan tugas, saya mengonfirmasi penggunaan AI generatif selama proses pengembangan proyek ini. Bantuan AI dimanfaatkan khusus pada aspek:
1. **Boilerplate & Layouting:** Pembuatan struktur dasar kode UI Flutter (seperti penyusunan *widget tree* untuk efek *glassmorphism* dan mode gelap).
2. **Implementasi Logic Dasar:** Penyusunan logika awal algoritma filtering, *sorting* RSSI, serta kerangka *Clean Architecture*.
3. **Drafting Dokumentasi:** Pendampingan dalam penulisan draf awal untuk dokumentasi *README* ini.

Setiap baris kode yang dihasilkan telah saya pelajari, uji secara menyeluruh (termasuk *edge-cases*), dan sesuaikan secara mendalam agar memenuhi kaidah *Best Practice* Mobile Engineering serta menjawab seluruh parameter dari *study case* yang diberikan.
