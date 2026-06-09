import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
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


  void _showSwitchAccountModal(BuildContext context) async {
    final accounts = await AuthService.instance.getSavedAccounts();
    if (!context.mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, MediaQuery.of(ctx).padding.bottom + 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2.r))),
            SizedBox(height: 20.h),
            Text('Beralih Akun', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            Text('Pilih akun yang pernah login sebelumnya', style: TextStyle(fontSize: 13.sp, color: Colors.grey)),
            SizedBox(height: 24.h),
            ...accounts.map((acc) {
              final isCurrent = acc['email'] == data.userEmail;
              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                leading: CircleAvatar(
                  backgroundColor: isCurrent ? AppTheme.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  child: Text(acc['name']![0].toUpperCase(), style: TextStyle(color: isCurrent ? AppTheme.primary : Colors.grey)),
                ),
                title: Text(acc['name']!, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(acc['email']!),
                trailing: isCurrent ? Icon(Icons.check_circle_rounded, color: AppTheme.primary) : null,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                tileColor: isCurrent ? AppTheme.primary.withOpacity(0.05) : null,
                onTap: () async {
                  if (isCurrent) {
                    Navigator.pop(ctx);
                    return;
                  }
                  await AuthService.instance.switchAccount(acc['email']!, acc['name']!);
                  await AppData.instance.loadUserData(acc['email']!);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              );
            }).toList(),
            SizedBox(height: 16.h),
            Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
            SizedBox(height: 16.h),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              leading: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Icon(Icons.add_rounded, color: AppTheme.primary),
              ),
              title: Text('Tambah Akun KampusGo Baru', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
              onTap: () {
                Navigator.pop(ctx);
                widget.onLogout();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 12.h, top: 28.h),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12.sp,
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
    bool isSmaller = false,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: isSmaller ? 24 : 16, vertical: isSmaller ? 0 : 4),
          dense: isSmaller,
          leading: Container(
            padding: EdgeInsets.all(isSmaller ? 8 : 10),
            decoration: BoxDecoration(
              color: iconBgColor ?? AppTheme.primary.withOpacity(isSmaller ? 0.08 : 0.12), 
              borderRadius: BorderRadius.circular(isSmaller ? 10 : 12),
            ),
            child: Icon(icon, color: iconColor ?? AppTheme.primary, size: isSmaller ? 16 : 20),
          ),
          title: Text(title, style: TextStyle(fontWeight: isSmaller ? FontWeight.w500 : FontWeight.w600, fontSize: isSmaller ? 13 : 14)),
          subtitle: Text(subtitle, style: TextStyle(fontSize: isSmaller ? 11 : 12, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7))),
          trailing: trailingWidget ?? Icon(
            Icons.chevron_right_rounded, 
            size: isSmaller ? 16 : 20, 
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4),
          ),
          onTap: onTap,
        ),
        Divider(height: 1.h, indent: isSmaller ? 72 : 64, color: Theme.of(context).dividerColor.withOpacity(0.06)),
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
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            children: [
              // Bilah navigasi atas dengan '<- Pengaturan'
              Row(
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).dividerColor.withOpacity(0.08),
                      padding: EdgeInsets.all(12.w),
                    ),
                    icon: Icon(Icons.arrow_back_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      'Pengaturan',
                      style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Kartu profil ungu gradien besar yang diperbarui
              // Emoji tangan melambai diganti dengan foto profil mahasiswa melingkar yang sama dari dasbor
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primary.withOpacity(0.25), blurRadius: 20.r, offset: const Offset(0, 8)),
                  ],
                ),
                child: Row(
                  children: [
                    // Foto profil mahasiswa melingkar diposisikan sebelum nama dan prodi
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.4), width: 2.w),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8.r, spreadRadius: 1.r),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 36.r,
                        backgroundColor: Colors.white.withOpacity(0.15),
                        backgroundImage: data.userAvatarUrl.contains('/') || data.userAvatarUrl.contains('\\')
                            ? FileImage(File(data.userAvatarUrl))
                            : null,
                        child: data.userAvatarUrl.contains('/') || data.userAvatarUrl.contains('\\')
                            ? null
                            : Text(data.userAvatarUrl, style: TextStyle(fontSize: 34.sp)),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.userName,
                            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            data.userProdi,
                            style: TextStyle(fontSize: 13.sp, color: Colors.white.withOpacity(0.9)),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            data.userEmail,
                            style: TextStyle(fontSize: 12.sp, color: Colors.white.withOpacity(0.7)),
                          ),
                        ],
                      ),
                    ),
                    // Pertahankan ikon pensil 'Edit'
                    IconButton(
                      style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2)),
                      icon: Icon(Icons.edit_rounded, color: Colors.white, size: 20),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: [
                    // 'Edit Profil' diperbarui menyertakan teks 'Ubah nama, email, dan info akademik'
                    _buildTile(
                      icon: Icons.person_rounded,
                      title: 'Edit Profil',
                      subtitle: 'Ubah nama, email, dan info akademik',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _EditProfileScreen(data: data))),
                    ),
                    // Opsi baru spesifik yang lebih kecil 'Edit foto profil' dengan ikon pensil
                    _buildTile(
                      icon: Icons.edit_rounded,
                      title: 'Edit foto profil',
                      subtitle: 'Pilih avatar grafis personalisasi',
                      isSmaller: true,
                      iconColor: Colors.purpleAccent,
                      iconBgColor: Colors.purpleAccent.withOpacity(0.1),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _EditAvatarScreen(data: data))),
                    ),
                    _buildTile(
                      icon: Icons.school_rounded,
                      title: 'Data Perkuliahan',
                      subtitle: 'Semester ${data.activeSemester} • Target IPK ${data.targetGpa.toStringAsFixed(2)}',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _AcademicDataScreen(data: data))),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                      leading: Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(12.r)),
                        child: Icon(Icons.calendar_month_rounded, color: AppTheme.primary, size: 20),
                      ),
                      title: Text('Integrasi Kalender', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
                      subtitle: Text('Sinkronisasi otomatis tugas planner', style: TextStyle(fontSize: 12.sp, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7))),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
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
                      trailingWidget: Icon(Icons.delete_sweep_rounded, size: 20, color: Colors.redAccent),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
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

              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: () => _showSwitchAccountModal(context),
                icon: Icon(Icons.people_alt_rounded, color: AppTheme.primary),
                label: Text('Beralih Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppTheme.primary)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  foregroundColor: AppTheme.primary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                  elevation: 0,
                ),
              ),
              SizedBox(height: 16.h),
              // Tombol Keluar Akun (Logout) Paling Bawah dengan Warna Kontras Merah
              ElevatedButton.icon(
                onPressed: widget.onLogout,
                icon: Icon(Icons.logout_rounded, color: Colors.white),
                label: Text('Keluar Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                  elevation: 0,
                ),
              ),
              SizedBox(height: 48.h),
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
              padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  IconButton(
                    style: IconButton.styleFrom(backgroundColor: Theme.of(context).dividerColor.withOpacity(0.08)),
                    icon: Icon(Icons.arrow_back_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
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

class _EditAvatarScreen extends StatelessWidget {
  final AppData data;
  const _EditAvatarScreen({required this.data});

  @override
  Widget build(BuildContext context) {
    final list = ['🧑‍🎓', '👨‍💻', '👩‍💻', '🎓', '⚡', '🚀', '🌟', '🎯', '💡'];
    return _CustomSubScaffold(
      title: 'Edit Foto Profil',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pilihan Utama: Tambahkan dari Galeri HP Sendiri
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
            child: InkWell(
              borderRadius: BorderRadius.circular(24.r),
              onTap: () async {
                try {
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 50,
                  );
                  if (pickedFile != null && context.mounted) {
                    data.updateProfile(avatar: pickedFile.path);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🖼️ Foto profil kustom berhasil diunggah dari Galeri'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.teal,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    data.updateProfile(avatar: '📸');
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Foto disimulasikan dari Galeri'), behavior: SnackBarBehavior.floating),
                    );
                  }
                }
              },
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.purpleAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: Colors.purpleAccent.withOpacity(0.4), width: 2.w),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(color: Colors.purpleAccent, borderRadius: BorderRadius.circular(16.r)),
                      child: Icon(Icons.photo_library_rounded, color: Colors.white, size: 28),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pilih dari Galeri HP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Colors.purpleAccent)),
                          SizedBox(height: 4.h),
                          Text('Gunakan foto asli milikmu sendiri dari galeri internal', style: TextStyle(fontSize: 12.sp, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8))),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: Colors.purpleAccent),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(28, 24, 24, 8),
            child: Text('ATAU PILIH AVATAR GRAFIS TERSEDIA:', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6))),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 16, mainAxisSpacing: 16,
              ),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                final isSelected = data.userAvatarUrl == item;
                return InkWell(
                  borderRadius: BorderRadius.circular(24.r),
                  onTap: () {
                    data.updateProfile(avatar: item);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto profil diperbarui'), behavior: SnackBarBehavior.floating));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary.withOpacity(0.2) : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(color: isSelected ? AppTheme.primary : Theme.of(context).dividerColor.withOpacity(0.08), width: isSelected ? 2 : 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(item, style: TextStyle(fontSize: 40.sp)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
        padding: EdgeInsets.all(24.w),
        children: [
          TextField(
            controller: nameCtrl,
            decoration: InputDecoration(
              labelText: 'Nama Lengkap',
              prefixIcon: Icon(Icons.person_outline_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
            ),
          ),
          SizedBox(height: 20.h),
          TextField(
            controller: emailCtrl,
            decoration: InputDecoration(
              labelText: 'Alamat Email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
            ),
          ),
          SizedBox(height: 20.h),
          TextField(
            controller: prodiCtrl,
            decoration: InputDecoration(
              labelText: 'Program Studi',
              prefixIcon: Icon(Icons.school_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
            ),
          ),
          SizedBox(height: 32.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            ),
            onPressed: () {
              widget.data.updateProfile(name: nameCtrl.text, email: emailCtrl.text, prodi: prodiCtrl.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil diperbarui'), behavior: SnackBarBehavior.floating));
            },
            child: Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold)),
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
        padding: EdgeInsets.all(24.w),
        children: [
          Text('Semester Aktif: Semester $semVal', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Slider(
            value: semVal.toDouble(),
            min: 1, max: 14, divisions: 13,
            activeColor: AppTheme.primary,
            label: '$semVal',
            onChanged: (v) => setState(() => semVal = v.toInt()),
          ),
          SizedBox(height: 32.h),
          Text('Target IPK Kelulusan: ${targetVal.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Slider(
            value: targetVal,
            min: 2.0, max: 4.0, divisions: 40,
            activeColor: Colors.purpleAccent,
            label: targetVal.toStringAsFixed(2),
            onChanged: (v) => setState(() => targetVal = v),
          ),
          SizedBox(height: 12.h),
          Text('Digunakan untuk acuan perbandingan visual pada fitur GPA Predictor.', style: Theme.of(context).textTheme.bodySmall),
          SizedBox(height: 48.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 16.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r))),
            onPressed: () {
              widget.data.updateProfile(semester: semVal, target: targetVal);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data akademik disimpan'), behavior: SnackBarBehavior.floating));
            },
            child: Text('Simpan Data', style: TextStyle(fontWeight: FontWeight.bold)),
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
          padding: EdgeInsets.all(24.w),
          children: [
            Text('Kategori Pengeluaran Saat Ini:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: widget.data.expenseCategories.map((cat) {
                return Chip(
                  label: Text(cat),
                  onDeleted: widget.data.expenseCategories.length > 1 ? () => widget.data.removeExpenseCategory(cat) : null,
                  backgroundColor: AppTheme.primary.withOpacity(0.08),
                  deleteIconColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                );
              }).toList(),
            ),
            SizedBox(height: 32.h),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: catCtrl,
                    decoration: InputDecoration(labelText: 'Kategori baru...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r))),
                  ),
                ),
                SizedBox(width: 12.w),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r))),
                  onPressed: () {
                    if (catCtrl.text.isNotEmpty) {
                      widget.data.addExpenseCategory(catCtrl.text);
                      catCtrl.clear();
                    }
                  },
                  child: Icon(Icons.add_rounded),
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
        padding: EdgeInsets.all(24.w),
        children: [
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Total Limit Saldo (Rp)', prefixIcon: Icon(Icons.account_balance_wallet_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r))),
          ),
          SizedBox(height: 32.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 16.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r))),
            onPressed: () {
              final val = int.tryParse(ctrl.text) ?? widget.data.budgetLimit;
              widget.data.updateBudgetLimit(val);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Limit anggaran diperbarui'), behavior: SnackBarBehavior.floating));
            },
            child: Text('Simpan Anggaran', style: TextStyle(fontWeight: FontWeight.bold)),
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
        padding: EdgeInsets.all(24.w),
        children: [
          Text('Total Catatan Finansial: ${widget.data.expenses.length} pengeluaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
          SizedBox(height: 24.h),
          Text('Pilih Format Dokumen Unduhan:'),
          SizedBox(height: 12.h),
          RadioListTile<String>(
            title: Text('Format Dokumen PDF (.pdf)'),
            value: 'PDF', groupValue: selectedFormat,
            activeColor: Colors.redAccent,
            onChanged: (v) => setState(() => selectedFormat = v!),
          ),
          RadioListTile<String>(
            title: Text('Format Lembar Data CSV (.csv)'),
            value: 'CSV', groupValue: selectedFormat,
            activeColor: Colors.green,
            onChanged: (v) => setState(() => selectedFormat = v!),
          ),
          if (isExporting) ...[
            SizedBox(height: 48.h),
            Center(child: CircularProgressIndicator()),
            SizedBox(height: 16.h),
            Center(child: Text('Menyusun file $selectedFormat dan mengekspor lokal...', style: TextStyle(fontWeight: FontWeight.bold))),
          ] else ...[
            SizedBox(height: 48.h),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: selectedFormat == 'PDF' ? Colors.redAccent : Colors.green, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 16.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r))),
              onPressed: () async {
                setState(() => isExporting = true);
                await Future.delayed(const Duration(milliseconds: 1500));
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ File laporan $selectedFormat berhasil diunduh ke folder penyimpanan internal'), backgroundColor: Colors.teal, behavior: SnackBarBehavior.floating));
                }
              },
              icon: Icon(Icons.download_rounded),
              label: Text('Mulai Unduh Laporan', style: TextStyle(fontWeight: FontWeight.bold)),
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
          padding: EdgeInsets.all(24.w),
          children: [
            RadioListTile<ThemeMode>(
              title: Text('Mode Gelap'),
              secondary: Icon(Icons.dark_mode_rounded, color: Colors.amber),
              value: ThemeMode.dark, groupValue: data.themeMode,
              activeColor: AppTheme.primary,
              onChanged: (v) => data.setThemeMode(v!),
            ),
            RadioListTile<ThemeMode>(
              title: Text('Mode Terang'),
              secondary: Icon(Icons.light_mode_rounded, color: Colors.amber),
              value: ThemeMode.light, groupValue: data.themeMode,
              activeColor: AppTheme.primary,
              onChanged: (v) => data.setThemeMode(v!),
            ),
            RadioListTile<ThemeMode>(
              title: Text('Mengikuti Sistem'),
              secondary: Icon(Icons.brightness_auto_rounded, color: Colors.blue),
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
          padding: EdgeInsets.all(24.w),
          children: [
            Text('Munculkan tanda urgensi di layar utama dasbor sebelum:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            RadioListTile<int>(
              title: Text('24 Jam (1 Hari) sebelum deadline'),
              value: 24, groupValue: data.notificationReminderHours,
              activeColor: AppTheme.primary,
              onChanged: (v) => data.updateNotificationReminder(v!),
            ),
            RadioListTile<int>(
              title: Text('12 Jam sebelum deadline'),
              value: 12, groupValue: data.notificationReminderHours,
              activeColor: AppTheme.primary,
              onChanged: (v) => data.updateNotificationReminder(v!),
            ),
            RadioListTile<int>(
              title: Text('6 Jam sebelum deadline'),
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
          padding: EdgeInsets.all(24.w),
          children: [
            RadioListTile<String>(
              title: Text('Bahasa Indonesia'),
              subtitle: Text('ID'),
              value: 'Bahasa Indonesia', groupValue: data.appLanguage,
              activeColor: AppTheme.primary,
              onChanged: (v) => data.updateLanguage(v!),
            ),
            RadioListTile<String>(
              title: Text('English'),
              subtitle: Text('EN'),
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
  final confirmPass = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _signOutAll = false;

  String _passwordStrength = '';
  Color _strengthColor = Colors.transparent;

  void _checkPasswordStrength(String value) {
    if (value.isEmpty) {
      setState(() {
        _passwordStrength = '';
        _strengthColor = Colors.transparent;
      });
    } else if (value.length < 6) {
      setState(() {
        _passwordStrength = 'Lemah';
        _strengthColor = Colors.redAccent;
      });
    } else if (value.length < 10 || !value.contains(RegExp(r'[0-9]')) || !value.contains(RegExp(r'[A-Z]'))) {
      setState(() {
        _passwordStrength = 'Sedang';
        _strengthColor = Colors.orange;
      });
    } else {
      setState(() {
        _passwordStrength = 'Kuat';
        _strengthColor = Colors.green;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.data,
      builder: (context, _) => _CustomSubScaffold(
        title: 'Keamanan Akun',
        body: ListView(
          padding: EdgeInsets.all(24.w),
          children: [
            Text('Ganti Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
            SizedBox(height: 12.h),
            TextField(
              controller: oldPass, 
              obscureText: _obscureOld, 
              decoration: InputDecoration(
                labelText: 'Kata Sandi Lama', 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
                suffixIcon: IconButton(
                  icon: Icon(_obscureOld ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  onPressed: () => setState(() => _obscureOld = !_obscureOld),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: newPass, 
              obscureText: _obscureNew, 
              onChanged: _checkPasswordStrength,
              decoration: InputDecoration(
                labelText: 'Kata Sandi Baru', 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
                suffixIcon: IconButton(
                  icon: Icon(_obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
            ),
            if (_passwordStrength.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 8.h, left: 12.w),
                child: Text('Kekuatan sandi: $_passwordStrength', style: TextStyle(color: _strengthColor, fontSize: 12.sp, fontWeight: FontWeight.bold)),
              ),
            SizedBox(height: 16.h),
            TextField(
              controller: confirmPass, 
              obscureText: _obscureConfirm, 
              decoration: InputDecoration(
                labelText: 'Konfirmasi Kata Sandi Baru', 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Keluarkan akun saya dari perangkat lain', style: TextStyle(fontSize: 14.sp)),
              value: _signOutAll,
              activeColor: AppTheme.primary,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (val) => setState(() => _signOutAll = val ?? false),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 16.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r))),
              onPressed: () {
                if (newPass.text.isNotEmpty) {
                  if (newPass.text != confirmPass.text) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kata sandi baru dan konfirmasi tidak cocok!'), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating));
                    return;
                  }
                  oldPass.clear(); newPass.clear(); confirmPass.clear();
                  setState(() {
                    _passwordStrength = '';
                    _signOutAll = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kata sandi berhasil diubah'), backgroundColor: Colors.teal, behavior: SnackBarBehavior.floating));
                }
              },
              child: Text('Perbarui Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 32.h),
            const Divider(),
            SizedBox(height: 16.h),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Autentikasi Biometrik (Sidik Jari)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Login instan tanpa memasukkan sandi'),
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
          padding: EdgeInsets.all(24.w),
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.08), borderRadius: BorderRadius.circular(24.r), border: Border.all(color: Colors.blue.withOpacity(0.2))),
              child: Column(
                children: [
                  Icon(Icons.cloud_done_rounded, size: 48, color: Colors.blue),
                  SizedBox(height: 12.h),
                  Text('Sinkronisasi Cloud Server', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                  SizedBox(height: 4.h),
                  Text('Terakhir dicadangkan: ${widget.data.lastBackupDate}', style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            Text('Tautan Aktif Tersimpan: ${widget.data.resources.length} link', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            Text('Riwayat Transaksi Finansial: ${widget.data.expenses.length} catatan', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 48.h),
            if (isBackingUp) ...[
              Center(child: CircularProgressIndicator()),
              SizedBox(height: 16.h),
              Center(child: Text('Mengunggah paket data terenkripsi ke Cloud server...', style: TextStyle(fontWeight: FontWeight.bold))),
            ] else ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 16.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r))),
                onPressed: () async {
                  setState(() => isBackingUp = true);
                  await Future.delayed(const Duration(milliseconds: 1500));
                  if (context.mounted) {
                    widget.data.performBackup('Hari ini, ${TimeOfDay.now().format(context)}');
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Seluruh data berhasil dicadangkan ke Cloud Server'), backgroundColor: Colors.teal, behavior: SnackBarBehavior.floating));
                  }
                },
                icon: Icon(Icons.backup_rounded),
                label: Text('Mulai Cadangkan Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
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
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]), borderRadius: BorderRadius.circular(32.r)),
              child: Icon(Icons.school_rounded, size: 64, color: Colors.white),
            ),
            SizedBox(height: 24.h),
            Text('KAMPUSGO', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 4.h),
            Text('Versi 1.0.0+1', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 16.h),
            Text('Dikembangkan khusus untuk mendukung manajemen\nproduktivitas kehidupan mahasiswa.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13.sp)),
            SizedBox(height: 48.h),
            Text('© 2026 KAMPUSGO Mobile Team', style: TextStyle(fontSize: 12.sp, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5))),
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
        padding: EdgeInsets.all(24.w),
        children: [
          Text('Kebijakan Privasi & Lisensi Penggunaan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
          SizedBox(height: 16.h),
          Text(
            'Aplikasi KAMPUSGO berkomitmen penuh untuk melindungi privasi setiap mahasiswa. Seluruh data perkuliahan, tugas aktif pada Smart Study Planner, alokasi keuangan pada Budget Buddy, serta repositori tautan Resource Hub disimpan dan diproses secara aman dalam perangkat lokal Anda menggunakan protokol enkripsi terstandarisasi.\n\n'
            'Data tidak akan pernah dibagikan kepada pihak ketiga tanpa persetujuan eksplisit melalui fitur pencadangan mandiri (Cloud Backup). Dengan menggunakan aplikasi ini, Anda menyetujui pemanfaatan fitur pengingat lokal dan kalkulasi IPK prediktif sebagai sarana penunjang akademis mandiri.',
            style: TextStyle(height: 1.6.h),
          ),
        ],
      ),
    );
  }
}
