import 'package:flutter/material.dart';
import '../services/app_data.dart';
import '../utils/app_theme.dart';
import '../widgets/section_title.dart';

class GpaScreen extends StatefulWidget {
  const GpaScreen({super.key});

  @override
  State<GpaScreen> createState() => _GpaScreenState();
}

class _GpaScreenState extends State<GpaScreen> {
  @override
  Widget build(BuildContext context) {
    final data = AppData.instance;
    return AnimatedBuilder(
      animation: data,
      builder: (_, __) {
        final currentGpa = data.calculateGpa();
        final diff = currentGpa - data.previousGpa;
        final isUp = diff >= 0;
        final progressToTarget = data.targetGpa > 0 ? (currentGpa / data.targetGpa).clamp(0.0, 1.0) : 0.0;

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SectionTitle(
                title: 'GPA Predictor',
                subtitle: 'Simulasikan IPK semester dan pantau perbandingannya dengan targetmu.',
              ),
              // Premium Visualization Card
              Card(
                elevation: 6,
                shadowColor: Colors.black.withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Melingkar / Circular Progress Bar dengan Animasi Halus
                          SizedBox(
                            width: 110,
                            height: 110,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 110,
                                  height: 110,
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0, end: progressToTarget),
                                    duration: const Duration(milliseconds: 1000),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, value, _) => CircularProgressIndicator(
                                      value: value,
                                      strokeWidth: 10,
                                      backgroundColor: AppTheme.secondary.withOpacity(0.15),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        currentGpa >= data.targetGpa
                                            ? Colors.green
                                            : AppTheme.secondary,
                                      ),
                                      strokeCap: StrokeCap.round,
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      currentGpa.toStringAsFixed(2),
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        height: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Estimasi',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Konteks Perbandingan & Target
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Perbandingan Nilai',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                // Label Konteks Naik / Turun
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: (isUp ? Colors.green : AppTheme.accent).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: (isUp ? Colors.green : AppTheme.accent).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                                        color: isUp ? Colors.green : AppTheme.accent,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          '${isUp ? "Naik" : "Turun"} ${diff.abs().toStringAsFixed(2)} dr sems lalu',
                                          style: TextStyle(
                                            color: isUp ? Colors.green : AppTheme.accent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Konteks Target
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).dividerColor.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Target IPK',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  fontSize: 10,
                                                ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            data.targetGpa.toStringAsFixed(2),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: AppTheme.secondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        tooltip: 'Sesuaikan Target',
                                        icon: const Icon(Icons.edit_rounded, size: 16),
                                        onPressed: () => _showEditTargetDialog(context),
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Progress Bar mendatar penunjuk sisa ke target jika belum tercapai
                      if (currentGpa < data.targetGpa) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Jarak ke Target',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '+${(data.targetGpa - currentGpa).toStringAsFixed(2)} Poin lagi',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                            const SizedBox(width: 6),
                            const Expanded(
                              child: Text(
                                'Luar biasa! Target IPK semester ini terlampaui 🎉',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Tombol Tambah Matkul
              ElevatedButton.icon(
                onPressed: () => _showAdd(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Tambah Simulasi Mata Kuliah'),
              ),
              const SizedBox(height: 16),
              // Daftar Matkul Simulasi
              ...data.gpaItems.map((e) {
                return Dismissible(
                  key: ValueKey(e.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => data.deleteGpa(e.id),
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Icon(Icons.delete_rounded, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.school_rounded, color: AppTheme.secondary),
                        ),
                        title: Text(
                          e.course,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${e.sks} SKS'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.secondary.withOpacity(0.3)),
                          ),
                          child: Text(
                            e.gradePoint.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.secondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showEditTargetDialog(BuildContext context) {
    final targetController = TextEditingController(text: AppData.instance.targetGpa.toString());
    final prevController = TextEditingController(text: AppData.instance.previousGpa.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sesuaikan Konteks IPK'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: targetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Target IPK Semester Ini'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: prevController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'IPK Semester Lalu'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final t = double.tryParse(targetController.text);
              final p = double.tryParse(prevController.text);
              if (t != null && t > 0 && t <= 4.0) {
                AppData.instance.updateTargetGpa(t);
              }
              if (p != null && p >= 0 && p <= 4.0) {
                AppData.instance.previousGpa = p;
                AppData.instance.notifyListeners();
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(100, 48),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showAdd(BuildContext context) {
    final course = TextEditingController();
    final sks = TextEditingController();
    double grade = 4.0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tambah Simulasi Nilai',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: course,
                decoration: const InputDecoration(labelText: 'Mata Kuliah'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: sks,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Bobot SKS'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<double>(
                value: grade,
                decoration: const InputDecoration(labelText: 'Target Nilai / Huruf'),
                items: const [
                  DropdownMenuItem(value: 4.0, child: Text('A / 4.0')),
                  DropdownMenuItem(value: 3.7, child: Text('A- / 3.7')),
                  DropdownMenuItem(value: 3.3, child: Text('B+ / 3.3')),
                  DropdownMenuItem(value: 3.0, child: Text('B / 3.0')),
                  DropdownMenuItem(value: 2.7, child: Text('B- / 2.7')),
                  DropdownMenuItem(value: 2.3, child: Text('C+ / 2.3')),
                  DropdownMenuItem(value: 2.0, child: Text('C / 2.0')),
                  DropdownMenuItem(value: 1.0, child: Text('D / 1.0')),
                  DropdownMenuItem(value: 0.0, child: Text('E / 0.0')),
                ],
                onChanged: (v) => setModal(() => grade = v!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final s = int.tryParse(sks.text) ?? 0;
                  if (course.text.isNotEmpty && s > 0) {
                    AppData.instance.addGpa(course.text, s, grade);
                    Navigator.pop(ctx);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Harap masukkan nama mata kuliah dan SKS yang valid.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: const Text('Hitung Simulasi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
