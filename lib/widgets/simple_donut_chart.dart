import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class SimpleDonutChart extends StatelessWidget {
  final Map<String, int> data;
  final String? selectedCategory;
  final ValueChanged<String?>? onCategorySelected;

  const SimpleDonutChart({
    super.key,
    required this.data,
    this.selectedCategory,
    this.onCategorySelected,
  });

  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Makanan':
        return AppTheme.primary;
      case 'Transportasi':
        return AppTheme.secondary;
      case 'Fotokopi':
        return AppTheme.accent;
      case 'Organisasi':
        return const Color(0xFF10B981);
      default:
        return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold<int>(0, (a, b) => a + b);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            // Donut Chart visualization
            SizedBox(
              width: 120.w,
              height: 120.h,
              child: CustomPaint(
                painter: _DonutPainter(
                  data: data,
                  selectedCategory: selectedCategory,
                ),
              ),
            ),
            SizedBox(width: 24.w),
            // Legend items (fully interactive/clickable)
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
                  SizedBox(height: 4.h),
                  Text(
                    'Klik item untuk filter',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  if (total == 0)
                    Text(
                      'Belum ada pengeluaran',
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  else
                    ...data.entries.map((e) {
                      final color = getCategoryColor(e.key);
                      final pct = ((e.value / total) * 100).toStringAsFixed(0);
                      final isSelected = selectedCategory == e.key;
                      final isDimmed = selectedCategory != null && !isSelected;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(bottom: 6.h),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withOpacity(0.12) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isSelected ? color.withOpacity(0.3) : Colors.transparent,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            if (onCategorySelected != null) {
                              onCategorySelected!(isSelected ? null : e.key);
                            }
                          },
                          borderRadius: BorderRadius.circular(12.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                            child: Row(
                              children: [
                                Container(
                                  width: 10.w,
                                  height: 10.h,
                                  decoration: BoxDecoration(
                                    color: isDimmed ? color.withOpacity(0.3) : color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    e.key,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                      color: isDimmed
                                          ? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4)
                                          : Theme.of(context).textTheme.bodyMedium?.color,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '$pct%',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isDimmed ? color.withOpacity(0.4) : color,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
  final String? selectedCategory;

  _DonutPainter({required this.data, this.selectedCategory});

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
      final baseColor = SimpleDonutChart.getCategoryColor(e.key);
      
      // Jika ada filter kategori, redupkan segmen yang tidak dipilih
      if (selectedCategory != null && selectedCategory != e.key) {
        paint.color = baseColor.withOpacity(0.2);
      } else {
        paint.color = baseColor;
      }

      canvas.drawArc(rect.deflate(11), start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.selectedCategory != selectedCategory ||
           oldDelegate.data != data;
  }
}
