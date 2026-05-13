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
  @override
  Widget build(BuildContext context) {
    final data = AppData.instance;
    return AnimatedBuilder(
      animation: data,
      builder: (_, __) {
        final totalExp = data.totalExpense();
        final sisa = data.budgetLimit - totalExp;
        final usageRatio = data.budgetLimit > 0 ? (totalExp / data.budgetLimit).clamp(0.0, 1.0) : 1.0;
        final isOver = sisa < 0;

        // Tentukan warna status berdasarkan pemakaian
        Color statusColor = Colors.green;
        if (usageRatio >= 0.9 || isOver) {
          statusColor = AppTheme.accent;
        } else if (usageRatio >= 0.7) {
          statusColor = Colors.orange;
        }

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SectionTitle(
                title: 'Budget Buddy',
                subtitle: 'Pantau sisa anggaran mingguan dan lacak setiap pengeluaranmu.',
              ),
              // Kartu Batas Anggaran & Sisa Saldo
              Card(
                elevation: 6,
                shadowColor: Colors.black.withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
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
                          Text(
                            'Sisa Anggaran Minggu Ini',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isOver ? 'Melebihi Batas!' : '${((1.0 - usageRatio) * 100).toInt()}% Tersisa',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        Formatters.currency.format(sisa),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isOver ? AppTheme.accent : Theme.of(context).textTheme.headlineMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Progress Bar Pemakaian Anggaran
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: usageRatio,
                          minHeight: 10,
                          backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Keterangan Total Pengeluaran & Pengaturan Limit
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
                              const SizedBox(height: 2),
                              Text(
                                'Batas: ${Formatters.currency.format(data.budgetLimit)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () => _showEditLimitDialog(context),
                            icon: const Icon(Icons.edit_rounded, size: 16),
                            label: const Text('Atur Batas', style: TextStyle(fontSize: 12)),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              const SizedBox(height: 16),
              // Grafik Donat yang warnanya sinkron dengan daftar
              SimpleDonutChart(data: data.expenseByCategory()),
              const SizedBox(height: 16),
              // Tombol Tambah Pengeluaran
              ElevatedButton.icon(
                onPressed: () => _showAdd(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Catat Pengeluaran Baru'),
              ),
              const SizedBox(height: 20),
              Text(
                'Riwayat Pengeluaran',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // Daftar Pengeluaran dengan warna ikon yang serasi dengan grafik donat
              if (data.expenses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Belum ada catatan pengeluaran minggu ini.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )
              else
                ...data.expenses.map((e) {
                  final catColor = SimpleDonutChart.getCategoryColor(e.category);
                  return Dismissible(
                    key: ValueKey(e.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => data.deleteExpense(e.id),
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
                              color: catColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(Icons.receipt_long_rounded, color: catColor),
                          ),
                          title: Text(
                            e.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(color: catColor, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${e.category} • ${Formatters.date.format(e.date)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: Text(
                            Formatters.currency.format(e.amount),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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

  void _showEditLimitDialog(BuildContext context) {
    final limitController = TextEditingController(text: AppData.instance.budgetLimit.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Atur Batas Anggaran'),
        content: TextField(
          controller: limitController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Batas Anggaran Mingguan (Rp)',
            hintText: 'Contoh: 500000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
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
            child: const Text('Simpan'),
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
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Catat Pengeluaran',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Nama pengeluaran / barang'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Nominal (Rp)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: ['Makanan', 'Transportasi', 'Fotokopi', 'Organisasi', 'Lainnya']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setModal(() => category = v!),
              ),
              const SizedBox(height: 20),
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
                child: const Text('Simpan Pengeluaran'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
