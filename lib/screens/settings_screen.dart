import 'package:flutter/material.dart';
import '../services/app_data.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const SettingsScreen({super.key, required this.onLogout});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final data = AppData.instance;

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 28),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.primary.withOpacity(0.9),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconBgColor,
    Color? iconColor,
    Widget? trailingWidget,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor ?? AppTheme.primary.withOpacity(0.12), 
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor ?? AppTheme.primary, size: 20),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7))),
          trailing: trailingWidget ?? Icon(
            Icons.chevron_right_rounded, 
            size: 20, 
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4),
          ),
          onTap: onTap,
        ),
        Divider(height: 1, indent: 64, color: Theme.of(context).dividerColor.withOpacity(0.06)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: data,
      builder: (context, _) => Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            children: [
              // Header Kiri Atas Tebal Beserta Tombol Kembali Sesuai Rekomendasi UI
              Row(
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
                      'Pengaturan',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Kartu Profil Utama
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primary.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: const Text('👋', style: TextStyle(fontSize: 32)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.userName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            data.userProdi,
                            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            data.userEmail,
                            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2)),
                      icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => _EditProfileScreen(data: data)));
                      },
                    ),
                  ],
                ),
              ),

              // Kategori 1: Profil & Akademik
              _sectionTitle('1. Pengaturan Profil & Akademik'),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: [
                    _buildTile(
                      icon: Icons.person_rounded,
                      title: 'Edit Profil',
                      subtitle: 'Ubah nama, foto, dan email',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _EditProfileScreen(data: data))),
                    ),
                    _buildTile(
                      icon: Icons.school_rounded,
                      title: 'Data Perkuliahan',
                      subtitle: 'Semester ${data.activeSemester} • Target IPK ${data.targetGpa.toStringAsFixed(2)}',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _AcademicDataScreen(data: data))),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.calendar_month_rounded, color: AppTheme.primary, size: 20),
                      ),
                      title: const Text('Integrasi Kalender', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text('Sinkronisasi otomatis tugas planner', style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7))),
                      trailing: Switch(
                        value: data.calendarIntegration,
                        onChanged: data.toggleCalendarIntegration,
                        activeColor: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Kategori 2: Keuangan / Budgeting
              _sectionTitle('2. Pengaturan Keuangan (Budgeting)'),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: [
                    _buildTile(
                      icon: Icons.category_rounded,
                      title: 'Kelola Kategori',
                      subtitle: '${data.expenseCategories.length} kategori pengeluaran aktif',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _ManageCategoriesScreen(data: data))),
                    ),
                    _buildTile(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'Atur Anggaran Bulanan',
                      subtitle: 'Limit: ${Formatters.currency.format(data.budgetLimit)}',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _BudgetLimitScreen(data: data))),
                    ),
                    _buildTile(
                      icon: Icons.picture_as_pdf_rounded,
                      title: 'Ekspor Data Laporan',
                      subtitle: 'Unduh riwayat format PDF / CSV',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _ExportDataScreen(data: data))),
                    ),
                  ],
                ),
              ),

              // Kategori 3: Preferensi Aplikasi
              _sectionTitle('3. Preferensi Aplikasi'),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: [
                    _buildTile(
                      icon: Icons.palette_rounded,
                      title: 'Tampilan (Theme)',
                      subtitle: data.themeMode == ThemeMode.dark ? 'Mode Gelap' : (data.themeMode == ThemeMode.light ? 'Mode Terang' : 'Mengikuti Sistem'),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _ThemeSelectionScreen(data: data))),
                    ),
                    _buildTile(
                      icon: Icons.timer_rounded,
                      title: 'Pengingat Deadline Aktif',
                      subtitle: 'Muncul urgensi < ${data.notificationReminderHours} jam',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _NotificationReminderScreen(data: data))),
                    ),
                    _buildTile(
                      icon: Icons.language_rounded,
                      title: 'Bahasa Aplikasi',
                      subtitle: data.appLanguage,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _LanguageSelectionScreen(data: data))),
                    ),
                  ],
                ),
              ),

              // Kategori 4: Keamanan & Data
              _sectionTitle('4. Keamanan & Data'),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: [
                    _buildTile(
                      icon: Icons.security_rounded,
                      title: 'Keamanan Akun',
                      subtitle: data.biometricAuth ? 'Sandi & Biometrik Aktif' : 'Sandi Terlindungi',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _AccountSecurityScreen(data: data))),
                    ),
                    _buildTile(
                      icon: Icons.cloud_upload_rounded,
                      title: 'Cadangkan Data (Backup)',
                      subtitle: 'Enkripsi sinkronisasi Resource Hub',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _BackupDataScreen(data: data))),
                    ),
                    _buildTile(
                      icon: Icons.cleaning_services_rounded,
                      iconBgColor: Colors.red.withOpacity(0.12),
                      iconColor: Colors.redAccent,
                      title: 'Hapus Cache',
                      subtitle: 'Bersihkan memori sementara',
                      trailingWidget: const Icon(Icons.delete_sweep_rounded, size: 20, color: Colors.redAccent),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ 24.5 MB file cache berhasil dibersihkan. Performa optimal.'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.teal,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Kategori 5: Informasi & Dukungan
              _sectionTitle('5. Informasi & Dukungan'),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: [
                    _buildTile(
                      icon: Icons.info_rounded,
                      title: 'Tentang KAMPUSGO',
                      subtitle: 'Versi aplikasi & info pengembang',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _AboutScreen())),
                    ),
                    _buildTile(
                      icon: Icons.description_rounded,
                      title: 'Ketentuan & Privasi',
                      subtitle: 'Dokumen legal & lisensi penggunaan',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _PrivacyScreenView())),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),
              // Tombol Keluar Akun (Logout) Paling Bawah dengan Warna Kontras Merah
              ElevatedButton.icon(
                onPressed: widget.onLogout,
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                label: const Text('Keluar Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// FULL SCREEN SUB-ROUTES (MENGHINDARI POP-UP SESUAI REKOMENDASI UI)
// ============================================================================

class _CustomSubScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? bottomNavigationBar;
  const _CustomSubScaffold({required this.title, required this.body, this.bottomNavigationBar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  IconButton(
                    style: IconButton.styleFrom(backgroundColor: Theme.of(context).dividerColor.withOpacity(0.08)),
                    icon: const Icon(Icons.arrow_back_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class _EditProfileScreen extends StatefulWidget {
  final AppData data;
  const _EditProfileScreen({required this.data});
  @override
  State<_EditProfileScreen> createState() => _EditProfileScreenState();
}
class _EditProfileScreenState extends State<_EditProfileScreen> {
  late final nameCtrl = TextEditingController(text: widget.data.userName);
  late final emailCtrl = TextEditingController(text: widget.data.userEmail);
  late final prodiCtrl = TextEditingController(text: widget.data.userProdi);

  @override
  Widget build(BuildContext context) {
    return _CustomSubScaffold(
      title: 'Edit Profil',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: nameCtrl,
            decoration: InputDecoration(
              labelText: 'Nama Lengkap',
              prefixIcon: const Icon(Icons.person_outline_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: emailCtrl,
            decoration: InputDecoration(
              labelText: 'Alamat Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: prodiCtrl,
            decoration: InputDecoration(
              labelText: 'Program Studi',
              prefixIcon: const Icon(Icons.school_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              widget.data.updateProfile(name: nameCtrl.text, email: emailCtrl.text, prodi: prodiCtrl.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil diperbarui'), behavior: SnackBarBehavior.floating));
            },
            child: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _AcademicDataScreen extends StatefulWidget {
  final AppData data;
  const _AcademicDataScreen({required this.data});
  @override
  State<_AcademicDataScreen> createState() => _AcademicDataScreenState();
}
class _AcademicDataScreenState extends State<_AcademicDataScreen> {
  late int semVal = widget.data.activeSemester;
  late double targetVal = widget.data.targetGpa;

  @override
  Widget build(BuildContext context) {
    return _CustomSubScaffold(
      title: 'Data Perkuliahan',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Semester Aktif: Semester $semVal', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Slider(
            value: semVal.toDouble(),
            min: 1, max: 14, divisions: 13,
            activeColor: AppTheme.primary,
            label: '$semVal',
            onChanged: (v) => setState(() => semVal = v.toInt()),
          ),
          const SizedBox(height: 32),
          Text('Target IPK Kelulusan: ${targetVal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Slider(
            value: targetVal,
            min: 2.0, max: 4.0, divisions: 40,
            activeColor: Colors.purpleAccent,
            label: targetVal.toStringAsFixed(2),
            onChanged: (v) => setState(() => targetVal = v),
          ),
          const SizedBox(height: 12),
          Text('Digunakan untuk acuan perbandingan visual pada fitur GPA Predictor.', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 48),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            onPressed: () {
              widget.data.updateProfile(semester: semVal, target: targetVal);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data akademik disimpan'), behavior: SnackBarBehavior.floating));
            },
            child: const Text('Simpan Data', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _ManageCategoriesScreen extends StatefulWidget {
  final AppData data;
  const _ManageCategoriesScreen({required this.data});
  @override
  State<_ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}
class _ManageCategoriesScreenState extends State<_ManageCategoriesScreen> {
  final catCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.data,
      builder: (context, _) => _CustomSubScaffold(
        title: 'Kelola Kategori',
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text('Kategori Pengeluaran Saat Ini:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: widget.data.expenseCategories.map((cat) {
                return Chip(
                  label: Text(cat),
                  onDeleted: widget.data.expenseCategories.length > 1 ? () => widget.data.removeExpenseCategory(cat) : null,
                  backgroundColor: AppTheme.primary.withOpacity(0.08),
                  deleteIconColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: catCtrl,
                    decoration: InputDecoration(labelText: 'Kategori baru...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: () {
                    if (catCtrl.text.isNotEmpty) {
                      widget.data.addExpenseCategory(catCtrl.text);
                      catCtrl.clear();
                    }
                  },
                  child: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetLimitScreen extends StatefulWidget {
  final AppData data;
  const _BudgetLimitScreen({required this.data});
  @override
  State<_BudgetLimitScreen> createState() => _BudgetLimitScreenState();
}
class _BudgetLimitScreenState extends State<_BudgetLimitScreen> {
  late final ctrl = TextEditingController(text: widget.data.budgetLimit.toString());
  @override
  Widget build(BuildContext context) {
    return _CustomSubScaffold(
      title: 'Atur Anggaran Bulanan',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Total Limit Saldo (Rp)', prefixIcon: const Icon(Icons.account_balance_wallet_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            onPressed: () {
              final val = int.tryParse(ctrl.text) ?? widget.data.budgetLimit;
              widget.data.updateBudgetLimit(val);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Limit anggaran diperbarui'), behavior: SnackBarBehavior.floating));
            },
            child: const Text('Simpan Anggaran', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _ExportDataScreen extends StatefulWidget {
  final AppData data;
  const _ExportDataScreen({required this.data});
  @override
  State<_ExportDataScreen> createState() => _ExportDataScreenState();
}
class _ExportDataScreenState extends State<_ExportDataScreen> {
  String selectedFormat = 'PDF';
  bool isExporting = false;

  @override
  Widget build(BuildContext context) {
    return _CustomSubScaffold(
      title: 'Ekspor Data Laporan',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Total Catatan Finansial: ${widget.data.expenses.length} pengeluaran', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 24),
          const Text('Pilih Format Dokumen Unduhan:'),
          const SizedBox(height: 12),
          RadioListTile<String>(
            title: const Text('Format Dokumen PDF (.pdf)'),
            value: 'PDF', groupValue: selectedFormat,
            activeColor: Colors.redAccent,
            onChanged: (v) => setState(() => selectedFormat = v!),
          ),
          RadioListTile<String>(
            title: const Text('Format Lembar Data CSV (.csv)'),
            value: 'CSV', groupValue: selectedFormat,
            activeColor: Colors.green,
            onChanged: (v) => setState(() => selectedFormat = v!),
          ),
          if (isExporting) ...[
            const SizedBox(height: 48),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 16),
            Center(child: Text('Menyusun file $selectedFormat dan mengekspor lokal...', style: const TextStyle(fontWeight: FontWeight.bold))),
          ] else ...[
            const SizedBox(height: 48),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: selectedFormat == 'PDF' ? Colors.redAccent : Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: () async {
                setState(() => isExporting = true);
                await Future.delayed(const Duration(milliseconds: 1500));
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ File laporan $selectedFormat berhasil diunduh ke folder penyimpanan internal'), backgroundColor: Colors.teal, behavior: SnackBarBehavior.floating));
                }
              },
              icon: const Icon(Icons.download_rounded),
              label: const Text('Mulai Unduh Laporan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }
}

class _ThemeSelectionScreen extends StatelessWidget {
  final AppData data;
  const _ThemeSelectionScreen({required this.data});
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: data,
      builder: (context, _) => _CustomSubScaffold(
        title: 'Tampilan (Theme)',
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Mode Gelap'),
              secondary: const Icon(Icons.dark_mode_rounded, color: Colors.amber),
              value: ThemeMode.dark, groupValue: data.themeMode,
              activeColor: AppTheme.primary,
              onChanged: (v) => data.setThemeMode(v!),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Mode Terang'),
              secondary: const Icon(Icons.light_mode_rounded, color: Colors.amber),
              value: ThemeMode.light, groupValue: data.themeMode,
              activeColor: AppTheme.primary,
              onChanged: (v) => data.setThemeMode(v!),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Mengikuti Sistem'),
              secondary: const Icon(Icons.brightness_auto_rounded, color: Colors.blue),
              value: ThemeMode.system, groupValue: data.themeMode,
              activeColor: AppTheme.primary,
              onChanged: (v) => data.setThemeMode(v!),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationReminderScreen extends StatelessWidget {
  final AppData data;
  const _NotificationReminderScreen({required this.data});
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: data,
      builder: (context, _) => _CustomSubScaffold(
        title: 'Pengingat Deadline Aktif',
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text('Munculkan tanda urgensi di layar utama dasbor sebelum:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            RadioListTile<int>(
              title: const Text('24 Jam (1 Hari) sebelum deadline'),
              value: 24, groupValue: data.notificationReminderHours,
              activeColor: AppTheme.primary,
              onChanged: (v) => data.updateNotificationReminder(v!),
            ),
            RadioListTile<int>(
              title: const Text('12 Jam sebelum deadline'),
              value: 12, groupValue: data.notificationReminderHours,
              activeColor: AppTheme.primary,
              onChanged: (v) => data.updateNotificationReminder(v!),
            ),
            RadioListTile<int>(
              title: const Text('6 Jam sebelum deadline'),
              value: 6, groupValue: data.notificationReminderHours,
              activeColor: AppTheme.primary,
              onChanged: (v) => data.updateNotificationReminder(v!),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageSelectionScreen extends StatelessWidget {
  final AppData data;
  const _LanguageSelectionScreen({required this.data});
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: data,
      builder: (context, _) => _CustomSubScaffold(
        title: 'Bahasa Aplikasi',
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            RadioListTile<String>(
              title: const Text('Bahasa Indonesia'),
              subtitle: const Text('ID'),
              value: 'Bahasa Indonesia', groupValue: data.appLanguage,
              activeColor: AppTheme.primary,
              onChanged: (v) => data.updateLanguage(v!),
            ),
            RadioListTile<String>(
              title: const Text('English'),
              subtitle: const Text('EN'),
              value: 'English', groupValue: data.appLanguage,
              activeColor: AppTheme.primary,
              onChanged: (v) => data.updateLanguage(v!),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountSecurityScreen extends StatefulWidget {
  final AppData data;
  const _AccountSecurityScreen({required this.data});
  @override
  State<_AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}
class _AccountSecurityScreenState extends State<_AccountSecurityScreen> {
  final oldPass = TextEditingController();
  final newPass = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.data,
      builder: (context, _) => _CustomSubScaffold(
        title: 'Keamanan Akun',
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text('Ganti Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(controller: oldPass, obscureText: true, decoration: InputDecoration(labelText: 'Kata Sandi Lama', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)))),
            const SizedBox(height: 16),
            TextField(controller: newPass, obscureText: true, decoration: InputDecoration(labelText: 'Kata Sandi Baru', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)))),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: () {
                if (newPass.text.isNotEmpty) {
                  oldPass.clear(); newPass.clear();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kata sandi berhasil diubah'), behavior: SnackBarBehavior.floating));
                }
              },
              child: const Text('Perbarui Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Autentikasi Biometrik (Sidik Jari)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Login instan tanpa memasukkan sandi'),
              value: widget.data.biometricAuth,
              activeColor: AppTheme.primary,
              onChanged: widget.data.toggleBiometricAuth,
            ),
          ],
        ),
      ),
    );
  }
}

class _BackupDataScreen extends StatefulWidget {
  final AppData data;
  const _BackupDataScreen({required this.data});
  @override
  State<_BackupDataScreen> createState() => _BackupDataScreenState();
}
class _BackupDataScreenState extends State<_BackupDataScreen> {
  bool isBackingUp = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.data,
      builder: (context, _) => _CustomSubScaffold(
        title: 'Cadangkan Data (Backup)',
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.08), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.blue.withOpacity(0.2))),
              child: Column(
                children: [
                  const Icon(Icons.cloud_done_rounded, size: 48, color: Colors.blue),
                  const SizedBox(height: 12),
                  const Text('Sinkronisasi Cloud Server', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Terakhir dicadangkan: ${widget.data.lastBackupDate}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Tautan Aktif Tersimpan: ${widget.data.resources.length} link', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Riwayat Transaksi Finansial: ${widget.data.expenses.length} catatan', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 48),
            if (isBackingUp) ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 16),
              const Center(child: Text('Mengunggah paket data terenkripsi ke Cloud server...', style: TextStyle(fontWeight: FontWeight.bold))),
            ] else ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () async {
                  setState(() => isBackingUp = true);
                  await Future.delayed(const Duration(milliseconds: 1500));
                  if (context.mounted) {
                    widget.data.performBackup('Hari ini, ${TimeOfDay.now().format(context)}');
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Seluruh data berhasil dicadangkan ke Cloud Server'), backgroundColor: Colors.teal, behavior: SnackBarBehavior.floating));
                  }
                },
                icon: const Icon(Icons.backup_rounded),
                label: const Text('Mulai Cadangkan Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AboutScreen extends StatelessWidget {
  const _AboutScreen();
  @override
  Widget build(BuildContext context) {
    return _CustomSubScaffold(
      title: 'Tentang KAMPUSGO',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]), borderRadius: BorderRadius.circular(32)),
              child: const Icon(Icons.school_rounded, size: 64, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text('KAMPUSGO', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Versi 1.0.0+1', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            const Text('Dikembangkan khusus untuk mendukung manajemen\nproduktivitas kehidupan mahasiswa.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
            const SizedBox(height: 48),
            Text('© 2026 KAMPUSGO Mobile Team', style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5))),
          ],
        ),
      ),
    );
  }
}

class _PrivacyScreenView extends StatelessWidget {
  const _PrivacyScreenView();
  @override
  Widget build(BuildContext context) {
    return _CustomSubScaffold(
      title: 'Ketentuan & Privasi',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          Text('Kebijakan Privasi & Lisensi Penggunaan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 16),
          Text(
            'Aplikasi KAMPUSGO berkomitmen penuh untuk melindungi privasi setiap mahasiswa. Seluruh data perkuliahan, tugas aktif pada Smart Study Planner, alokasi keuangan pada Budget Buddy, serta repositori tautan Resource Hub disimpan dan diproses secara aman dalam perangkat lokal Anda menggunakan protokol enkripsi terstandarisasi.\n\n'
            'Data tidak akan pernah dibagikan kepada pihak ketiga tanpa persetujuan eksplisit melalui fitur pencadangan mandiri (Cloud Backup). Dengan menggunakan aplikasi ini, Anda menyetujui pemanfaatan fitur pengingat lokal dan kalkulasi IPK prediktif sebagai sarana penunjang akademis mandiri.',
            style: TextStyle(height: 1.6),
          ),
        ],
      ),
    );
  }
}
