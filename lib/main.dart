import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/splash_screen.dart';
import 'services/app_data.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await initializeDateFormatting('id_ID', null);
  await AppData.instance.init();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed (Have you run flutterfire configure?): $e");
  }

  runApp(const KampusGoApp());
}

class KampusGoApp extends StatelessWidget {
  const KampusGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // Standard iPhone 12/13/14 size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: AppData.instance,
          builder: (context, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'KAMPUSGO',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: AppData.instance.themeMode,
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
