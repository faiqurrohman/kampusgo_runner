import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController(text: 'demo@kampusgo.id');
  final password = TextEditingController(text: '123456');

  bool hide = true;
  bool rememberMe = true;

  // State loading terpisah per tombol agar UX lebih tepat
  bool isLoading = false;
  bool isGoogleLoading = false;
  bool isBiometricLoading = false;

  String? errorMessage;

  // Status biometrik — diperiksa saat init
  BiometricStatus _biometricStatus = BiometricStatus.deviceNotSupported;
  bool _hasPreviousSession = false;

  // Animasi shake untuk error
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  /// Memeriksa dukungan biometrik dan sesi sebelumnya saat screen dibuka.
  Future<void> _checkBiometricAvailability() async {
    final status = await AuthService.instance.checkBiometricStatus();
    final hasSession = await AuthService.instance.hasPreviousSession();
    if (mounted) {
      setState(() {
        _biometricStatus = status;
        _hasPreviousSession = hasSession;
      });
    }
  }

  /// Apakah tombol biometrik aktif: hanya jika perangkat mendukung DAN sudah pernah login.
  bool get _isBiometricEnabled =>
      _biometricStatus == BiometricStatus.available && _hasPreviousSession;

  /// Teks tooltip tombol biometrik sesuai kondisi.
  String get _biometricTooltip {
    if (_biometricStatus == BiometricStatus.deviceNotSupported) {
      return 'Perangkat tidak mendukung biometrik';
    }
    if (_biometricStatus == BiometricStatus.notEnrolled) {
      return 'Sidik jari/wajah belum terdaftar di perangkat';
    }
    if (!_hasPreviousSession) {
      return 'Login manual dulu untuk mengaktifkan biometrik';
    }
    return 'Masuk dengan sidik jari atau wajah';
  }

  void _showForgotPasswordDialog() {
    final resetCtrl = TextEditingController(text: email.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Lupa Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan alamat email terdaftar untuk menerima instruksi tautan pemulihan kata sandi.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetCtrl,
              decoration: InputDecoration(
                labelText: 'Alamat Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _showSnackBar('✅ Instruksi pemulihan dikirim ke ${resetCtrl.text}', Colors.teal);
            },
            child: const Text('Kirim Tautan', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _navigateToDashboard() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  void _setError(String? msg) {
    setState(() {
      isLoading = false;
      isGoogleLoading = false;
      isBiometricLoading = false;
      errorMessage = msg;
    });
    if (msg != null) _shakeCtrl.forward(from: 0);
  }

  // ─── Login Manual Email/Password ──────────────────────────────────────────
  Future<void> _handleLogin() async {
    if (!formKey.currentState!.validate()) return;
    setState(() { isLoading = true; errorMessage = null; });

    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    if (email.text.trim() == 'demo@kampusgo.id' && password.text == '123456') {
      // Simpan sesi aman setelah login berhasil
      await AuthService.instance.saveManualSession(
        email: email.text.trim(),
        name: 'Mahasiswa Demo',
      );
      // Refresh status biometrik (kini tombol bisa aktif)
      await _checkBiometricAvailability();
      _navigateToDashboard();
    } else {
      _setError('Kredensial tidak sesuai. Periksa kembali email dan password Anda.');
    }
  }

  // ─── Google Sign-In ───────────────────────────────────────────────────────
  Future<void> _handleGoogleSignIn() async {
    setState(() { isGoogleLoading = true; errorMessage = null; });

    try {
      final account = await AuthService.instance.signInWithGoogle();
      if (!mounted) return;
      if (account != null) {
        _showSnackBar('🔑 Berhasil masuk dengan akun Google: ${account.email}', Colors.teal);
        await Future.delayed(const Duration(milliseconds: 400));
        _navigateToDashboard();
      } else {
        // User membatalkan dialog Google
        setState(() => isGoogleLoading = false);
      }
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('Gagal terhubung ke layanan Google. Coba lagi.');
    }
  }

  // ─── Biometric Auth ───────────────────────────────────────────────────────
  Future<void> _handleBiometricAuth() async {
    if (!_isBiometricEnabled) {
      // Tampilkan pesan tooltip sebagai SnackBar agar jelas
      _showSnackBar('ℹ️ $_biometricTooltip', Colors.blueGrey.shade700);
      return;
    }

    setState(() { isBiometricLoading = true; errorMessage = null; });

    try {
      final ok = await AuthService.instance.authenticateWithBiometric();
      if (!mounted) return;
      if (ok) {
        final savedEmail = await AuthService.instance.getSavedEmail();
        _showSnackBar('✅ Sidik jari/wajah terverifikasi — Selamat datang kembali!', Colors.teal);
        await Future.delayed(const Duration(milliseconds: 400));
        _navigateToDashboard();
      } else {
        // Dibatalkan oleh user (dialog ditutup)
        setState(() => isBiometricLoading = false);
      }
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('Autentikasi biometrik gagal. Coba lagi.');
    }
  }

  // ─── Input Decoration ─────────────────────────────────────────────────────
  InputDecoration _customInputDeco({
    required String label,
    required Widget prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        children: [
          const SizedBox(height: 40),

          // ── Logo ──
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary.withOpacity(0.08),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 1),
                    boxShadow: [
                      BoxShadow(color: Colors.purpleAccent.withOpacity(0.2), blurRadius: 16, spreadRadius: 2),
                    ],
                  ),
                  child: const Icon(Icons.school_outlined, color: Colors.purpleAccent, size: 26),
                ),
                const SizedBox(width: 16),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'KAMPUS',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 2.0, color: Colors.white),
                        ),
                        TextSpan(
                          text: 'GO',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w200, letterSpacing: 1.0, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          Text('Masuk ke KAMPUSGO', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 32)),
          const SizedBox(height: 12),
          Text(
            'Kelola jadwal, uang saku, IPK, dan link kuliahmu dengan lebih cerdas.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 36),

          // ── Error Banner dengan animasi shake ──
          if (errorMessage != null) ...[
            AnimatedBuilder(
              animation: _shakeAnim,
              builder: (ctx, child) => Transform.translate(
                offset: Offset(8 * (_shakeAnim.value < 0.5 ? _shakeAnim.value : 1 - _shakeAnim.value) * 4, 0),
                child: child,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.w600),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => errorMessage = null),
                      child: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 18),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── Form ──
          Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: email,
                  enabled: !isLoading,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: _customInputDeco(
                    label: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (v) => v != null && v.contains('@') ? null : 'Alamat email tidak valid',
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: password,
                  obscureText: hide,
                  enabled: !isLoading,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleLogin(),
                  decoration: _customInputDeco(
                    label: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(hide ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => hide = !hide),
                    ),
                  ),
                  validator: (v) => v != null && v.length >= 6 ? null : 'Password minimal 6 karakter',
                ),
                const SizedBox(height: 16),

                // ── Ingat Saya & Lupa Kata Sandi ──
                Row(
                  children: [
                    SizedBox(
                      height: 24, width: 24,
                      child: Checkbox(
                        value: rememberMe,
                        onChanged: isLoading ? null : (v) => setState(() => rememberMe = v ?? false),
                        activeColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: isLoading ? null : () => setState(() => rememberMe = !rememberMe),
                      child: Text(
                        'Ingat Saya',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: AppTheme.primary,
                      ),
                      onPressed: isLoading ? null : _showForgotPasswordDialog,
                      child: const Text('Lupa Kata Sandi?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ── Tombol Masuk Sekarang ──
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: (isLoading || isGoogleLoading || isBiometricLoading) ? null : _handleLogin,
                  child: isLoading
                      ? const SizedBox(
                          height: 22, width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Masuk Sekarang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Divider ATAU MASUK DENGAN ──
          Row(
            children: [
              Expanded(child: Divider(color: Theme.of(context).dividerColor.withOpacity(0.15))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'ATAU MASUK DENGAN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Theme.of(context).dividerColor.withOpacity(0.15))),
            ],
          ),
          const SizedBox(height: 24),

          // ── Tombol Google & Biometrik ──
          Row(
            children: [
              // ── Tombol Google ──
              Expanded(
                child: _SocialButton(
                  onTap: (isLoading || isGoogleLoading || isBiometricLoading) ? null : _handleGoogleSignIn,
                  isLoading: isGoogleLoading,
                  icon: _GoogleIcon(),
                  label: 'Google',
                  tooltip: 'Masuk dengan Akun Google',
                ),
              ),
              const SizedBox(width: 16),
              // ── Tombol Biometrik ──
              Expanded(
                child: Tooltip(
                  message: _biometricTooltip,
                  child: _SocialButton(
                    onTap: (isLoading || isGoogleLoading || isBiometricLoading) ? null : _handleBiometricAuth,
                    isLoading: isBiometricLoading,
                    icon: Icon(
                      Icons.fingerprint_rounded,
                      color: _isBiometricEnabled ? Colors.blueAccent : Colors.grey,
                      size: 22,
                    ),
                    label: 'Biometrik',
                    tooltip: _biometricTooltip,
                    isDisabled: !_isBiometricEnabled,
                  ),
                ),
              ),
            ],
          ),

          // ── Keterangan biometrik belum aktif ──
          if (!_hasPreviousSession && _biometricStatus == BiometricStatus.available) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline_rounded, size: 13, color: Colors.grey.withOpacity(0.7)),
                const SizedBox(width: 6),
                Text(
                  'Login pertama diperlukan untuk mengaktifkan Biometrik',
                  style: TextStyle(fontSize: 11, color: Colors.grey.withOpacity(0.7)),
                ),
              ],
            ),
          ],

          const SizedBox(height: 24),

          // ── Daftar ──
          TextButton(
            onPressed: (isLoading || isGoogleLoading || isBiometricLoading)
                ? null
                : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).textTheme.bodyMedium?.color),
            child: RichText(
              text: TextSpan(
                text: 'Belum punya akun? ',
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: 'Daftar',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Info Demo ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Demo akun: demo@kampusgo.id / 123456',
                    style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Dengan masuk, Anda menyetujui Syarat & Ketentuan serta Kebijakan Privasi kami.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}

// ─── Widget Helper: Tombol Sosial ─────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;
  final Widget icon;
  final String label;
  final String tooltip;
  final bool isDisabled;

  const _SocialButton({
    required this.onTap,
    required this.isLoading,
    required this.icon,
    required this.label,
    required this.tooltip,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isDisabled
        ? Theme.of(context).dividerColor.withOpacity(0.08)
        : Theme.of(context).dividerColor.withOpacity(0.15);

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: effectiveColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: isDisabled ? Theme.of(context).dividerColor.withOpacity(0.03) : null,
        foregroundColor: isDisabled ? Colors.grey : null,
      ),
      onPressed: onTap,
      child: isLoading
          ? const SizedBox(
              height: 20, width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDisabled ? Colors.grey : null,
                  ),
                ),
              ],
            ),
    );
  }
}

// ─── Widget: Google "G" Icon ──────────────────────────────────────────────────

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lingkaran merah (representasi G)
          CustomPaint(size: const Size(20, 20), painter: _GoogleGPainter()),
        ],
      ),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Segmen warna Google
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
