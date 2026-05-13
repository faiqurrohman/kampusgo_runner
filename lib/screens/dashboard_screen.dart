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

class DashboardScreen extends StatefulWidget { const DashboardScreen({super.key}); @override State<DashboardScreen> createState() => _DashboardScreenState(); }
class _DashboardScreenState extends State<DashboardScreen> {
  int index = 0;
  final data = AppData.instance;
  late final pages = [_Home(onLogout: _logout, onTabChange: (i) => setState(() => index = i)), const PlannerScreen(), const BudgetScreen(), const GpaScreen(), const ResourceScreen()];
  void _logout() => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));

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
              icon: Icons.event_note_rounded,
              color: Colors.orange,
              title: 'Tambah Jadwal / Deadline',
              subtitle: 'Catat tugas kuliah atau jadwal ujian baru',
              onTap: () {
                Navigator.pop(ctx);
                setState(() => index = 1);
              },
            ),
            const SizedBox(height: 12),
            _QuickActionTile(
              icon: Icons.account_balance_wallet_rounded,
              color: Colors.green,
              title: 'Catat Pengeluaran',
              subtitle: 'Lacak pengeluaran dan sisa uang saku mingguan',
              onTap: () {
                Navigator.pop(ctx);
                setState(() => index = 2);
              },
            ),
            const SizedBox(height: 12),
            _QuickActionTile(
              icon: Icons.workspace_premium_rounded,
              color: AppTheme.secondary,
              title: 'Simulasi Nilai IPK',
              subtitle: 'Tambah bobot SKS dan target nilai mata kuliah',
              onTap: () {
                Navigator.pop(ctx);
                setState(() => index = 3);
              },
            ),
            const SizedBox(height: 12),
            _QuickActionTile(
              icon: Icons.folder_rounded,
              color: AppTheme.primary,
              title: 'Simpan Arsip / Link',
              subtitle: 'Simpan materi, tugas, atau panduan penting',
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
        body: pages[index],
        floatingActionButton: index == 0 ? FloatingActionButton(
          onPressed: () => _showQuickActionSheet(context),
          backgroundColor: AppTheme.primary,
          elevation: 4,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ) : null,
        bottomNavigationBar: _AnimatedMotionNavBar(
          selectedIndex: index,
          onDestinationSelected: (v) => setState(() => index = v),
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
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Halo, Mahasiswa 👋', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6), 
          Text('Pantau hidup kampusmu hari ini.', style: Theme.of(context).textTheme.bodyMedium),
        ])),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
                  Positioned(
                    top: 12, right: 12,
                    child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle)),
                  )
                ]
              ),
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => _SettingsSheet(onLogout: onLogout),
                  );
                }, 
                icon: const Icon(Icons.settings_rounded)
              ),
            ],
          ),
        ),
      ]),
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
            BoxShadow(
              color: AppTheme.secondary.withOpacity(0.4),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 12),
            ),
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
            if (next.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text('Sisa ${next.first.deadline.difference(DateTime.now()).inDays} hari', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
          ]),
          const SizedBox(height: 16),
          Text(next.isEmpty ? 'Semua tugas selesai. Mantap!' : next.first.title, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          if (next.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(next.first.course, style: const TextStyle(color: Colors.white, fontSize: 16)),
                const Text('65%', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.65,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 6,
              ),
            ),
          ]
        ])
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(32), border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1))),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.door_front_door_outlined, color: AppTheme.primary)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Kelas Selanjutnya', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Mobile Programming • R. A3.1', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ])),
          const Text('10:00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
        ]),
      ),
      const SizedBox(height: 28),
      Text('Ringkasan', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 16),
      InfoCard(icon: Icons.assignment_rounded, title: 'Deadline Aktif', value: data.schedules.where((e)=>!e.done).isEmpty ? 'Tugas beres! 🎉' : '${data.schedules.where((e)=>!e.done).length} tugas', color: const Color(0xFFF59E0B), onTap: () => onTabChange(1)),
      const SizedBox(height: 12),
      InfoCard(icon: Icons.payments_rounded, title: 'Total Pengeluaran', value: data.expenses.isEmpty ? 'Belum jajan 💸' : Formatters.currency.format(data.totalExpense()), color: const Color(0xFF10B981), valueColor: data.expenses.isEmpty ? null : AppTheme.accent, onTap: () => onTabChange(2), trailingWidget: data.expenses.isEmpty ? null : CustomPaint(size: const Size(40, 24), painter: _SparklinePainter(color: const Color(0xFF10B981)))),
      const SizedBox(height: 12),
      InfoCard(
        icon: Icons.workspace_premium_rounded, title: 'Prediksi IPK', value: data.gpaItems.isEmpty ? 'Belum ada nilai 🎯' : data.calculateGpa().toStringAsFixed(2), color: AppTheme.secondary, onTap: () => onTabChange(3),
        trailingWidget: data.gpaItems.isEmpty ? null : SizedBox(
          width: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${((data.calculateGpa() / data.targetGpa).clamp(0.0, 1.0) * 100).toInt()}% ke ${data.targetGpa.toStringAsFixed(2)}', style: const TextStyle(fontSize: 10, color: AppTheme.secondary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (data.calculateGpa() / data.targetGpa).clamp(0.0, 1.0),
                  backgroundColor: AppTheme.secondary.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.secondary),
                  minHeight: 6,
                ),
              ),
            ]
          )
        )
      ),
      const SizedBox(height: 12),
      InfoCard(icon: Icons.lightbulb_rounded, title: 'Tips Hari Ini', value: 'Fokus 25 menit, istirahat 5 menit', color: Colors.amber, onTap: () {}),
      // Margin bawah ekstra agar FAB tidak menutupi item/teks ringkasan terakhir
      const SizedBox(height: 88),
    ]));
  }
}

