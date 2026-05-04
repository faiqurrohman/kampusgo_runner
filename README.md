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

