import 'package:flutter/material.dart';
import '../services/app_data.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/section_title.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  @override
  Widget build(BuildContext context) {
    final data = AppData.instance;
    return AnimatedBuilder(
      animation: data,
      builder: (_, __) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SectionTitle(
              title: 'Smart Study Planner',
              subtitle: 'Kelola jadwal tugas dan ujian dengan panduan prioritas visual otomatis.',
            ),
            // Tombol Tambah & Petunjuk Interaksi
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAdd(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Tambah Deadline Baru'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Petunjuk Gestur Swipe
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tips_and_updates_rounded, size: 16, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Geser kanan ke kiri untuk Hapus • Kiri ke kanan untuk Selesai',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Daftar Jadwal/Tugas
            if (data.schedules.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'Belum ada jadwal tugas atau ujian aktif 🎉',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            else
              ...data.schedules.map((item) {
                final duration = item.deadline.difference(DateTime.now());
                final hoursRemaining = duration.inHours;
                final daysRemaining = duration.inDays;

                // Penentuan Prioritas Visual (Kode Warna)
                Color priorityColor;
                String timeLabel;

                if (item.done) {
                  priorityColor = Colors.grey;
                  timeLabel = 'Selesai';
                } else if (hoursRemaining < 0) {
                  priorityColor = AppTheme.accent;
                  timeLabel = 'Terlambat';
                } else if (hoursRemaining < 24) {
                  priorityColor = Colors.redAccent;
                  timeLabel = '< 24 Jam Lagi';
                } else if (daysRemaining < 3) {
                  priorityColor = Colors.orange;
                  timeLabel = '< 3 Hari Lagi';
                } else {
                  priorityColor = Colors.green;
                  timeLabel = 'Waktu Aman';
                }

                return Dismissible(
                  key: ValueKey(item.id),
                  // Background saat di-swipe ke kanan (Selesai / Selesai Toggle)
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Status Selesai', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  // Background saat di-swipe ke kiri (Hapus)
                  secondaryBackground: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(Icons.delete_rounded, color: Colors.white),
                      ],
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      // Toggle status selesai tanpa menghapus item dari list
                      data.toggleSchedule(item.id);
                      return false;
                    }
                    return true;
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      data.deleteSchedule(item.id);
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(
                        color: priorityColor.withOpacity(item.done ? 0.2 : 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: CheckboxListTile(
                        value: item.done,
                        onChanged: (_) => data.toggleSchedule(item.id),
                        activeColor: Colors.green,
                        checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        contentPadding: const EdgeInsets.only(left: 12, right: 16),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: item.done ? TextDecoration.lineThrough : null,
                                  color: item.done ? Colors.grey : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Lencana Kode Warna Visual
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: priorityColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                timeLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: priorityColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${item.course} • ${Formatters.date.format(item.deadline)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: item.done ? Colors.grey : null,
                            ),
                          ),
                        ),
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            item.done ? Icons.task_alt_rounded : Icons.alarm_rounded,
                            color: priorityColor,
                            size: 20,
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.trailing,
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  void _showAdd(BuildContext context) {
    final title = TextEditingController();
    final course = TextEditingController();
    String priority = 'Sedang';
    DateTime deadline = DateTime.now().add(const Duration(days: 1));

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
                'Tambah Deadline / Tugas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Judul tugas / ujian'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: course,
                decoration: const InputDecoration(labelText: 'Mata kuliah'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: priority,
                decoration: const InputDecoration(labelText: 'Tingkat Prioritas'),
                items: ['Rendah', 'Sedang', 'Tinggi']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setModal(() => priority = v!),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    firstDate: DateTime.now().subtract(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    initialDate: deadline,
                  );
                  if (picked != null) {
                    // Minta waktu spesifik juga untuk presisi < 24 jam
                    final timePicked = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay.fromDateTime(deadline),
                    );
                    setModal(() {
                      if (timePicked != null) {
                        deadline = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          timePicked.hour,
                          timePicked.minute,
                        );
                      } else {
                        deadline = picked;
                      }
                    });
                  }
                },
                icon: const Icon(Icons.calendar_month_rounded),
                label: Text('Batas Waktu: ${Formatters.date.format(deadline)}'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (title.text.isNotEmpty && course.text.isNotEmpty) {
                    AppData.instance.addSchedule(title.text, course.text, deadline, priority);
                    Navigator.pop(ctx);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Harap masukkan judul tugas dan mata kuliah dengan valid.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: const Text('Simpan Jadwal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
