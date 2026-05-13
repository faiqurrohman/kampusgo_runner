import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';
import '../utils/app_theme.dart';

class LoginScreen extends StatefulWidget { 
  const LoginScreen({super.key}); 
  @override 
  State<LoginScreen> createState() => _LoginScreenState(); 
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController(text: 'demo@kampusgo.id');
  final password = TextEditingController(text: '123456');
  bool hide = true;
  bool rememberMe = true; // Keamanan & Aksesibilitas: Ingat Saya
  bool isLoading = false; // Status Loading saat autentikasi berjalan
  String? errorMessage; // Pesan Kesalahan (Error Handling)

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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Instruksi pemulihan berhasil dikirim ke ${resetCtrl.text}'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.teal,
                ),
              );
            },
            child: const Text('Kirim Tautan', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    // 1. Memicu Validasi visual (garis tepi otomatis merah jika salah)
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // Simulasi jeda autentikasi / proses verifikasi server
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Verifikasi kredensial demo
    if (email.text.trim() == 'demo@kampusgo.id' && password.text == '123456') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    } else {
      setState(() {
        isLoading = false;
        errorMessage = 'Kredensial tidak sesuai. Periksa kembali penulisan email dan password Anda.';
      });
    }
  }

  InputDecoration _customInputDeco({required String label, required Widget prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      // Desain mempertimbangkan garis tepi kolom berubah menjadi merah jika email/password salah
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

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        children: [
          const SizedBox(height: 40),
          // Logotype Premium KAMPUSGO tanpa kotak blok ungu (No Background + Glow)
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sentuhan Ikonik yang Minimalis: outline icon dengan efek soft outer glow
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
                // Tipografi Custom Logotype (Bold untuk KAMPUS, Light/Thin untuk GO) dengan Shader Gradient & Soft Glow
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(color: Colors.purple.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'KAMPUS',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: 'GO',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w200,
                              letterSpacing: 1.0,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Masuk ke KAMPUSGO', 
            style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 32),
          ),
          const SizedBox(height: 12), 
          Text(
            'Kelola jadwal, uang saku, IPK, dan link kuliahmu dengan lebih cerdas.', 
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 36),

          // Feedback Visual: Banner Pesan Kesalahan jika login tidak valid
          if (errorMessage != null) ...[
            Container(
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
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          Form(
            key: formKey, 
            child: Column(
              children: [
                TextFormField(
                  controller: email, 
                  enabled: !isLoading,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: _customInputDeco(label: 'Email', prefixIcon: const Icon(Icons.email_outlined)), 
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
                // Elemen Keamanan & Aksesibilitas: Ingat Saya dan Lupa Kata Sandi
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
                
                // Status Loading: Tampilan tombol saat proses autentikasi berjalan
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: isLoading ? null : _handleLogin, 
                  child: isLoading 
                      ? const SizedBox(
                          height: 24, width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Masuk Sekarang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Opsi Login Alternatif: Google & Biometrik
          Row(
            children: [
              Expanded(child: Divider(color: Theme.of(context).dividerColor.withOpacity(0.1))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'ATAU MASUK DENGAN',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5)),
                ),
              ),
              Expanded(child: Divider(color: Theme.of(context).dividerColor.withOpacity(0.1))),
            ],
          ),
          const SizedBox(height: 24),
          // Baris tombol Google & Biometrik
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.15)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: isLoading ? null : () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('🔑 Berhasil masuk cepat dengan Akun Google'), behavior: SnackBarBehavior.floating, backgroundColor: Colors.teal),
                    );
                  },
                  icon: const Icon(Icons.g_mobiledata_rounded, color: Colors.redAccent, size: 28),
                  label: const Text('Google', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.15)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: isLoading ? null : () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Sensor biometrik wajah/sidik jari terverifikasi'), behavior: SnackBarBehavior.floating, backgroundColor: Colors.teal),
                    );
                  },
                  icon: const Icon(Icons.fingerprint_rounded, color: Colors.blueAccent, size: 20),
                  label: const Text('Biometrik', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: isLoading ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())), 
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
          // Demo info dipindahkan menjadi kotak kecil yang efisien untuk mode produksi
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
          // Aspek Legalitas: Ketentuan Layanan
          Text(
            'Dengan masuk, Anda menyetujui Syarat & Ketentuan serta Kebijakan Privasi kami.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6), height: 1.4),
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}
