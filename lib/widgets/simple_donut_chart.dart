import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class SimpleDonutChart extends StatelessWidget {
  final Map<String, int> data;
  const SimpleDonutChart({super.key, required this.data});

  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Makanan':
        return AppTheme.primary;
      case 'Transportasi':
        return AppTheme.secondary;
      case 'Fotokopi':
        return AppTheme.accent;
      case 'Organisasi':
        return Colors.green;
      default:
        return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold<int>(0, (a, b) => a + b);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(painter: _DonutPainter(data: data)),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Distribusi Kategori',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (total == 0)
                    Text(
                      'Belum ada pengeluaran',
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  else
                    ...data.entries.map((e) {
                      final color = getCategoryColor(e.key);
                      final pct = ((e.value / total) * 100).toStringAsFixed(0);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                e.key,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '$pct%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final Map<String, int> data;
  _DonutPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.values.fold<int>(0, (a, b) => a + b);
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: size.width / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round;

    if (total == 0) {
      paint.color = Colors.grey.withOpacity(0.2);
      canvas.drawCircle(center, size.width / 2 - 11, paint);
      return;
    }

    double start = -1.57; // -PI/2 (atas)
    for (final e in data.entries) {
      final sweep = (e.value / total) * 6.28318530718; // 2*PI
      paint.color = SimpleDonutChart.getCategoryColor(e.key);
      canvas.drawArc(rect.deflate(11), start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => true;
}
