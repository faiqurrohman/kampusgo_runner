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
  late final pages = [_Home(onLogout: _logout), const PlannerScreen(), const BudgetScreen(), const GpaScreen(), const ResourceScreen()];
  void _logout() => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));

  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: data, builder: (_, __) => Scaffold(
    body: pages[index],
    bottomNavigationBar: NavigationBar(selectedIndex: index, onDestinationSelected: (v) => setState(() => index = v), destinations: const [
      NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.event_note_outlined), selectedIcon: Icon(Icons.event_note), label: 'Planner'),
      NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Budget'),
      NavigationDestination(icon: Icon(Icons.show_chart), label: 'GPA'),
      NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: 'Resource'),
    ]),
  ));
}

class _Home extends StatelessWidget {
  final VoidCallback onLogout; const _Home({required this.onLogout});
  @override
  Widget build(BuildContext context) {
    final data = AppData.instance;
    final next = data.schedules.where((e) => !e.done).toList()..sort((a,b)=>a.deadline.compareTo(b.deadline));
    return SafeArea(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32), children: [
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
        padding: const EdgeInsets.all(28), 
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
            const Text('Prioritas Terdekat', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 16),
          Text(next.isEmpty ? 'Semua tugas selesai. Mantap!' : next.first.title, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          if (next.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(next.first.course, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16)),
          ]
        ])
      ),
      const SizedBox(height: 28),
      Text('Ringkasan', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 16),
      InfoCard(icon: Icons.assignment_rounded, title: 'Deadline Aktif', value: '${data.schedules.where((e)=>!e.done).length} tugas', color: Colors.orange),
      const SizedBox(height: 12),
      InfoCard(icon: Icons.payments_rounded, title: 'Total Pengeluaran', value: Formatters.currency.format(data.totalExpense()), color: Colors.green),
      const SizedBox(height: 12),
      InfoCard(icon: Icons.workspace_premium_rounded, title: 'Prediksi IPK', value: data.calculateGpa().toStringAsFixed(2), color: AppTheme.secondary),
    ]));
  }
}
