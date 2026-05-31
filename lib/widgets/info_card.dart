import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final Color? valueColor;
  final VoidCallback? onTap;
  final Widget? trailingWidget;
  const InfoCard({super.key, required this.icon, required this.title, required this.value, required this.color, this.valueColor, this.onTap, this.trailingWidget});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.08)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
            child: Row(children: [
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12), 
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Text(
                      title, 
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12.sp),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      value, 
                      style: TextStyle(
                        fontSize: 20.sp, 
                        fontWeight: FontWeight.bold, 
                        color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingWidget != null) ...[
                trailingWidget!,
                SizedBox(width: 12.w),
              ],
              Icon(
                Icons.chevron_right_rounded, 
                size: 20, 
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
