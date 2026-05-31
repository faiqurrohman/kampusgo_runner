import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const SectionTitle({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
      SizedBox(height: 6.h),
      Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      SizedBox(height: 18.h),
    ]);
  }
}
