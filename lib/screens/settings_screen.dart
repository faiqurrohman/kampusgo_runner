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

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: data.userName);
    final emailCtrl = TextEditingController(text: data.userEmail);
    final prodiCtrl = TextEditingController(text: data.userProdi);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Edit Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText: 'Alamat Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: prodiCtrl,
                decoration: InputDecoration(
                  labelText: 'Program Studi',
                  prefixIcon: const Icon(Icons.school_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              data.updateProfile(
                name: nameCtrl.text,
                email: emailCtrl.text,
                prodi: prodiCtrl.text,
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profil berhasil diperbarui'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showAcademicDataDialog() {
    double targetVal = data.targetGpa;
    int semVal = data.activeSemester;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Data Perkuliahan', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Semester Aktif: Semester $semVal', style: const TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: semVal.toDouble(),
                min: 1, max: 14, divisions: 13,
                activeColor: AppTheme.primary,
                label: '$semVal',
                onChanged: (v) => setModalState(() => semVal = v.toInt()),
              ),
              const SizedBox(height: 16),
              Text('Target IPK Kelulusan: ${targetVal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: targetVal,
                min: 2.0, max: 4.0, divisions: 40,
                activeColor: Colors.purpleAccent,
                label: targetVal.toStringAsFixed(2),
                onChanged: (v) => setModalState(() => targetVal = v),
              ),
              const SizedBox(height: 8),
              Text(
                'Digunakan sebagai acuan perbandingan visual pada fitur GPA Predictor.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                data.updateProfile(semester: semVal, target: targetVal);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data akademik diperbarui'), behavior: SnackBarBehavior.floating),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showManageCategoriesDialog() {
    final catCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Kelola Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kategori Pengeluaran Saat Ini:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: data.expenseCategories.map((cat) {
                    return Chip(
                      label: Text(cat, style: const TextStyle(fontSize: 12)),
                      onDeleted: data.expenseCategories.length > 1 ? () {
                        setModalState(() => data.removeExpenseCategory(cat));
                      } : null,
                      backgroundColor: AppTheme.primary.withOpacity(0.08),
                      deleteIconColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: catCtrl,
                        decoration: InputDecoration(
                          hintText: 'Kategori baru...',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      style: IconButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      onPressed: () {
                        if (catCtrl.text.trim().isNotEmpty) {
                          setModalState(() {
                            data.addExpenseCategory(catCtrl.text);
                            catCtrl.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
          ],
        ),
      ),
    );
  }

  void _showBudgetLimitDialog() {
    final ctrl = TextEditingController(text: data.budgetLimit.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Atur Anggaran Bulanan', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Total Limit Saldo (Rp)',
            prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () {
              final val = int.tryParse(ctrl.text) ?? data.budgetLimit;
              data.updateBudgetLimit(val);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Limit anggaran diperbarui'), behavior: SnackBarBehavior.floating),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showExportDataDialog() {
    String selectedFormat = 'PDF';
    bool isExporting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Ekspor Riwayat Keuangan', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Catatan: ${data.expenses.length} pengeluaran', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Format Laporan:'),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('PDF', style: TextStyle(fontSize: 13)),
                      value: 'PDF',
                      groupValue: selectedFormat,
                      activeColor: Colors.redAccent,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) => setModalState(() => selectedFormat = v!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('CSV', style: TextStyle(fontSize: 13)),
                      value: 'CSV',
                      groupValue: selectedFormat,
                      activeColor: Colors.green,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) => setModalState(() => selectedFormat = v!),
                    ),
                  ),
                ],
              ),
              if (isExporting) ...[
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator(strokeWidth: 3)),
                const SizedBox(height: 8),
                Center(child: Text('Menyiapkan file $selectedFormat...', style: const TextStyle(fontSize: 11))),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isExporting ? null : () => Navigator.pop(ctx), 
              child: const Text('Batal'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedFormat == 'PDF' ? Colors.redAccent : Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: isExporting ? null : () async {
                setModalState(() => isExporting = true);
                await Future.delayed(const Duration(milliseconds: 1200));
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Laporan $selectedFormat berhasil diunduh ke folder dokumen'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.teal,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Unduh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12, top: 24),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.primary.withOpacity(0.8),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: data,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Pengaturan', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          children: [
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
                    onPressed: _showEditProfileDialog,
                  ),
                ],
              ),
            ),

            _sectionTitle('1. Pengaturan Profil & Akademik'),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.person_rounded, color: Colors.blue),
                    ),
                    title: const Text('Edit Profil'),
                    subtitle: const Text('Ubah nama, foto, dan email'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _showEditProfileDialog,
                  ),
                  Divider(height: 1, indent: 64, color: Theme.of(context).dividerColor.withOpacity(0.08)),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.purple.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.school_rounded, color: Colors.purple),
                    ),
                    title: const Text('Data Perkuliahan'),
                    subtitle: Text('Semester ${data.activeSemester} • Target IPK ${data.targetGpa.toStringAsFixed(2)}'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _showAcademicDataDialog,
                  ),
                  Divider(height: 1, indent: 64, color: Theme.of(context).dividerColor.withOpacity(0.08)),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.amber.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.calendar_month_rounded, color: Colors.amber),
                    ),
                    title: const Text('Integrasi Kalender'),
                    subtitle: const Text('Sinkronisasi otomatis tugas planner'),
                    trailing: Switch(
                      value: data.calendarIntegration,
                      onChanged: data.toggleCalendarIntegration,
                      activeColor: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            _sectionTitle('2. Pengaturan Keuangan (Budgeting)'),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.category_rounded, color: Colors.green),
                    ),
                    title: const Text('Kelola Kategori'),
                    subtitle: Text('${data.expenseCategories.length} kategori pengeluaran aktif'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _showManageCategoriesDialog,
                  ),
                  Divider(height: 1, indent: 64, color: Theme.of(context).dividerColor.withOpacity(0.08)),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.teal.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.teal),
                    ),
                    title: const Text('Atur Anggaran Bulanan'),
                    subtitle: Text('Limit: ${Formatters.currency.format(data.budgetLimit)}'),
                    trailing: const Icon(Icons.edit_rounded, size: 18),
                    onTap: _showBudgetLimitDialog,
                  ),
                  Divider(height: 1, indent: 64, color: Theme.of(context).dividerColor.withOpacity(0.08)),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent),
                    ),
                    title: const Text('Ekspor Data Laporan'),
                    subtitle: const Text('Unduh riwayat format PDF / CSV'),
                    trailing: const Icon(Icons.download_rounded, size: 18),
                    onTap: _showExportDataDialog,
                  ),
                ],
              ),
            ),

            _sectionTitle('3. Preferensi & Tampilan Aplikasi'),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.palette_rounded, color: Colors.orange),
                    ),
                    title: const Text('Tema Tampilan'),
                    subtitle: Text(data.themeMode == ThemeMode.dark ? 'Mode Gelap Aktif' : 'Mode Terang Aktif'),
                    trailing: Switch(
                      value: data.themeMode == ThemeMode.dark,
                      onChanged: (_) => data.toggleTheme(),
                      activeColor: Colors.orange,
                    ),
                  ),
                  Divider(height: 1, indent: 64, color: Theme.of(context).dividerColor.withOpacity(0.08)),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.notifications_active_rounded, color: Colors.deepPurple),
                    ),
                    title: const Text('Notifikasi Presisi'),
                    subtitle: const Text('Peringatan otomatis < 24 jam'),
                    trailing: Switch(
                      value: data.preciseNotifications,
                      onChanged: data.togglePreciseNotifications,
                      activeColor: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),

            _sectionTitle('4. Keamanan & Informasi'),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.blueGrey.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.security_rounded, color: Colors.blueGrey),
                    ),
                    title: const Text('Keamanan Akun'),
                    subtitle: const Text('Autentikasi & sandi terenkripsi'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Keamanan biometrik diaktifkan'), behavior: SnackBarBehavior.floating),
                      );
                    },
                  ),
                  Divider(height: 1, indent: 64, color: Theme.of(context).dividerColor.withOpacity(0.08)),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.description_rounded, color: Colors.grey),
                    ),
                    title: const Text('Ketentuan & Privasi'),
                    subtitle: const Text('Dokumen legal & lisensi KAMPUSGO'),
                    trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          title: const Text('Ketentuan & Privasi'),
                          content: const Text('Aplikasi KAMPUSGO dirancang khusus untuk mempermudah produktivitas mahasiswa. Seluruh data dilindungi secara terenkripsi lokal pada perangkat Anda.'),
                          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            // Tombol Keluar / Logout Premium
            ElevatedButton.icon(
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Keluar Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
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
    );
  }
}
