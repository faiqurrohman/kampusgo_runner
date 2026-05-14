import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import '../services/app_data.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController(text: 'nama@gmail.com');
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
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (ctx) => _ForgotPasswordDialog(
        initialEmail: email.text,
        onSuccess: (sentEmail) {
          _showSnackBar(
            '✅ Tautan pemulihan dikirim ke $sentEmail',
            Colors.teal,
          );
        },
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

    final inputEmail = email.text.trim();
    // Mendukung login fleksibel dengan email pribadi apa pun yang terdaftar / berformat valid
    if (inputEmail.contains('@') && password.text.length >= 6) {
      final effectiveName = inputEmail == 'nama@gmail.com' ? 'Mahasiswa Demo' : inputEmail.split('@').first;
      // Simpan sesi aman setelah login berhasil
      await AuthService.instance.saveManualSession(
        email: inputEmail,
        name: effectiveName,
      );
      // Sinkronisasi memori global aplikasi secara reaktif
      AppData.instance.updateProfile(name: effectiveName, email: inputEmail);
      // Refresh status biometrik (kini tombol bisa aktif)
      await _checkBiometricAvailability();
      _navigateToDashboard();
    } else {
      _setError('Kredensial tidak sesuai. Periksa kembali format email dan password Anda.');
    }
  }

  // ─── Google Sign-In ───────────────────────────────────────────────────────
  Future<void> _handleGoogleSignIn() async {
    setState(() { isGoogleLoading = true; errorMessage = null; });

    try {
      final account = await AuthService.instance.signInWithGoogle();
      if (!mounted) return;
      if (account != null) {
        AppData.instance.updateProfile(
          name: account.displayName ?? account.email.split('@').first,
          email: account.email,
        );
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
        // Muat nama tersimpan ke memori aktif
        final savedName = await AuthService.instance.getSavedName();
        final savedEmail = await AuthService.instance.getSavedEmail();
        if (savedName != null) AppData.instance.updateProfile(name: savedName, email: savedEmail);

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
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.purpleAccent.withOpacity(0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.purpleAccent.withOpacity(0.4), blurRadius: 20, spreadRadius: 2),
                      BoxShadow(color: Colors.deepPurple.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo_mewah.png',
                      fit: BoxFit.cover,
                    ),
                  ),
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
                    'Demo akun: nama@gmail.com / 123456',
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

// ─── Widget: Forgot Password Dialog (Premium) ─────────────────────────────────

class _ForgotPasswordDialog extends StatefulWidget {
  final String initialEmail;
  final void Function(String email) onSuccess;

  const _ForgotPasswordDialog({
    required this.initialEmail,
    required this.onSuccess,
  });

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog>
    with TickerProviderStateMixin {
  late final TextEditingController _emailCtrl;
  late final TextEditingController _captchaCtrl;

  // UI state
  String? _emailError;
  String? _captchaError;
  bool _isSending = false;
  bool _isSuccess = false;

  // Cooldown timer
  int _cooldownSeconds = 0;
  bool get _isCoolingDown => _cooldownSeconds > 0;

  // CAPTCHA
  late int _captchaA;
  late int _captchaB;

  // Animations
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final AnimationController _successCtrl;
  late final Animation<double> _successAnim;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.initialEmail);
    _captchaCtrl = TextEditingController();
    _generateCaptcha();

    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _successCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _successAnim = CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _captchaCtrl.dispose();
    _fadeCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  void _generateCaptcha() {
    _captchaA = 2 + DateTime.now().millisecond % 8; // 2–9
    _captchaB = 1 + DateTime.now().microsecond % 7; // 1–7
  }

  // ── Real-time email validation ──
  String? _validateEmail(String v) {
    if (v.trim().isEmpty) return 'Email tidak boleh kosong';
    final re = RegExp(r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$', caseSensitive: false);
    if (!re.hasMatch(v.trim())) return 'Format email tidak valid (misal: user@domain.com)';
    return null;
  }

  // ── Cooldown logic ──
  void _startCooldown() {
    _cooldownSeconds = 60;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _cooldownSeconds--);
      return _cooldownSeconds > 0;
    });
  }

  // ── Submit handler ──
  Future<void> _handleSend() async {
    final emailErr = _validateEmail(_emailCtrl.text);
    final userAnswer = int.tryParse(_captchaCtrl.text.trim());
    final captchaErr = (userAnswer == null || userAnswer != _captchaA + _captchaB)
        ? 'Jawaban verifikasi tidak tepat'
        : null;

    setState(() {
      _emailError = emailErr;
      _captchaError = captchaErr;
    });

    if (emailErr != null || captchaErr != null) return;

    setState(() => _isSending = true);

    // Simulasi API call (ganti dengan Firebase / custom API)
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    setState(() {
      _isSending = false;
      _isSuccess = true;
    });
    _successCtrl.forward();
    _startCooldown();
    widget.onSuccess(_emailCtrl.text.trim());
  }

  // ── Resend ──
  Future<void> _handleResend() async {
    if (_isCoolingDown || _isSending) return;
    setState(() {
      _isSuccess = false;
      _captchaCtrl.clear();
      _generateCaptcha();
      _captchaError = null;
      _emailError = null;
    });
    _successCtrl.reset();
    await _handleSend();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E1E2E).withOpacity(0.96),
                  const Color(0xFF252540).withOpacity(0.96),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.purpleAccent.withOpacity(0.25),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purpleAccent.withOpacity(0.15),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _isSuccess ? _buildSuccessView() : _buildInputView(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── SUCCESS VIEW ──────────────────────────────────────────────────────────
  Widget _buildSuccessView() {
    return ScaleTransition(
      scale: _successAnim,
      key: const ValueKey('success'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon sukses
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.teal.withOpacity(0.15),
              border: Border.all(color: Colors.teal.withOpacity(0.4), width: 1.5),
            ),
            child: const Icon(Icons.mark_email_read_rounded, color: Colors.tealAccent, size: 36),
          ),
          const SizedBox(height: 20),
          const Text(
            'Email Terkirim! 🎉',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Tautan pemulihan telah dikirim ke:\n${_emailCtrl.text.trim()}\n\nSilakan cek kotak masuk atau folder spam Anda.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.75),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Cooldown / Resend button
          _isCoolingDown
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Kirim ulang dalam $_cooldownSeconds detik',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.purpleAccent,
                      side: BorderSide(color: Colors.purpleAccent.withOpacity(0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: _handleResend,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Kirim Ulang', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),

          const SizedBox(height: 12),

          // Tutup
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C5CFC),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 13),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),

          const SizedBox(height: 20),

          // Bantuan alternatif
          _buildContactAdminLink(),
        ],
      ),
    );
  }

  // ── INPUT VIEW ────────────────────────────────────────────────────────────
  Widget _buildInputView() {
    return Column(
      key: const ValueKey('input'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purpleAccent.withOpacity(0.15),
                border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
              ),
              child: const Icon(Icons.lock_reset_rounded, color: Colors.purpleAccent, size: 20),
            ),
            const SizedBox(width: 14),
            const Text(
              'Lupa Kata Sandi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        Text(
          'Masukkan alamat email terdaftar untuk menerima instruksi tautan pemulihan kata sandi.',
          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.65), height: 1.5),
        ),
        const SizedBox(height: 22),

        // ── Email field ──
        _buildLabel('Alamat Email'),
        const SizedBox(height: 8),
        _GlassTextField(
          controller: _emailCtrl,
          hintText: 'contoh@kampusgo.id',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          errorText: _emailError,
          onChanged: (v) {
            if (_emailError != null) {
              setState(() => _emailError = _validateEmail(v));
            }
          },
        ),

        // Error email
        if (_emailError != null) _buildErrorText(_emailError!),

        const SizedBox(height: 20),

        // ── CAPTCHA ──
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.purpleAccent.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.security_rounded, size: 14, color: Colors.purpleAccent),
                  const SizedBox(width: 6),
                  Text(
                    'Verifikasi Keamanan',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.55),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Soal
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.purpleAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purpleAccent.withOpacity(0.25)),
                      ),
                      child: Text(
                        '$_captchaA + $_captchaB = ?',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.purpleAccent,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Jawaban
                  Expanded(
                    child: _GlassTextField(
                      controller: _captchaCtrl,
                      hintText: 'Jawaban',
                      keyboardType: TextInputType.number,
                      errorText: _captchaError,
                      onChanged: (v) {
                        if (_captchaError != null) setState(() => _captchaError = null);
                      },
                    ),
                  ),
                ],
              ),
              if (_captchaError != null) _buildErrorText(_captchaError!),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Action buttons ──
        Row(
          children: [
            // Batal
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withOpacity(0.55),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                onPressed: _isSending ? null : () => Navigator.pop(context),
                child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            // Kirim Tautan
            Expanded(
              flex: 2,
              child: _AnimatedSendButton(
                isLoading: _isSending,
                isCoolingDown: _isCoolingDown,
                cooldownSeconds: _cooldownSeconds,
                onPressed: (_isSending || _isCoolingDown) ? null : _handleSend,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ── Bantuan alternatif ──
        _buildContactAdminLink(),
      ],
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.6),
          letterSpacing: 0.5,
        ),
      );

  Widget _buildErrorText(String text) => Padding(
        padding: const EdgeInsets.only(top: 6, left: 4),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, size: 13, color: Colors.redAccent),
            const SizedBox(width: 5),
            Text(text, style: const TextStyle(fontSize: 12, color: Colors.redAccent)),
          ],
        ),
      );

  Widget _buildContactAdminLink() => Center(
        child: TextButton.icon(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: Colors.purpleAccent.withOpacity(0.75),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: Size.zero,
          ),
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Hubungi Admin Kampus: admin@kampusgo.id'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.blueGrey.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                action: SnackBarAction(
                  label: 'Salin',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          },
          icon: const Icon(Icons.help_outline_rounded, size: 14),
          label: const Text(
            'Tidak punya akses ke email ini? Hubungi Admin Kampus',
            style: TextStyle(fontSize: 12, decoration: TextDecoration.underline),
          ),
        ),
      );
}

// ─── Helper: Glass Text Field ──────────────────────────────────────────────────

class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final String? errorText;
  final void Function(String)? onChanged;

  const _GlassTextField({
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: Colors.purpleAccent.withOpacity(0.7), size: 20)
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: hasError ? Colors.redAccent.withOpacity(0.6) : Colors.white.withOpacity(0.12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: hasError ? Colors.redAccent : Colors.purpleAccent,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

// ─── Helper: Animated Send Button ─────────────────────────────────────────────

class _AnimatedSendButton extends StatelessWidget {
  final bool isLoading;
  final bool isCoolingDown;
  final int cooldownSeconds;
  final VoidCallback? onPressed;

  const _AnimatedSendButton({
    required this.isLoading,
    required this.isCoolingDown,
    required this.cooldownSeconds,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: onPressed != null
            ? const LinearGradient(
                colors: [Color(0xFF7C5CFC), Color(0xFF5B8DEF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: onPressed == null ? Colors.grey.withOpacity(0.25) : null,
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: const Color(0xFF7C5CFC).withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          isCoolingDown ? 'Tunggu ${cooldownSeconds}d' : 'Kirim Tautan',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