class _SparklinePainter extends CustomPainter {
  final Color color;
  _SparklinePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, size.height * 0.8)
      ..lineTo(size.width * 0.3, size.height * 0.4)
      ..lineTo(size.width * 0.6, size.height * 0.6)
      ..lineTo(size.width, size.height * 0.1);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SettingsSheet extends StatelessWidget {
  final VoidCallback onLogout;
  const _SettingsSheet({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final data = AppData.instance;
    return AnimatedBuilder(
      animation: data,
      builder: (_, __) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text('Pengaturan', style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const CircleAvatar(backgroundColor: AppTheme.primary, child: Text('MH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      title: const Text('Mahasiswa Hebat', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('NIM: 12345678 • Universitas A'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {},
                    ),
                    const Divider(height: 24),
                    ListTile(
                      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.dark_mode_rounded, color: AppTheme.primary)),
                      title: const Text('Mode Gelap'),
                      trailing: Switch(value: data.themeMode == ThemeMode.dark, onChanged: (v) => data.toggleTheme(), activeColor: AppTheme.primary),
                    ),
                    ListTile(
                      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.notifications_active_rounded, color: Colors.orange)),
                      title: const Text('Pengingat Tugas'),
                      subtitle: const Text('1 hari sebelum deadline', style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.track_changes_rounded, color: AppTheme.secondary)),
                      title: const Text('Target IPK Semester'),
                      subtitle: const Text('Saat ini: 4.00', style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.sync_rounded, color: Colors.blue)),
                      title: const Text('Sinkronisasi Kalender'),
                      subtitle: const Text('Terhubung ke Google Calendar', style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.help_outline_rounded, color: Colors.teal)),
                      title: const Text('Bantuan & Masukan'),
                      subtitle: const Text('Lapor bug atau saran fitur', style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {},
                    ),
                    const Divider(height: 32),
                    ListTile(
                      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.logout_rounded, color: AppTheme.accent)),
                      title: const Text('Keluar Akun', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold)),
                      onTap: () { Navigator.pop(context); onLogout(); },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedMotionNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _AnimatedMotionNavBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
      (icon: Icons.event_note_outlined, activeIcon: Icons.event_note, label: 'Jadwal'),
      (icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet, label: 'Keuangan'),
      (icon: Icons.show_chart, activeIcon: Icons.show_chart, label: 'Nilai'),
      (icon: Icons.folder_outlined, activeIcon: Icons.folder, label: 'Arsip'),
    ];

    // Menggunakan warna Teal utama sesuai instruksi dan gambar referensi user
    const bgColor = Color(0xFF338385);
    const circleColor = Color(0xFF1A3D3E);

    return SizedBox(
      height: 80,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: selectedIndex.toDouble(), end: selectedIndex.toDouble()),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        builder: (context, animatedIndex, child) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Custom Painter untuk menggambar bar beserta notch dan lingkaran indikator
              CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 80),
                painter: _NotchPainter(
                  animatedIndex: animatedIndex,
                  bgColor: bgColor,
                  circleColor: circleColor,
                ),
              ),
              // 2. Ikon-ikon navigasi beserta nama/labelnya
              Row(
                children: List.generate(items.length, (index) {
                  final isSelected = index == selectedIndex;
                  final item = items[index];
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onDestinationSelected(index),
                      child: SizedBox(
                        height: 80,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Animasi pergerakan ikon ke atas memasuki lingkaran indikator
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                              top: isSelected ? 0 : 22,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                                child: Icon(
                                  isSelected ? item.activeIcon : item.icon,
                                  key: ValueKey<bool>(isSelected),
                                  color: isSelected ? Colors.white : Colors.white70,
                                  size: isSelected ? 26 : 24,
                                ),
                              ),
                            ),
                            // Nama label tetap dipertahankan di bagian bawah tab
                            Positioned(
                              bottom: 10,
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  color: isSelected ? Colors.white : Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NotchPainter extends CustomPainter {
  final double animatedIndex;
  final Color bgColor;
  final Color circleColor;

  _NotchPainter({
    required this.animatedIndex,
    required this.bgColor,
    required this.circleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double itemWidth = size.width / 5;
    double centerX = (itemWidth * animatedIndex) + (itemWidth / 2);

    // Jalur (Path) dari Bottom Navigation Bar dengan lekukan (notch) yang dinamis
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(centerX - 42, 0);
    
    // Kurva masuk ke dalam lekukan (notch)
    path.quadraticBezierTo(centerX - 22, 0, centerX - 18, 12);
    
    // Busur melingkar cekung ke bawah
    path.arcToPoint(
      Offset(centerX + 18, 12),
      radius: const Radius.circular(20),
      clockwise: false,
    );
    
    // Kurva keluar dari lekukan (notch)
    path.quadraticBezierTo(centerX + 22, 0, centerX + 42, 0);
    
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Menggambar bayangan halus di bawah bar agar terlihat lebih hidup dan premium
    canvas.drawShadow(path, Colors.black, 8, true);

    // Mengisi warna latar belakang bar utama
    Paint bgPaint = Paint()..color = bgColor..style = PaintingStyle.fill;
    canvas.drawPath(path, bgPaint);

    // Menggambar lingkaran indikator gelap yang mengapung di dalam lekukan
    Paint circlePaint = Paint()..color = circleColor..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, 13), 22, circlePaint);
  }

  @override
  bool shouldRepaint(covariant _NotchPainter oldDelegate) {
    return oldDelegate.animatedIndex != animatedIndex ||
           oldDelegate.bgColor != bgColor ||
           oldDelegate.circleColor != circleColor;
  }
}
