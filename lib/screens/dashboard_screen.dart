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
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Halo, ${data.userName}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('👋', style: TextStyle(fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 4), 
                Text('Pantau hidup kampusmu hari ini.', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Foto profil mahasiswa melingkar di tengah baris atas
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primary.withOpacity(0.5), width: 2),
              boxShadow: [
                BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 8, spreadRadius: 1),
              ],
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withOpacity(0.12),
              child: Text(data.userAvatarUrl, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Ikon Lonceng Notifikasi berwarna kuning/amber
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
                // 2. Ikon Toggle Tema (Matahari/Bulan) berwarna kuning/amber
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
                // 3. Ikon Pengaturan (Roda Gigi)
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
    _NavItem(icon: Icons.dashboard_rounded, label: 'Dasbor'),
    _NavItem(icon: Icons.event_note_rounded, label: 'Jadwal'),
    _NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Keuangan'),
    _NavItem(icon: Icons.school_rounded, label: 'Nilai'),
    _NavItem(icon: Icons.folder_special_rounded, label: 'Arsip'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBgColor = isDark ? const Color(0xFF1E1B2E) : Colors.white;
    final activeCircleColor = isDark ? const Color(0xFF2D2747) : AppTheme.primary.withOpacity(0.08);

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: navBgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Custom Painter untuk Background dan Indikator Notch Bergerak
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: widget.selectedIndex.toDouble(),
                end: widget.selectedIndex.toDouble(),
              ),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              builder: (context, animatedValue, child) {
                return CustomPaint(
                  painter: _NotchPainter(
                    animatedIndex: animatedValue,
                    itemCount: _items.length,
                    bgColor: navBgColor,
                    circleColor: activeCircleColor,
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
                  onTap: () => widget.onDestinationSelected(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animasi Translasi Ikon (Naik saat aktif)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        transform: Matrix4.translationValues(
                          0,
                          isSelected ? -6 : 2,
                          0,
                        ),
                        child: AnimatedTheme(
                          data: Theme.of(context),
                          child: Icon(
                            item.icon,
                            size: 24,
                            color: isSelected
                                ? AppTheme.primary
                                : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Animasi Skala & Opasitas Label Teks
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isSelected ? 1.0 : 0.6,
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? AppTheme.primary
                                : Theme.of(context).textTheme.bodySmall?.color,
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
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  _NavItem({required this.icon, required this.label});
}

class _NotchPainter extends CustomPainter {
  final double animatedIndex;
  final int itemCount;
  final Color bgColor;
  final Color circleColor;

  _NotchPainter({
    required this.animatedIndex,
    required this.itemCount,
    required this.bgColor,
    required this.circleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final itemWidth = size.width / itemCount;
    final centerX = (animatedIndex * itemWidth) + (itemWidth / 2);

    // Menggambar latar belakang utama tanpa menutup lekukan atas
    Paint bgPaint = Paint()..color = bgColor..style = PaintingStyle.fill;
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, bgPaint);

    // Menggambar lingkaran indikator lembut yang mengapung di dalam lekukan
    Paint circlePaint = Paint()..color = circleColor..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, 14), 22, circlePaint);
  }

  @override
  bool shouldRepaint(covariant _NotchPainter oldDelegate) {
    return oldDelegate.animatedIndex != animatedIndex ||
           oldDelegate.bgColor != bgColor ||
           oldDelegate.circleColor != circleColor;
  }
}
