import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/app_data.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/info_card.dart';
import 'budget_screen.dart';
import 'gpa_screen.dart';
import 'login_screen.dart';
import 'planner_screen.dart';
import 'resource_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget { const DashboardScreen({super.key}); @override State<DashboardScreen> createState() => _DashboardScreenState(); }
class _DashboardScreenState extends State<DashboardScreen> {
  int index = 0;
  bool _isLoading = true;
  final data = AppData.instance;
  late final pages = [_Home(onLogout: _logout, onTabChange: (i) => setState(() => index = i)), const PlannerScreen(), const BudgetScreen(), const GpaScreen(), const ResourceScreen()];
  void _logout() => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));

  @override
  void initState() {
    super.initState();
    // Muat profil tersimpan dari sesi lokal ke dalam memori reaktif global AppData
    AuthService.instance.getSavedName().then((name) {
      if (name != null && name.isNotEmpty) AppData.instance.updateProfile(name: name);
    });
    AuthService.instance.getSavedEmail().then((email) {
      if (email != null && email.isNotEmpty) AppData.instance.updateProfile(email: email);
    });

    // Efek Skeleton Loading saat pertama kali mengambil data agar terasa instan & mulus
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _showQuickActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Theme.of(ctx).dividerColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Aksi Cepat',
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              'Pilih item baru yang ingin ditambahkan ke ruang kerjamu.',
              style: Theme.of(ctx).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            _QuickActionTile(
              icon: Icons.alarm_add_rounded,
              color: Colors.redAccent,
              title: 'Tambah Jadwal / Tugas',
              subtitle: 'Tetapkan tenggat waktu otomatis di Smart Planner',
              onTap: () {
                Navigator.pop(ctx);
                setState(() => index = 1);
              },
            ),
            SizedBox(height: 12.h),
            _QuickActionTile(
              icon: Icons.receipt_long_rounded,
              color: Colors.green,
              title: 'Catat Pengeluaran',
              subtitle: 'Lacak saku dan sinkronisasi di Budget Buddy',
              onTap: () {
                Navigator.pop(ctx);
                setState(() => index = 2);
              },
            ),
            SizedBox(height: 12.h),
            _QuickActionTile(
              icon: Icons.grade_rounded,
              color: Colors.orange,
              title: 'Input Nilai Matkul',
              subtitle: 'Hitung dan bandingkan di GPA Predictor',
              onTap: () {
                Navigator.pop(ctx);
                setState(() => index = 3);
              },
            ),
            SizedBox(height: 12.h),
            _QuickActionTile(
              icon: Icons.link_rounded,
              color: AppTheme.primary,
              title: 'Simpan Resource Link',
              subtitle: 'Sematkan pintasan materi kuliah di Resource Hub',
              onTap: () {
                Navigator.pop(ctx);
                setState(() => index = 4);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: data,
    builder: (_, __) => AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: _isLoading ? const _SkeletonLoaderView() : pages[index],
        floatingActionButton: (index == 0 && !_isLoading) ? FloatingActionButton(
          onPressed: () => _showQuickActionSheet(context),
          backgroundColor: AppTheme.primary,
          elevation: 4,
          child: Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ) : null,
        bottomNavigationBar: _AnimatedMotionNavBar(
          selectedIndex: index,
          onDestinationSelected: (v) {
            if (!_isLoading) setState(() => index = v);
          },
        ),
      ),
    ),
  );
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.08)),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                  SizedBox(height: 2.h),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11.sp)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String time;
  final String message;
  final bool isUnread;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.time,
    required this.message,
    required this.isUnread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isUnread 
            ? iconColor.withOpacity(0.08) 
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isUnread 
              ? iconColor.withOpacity(0.2) 
              : Theme.of(context).dividerColor.withOpacity(0.06),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                              fontSize: 13.sp,
                              color: isUnread ? iconColor : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          time,
                          style: TextStyle(fontSize: 10.sp, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6)),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11.sp, height: 1.4.h),
                    ),
                  ],
                ),
              ),
              if (isUnread) ...[
                SizedBox(width: 8.w),
                Container(
                  width: 8.w,
                  height: 8.h,
                  margin: EdgeInsets.only(top: 6.h),
                  decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Panel Notifikasi Lengkap ────────────────────────────────────────────────
void _showNotificationPanel(BuildContext context, void Function(int) onTabChange) {
  final data = AppData.instance;
  final now = DateTime.now();
  final fmt = DateFormat('HH:mm', 'id_ID');
  final dateFmt = DateFormat('dd MMM', 'id_ID');

  // Bangun daftar notifikasi dinamis dari data nyata aplikasi
  final List<Map<String, dynamic>> notifications = [];

  // 1. Notifikasi DEADLINE dari data jadwal (prioritas tertinggi)
  final urgentSchedules = data.schedules
      .where((s) => !s.done && s.deadline.difference(now).inDays <= 3)
      .toList();
  for (final s in urgentSchedules) {
    final id = 'sched_${s.id}';
    final diff = s.deadline.difference(now);
    final label = diff.inHours < 24
        ? '${diff.inHours}j lagi ⚠️'
        : '${diff.inDays} hari lagi';
    notifications.add({
      'id': id,
      'icon': Icons.alarm_rounded,
      'color': diff.inHours < 24 ? Colors.redAccent : Colors.orangeAccent,
      'title': '⏰ Tenggat Mendekat',
      'time': label,
      'message': '${s.title} — ${s.course} harus dikumpulkan ${dateFmt.format(s.deadline)}.',
      'targetIndex': 1,
    });
  }

  // 2. Notifikasi ANGGARAN dari data pengeluaran nyata
  final totalExp = data.totalExpense();
  final limit = data.budgetLimit;
  if (totalExp >= limit * 0.8) {
    final id = 'budget_warn';
    final pct = ((totalExp / limit) * 100).toStringAsFixed(0);
    notifications.add({
      'id': id,
      'icon': Icons.account_balance_wallet_rounded,
      'color': Colors.green,
      'title': '💸 Peringatan Anggaran',
      'time': fmt.format(now),
      'message': 'Kamu sudah memakai ${pct}% anggaran bulan ini '
          '(${Formatters.currency.format(totalExp)} / ${Formatters.currency.format(limit)}). Bijak dalam belanja!',
      'targetIndex': 2,
    });
  }

  // 3. Notifikasi IPK / Akademik
  final gpa = data.calculateGpa();
  final gap = (data.targetGpa - gpa).abs();
  if (gap > 0.01) {
    final id = 'gpa_update';
    notifications.add({
      'id': id,
      'icon': Icons.school_rounded,
      'color': AppTheme.primary,
      'title': '🎓 Pembaruan IPK',
      'time': 'Hari ini',
      'message': 'IPK kamu saat ini ${gpa.toStringAsFixed(2)} — '
          '${gpa < data.targetGpa ? "kurang ${gap.toStringAsFixed(2)} poin" : "sudah melampaui"} '
          'dari target ${data.targetGpa.toStringAsFixed(2)}.',
      'targetIndex': 3,
    });
  }

  // 4. Notifikasi Sumber Belajar Tersimpan
  if (data.resources.isNotEmpty) {
    final id = 'resource_new';
    final latest = data.resources.first;
    notifications.add({
      'id': id,
      'icon': Icons.link_rounded,
      'color': Colors.teal,
      'title': '📎 Resource Baru Tersimpan',
      'time': 'Baru saja',
      'message': '"${latest.title}" (${latest.course}) berhasil disematkan ke Resource Hub-mu.',
      'targetIndex': 4,
    });
  }

  // 5. Notifikasi Pengingat Sistem / Tips
  final idTips = 'tips_cloud';
  notifications.add({
    'id': idTips,
    'icon': Icons.tips_and_updates_rounded,
    'color': Colors.purpleAccent,
    'title': '💡 Tips KampusGo',
    'time': dateFmt.format(now),
    'message': 'Aktifkan backup cloud di Pengaturan agar semua data jadwal dan nilai-mu tersimpan aman.',
    'targetIndex': 0,
  });

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          // Tentukan status isUnread secara seketika berdasarkan Set memori
          for (final n in notifications) {
            final id = n['id'] as String;
            n['isUnread'] = !data.readNotificationIds.contains(id);
          }
          final unreadCount = notifications.where((n) => n['isUnread'] == true).length;

          return DraggableScrollableSheet(
            initialChildSize: 0.72,
            minChildSize: 0.4,
            maxChildSize: 0.92,
            builder: (_, controller) => Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1B2E) : Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.15),
                    blurRadius: 30.r,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle bar
                  Padding(
                    padding: EdgeInsets.only(top: 14.h),
                    child: Container(
                      width: 42.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Icon(Icons.notifications_rounded, color: Colors.amber, size: 22),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notifikasi',
                                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '$unreadCount belum dibaca',
                                style: TextStyle(fontSize: 11.sp, color: Colors.amber.shade700),
                              ),
                            ],
                          ),
                        ),
                        if (unreadCount > 0)
                          TextButton(
                            onPressed: () {
                              final unreadIds = notifications
                                  .where((n) => n['isUnread'] == true)
                                  .map((n) => n['id'] as String)
                                  .toList();
                              data.markAllNotificationsRead(unreadIds);
                              setSheetState(() {
                                for (final n in notifications) {
                                  n['isUnread'] = false;
                                }
                              });
                            },
                            child: Text('Baca Semua', style: TextStyle(fontSize: 12.sp, color: AppTheme.primary)),
                          ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('Tutup', style: TextStyle(fontSize: 12.sp)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Divider(indent: 24, endIndent: 24, color: isDark ? Colors.white12 : Colors.black12),
                  // Daftar Notifikasi
                  Expanded(
                    child: notifications.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.notifications_off_outlined, size: 56, color: Colors.grey.withOpacity(0.4)),
                                SizedBox(height: 12.h),
                                Text('Tidak ada notifikasi saat ini', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: controller,
                            padding: EdgeInsets.fromLTRB(20, 8, 20, 32),
                            itemCount: notifications.length,
                            itemBuilder: (_, i) {
                              final n = notifications[i];
                              return _NotificationCard(
                                icon: n['icon'] as IconData,
                                iconColor: n['color'] as Color,
                                title: n['title'] as String,
                                time: n['time'] as String,
                                message: n['message'] as String,
                                isUnread: n['isUnread'] as bool,
                                onTap: () {
                                  final id = n['id'] as String;
                                  // Tandai terbaca di AppData
                                  data.markNotificationRead(id);
                                  // Perbarui UI BottomSheet secara seketika agar titik hilang & jumlah berkurang
                                  setSheetState(() {});

                                  // Navigasi ke halaman terkait
                                  final targetIdx = n['targetIndex'] as int?;
                                  if (targetIdx != null) {
                                    Future.delayed(const Duration(milliseconds: 250), () {
                                      if (Navigator.canPop(ctx)) Navigator.pop(ctx);
                                      onTabChange(targetIdx);
                                    });
                                  }
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _Home extends StatelessWidget {
  final VoidCallback onLogout;
  final void Function(int) onTabChange;
  const _Home({required this.onLogout, required this.onTabChange});
  @override
  Widget build(BuildContext context) {
    final data = AppData.instance;
    final next = data.schedules.where((e) => !e.done).toList()..sort((a,b)=>a.deadline.compareTo(b.deadline));
    
    // Hitung status indikator titik unread utama secara dinamis
    final now = DateTime.now();
    bool hasUnread = false;
    if (data.schedules.any((s) => !s.done && s.deadline.difference(now).inDays <= 3 && !data.readNotificationIds.contains('sched_${s.id}'))) {
      hasUnread = true;
    } else if (data.totalExpense() >= data.budgetLimit * 0.8 && !data.readNotificationIds.contains('budget_warn')) {
      hasUnread = true;
    } else if ((data.targetGpa - data.calculateGpa()).abs() > 0.01 && !data.readNotificationIds.contains('gpa_update')) {
      hasUnread = true;
    } else if (data.resources.isNotEmpty && !data.readNotificationIds.contains('resource_new')) {
      hasUnread = true;
    } else if (!data.readNotificationIds.contains('tips_cloud')) {
      hasUnread = true;
    }

    return SafeArea(child: ListView(padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 48.h, bottom: 20.h), children: [
      // Tata Letak Header Diperbarui (Foto Profil di atas, disusul Nama Mahasiswa/Sapaan ke bawah seperti Slide 2)
      Column(
        children: [
          // Baris atas: Kapsul tombol kontrol aksi di pojok kanan agar layar tetap seimbang
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.12)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showNotificationPanel(context, onTabChange);
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(Icons.notifications_none_rounded, color: Colors.amber, size: 20),
                        if (hasUnread)
                          Positioned(
                            top: -2, right: -2,
                            child: Container(width: 6.w, height: 6.h, decoration: BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle)),
                          )
                      ]
                    ),
                  ),
                  SizedBox(width: 14.w),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      data.toggleTheme();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(data.themeMode == ThemeMode.dark ? '🌙 Beralih ke Dark Mode' : '☀️ Beralih ke Light Mode'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(milliseconds: 1000),
                        ),
                      );
                    },
                    child: Icon(
                      data.themeMode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SettingsScreen(onLogout: onLogout)),
                      );
                    },
                    child: Icon(Icons.settings_rounded, size: 20),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // Foto profil mahasiswa melingkar berukuran besar di tengah (seperti Slide 2)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primary.withOpacity(0.5), width: 2.w),
              boxShadow: [
                BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 12.r, spreadRadius: 2.r),
              ],
            ),
            child: CircleAvatar(
              radius: 36.r,
              backgroundColor: Colors.white.withOpacity(0.12),
              backgroundImage: data.userAvatarUrl.contains('/') || data.userAvatarUrl.contains('\\')
                  ? FileImage(File(data.userAvatarUrl))
                  : null,
              child: data.userAvatarUrl.contains('/') || data.userAvatarUrl.contains('\\')
                  ? null
                  : Text(data.userAvatarUrl, style: TextStyle(fontSize: 34.sp)),
            ),
          ),
          SizedBox(height: 16.h),
          // Nama mahasiswa/sapaan diletakkan ke bawah setelah foto profil tanpa mengubah variabel namanya
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Halo, ${data.userName}',
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 6.w),
              Text('👋', style: TextStyle(fontSize: 22.sp)),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Pantau hidup kampusmu hari ini.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12.sp),
          ),
        ],
      ),
      SizedBox(height: 32.h),
      Container(
        padding: EdgeInsets.fromLTRB(28, 28, 28, 36), 
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primary, AppTheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ), 
          borderRadius: BorderRadius.circular(32.r),
          boxShadow: [
            BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 24.r, offset: const Offset(0, 12)),
          ]
        ), 
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12.r)),
              child: Icon(Icons.star_rounded, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Prioritas Terdekat', 
                style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.w),
            if (next.isNotEmpty) ...[
              (() {
                final diff = next.first.deadline.difference(DateTime.now());
                final hrs = diff.inHours;
                final isUrgent = hrs < 24 && !diff.isNegative;
                String label;
                if (diff.isNegative) {
                  label = 'Terlambat';
                } else if (hrs >= 24) {
                  label = 'Sisa ${diff.inDays} hari';
                } else if (hrs > 0) {
                  label = 'Sisa $hrs jam';
                } else {
                  label = 'Sisa ${diff.inMinutes} menit';
                }
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isUrgent ? AppTheme.accent : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
                  ),
                );
              })(),
            ],
          ]),
          SizedBox(height: 16.h),
          Text(next.isEmpty ? 'Semua tugas selesai. Mantap!' : next.first.title, style: TextStyle(color: Colors.white, fontSize: 26.sp, fontWeight: FontWeight.bold)),
          if (next.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text('${next.first.course} • ${Formatters.date.format(next.first.deadline)}', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13.sp)),
          ],
          SizedBox(height: 24.h),
          Row(children: [
            Expanded(child: ElevatedButton(onPressed: () => onTabChange(1), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.primary, padding: EdgeInsets.symmetric(vertical: 12.h), elevation: 0), child: Text('Lihat Semua Jadwal'))),
          ]),
        ]),
      ),
      SizedBox(height: 24.h),
      // Komponen Produktivitas Ekstra: Kelas Selanjutnya
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(Icons.event_seat_rounded, color: Colors.amber, size: 20),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kelas Selanjutnya', style: Theme.of(context).textTheme.bodySmall),
                  SizedBox(height: 2.h),
                  Text('Struktur Data - Ruang B302', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                ],
              ),
            ),
            Text('13:00', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
          ],
        ),
      ),
      SizedBox(height: 24.h),
      InfoCard(
        title: 'Deadline Aktif', 
        value: '${next.length} tugas', 
        icon: Icons.assignment_rounded, 
        color: Colors.amber, 
        onTap: () => onTabChange(1),
      ),
      InfoCard(
        title: 'Total Pengeluaran', 
        value: Formatters.currency.format(data.totalExpense()), 
        valueColor: Colors.redAccent,
        icon: Icons.payments_rounded, 
        color: Colors.green, 
        onTap: () => onTabChange(2),
      ),
      InfoCard(
        title: 'Prediksi IPK', 
        value: data.calculateGpa().toStringAsFixed(2), 
        icon: Icons.workspace_premium_rounded, 
        color: Colors.purpleAccent, 
        trailingWidget: SizedBox(
          width: 40.w, height: 40.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: data.calculateGpa() / 4.0,
                strokeWidth: 3.5,
                backgroundColor: Theme.of(context).dividerColor.withOpacity(0.08),
                color: Colors.purpleAccent,
              ),
              Icon(Icons.star_rounded, size: 16, color: Colors.purpleAccent),
            ],
          ),
        ),
        onTap: () => onTabChange(3),
      ),
      InfoCard(
        title: 'Resource Hub', 
        value: '${data.resources.length} tautan', 
        icon: Icons.folder_shared_rounded, 
        color: AppTheme.primary, 
        onTap: () => onTabChange(4),
      ),
    ]));
  }
}

