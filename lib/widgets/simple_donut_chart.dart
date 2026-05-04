import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class SimpleDonutChart extends StatelessWidget {
  final Map<String, int> data;
  const SimpleDonutChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold<int>(0, (a, b) => a + b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(children: [
          SizedBox(width: 112, height: 112, child: CustomPaint(painter: _DonutPainter(data: data))),
          const SizedBox(width: 20),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Grafik Pengeluaran', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (total == 0) const Text('Belum ada data') else ...data.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('${e.key}: ${((e.value / total) * 100).toStringAsFixed(0)}%'),
            )),
          ])),
        ]),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final Map<String, int> data;
  _DonutPainter({required this.data});
  final colors = [AppTheme.primary, AppTheme.secondary, AppTheme.accent, Colors.purple, Colors.green];

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.values.fold<int>(0, (a, b) => a + b);
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: size.width / 2);
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 22..strokeCap = StrokeCap.round;
    if (total == 0) {
      paint.color = Colors.grey.shade300;
      canvas.drawCircle(center, size.width / 2 - 11, paint);
      return;
    }
    double start = -1.57;
    int i = 0;
    for (final e in data.entries) {
      final sweep = (e.value / total) * 6.283;
      paint.color = colors[i % colors.length];
      canvas.drawArc(rect.deflate(11), start, sweep, false, paint);
      start += sweep;
      i++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
