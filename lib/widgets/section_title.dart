import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const SectionTitle({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 18),
    ]);
  }
}