// Skeleton Loader Premium untuk Play Store Ready Experience
class _SkeletonLoaderView extends StatefulWidget {
  const _SkeletonLoaderView();
  @override
  State<_SkeletonLoaderView> createState() => _SkeletonLoaderViewState();
}

class _SkeletonLoaderViewState extends State<_SkeletonLoaderView> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat(reverse: true);

  late final Animation<double> _animation = Tween<double>(begin: 0.25, end: 0.6).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _box(double width, double height, {double borderRadius = 16}) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withOpacity(_animation.value * 0.15),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 48.h),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(140, 28),
                  SizedBox(height: 8.h),
                  _box(180, 14),
                ],
              ),
              _box(110, 44, borderRadius: 16),
            ],
          ),
          SizedBox(height: 32.h),
          // Main banner skeleton
          _box(double.infinity, 200, borderRadius: 32),
          SizedBox(height: 24.h),
          _box(double.infinity, 64, borderRadius: 24),
          SizedBox(height: 24.h),
          // Summaries row skeleton
          Row(
            children: [
              Expanded(child: _box(double.infinity, 110, borderRadius: 24)),
              SizedBox(width: 16.w),
              Expanded(child: _box(double.infinity, 110, borderRadius: 24)),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _box(double.infinity, 110, borderRadius: 24)),
              SizedBox(width: 16.w),
              Expanded(child: _box(double.infinity, 110, borderRadius: 24)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSheet extends StatelessWidget {
  final VoidCallback onLogout;
  const _SettingsSheet({required this.onLogout});
  @override
  Widget build(BuildContext context) {
    final data = AppData.instance;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Theme.of(context).dividerColor.withOpacity(0.2), borderRadius: BorderRadius.circular(2.r))),
          SizedBox(height: 24.h),
          Text('Pengaturan Dasbor', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 24.h),
          ListTile(
            leading: Icon(Icons.dark_mode_rounded, color: Colors.amber),
            title: Text('Tema Gelap / Terang'),
            subtitle: Text('Beralih mode warna UI'),
            trailing: Switch(
              value: data.themeMode == ThemeMode.dark,
              onChanged: (_) => data.toggleTheme(),
              activeColor: AppTheme.primary,
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.security_rounded, color: Colors.green),
            title: Text('Keamanan & Sandi'),
            subtitle: Text('Perbarui kredensial autentikasi'),
            trailing: Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.description_rounded, color: Colors.blue),
            title: Text('Ketentuan & Privasi'),
            subtitle: Text('Baca dokumen legal KAMPUSGO'),
            trailing: Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: onLogout, 
            icon: Icon(Icons.logout_rounded), 
            label: Text('Keluar Akun'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedMotionNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _AnimatedMotionNavBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  State<_AnimatedMotionNavBar> createState() => _AnimatedMotionNavBarState();
}

class _AnimatedMotionNavBarState extends State<_AnimatedMotionNavBar> {
  final List<_NavItem> _items = [
    _NavItem(icon: Icons.grid_view_rounded, label: 'Dasbor'),
    _NavItem(icon: Icons.edit_calendar_rounded, label: 'Jadwal'),
    _NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Keuangan'),
    _NavItem(icon: Icons.school_rounded, label: 'Nilai'),
    _NavItem(icon: Icons.folder_special_rounded, label: 'Arsip'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Konsep: Liquid Floating Curved Bar beraksen Glassmorphism melayang
    final navBgColor = isDark ? const Color(0xFF221E35).withOpacity(0.9) : Colors.white.withOpacity(0.95);
    final liquidColor = isDark ? AppTheme.accent : AppTheme.primary;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: SizedBox(
          height: 74.h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Custom Painter untuk Dock Melayang dengan Kurva Unik & Indikator Cairan (Liquid)
              Positioned.fill(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: widget.selectedIndex.toDouble(),
                    end: widget.selectedIndex.toDouble(),
                  ),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut, // Animasi Pegas (Spring Physics) memantul alami
                  builder: (context, animatedValue, child) {
                    return CustomPaint(
                      painter: _LiquidFloatingDockPainter(
                        animatedIndex: animatedValue,
                        itemCount: _items.length,
                        baseColor: navBgColor,
                        liquidColor: liquidColor,
                      ),
                    );
                  },
                ),
              ),
              // Ikon dan Teks Navigasi
              Row(
                children: List.generate(_items.length, (index) {
                  final isSelected = widget.selectedIndex == index;
                  final item = _items[index];

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        // Fitur Sulit Ditiru: Haptic Feedback Terintegrasi
                        HapticFeedback.lightImpact();
                        widget.onDestinationSelected(index);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animasi Pegas (Spring Physics) memantul saat aktif
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: isSelected ? 1.0 : 0.0,
                              end: isSelected ? 1.0 : 0.0,
                            ),
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.elasticOut,
                            builder: (context, val, child) {
                              final scale = 1.0 + (val * 0.25); // Memantul hingga 1.25x
                              final translateY = -8.0 * val; // Efek melayang terangkat
                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..translate(0.0, translateY)..scale(scale),
                                child: isSelected
                                    ? ShaderMask(
                                        // Fitur Sulit Ditiru: Shader Masking efek gradasi pendar bergerak
                                        shaderCallback: (bounds) => LinearGradient(
                                          colors: [liquidColor, Colors.purpleAccent, Colors.white],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ).createShader(bounds),
                                        child: Icon(item.icon, size: 24, color: Colors.white),
                                      )
                                    : Icon(
                                        item.icon,
                                        size: 24,
                                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.45),
                                      ),
                              );
                            },
                          ),
                          SizedBox(height: 4.h),
                          // Animasi Skala & Opasitas Label Teks
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: isSelected ? 1.0 : 0.5,
                            child: Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? liquidColor : Theme.of(context).textTheme.bodySmall?.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  _NavItem({required this.icon, required this.label});
}

class _LiquidFloatingDockPainter extends CustomPainter {
  final double animatedIndex;
  final int itemCount;
  final Color baseColor;
  final Color liquidColor;

  _LiquidFloatingDockPainter({
    required this.animatedIndex,
    required this.itemCount,
    required this.baseColor,
    required this.liquidColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Gambar Dock Melengkung Eksklusif (Liquid Floating Curved Bar)
    Paint basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;

    Path path = Path();
    final double radius = 24.0;
    path.moveTo(0, radius);
    // Kurva atas cekung/cembung dinamis terinspirasi dari SexyBottomBarPainter
    path.quadraticBezierTo(size.width * 0.5, -6, size.width, radius);
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);
    path.close();

    // Cahaya ungu eksklusif memancar seperti di dashboard
    canvas.drawShadow(path, Colors.purpleAccent, 12, true);
    canvas.drawPath(path, basePaint);

    // 2. Indikator Cairan (Liquid) yang berpindah secara mulus
    final itemWidth = size.width / itemCount;
    final centerX = (animatedIndex * itemWidth) + (itemWidth / 2);

    Paint liquidPaint = Paint()
      ..color = liquidColor
      ..style = PaintingStyle.fill;

    // Tetesan cairan melengkung organik di bawah item yang aktif
    Path liquidPath = Path();
    liquidPath.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(centerX, size.height - 8), width: 22.w, height: 5.h),
        const Radius.circular(4),
      ),
    );
    canvas.drawShadow(liquidPath, liquidColor, 8, true);
    canvas.drawPath(liquidPath, liquidPaint);

    // Pancaran pendar/shimmer melingkar lembut di latar belakang ikon aktif
    canvas.drawCircle(
      Offset(centerX, size.height * 0.4),
      22,
      Paint()..color = liquidColor.withOpacity(0.12)..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _LiquidFloatingDockPainter oldDelegate) {
    return oldDelegate.animatedIndex != animatedIndex ||
           oldDelegate.baseColor != baseColor ||
           oldDelegate.liquidColor != liquidColor;
  }
}
