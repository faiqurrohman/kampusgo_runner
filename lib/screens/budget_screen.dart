import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../services/app_data.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/section_title.dart';
import '../widgets/simple_donut_chart.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  String? _selectedCategoryFilter;

  @override
  Widget build(BuildContext context) {
    final data = AppData.instance;
    return AnimatedBuilder(
      animation: data,
      builder: (_, __) {
        final totalExp = data.totalExpense();
        final sisa = data.budgetLimit - totalExp;
        final usageRatio = data.budgetLimit > 0 ? (totalExp / data.budgetLimit).clamp(0.0, 1.0) : 0.0;
        final isOver = sisa < 0;

        // Tentukan warna status berdasarkan pemakaian
        Color statusColor = Colors.green;
        if (usageRatio >= 0.9 || isOver) {
          statusColor = AppTheme.accent;
        } else if (usageRatio >= 0.7) {
          statusColor = Colors.orange;
        }

        // Daftar pengeluaran terfilter sesuai kategori yang diklik pada grafik donat
        final filteredExpenses = _selectedCategoryFilter == null
            ? data.expenses
            : data.expenses.where((e) => e.category == _selectedCategoryFilter).toList();

        return Scaffold(
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
                title: 'Budget Buddy',
                subtitle: 'Pantau sisa uang saku bulanan/mingguan dan lacak setiap pengeluaranmu.',
              ),
              // Kartu Batas Uang Saku & Sisa Saldo Otomatis
              Card(
                elevation: 6,
                shadowColor: Colors.black.withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.r)),
                child: Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32.r),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.surface,
                        Theme.of(context).colorScheme.surface.withOpacity(0.95),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Sisa Uang Saku / Anggaran',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              isOver ? 'Melebihi Saldo!' : '${((1.0 - usageRatio) * 100).toInt()}% Tersisa',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        Formatters.currency.format(sisa),
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          color: isOver ? AppTheme.accent : Theme.of(context).textTheme.headlineMedium?.color,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Progress Bar Pemakaian Anggaran
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: LinearProgressIndicator(
                          value: usageRatio,
                          minHeight: 10,
                          backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Keterangan Total Pengeluaran & Pengaturan Uang Saku
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Terpakai: ${Formatters.currency.format(totalExp)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Uang Saku: ${Formatters.currency.format(data.budgetLimit)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () => _showEditLimitDialog(context),
                            icon: Icon(Icons.edit_rounded, size: 16),
                            label: Text('Input Saldo', style: TextStyle(fontSize: 12.sp)),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // Grafik Donat Interaktif (Klik Kategori untuk Filter)
              SimpleDonutChart(
                data: data.expenseByCategory(),
                selectedCategory: _selectedCategoryFilter,
                onCategorySelected: (category) {
                  setState(() => _selectedCategoryFilter = category);
                },
              ),
              SizedBox(height: 16.h),
              // Tombol Tambah dihapus, dipindah ke FAB
              SizedBox(height: 20.h),
              // Header Riwayat Pengeluaran beserta tombol ekspor ke orang tua & indikator filter
              Row(
                children: [
                  Text(
                    'Riwayat Pengeluaran',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (_selectedCategoryFilter != null) ...[
                    ActionChip(
                      avatar: Icon(Icons.clear_rounded, size: 12),
                      label: Text(
                        _selectedCategoryFilter!,
                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: AppTheme.primary.withOpacity(0.12),
                      side: BorderSide.none,
                      onPressed: () => setState(() => _selectedCategoryFilter = null),
                    ),
                    SizedBox(width: 6.w),
                  ],
                  // Tombol Ekspor CSV/Laporan
                  IconButton(
                    onPressed: () => _showExportDialog(context),
                    icon: Icon(Icons.ios_share_rounded, size: 18),
                    tooltip: 'Ekspor Laporan (CSV/PDF)',
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primary.withOpacity(0.08),
                      foregroundColor: AppTheme.primary,
                      padding: EdgeInsets.all(8.w),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              // Daftar Pengeluaran terfilter dengan Empty State yang relevan
              if (filteredExpenses.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Text(
                      _selectedCategoryFilter == null
                          ? 'Belum ada catatan pengeluaran minggu ini.'
                          : 'Tidak ada pengeluaran untuk kategori $_selectedCategoryFilter.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...filteredExpenses.map((e) {
                  final catColor = SimpleDonutChart.getCategoryColor(e.category);
                  return Dismissible(
                    key: ValueKey(e.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => data.deleteExpense(e.id),
                    background: Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20.w),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(32.r),
                      ),
                      child: Icon(Icons.delete_rounded, color: Colors.white),
                    ),
                    child: Card(
                      margin: EdgeInsets.only(bottom: 12.h),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: catColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Icon(Icons.receipt_long_rounded, color: catColor),
                          ),
                          title: Text(
                            e.title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Row(
                            children: [
                              Container(
                                width: 8.w,
                                height: 8.h,
                                decoration: BoxDecoration(color: catColor, shape: BoxShape.circle),
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  '${e.category} • ${Formatters.date.format(e.date)}',
                                  style: TextStyle(fontSize: 12.sp),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          trailing: Text(
                            Formatters.currency.format(e.amount),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      );
    },
  );
  }

  void _showExportDialog(BuildContext context) {
    final data = AppData.instance;
    if (data.expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belum ada catatan pengeluaran untuk diekspor.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('KAMPUSGO - LAPORAN PENGELUARAN');
    buffer.writeln('Tanggal Cetak: ${Formatters.date.format(DateTime.now())}');
    buffer.writeln('Total Uang Saku: ${Formatters.currency.format(data.budgetLimit)}');
    buffer.writeln('Total Terpakai: ${Formatters.currency.format(data.totalExpense())}');
    buffer.writeln('Sisa Saldo: ${Formatters.currency.format(data.budgetLimit - data.totalExpense())}');
    buffer.writeln('----------------------------------------');
    buffer.writeln('Tanggal,Kategori,Item,Nominal');
    for (final e in data.expenses) {
      buffer.writeln('${Formatters.date.format(e.date)},"${e.category}","${e.title}",${e.amount}');
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.insert_drive_file_rounded, color: AppTheme.primary),
            SizedBox(width: 8.w),
            Text('Ekspor Laporan (CSV)', style: TextStyle(fontSize: 18.sp)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Format CSV/Teks siap dikirimkan ke orang tua atau diolah di Excel:',
              style: TextStyle(fontSize: 12.sp),
            ),
            SizedBox(height: 12.h),
            Container(
              constraints: const BoxConstraints(maxHeight: 180),
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  buffer.toString(),
                  style: TextStyle(fontFamily: 'monospace', fontSize: 10.sp),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Tutup'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Laporan berhasil disalin! Siap dikirim ke WhatsApp / Email orang tua 🚀'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Icon(Icons.copy_rounded, size: 16),
            label: Text('Salin Data'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(120, 40)),
          ),
        ],
      ),
    );
  }

  void _showEditLimitDialog(BuildContext context) {
    final limitController = TextEditingController(text: AppData.instance.budgetLimit.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Input Uang Saku / Anggaran'),
        content: TextField(
          controller: limitController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Total Uang Saku / Anggaran (Rp)',
            hintText: 'Contoh: 500000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(limitController.text);
              if (val != null && val >= 0) {
                AppData.instance.updateBudgetLimit(val);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 48)),
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showAdd(BuildContext context) {
    final title = TextEditingController();
    final amount = TextEditingController();
    String category = 'Makanan';

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
                'Catat Pengeluaran',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Nama pengeluaran / barang'),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Nominal (Rp)'),
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: ['Makanan', 'Transportasi', 'Fotokopi', 'Organisasi', 'Lainnya']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setModal(() => category = v!),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () {
                  final nominal = int.tryParse(amount.text) ?? 0;
                  if (title.text.isNotEmpty && nominal > 0) {
                    AppData.instance.addExpense(title.text, category, nominal);
                    Navigator.pop(ctx);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Harap lengkapi nama pengeluaran dan nominal dengan valid.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: Text('Simpan Pengeluaran'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
