import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary.withOpacity(0.95),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.85),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header custom
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).dividerColor.withOpacity(0.08),
                      padding: const EdgeInsets.all(12),
                    ),
                    icon: const Icon(Icons.arrow_back_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Syarat & Ketentuan',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Konten utama
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Icon/Ilustrasi Header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 1.5),
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        size: 48,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Persetujuan Layanan & Kebijakan Privasi Akun Mahasiswa',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Terakhir diperbarui: Mei 2026',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildSection(
                    context,
                    '1. Pengumpulan & Validasi Data',
                    'Untuk mendaftarkan akun di platform KAMPUSGO, sistem memerlukan verifikasi Nomor Induk Mahasiswa (NIM) dan alamat Email Kampus yang sah. Data ini digunakan secara eksklusif untuk memastikan bahwa pengguna terdaftar adalah mahasiswa aktif di lingkungan universitas.',
                  ),

                  _buildSection(
                    context,
                    '2. Keamanan Kredensial',
                    'Kata sandi Anda dienkripsi menggunakan algoritma hashing modern sebelum disimpan di server. Kami tidak pernah menyimpan kata sandi dalam bentuk teks biasa (plaintext). Pengguna bertanggung jawab penuh untuk menjaga kerahasiaan kata sandi dan disarankan menggunakan kombinasi yang kuat.',
                  ),

                  _buildSection(
                    context,
                    '3. Hak Akses & Penggunaan Fasilitas',
                    'Akun mahasiswa memberikan akses ke fitur Smart Study Planner, pemantauan Indeks Prestasi Kumulatif (IPK), dan manajemen keuangan (Budget Buddy). Penggunaan fasilitas ini harus mematuhi norma akademik dan ketentuan hukum yang berlaku.',
                  ),

                  _buildSection(
                    context,
                    '4. Integrasi Single Sign-On (SSO)',
                    'Opsi pendaftaran melalui Google atau SSO Kampus tunduk pada pertukaran token otorisasi standar. Kami hanya mengambil informasi profil dasar (Nama dan Email) yang diizinkan oleh penyedia identitas terkait.',
                  ),

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 20, color: Colors.blueAccent),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Dengan mendaftar, Anda otomatis terikat pada peraturan sistem informasi akademik kampus.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tombol Setuju / Kembali
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Saya Mengerti & Setuju', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
