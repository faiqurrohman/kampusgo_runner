# Blueprint Aplikasi KampusGo

Berikut adalah cetak biru (blueprint) atau peta arsitektur dari aplikasi **KampusGo** versi saat ini. Aplikasi ini dibangun menggunakan *framework* Flutter dengan pola arsitektur yang terpusat pada *State Management* bawaan (`ChangeNotifier`) untuk menjaga agar aplikasi tetap ringan.

## 🗂️ Struktur Direktori (`lib/`)

```text
lib/
├── main.dart                  # Titik awal (Entry Point) aplikasi dijalankan
├── firebase_options.dart      # Konfigurasi otomatis dari Firebase
│
├── models/                    # [DATA LAYER] Cetakan Data (Class)
│   ├── schedule_model.dart    # Struktur data untuk Tugas & Jadwal Ujian
│   ├── expense_model.dart     # Struktur data untuk Pengeluaran Finansial
│   ├── gpa_model.dart         # Struktur data untuk Mata Kuliah & Nilai
│   └── resource_model.dart    # Struktur data untuk Tautan Materi
│
├── services/                  # [LOGIC LAYER] Otak Aplikasi & Pengelola Data
│   ├── app_data.dart          # State Management pusat (menyimpan data ke memori lokal HP)
│   ├── auth_service.dart      # Mengatur Login (Firebase Auth & Sidik Jari/Biometrik)
│   └── notification_service.dart # Mengatur Izin & Push Notifikasi Sistem
│
├── screens/                   # [UI LAYER] Antarmuka Halaman (Tampilan)
│   ├── splash_screen.dart     # Layar Pembuka saat aplikasi baru diklik
│   ├── login_screen.dart      # Halaman Masuk
│   ├── register_screen.dart   # Halaman Daftar Akun Baru
│   ├── dashboard_screen.dart  # Halaman Induk (Beranda & Navigasi Bawah)
│   ├── planner_screen.dart    # Fitur 1: Smart Planner (Tugas)
│   ├── budget_screen.dart     # Fitur 2: Budget Buddy (Keuangan)
│   ├── gpa_screen.dart        # Fitur 3: GPA Predictor (Nilai/IPK)
│   ├── resource_screen.dart   # Fitur 4: Resource Hub (Tautan Belajar)
│   ├── settings_screen.dart   # Halaman Pengaturan & Keamanan Akun
│   └── privacy_screen.dart    # Halaman Syarat & Kebijakan Privasi
│
├── utils/                     # [UTILITIES] Alat Bantu Tambahan
│   ├── app_theme.dart         # Pengaturan Warna (Primary/Accent), Mode Gelap & Terang
│   └── formatters.dart        # Pengubah format teks (Misal: format Rupiah/Tanggal)
│
└── widgets/                   # [COMPONENTS] Elemen Visual yang Dipakai Berulang
    ├── info_card.dart         # Kotak Kartu Informasi umum
    ├── section_title.dart     # Teks Judul Bagian
    └── simple_donut_chart.dart# Grafik Lingkaran/Donat untuk Analisis Keuangan
```

---

## ⚙️ Cara Kerja (Alur Data)

1. **Autentikasi (Pintu Masuk)**: Saat aplikasi dibuka, `main.dart` akan memanggil `auth_service.dart` untuk mengecek apakah pengguna sudah login (lewat email/password Firebase, atau sidik jari). Jika belum, diarahkan ke `login_screen.dart`.
2. **Pemuatan Data**: Setelah masuk, `app_data.dart` akan mengambil semua data yang tersimpan di memori HP (`shared_preferences`) seperti jadwal, uang sisa, dan nilai IPK, lalu memuatnya ke dalam memori RAM (State) agar aplikasi terasa sangat cepat (tanpa loading internet).
3. **Navigasi Utama**: `dashboard_screen.dart` adalah rumah utama. Halaman ini memiliki bar navigasi di bagian bawah untuk berpindah-pindah ke 4 fitur utama (Planner, Budget, GPA, Resource) tanpa menutup beranda.
4. **Pemberitahuan**: `notification_service.dart` akan meminta izin ke sistem HP, lalu `dashboard_screen.dart` akan memeriksa data di `app_data.dart`. Jika ada tugas yang besok harus dikumpulkan, atau saldo uang sudah menipis, aplikasi akan membunyikan notifikasi sistem ke HP pengguna.

## 🚀 Fitur Unggulan Saat Ini
- **Offline First**: Aplikasi tetap bisa digunakan secara lancar walaupun tidak ada kuota internet.
- **Biometric Login**: Masuk menggunakan sidik jari atau Face ID.
- **Dark Mode Support**: Tema yang bisa beradaptasi secara otomatis dengan siang/malam.
- **4 Pilar Mahasiswa**: Manajemen Waktu (Planner), Uang (Budget), Nilai (GPA), dan Materi (Resource).
