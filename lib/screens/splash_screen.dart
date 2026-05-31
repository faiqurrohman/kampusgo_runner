import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import '../services/app_data.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final loggedIn = await AuthService.instance.isLoggedIn();
    if (loggedIn) {
      final email = await AuthService.instance.getSavedEmail();
      if (email != null) await AppData.instance.loadUserData(email);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
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
        ClipRRect(
          borderRadius: BorderRadius.circular(36.r),
          child: Image.asset(
            'assets/images/logo_mewah.png',
            width: 150.w,
            height: 150.w, // maintain aspect ratio
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 32.h),
        Text('KAMPUSGO', style: Theme.of(context).textTheme.displayMedium?.copyWith(letterSpacing: 2.w, fontSize: 45.sp)),
        SizedBox(height: 12.h),
        Text('Smart Assistant untuk Hidup Kampus', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.sp)),
      ])),
    ),
  );
}
