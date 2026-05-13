import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/app_data.dart';
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
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(ctx).dividerColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aksi Cepat',
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih item baru yang ingin ditambahkan ke ruang kerjamu.',
              style: Theme.of(ctx).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
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
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
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
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.08)),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _Home extends StatelessWidget {
  final VoidCallback onLogout;
  final void Function(int) onTabChange;
  const _Home({required this.onLogout, required this.onTabChange});
  @override
  Widget build(BuildContext context) {
    final data = AppData.instance;
    final next = data.schedules.where((e) => !e.done).toList()..sort((a,b)=>a.deadline.compareTo(b.deadline));
    return SafeArea(child: ListView(padding: const EdgeInsets.only(left: 24, right: 24, top: 48, bottom: 20), children: [
      // Tata Letak Header Diperbarui (Foto Profil di atas, disusul Nama Mahasiswa/Sapaan ke bawah seperti Slide 2)
      Column(
        children: [
          // Baris atas: Kapsul tombol kontrol aksi di pojok kanan agar layar tetap seimbang
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.12)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {},
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.notifications_none_rounded, color: Colors.amber, size: 20),
                        Positioned(
                          top: -2, right: -2,
                          child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle)),
                        )
                      ]
                    ),
                  ),
                  const SizedBox(width: 14),
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
                  const SizedBox(width: 14),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SettingsScreen(onLogout: onLogout)),
                      );
                    },
                    child: const Icon(Icons.settings_rounded, size: 20),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Foto profil mahasiswa melingkar berukuran besar di tengah (seperti Slide 2)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primary.withOpacity(0.5), width: 2),
              boxShadow: [
                BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 12, spreadRadius: 2),
              ],
            ),
            child: CircleAvatar(
              radius: 36,
              backgroundColor: Colors.white.withOpacity(0.12),
              backgroundImage: data.userAvatarUrl.contains('/') || data.userAvatarUrl.contains('\\')
                  ? FileImage(File(data.userAvatarUrl))
                  : null,
              child: data.userAvatarUrl.contains('/') || data.userAvatarUrl.contains('\\')
                  ? null
                  : Text(data.userAvatarUrl, style: const TextStyle(fontSize: 34)),
            ),
          ),
          const SizedBox(height: 16),
          // Nama mahasiswa/sapaan diletakkan ke bawah setelah foto profil tanpa mengubah variabel namanya
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Halo, ${data.userName}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              const Text('👋', style: TextStyle(fontSize: 22)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Pantau hidup kampusmu hari ini.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
          ),
        ],
      ),
      const SizedBox(height: 32),
      Container(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 36), 
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primary, AppTheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ), 
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 12)),
          ]
        ), 
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.star_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Prioritas Terdekat', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const Spacer(),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUrgent ? AppTheme.accent : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                );
              })(),
            ],
          ]),
          const SizedBox(height: 16),
          Text(next.isEmpty ? 'Semua tugas selesai. Mantap!' : next.first.title, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          if (next.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('${next.first.course} • ${Formatters.date.format(next.first.deadline)}', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
          ],
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: ElevatedButton(onPressed: () => onTabChange(1), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(vertical: 12), elevation: 0), child: const Text('Lihat Semua Jadwal'))),
          ]),
        ]),
      ),
      const SizedBox(height: 24),
      // Komponen Produktivitas Ekstra: Kelas Selanjutnya
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.event_seat_rounded, color: Colors.amber, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kelas Selanjutnya', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 2),
                  const Text('Struktur Data - Ruang B302', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
            const Text('13:00', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
          ],
        ),
      ),
      const SizedBox(height: 24),
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
          width: 40, height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: data.calculateGpa() / 4.0,
                strokeWidth: 3.5,
                backgroundColor: Theme.of(context).dividerColor.withOpacity(0.08),
                color: Colors.purpleAccent,
              ),
              const Icon(Icons.star_rounded, size: 16, color: Colors.purpleAccent),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(140, 28),
                  const SizedBox(height: 8),
                  _box(180, 14),
                ],
              ),
              _box(110, 44, borderRadius: 16),
            ],
          ),
          const SizedBox(height: 32),
          // Main banner skeleton
          _box(double.infinity, 200, borderRadius: 32),
          const SizedBox(height: 24),
          _box(double.infinity, 64, borderRadius: 24),
          const SizedBox(height: 24),
          // Summaries row skeleton
          Row(
            children: [
              Expanded(child: _box(double.infinity, 110, borderRadius: 24)),
              const SizedBox(width: 16),
              Expanded(child: _box(double.infinity, 110, borderRadius: 24)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _box(double.infinity, 110, borderRadius: 24)),
              const SizedBox(width: 16),
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
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Theme.of(context).dividerColor.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          const Text('Pengaturan Dasbor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.dark_mode_rounded, color: Colors.amber),
            title: const Text('Tema Gelap / Terang'),
            subtitle: const Text('Beralih mode warna UI'),
            trailing: Switch(
              value: data.themeMode == ThemeMode.dark,
              onChanged: (_) => data.toggleTheme(),
              activeColor: AppTheme.primary,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.security_rounded, color: Colors.green),
            title: const Text('Keamanan & Sandi'),
            subtitle: const Text('Perbarui kredensial autentikasi'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description_rounded, color: Colors.blue),
            title: const Text('Ketentuan & Privasi'),
            subtitle: const Text('Baca dokumen legal KAMPUSGO'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onLogout, 
            icon: const Icon(Icons.logout_rounded), 
            label: const Text('Keluar Akun'),
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
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: SizedBox(
          height: 74,
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
                          const SizedBox(height: 4),
                          // Animasi Skala & Opasitas Label Teks
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: isSelected ? 1.0 : 0.5,
                            child: Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 10,
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
        Rect.fromCenter(center: Offset(centerX, size.height - 8), width: 22, height: 5),
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
