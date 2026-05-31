import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      builder: (_, __) => Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAdd(context),
          backgroundColor: AppTheme.primary,
          elevation: 4,
          child: Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h, bottom: 80.h),
          children: [
            const SectionTitle(
              title: 'Smart Study Planner',
              subtitle: 'Kelola jadwal tugas dan ujian dengan panduan prioritas visual otomatis.',
            ),
            // Tombol Tambah dihapus, dipindah ke FAB
            SizedBox(height: 12.h),
            // Petunjuk Gestur Swipe
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.tips_and_updates_rounded, size: 16, color: Colors.amber),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Geser kanan ke kiri untuk Hapus • Kiri ke kanan untuk Selesai',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11.sp),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            // Daftar Jadwal/Tugas dengan Premium Empty State
            if (data.schedules.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48.h, horizontal: 20.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(24.w),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.nightlight_round_rounded,
                          size: 64,
                          color: AppTheme.primary,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Santai dulu, belum ada tugas yang mendekat!',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Tekan tombol "Tambah Deadline Baru" di atas untuk mulai menyusun riwayat dan target studimu.',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...data.schedules.map((item) {
                final duration = item.deadline.difference(DateTime.now());
                final hoursRemaining = duration.inHours;
                final daysRemaining = duration.inDays;

                // Penentuan Prioritas Visual & Countdown Presisi (Jam/Menit)
                Color priorityColor;
                String timeLabel;

                if (item.done) {
                  priorityColor = Colors.grey;
                  timeLabel = 'Selesai';
                } else if (duration.isNegative) {
                  priorityColor = AppTheme.accent;
                  timeLabel = 'Terlambat';
                } else if (hoursRemaining < 24) {
                  priorityColor = Colors.redAccent;
                  if (hoursRemaining > 0) {
                    timeLabel = '$hoursRemaining Jam Lagi';
                  } else {
                    final minsRemaining = duration.inMinutes;
                    timeLabel = '$minsRemaining Menit Lagi';
                  }
                } else if (daysRemaining < 3) {
                  priorityColor = Colors.orange;
                  timeLabel = '$daysRemaining Hari Lagi';
                } else {
                  priorityColor = Colors.green;
                  timeLabel = '$daysRemaining Hari Lagi';
                }

                return Dismissible(
                  key: ValueKey(item.id),
                  // Background saat di-swipe ke kanan (Selesai / Selesai Toggle)
                  background: Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 20.w),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.white),
                        SizedBox(width: 8.w),
                        Text('Status Selesai', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  // Background saat di-swipe ke kiri (Hapus)
                  secondaryBackground: Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20.w),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8.w),
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
                    margin: EdgeInsets.only(bottom: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                      side: BorderSide(
                        color: priorityColor.withOpacity(item.done ? 0.2 : 0.4),
                        width: 1.5.w,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: CheckboxListTile(
                        value: item.done,
                        onChanged: (_) => data.toggleSchedule(item.id),
                        activeColor: Colors.green,
                        checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
                        contentPadding: EdgeInsets.only(left: 12.w, right: 16.w),
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
                            SizedBox(width: 8.w),
                            // Lencana Kode Warna Visual Countdown Presisi
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: priorityColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                timeLabel,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: priorityColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            '${item.course} • ${Formatters.date.format(item.deadline)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: item.done ? Colors.grey : null,
                            ),
                          ),
                        ),
                        secondary: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14.r),
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
            SizedBox(height: 24.h),
            // Widget Layar Utama (Home Screen Widget Simulator)
            Card(
              elevation: 0,
              color: AppTheme.primary.withOpacity(0.06),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28.r),
                side: BorderSide(color: AppTheme.primary.withOpacity(0.2), width: 1.5.w),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.widgets_rounded, color: AppTheme.primary, size: 20),
                        SizedBox(width: 8.w),
                        Text(
                          'Widget Layar Utama Tersedia',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Tambahkan widget KampusGo ke HP kamu untuk pantau tugas mendesak langsung dari Home Screen.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(height: 14.h),
                    // Widget Preview / Mockup
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10.r,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Icon(Icons.alarm_rounded, color: Colors.redAccent, size: 20),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tugas Kritis Terdekat',
                                  style: TextStyle(fontSize: 10.sp, color: Colors.grey, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  data.schedules.where((e) => !e.done).isEmpty
                                      ? 'Semua tugas tuntas! 🎉'
                                      : data.schedules.where((e) => !e.done).first.title,
                                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Petunjuk: Tekan lama (long press) di Home Screen HP kamu, pilih menu Widgets, lalu cari KampusGo.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: Icon(Icons.help_outline_rounded, size: 14),
                        label: Text('Cara Pasang Widget', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 88.h), // Spasi bawah ekstra
          ],
        ),
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
            left: 20.w,
            right: 20.w,
            top: 24.h,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tambah Deadline / Tugas',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Judul tugas / ujian'),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: course,
                decoration: const InputDecoration(labelText: 'Mata kuliah'),
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<String>(
                value: priority,
                decoration: const InputDecoration(labelText: 'Tingkat Prioritas'),
                items: ['Rendah', 'Sedang', 'Tinggi']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setModal(() => priority = v!),
              ),
              SizedBox(height: 16.h),
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
                icon: Icon(Icons.calendar_month_rounded),
                label: Text('Batas Waktu: ${Formatters.date.format(deadline)}'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  alignment: Alignment.center,
                ),
              ),
              SizedBox(height: 20.h),
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
                child: Text('Simpan Jadwal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
