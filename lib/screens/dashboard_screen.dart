import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: data, builder: (_, __) => Scaffold(
    body: pages[index],
    bottomNavigationBar: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: NavigationBar(selectedIndex: index, onDestinationSelected: (v) => setState(() => index = v), destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.event_note_outlined), selectedIcon: Icon(Icons.event_note), label: 'Jadwal'),
        NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Keuangan'),
        NavigationDestination(icon: Icon(Icons.show_chart), label: 'Nilai'),
        NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: 'Arsip'),
      ]),
    ),
  ));
}

class _Home extends StatelessWidget {
  final VoidCallback onLogout;
  final void Function(int) onTabChange;
  const _Home({required this.onLogout, required this.onTabChange});
  @override
  Widget build(BuildContext context) {
    final data = AppData.instance;
    final next = data.schedules.where((e) => !e.done).toList()..sort((a,b)=>a.deadline.compareTo(b.deadline));
    return SafeArea(child: ListView(padding: const EdgeInsets.only(left: 24, right: 24, top: 48, bottom: 32), children: [
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
              IconButton(
                onPressed: () => data.toggleTheme(),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    data.themeMode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    key: ValueKey(data.themeMode),
                    color: Colors.amber,
                  ),
                ),
              ),
              IconButton(onPressed: onLogout, icon: Icon(Icons.logout_rounded, color: Theme.of(context).colorScheme.error)),
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
            BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
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
      const SizedBox(height: 28),
      Text('Ringkasan', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 16),
      InfoCard(icon: Icons.assignment_rounded, title: 'Deadline Aktif', value: '${data.schedules.where((e)=>!e.done).length} tugas', color: Colors.orange, onTap: () => onTabChange(1)),
      const SizedBox(height: 12),
      InfoCard(icon: Icons.payments_rounded, title: 'Total Pengeluaran', value: Formatters.currency.format(data.totalExpense()), color: Colors.green, valueColor: AppTheme.accent, onTap: () => onTabChange(2), trailingWidget: CustomPaint(size: const Size(40, 24), painter: _SparklinePainter(color: Colors.green))),
      const SizedBox(height: 12),
      InfoCard(
        icon: Icons.workspace_premium_rounded, title: 'Prediksi IPK', value: data.calculateGpa().toStringAsFixed(2), color: AppTheme.secondary, onTap: () => onTabChange(3),
        trailingWidget: SizedBox(
          width: 70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${((data.calculateGpa() / 4.0) * 100).toInt()}% ke 4.0', style: const TextStyle(fontSize: 10, color: AppTheme.secondary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: data.calculateGpa() / 4.0,
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
