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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.08)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12), 
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Text(
                      title, 
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value, 
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold, 
                        color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingWidget != null) ...[
                trailingWidget!,
                const SizedBox(width: 12),
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
