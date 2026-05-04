# KAMPUSGO

KAMPUSGO adalah aplikasi mobile berbasis Flutter untuk membantu mahasiswa mengatur kehidupan kampus dalam satu aplikasi. Aplikasi ini memiliki fitur manajemen deadline, pengeluaran, prediksi IPK, dan penyimpanan link penting kuliah.

## Tema dan Nama Aplikasi

- **Nama Aplikasi:** KAMPUSGO
- **Tema:** Campus Life Management App
- **Platform:** Android/iOS menggunakan Flutter
- **Target Pengguna:** Mahasiswa aktif

## Deskripsi Singkat

Mahasiswa sering kesulitan membagi waktu antara kuliah, organisasi, tugas, ujian, dan pengelolaan uang saku. KAMPUSGO dibuat untuk membantu mahasiswa mengatur jadwal, mengontrol pengeluaran, memprediksi IPK, dan menyimpan resource kuliah secara praktis.

## Fitur Aplikasi

### 1. Login dan Register Demo
- Form login dan register
- Validasi email dan password
- Demo account: `demo@kampusgo.id` / `123456`

### 2. Dashboard
- Ringkasan deadline aktif
- Total pengeluaran
- Prediksi IPK semester
- Prioritas tugas terdekat

### 3. Smart Study Planner
- Tambah deadline tugas/ujian
- Pilih tanggal deadline
- Prioritas tugas
- Checklist tugas selesai
- Hapus tugas dengan swipe

### 4. Budget Buddy
- Tambah pengeluaran
- Kategori pengeluaran
- Total pengeluaran
- Grafik donut sederhana berdasarkan kategori
- Hapus pengeluaran dengan swipe

### 5. GPA Predictor
- Input mata kuliah
- Input SKS
- Input target nilai
- Perhitungan estimasi IPK otomatis
- Hapus data nilai dengan swipe

### 6. Community Resource Hub
- Simpan link materi kuliah
- Simpan link Zoom/Meet
- Simpan link penting per mata kuliah
- Buka link ke browser
- Hapus resource dengan swipe

## Teknologi yang Digunakan

- Flutter
- Dart
- Material Design 3
- intl
- url_launcher
- Git dan GitHub

## Struktur Folder

```text
lib/
├── main.dart
├── models/
│   ├── schedule_model.dart
│   ├── expense_model.dart
│   ├── gpa_model.dart
│   └── resource_model.dart
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── dashboard_screen.dart
│   ├── planner_screen.dart
│   ├── budget_screen.dart
│   ├── gpa_screen.dart
│   └── resource_screen.dart
├── services/
│   └── app_data.dart
├── widgets/
│   ├── info_card.dart
│   ├── section_title.dart
│   └── simple_donut_chart.dart
└── utils/
    ├── app_theme.dart
    └── formatters.dart
```

## Cara Menjalankan Aplikasi

1. Pastikan Flutter sudah terinstall.
2. Buka folder project menggunakan VS Code.
3. Jalankan perintah berikut:

```bash
flutter pub get
flutter run
```

## Cara Menjalankan di HP Android

1. Aktifkan Developer Options di HP.
2. Aktifkan USB Debugging.
3. Sambungkan HP ke laptop menggunakan kabel USB.
4. Jalankan:

```bash
flutter devices
flutter run
```

## Cara Build APK

```bash
flutter build apk --release
```

File APK akan muncul di:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Cara Build AAB untuk Google Play Store

```bash
flutter build appbundle --release
```

File AAB akan muncul di:

```text
build/app/outputs/bundle/release/app-release.aab
```

## Catatan Penting untuk Upload Play Store

Agar benar-benar bisa upload ke Google Play Store, masih perlu:

1. Akun Google Play Console.
2. Package name final, misalnya `com.nama.kampusgo`.
3. App signing key.
4. Icon aplikasi final.
5. Screenshot aplikasi.
6. Privacy Policy.
7. Testing internal/closed testing sesuai aturan Google Play.

## Git Workflow

Project harus di-push ke GitHub secara bertahap. Contoh alur:

```bash
git init
git add .
git commit -m "Week 1: Initial KAMPUSGO project"
git branch -M main
git remote add origin https://github.com/username/kampusgo.git
git push -u origin main
```

Update berikutnya:

```bash
git add .
git commit -m "Week 2: Add login and register UI"
git push
```

## Rencana Commit Mingguan

- Week 1: Initial UI and dashboard
- Week 2: Login and register UI
- Week 3: Planner CRUD
- Week 4: Budget tracker and chart
- Week 5: GPA predictor dynamic input
- Week 6: Resource hub management
- Week 7: UI polish and testing
- Week 8: Release preparation and build AAB

## Status Project

Project ini sudah berisi fitur utama sesuai blueprint dan bisa dijalankan sebagai aplikasi Flutter. Data masih bersifat lokal sementara di memori aplikasi, sehingga ketika aplikasi ditutup total data tambahan akan kembali ke data demo awal. Untuk versi produksi, penyimpanan bisa ditingkatkan menggunakan Firebase Firestore atau Shared Preferences.
