import re
import os

# --- auth_service.dart ---
filepath = 'lib/services/auth_service.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    auth = f.read()

# import dart:convert
if 'import \'dart:convert\';' not in auth:
    auth = auth.replace("import 'package:flutter/services.dart';", "import 'dart:convert';\nimport 'package:flutter/services.dart';")

# add constant key
if '_keyUsersDb' not in auth:
    auth = auth.replace("static const _keyAuthMethod = 'kampusgo_auth_method';", "static const _keyAuthMethod = 'kampusgo_auth_method';\n  static const _keyUsersDb = 'kampusgo_users_db';")

# add methods
new_methods = """
  // ─── Manual Auth (Lokal) ──────────────────────────────────────────────────

  Future<void> registerManual(String name, String email, String password) async {
    final dbStr = await _storage.read(key: _keyUsersDb) ?? '{}';
    final db = jsonDecode(dbStr) as Map<String, dynamic>;
    if (db.containsKey(email)) {
      throw AuthException('Email sudah terdaftar. Silakan gunakan email lain atau masuk ke akun Anda.');
    }
    db[email] = {
      'name': name,
      'email': email,
      'password': password, // Untuk aplikasi nyata wajib di-hash, ini hanya demonstrasi lokal
    };
    await _storage.write(key: _keyUsersDb, value: jsonEncode(db));
    await saveManualSession(email: email, name: name);
  }

  Future<void> loginManual(String email, String password) async {
    final dbStr = await _storage.read(key: _keyUsersDb) ?? '{}';
    final db = jsonDecode(dbStr) as Map<String, dynamic>;
    if (!db.containsKey(email)) {
      throw AuthException('Akun tidak ditemukan. Periksa email Anda atau daftar terlebih dahulu.');
    }
    final userData = db[email] as Map<String, dynamic>;
    if (userData['password'] != password) {
      throw AuthException('Kata sandi yang Anda masukkan salah.');
    }
    await saveManualSession(email: email, name: userData['name'] as String);
  }
"""
if 'loginManual' not in auth:
    auth = auth.replace("  // ─── Session Management ───────────────────────────────────────────────────", new_methods + "\n  // ─── Session Management ───────────────────────────────────────────────────")

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(auth)


# --- login_screen.dart ---
filepath = 'lib/screens/login_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    login = f.read()

# remove default values
login = re.sub(r"final email = TextEditingController\(text:\s*'[^']+'\);", "final email = TextEditingController();", login)
login = re.sub(r"final password = TextEditingController\(text:\s*'[^']+'\);", "final password = TextEditingController();", login)

# update handleLogin
old_handleLogin = """  Future<void> _handleLogin() async {
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
  }"""

new_handleLogin = """  Future<void> _handleLogin() async {
    if (!formKey.currentState!.validate()) return;
    setState(() { isLoading = true; errorMessage = null; });

    try {
      final inputEmail = email.text.trim();
      final inputPassword = password.text;

      // Autentikasi ke database lokal Secure Storage
      await AuthService.instance.loginManual(inputEmail, inputPassword);

      if (!mounted) return;
      final savedName = await AuthService.instance.getSavedName();
      
      // Sinkronisasi memori global
      AppData.instance.updateProfile(name: savedName ?? 'Mahasiswa', email: inputEmail);
      
      // Refresh status biometrik
      await _checkBiometricAvailability();
      
      _showSnackBar('✅ Login berhasil! Selamat datang kembali.', Colors.teal);
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      
      _navigateToDashboard();
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('Terjadi kesalahan. Silakan coba lagi.');
    }
  }"""
if old_handleLogin in login:
    login = login.replace(old_handleLogin, new_handleLogin)

# remove info demo
demo_block_regex = r"          // ── Info Demo ──.*?SizedBox\(height:\s*32\.h\),"
login = re.sub(demo_block_regex, "          SizedBox(height: 8.h),", login, flags=re.DOTALL)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(login)


# --- register_screen.dart ---
filepath = 'lib/screens/register_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    register = f.read()

old_handleRegister = """    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // Simulasi proses pendaftaran dan penyimpanan ke sistem
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final inputName = name.text.trim();
    final inputEmail = email.text.trim();
    // Simpan data sesi aman secara lokal agar terhubung lancar dengan database/fitur login
    await AuthService.instance.saveManualSession(
      email: inputEmail,
      name: inputName,
    );
    // Sinkronisasi langsung ke memori global aplikasi secara reaktif
    AppData.instance.updateProfile(
      name: inputName.isEmpty ? 'Mahasiswa' : inputName,
      email: inputEmail,
    );

    _showSnackBar('🎉 Pendaftaran berhasil! Selamat datang di KAMPUSGO.', Colors.teal);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );"""

new_handleRegister = """    setState(() {
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
    }"""
if old_handleRegister in register:
    register = register.replace(old_handleRegister, new_handleRegister)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(register)

print("Done Refactoring!")
