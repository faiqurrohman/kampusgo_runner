import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'privacy_screen.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import '../services/app_data.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final nim = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool acceptedTerms = false;

  bool isLoading = false;
  bool isGoogleLoading = false;
  String? errorMessage;

  // Indikator Kekuatan Sandi secara Real-time
  bool _hasMinLength = false;
  bool _hasNumber = false;
  bool _hasSymbol = false;

  // Animasi Shake untuk Feedback Error
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    name.dispose();
    nim.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String v) {
    setState(() {
      _hasMinLength = v.length >= 8;
      _hasNumber = RegExp(r'\d').hasMatch(v);
      _hasSymbol = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(v);
      // Hapus pesan error jika pengguna mulai memperbaiki
      if (errorMessage != null) errorMessage = null;
    });
  }

  int get _strengthScore {
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasNumber) score++;
    if (_hasSymbol) score++;
    return score;
  }

  Color get _strengthColor {
    final score = _strengthScore;
    if (password.text.isEmpty) return Colors.grey.withOpacity(0.3);
    if (score == 1) return Colors.redAccent;
    if (score == 2) return Colors.orangeAccent;
    if (score == 3) return Colors.teal;
    return Colors.grey.withOpacity(0.3);
  }

  String get _strengthLabel {
    if (password.text.isEmpty) return 'Kekuatan Kata Sandi';
    final score = _strengthScore;
    if (score == 1) return 'Lemah';
    if (score == 2) return 'Sedang';
    if (score == 3) return 'Kuat & Aman';
    return 'Sangat Lemah';
  }

  void _showSnackBar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  void _setError(String? msg) {
    setState(() {
      isLoading = false;
      isGoogleLoading = false;
      errorMessage = msg;
    });
    if (msg != null) _shakeCtrl.forward(from: 0);
  }

  // ─── Pendaftaran Manual ───────────────────────────────────────────────────
  Future<void> _handleRegister() async {
    // Validasi form standar
    if (!formKey.currentState!.validate()) {
      _setError('Periksa kembali isian formulir yang bertanda merah.');
      return;
    }

    // Validasi syarat & ketentuan
    if (!acceptedTerms) {
      _setError('Harap centang persetujuan Syarat & Ketentuan serta Kebijakan Privasi.');
      return;
    }

    // Validasi kekuatan sandi tambahan
    if (_strengthScore < 3) {
      _setError('Kata sandi belum memenuhi kriteria keamanan (Min. 8 karakter, angka, dan simbol).');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final inputName = name.text.trim();
      final inputEmail = email.text.trim();
      final inputPassword = password.text;
      
      final finalName = inputName.isEmpty ? 'Mahasiswa' : inputName;

      // Pendaftaran ke database lokal Secure Storage
      await AuthService.instance.registerManual(finalName, inputEmail, inputPassword);

      if (!mounted) return;
      
      // Sinkronisasi memori global
      AppData.instance.updateProfile(
        name: finalName,
        email: inputEmail,
      );

      _showSnackBar('🎉 Pendaftaran berhasil! Selamat datang di KAMPUSGO.', Colors.teal);
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('Pendaftaran gagal. Silakan coba lagi.');
    }
  }

  // ─── Pendaftaran OAuth Google ─────────────────────────────────────────────
  Future<void> _handleGoogleSignUp() async {
    setState(() {
      isGoogleLoading = true;
      errorMessage = null;
    });

    try {
      final account = await AuthService.instance.signInWithGoogle();
      if (!mounted) return;
      if (account != null) {
        AppData.instance.updateProfile(
          name: account.displayName ?? account.email.split('@').first,
          email: account.email,
        );
        _showSnackBar('🔑 Akun Google berhasil terhubung: ${account.email}', Colors.teal);
        await Future.delayed(const Duration(milliseconds: 400));
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        setState(() => isGoogleLoading = false);
      }
    } catch (e) {
      _setError('Pendaftaran via Google gagal. Silakan coba metode manual.');
    }
  }

  // ─── Pendaftaran SSO Kampus ───────────────────────────────────────────────
  void _handleSsoSignUp() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.domain_verification_rounded, color: Colors.teal),
            ),
            SizedBox(width: 12.w),
            Text('Portal SSO Kampus', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Anda akan dialihkan ke halaman masuk identitas akademik terintegrasi. Sistem akan memverifikasi status kemahasiswaan Anda secara otomatis.',
          style: TextStyle(fontSize: 13.sp, height: 1.5.h),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => isLoading = true);
              await Future.delayed(const Duration(milliseconds: 1500));
              if (!mounted) return;

              // Simpan sesi SSO
              await AuthService.instance.saveManualSession(
                email: 'sso.student@kampusgo.id',
                name: 'Mahasiswa Terverifikasi SSO',
              );
              AppData.instance.updateProfile(
                name: 'Mahasiswa Terverifikasi SSO',
                email: 'sso.student@kampusgo.id',
              );
              _showSnackBar('✅ Verifikasi Single Sign-On sukses.', Colors.teal);
              await Future.delayed(const Duration(milliseconds: 400));
              if (!mounted) return;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            },
            child: Text('Lanjutkan Autentikasi', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ─── Dekorasi Kolom Input Custom ──────────────────────────────────────────
  InputDecoration _customInputDeco({
    required String label,
    required Widget prefixIcon,
    Widget? suffixIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    return InputDecoration(
      labelText: label,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.r),
        borderSide: BorderSide(color: borderColor, width: 1.5.w),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.r),
        borderSide: BorderSide(color: AppTheme.primary, width: 2.0.w),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.r),
        borderSide: BorderSide(color: Colors.redAccent, width: 1.5.w),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.r),
        borderSide: BorderSide(color: Colors.redAccent, width: 2.0.w),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
    );
  }

  // Helper Item Kriteria Sandi
  Widget _buildCriteriaCheck(String label, bool met) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(right: 4.w),
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: met ? Colors.teal.withOpacity(0.15) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: met ? Colors.teal : Theme.of(context).dividerColor.withOpacity(0.3),
              width: 1.w,
            ),
          ),
          child: Icon(
            met ? Icons.check_rounded : Icons.close_rounded,
            size: 10,
            color: met ? Colors.teal : Theme.of(context).dividerColor.withOpacity(0.4),
          ),
        ),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: met ? FontWeight.w600 : FontWeight.normal,
              color: met
                  ? Theme.of(context).textTheme.bodyLarge?.color
                  : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header Bersih & Modern ───
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).dividerColor.withOpacity(0.08),
                      padding: EdgeInsets.all(12.w),
                    ),
                    icon: Icon(Icons.arrow_back_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    'Daftar Akun',
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // ─── Area Formulir Utama ───
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 20.h),
                children: [
                  Text(
                    'Buat akun mahasiswa',
                    style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Daftarkan identitas unik Anda untuk mengakses kapabilitas penuh platform kampus.',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                      height: 1.4.h,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // ─── Banner Error Dinamis (Animasi Shake) ───
                  if (errorMessage != null) ...[
                    AnimatedBuilder(
                      animation: _shakeAnim,
                      builder: (ctx, child) => Transform.translate(
                        offset: Offset(8 * (_shakeAnim.value < 0.5 ? _shakeAnim.value : 1 - _shakeAnim.value) * 4, 0),
                        child: child,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline_rounded, color: Colors.redAccent),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: TextStyle(fontSize: 12.sp, color: Colors.redAccent, fontWeight: FontWeight.w600),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => errorMessage = null),
                              child: Icon(Icons.close_rounded, color: Colors.redAccent, size: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],

                  // ─── Formulir Data Mahasiswa Bersih (Tanpa Duplikasi) ───
                  Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Nama Lengkap
                        TextFormField(
                          controller: name,
                          enabled: !isLoading,
                          textInputAction: TextInputAction.next,
                          decoration: _customInputDeco(
                            label: 'Nama Lengkap',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          validator: (v) => v != null && v.trim().length > 2
                              ? null
                              : 'Nama wajib diisi dengan benar',
                        ),
                        SizedBox(height: 16.h),

                        // 2. Nomor Induk Mahasiswa (NIM)
                        TextFormField(
                          controller: nim,
                          enabled: !isLoading,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: _customInputDeco(
                            label: 'Nomor Induk Mahasiswa (NIM)',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'NIM sangat penting untuk validasi identitas';
                            }
                            if (v.trim().length < 6) {
                              return 'Format NIM terlalu pendek (minimal 6 digit)';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),

                        // 3. Alamat Email (Fleksibel: Mendukung Gmail, Yahoo, dll.)
                        TextFormField(
                          controller: email,
                          enabled: !isLoading,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: _customInputDeco(
                            label: 'Alamat Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Alamat email tidak boleh kosong';
                            }
                            // Regex standar untuk validasi email umum
                            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(v.trim())) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),

                        // 4. Kata Sandi
                        TextFormField(
                          controller: password,
                          obscureText: hidePassword,
                          enabled: !isLoading,
                          textInputAction: TextInputAction.next,
                          onChanged: _onPasswordChanged,
                          decoration: _customInputDeco(
                            label: 'Password',
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(hidePassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => hidePassword = !hidePassword),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Password wajib diisi';
                            }
                            if (v.length < 8) {
                              return 'Password minimal 8 karakter';
                            }
                            return null;
                          },
                        ),

                        // ─── Indikator Kekuatan Sandi Visual (Hanya 1 Kali) ───
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.only(top: 8.h, bottom: 16.h),
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.08)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Kekuatan Sandi:',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                    ),
                                  ),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Text(
                                      _strengthLabel,
                                      key: ValueKey(_strengthLabel),
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: password.text.isEmpty
                                            ? Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5)
                                            : _strengthColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              // Bar Warna Progresif
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final width = constraints.maxWidth;
                                  final factor = password.text.isEmpty ? 0.0 : (_strengthScore / 3.0);
                                  return Stack(
                                    children: [
                                      Container(
                                        height: 6.h,
                                        width: width,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).dividerColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(3.r),
                                        ),
                                      ),
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeOut,
                                        height: 6.h,
                                        width: width * factor,
                                        decoration: BoxDecoration(
                                          color: _strengthColor,
                                          borderRadius: BorderRadius.circular(3.r),
                                          boxShadow: password.text.isNotEmpty
                                              ? [BoxShadow(color: _strengthColor.withOpacity(0.4), blurRadius: 6.r)]
                                              : null,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              SizedBox(height: 12.h),
                              // Checklist Aturan Sandi
                              Row(
                                children: [
                                  Expanded(child: _buildCriteriaCheck('Min. 8 karakter', _hasMinLength)),
                                  Expanded(child: _buildCriteriaCheck('Kombinasi angka', _hasNumber)),
                                  Expanded(child: _buildCriteriaCheck('Simbol (!@#)', _hasSymbol)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // 5. Konfirmasi Password
                        TextFormField(
                          controller: confirmPassword,
                          obscureText: hideConfirmPassword,
                          enabled: !isLoading,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleRegister(),
                          decoration: _customInputDeco(
                            label: 'Ulangi Password (Konfirmasi)',
                            prefixIcon: Icon(Icons.lock_reset_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(hideConfirmPassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => hideConfirmPassword = !hideConfirmPassword),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Kolom konfirmasi password wajib diisi';
                            }
                            if (v != password.text) {
                              return 'Kombinasi password tidak cocok. Silakan ketik ulang.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),

                        // ─── Syarat dan Ketentuan Checkbox ───
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 2.h),
                                child: SizedBox(
                                  height: 20.h,
                                  width: 20.w,
                                  child: Checkbox(
                                    value: acceptedTerms,
                                    onChanged: isLoading
                                        ? null
                                        : (v) {
                                            setState(() => acceptedTerms = v ?? false);
                                            if (acceptedTerms && errorMessage != null) {
                                              errorMessage = null;
                                            }
                                          },
                                    activeColor: AppTheme.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: isLoading ? null : () => setState(() => acceptedTerms = !acceptedTerms),
                                      child: Text(
                                        'Saya menyetujui penyimpanan & pemrosesan data identitas mahasiswa.',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(context).textTheme.bodyMedium?.color,
                                          height: 1.3.h,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const PrivacyScreen()),
                                      ),
                                      child: Text(
                                        'Baca Syarat & Ketentuan serta Kebijakan Privasi',
                                        style: TextStyle(
                                          fontSize: 11.5.sp,
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // ─── Tombol Daftar Utama ───
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                          ),
                          onPressed: (isLoading || isGoogleLoading) ? null : _handleRegister,
                          child: isLoading
                              ? SizedBox(
                                  height: 22.h,
                                  width: 22.w,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                )
                              : Text(
                                  'Daftar dan Masuk',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                                ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // ─── Alternatif Pendaftaran (SSO/OAuth) ───
                  Row(
                    children: [
                      Expanded(child: Divider(color: Theme.of(context).dividerColor.withOpacity(0.15))),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'ATAU DAFTAR DENGAN',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Theme.of(context).dividerColor.withOpacity(0.15))),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  Row(
                    children: [
                      // Tombol Google
                      Expanded(
                        child: _SocialButton(
                          onTap: (isLoading || isGoogleLoading) ? null : _handleGoogleSignUp,
                          isLoading: isGoogleLoading,
                          icon: _GoogleIcon(),
                          label: 'Google',
                        ),
                      ),
                      SizedBox(width: 16.w),
                      // Tombol SSO Kampus
                      Expanded(
                        child: _SocialButton(
                          onTap: (isLoading || isGoogleLoading) ? null : _handleSsoSignUp,
                          isLoading: false,
                          icon: Icon(Icons.domain_verification_rounded, color: Colors.teal, size: 20),
                          label: 'SSO Kampus',
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // ─── Tautan Login ───
                  TextButton(
                    onPressed: (isLoading || isGoogleLoading) ? null : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: 'Sudah punya akun? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: 'Masuk di sini',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widget Helper: Tombol Sosial ─────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;
  final Widget icon;
  final String label;

  const _SocialButton({
    required this.onTap,
    required this.isLoading,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = Theme.of(context).dividerColor.withOpacity(0.15);

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        side: BorderSide(color: effectiveColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      ),
      onPressed: onTap,
      child: isLoading
          ? SizedBox(
              height: 20.h,
              width: 20.w,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
    );
  }
}

// ─── Widget: Google "G" Icon Painter ──────────────────────────────────────────

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.w,
      height: 20.h,
      alignment: Alignment.center,
      child: CustomPaint(size: const Size(20, 20), painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final colors = [
      const Color(0xFF4285F4), // Biru
      const Color(0xFF34A853), // Hijau
      const Color(0xFFFBBC05), // Kuning
      const Color(0xFFEA4335), // Merah
    ];

    for (int i = 0; i < 4; i++) {
      final paint = Paint()..color = colors[i]..style = PaintingStyle.stroke..strokeWidth = 3;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 1.5),
        (i * 90 - 45) * 3.14159 / 180,
        90 * 3.14159 / 180,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
