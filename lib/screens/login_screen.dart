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
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
        child: Container(
          padding: const EdgeInsets.all(20), 
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface, 
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)), 
            borderRadius: BorderRadius.circular(24),
          ), 
          child: Row(children: [
            const Icon(Icons.info_outline_rounded, color: Colors.grey), 
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Demo login: demo@kampusgo.id / 123456', 
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ])
        ),
      ),
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24), 
        children: [
          const SizedBox(height: 60),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.school_rounded, color: Colors.white, size: 36),
                  const SizedBox(width: 16),
                  const Text(
                    'KAMPUSGO', 
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                  ),
                ],
              ),
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
                  decoration: _customInputDeco(label: 'Email', prefixIcon: const Icon(Icons.email_outlined)), 
                  validator: (v) => v != null && v.contains('@') ? null : 'Alamat email tidak valid',
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: password, 
                  obscureText: hide, 
                  enabled: !isLoading,
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
        ],
      ),
    ),
  );
}
