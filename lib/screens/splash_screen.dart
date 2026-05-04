import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../utils/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).scaffoldBackgroundColor, Theme.of(context).colorScheme.surface],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 120, height: 120,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 12)),
            ]
          ),
          child: const Icon(Icons.school_rounded, color: Colors.white, size: 64)
        ),
        const SizedBox(height: 32),
        Text('KAMPUSGO', style: Theme.of(context).textTheme.displayMedium?.copyWith(letterSpacing: 2)),
        const SizedBox(height: 12),
        Text('Smart Assistant untuk Hidup Kampus', style: Theme.of(context).textTheme.bodyMedium),
      ])),
    ),
  );
}
