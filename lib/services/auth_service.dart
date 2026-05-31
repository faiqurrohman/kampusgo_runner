import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// AuthService: Mengelola semua alur autentikasi KAMPUSGO
/// - Google Sign-In
/// - Biometric (Fingerprint / Face ID)
/// - Secure Token Storage
class AuthService {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  // ─── Google Sign-In ───────────────────────────────────────────────────────
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // ─── Local Auth (Biometrik) ───────────────────────────────────────────────
  final LocalAuthentication _localAuth = LocalAuthentication();

  // ─── Secure Storage ───────────────────────────────────────────────────────
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Storage keys
  static const _keyLoggedIn = 'kampusgo_is_logged_in';
  static const _keyUserEmail = 'kampusgo_user_email';
  static const _keyUserName = 'kampusgo_user_name';
  static const _keyAuthMethod = 'kampusgo_auth_method';
  static const _keyUsersDb = 'kampusgo_users_db'; // 'google' | 'manual'

  // ─── Google Sign-In ───────────────────────────────────────────────────────

  /// Memulai alur Google Sign-In.
  /// Mengembalikan [GoogleSignInAccount] jika berhasil, atau null jika dibatalkan.
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        // Simpan token/sesi aman ke secure storage
        await _storage.write(key: _keyLoggedIn, value: 'true');
        await _storage.write(key: _keyUserEmail, value: account.email);
        await _storage.write(key: _keyUserName, value: account.displayName ?? '');
        await _storage.write(key: _keyAuthMethod, value: 'google');
      }
      return account;
    } on PlatformException catch (e) {
      // Kode error spesifik Google Sign-In
      if (e.code == 'network_error') {
        throw AuthException('Tidak ada koneksi internet. Periksa jaringan Anda.');
      }
      throw AuthException('Login Google gagal: ${e.message}');
    } catch (_) {
      throw AuthException('Terjadi kesalahan tak terduga saat login Google.');
    }
  }

  /// Keluar dari akun Google.
  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
    await _clearSession();
  }

  // ─── Biometric Auth ───────────────────────────────────────────────────────

  /// Memeriksa apakah perangkat mendukung dan memiliki biometrik terdaftar.
  Future<BiometricStatus> checkBiometricStatus() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!isDeviceSupported) return BiometricStatus.deviceNotSupported;
      if (!isAvailable) return BiometricStatus.notEnrolled;

      final biometrics = await _localAuth.getAvailableBiometrics();
      if (biometrics.isEmpty) return BiometricStatus.notEnrolled;

      return BiometricStatus.available;
    } on PlatformException {
      return BiometricStatus.deviceNotSupported;
    }
  }

  /// Memeriksa apakah user sudah pernah login sebelumnya (untuk mengaktifkan biometrik).
  Future<bool> hasPreviousSession() async {
    final val = await _storage.read(key: _keyLoggedIn);
    return val == 'true';
  }

  /// Menjalankan autentikasi biometrik (sidik jari / wajah).
  /// Hanya bisa digunakan jika [hasPreviousSession()] == true.
  Future<bool> authenticateWithBiometric() async {
    try {
      final status = await checkBiometricStatus();
      if (status != BiometricStatus.available) return false;

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Gunakan sidik jari atau wajah untuk masuk ke KAMPUSGO',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return authenticated;
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable' || e.code == 'NotEnrolled') {
        throw AuthException('Biometrik tidak tersedia di perangkat ini.');
      }
      throw AuthException('Autentikasi biometrik gagal: ${e.message}');
    }
  }


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

  // ─── Session Management ───────────────────────────────────────────────────

  /// Simpan sesi login manual (email/password).
  Future<void> saveManualSession({required String email, required String name}) async {
    await _storage.write(key: _keyLoggedIn, value: 'true');
    await _storage.write(key: _keyUserEmail, value: email);
    await _storage.write(key: _keyUserName, value: name);
    await _storage.write(key: _keyAuthMethod, value: 'manual');
  }

  /// Membaca email user yang tersimpan.
  Future<String?> getSavedEmail() => _storage.read(key: _keyUserEmail);

  /// Membaca nama user yang tersimpan.
  Future<String?> getSavedName() => _storage.read(key: _keyUserName);

  /// Membaca metode autentikasi terakhir.
  Future<String?> getAuthMethod() => _storage.read(key: _keyAuthMethod);

  /// Menghapus seluruh sesi (logout).
  Future<void> _clearSession() async {
    await _storage.delete(key: _keyLoggedIn);
    await _storage.delete(key: _keyUserEmail);
    await _storage.delete(key: _keyUserName);
    await _storage.delete(key: _keyAuthMethod);
  }

  Future<void> signOut() async {
    final method = await getAuthMethod();
    if (method == 'google') {
      await _googleSignIn.signOut().catchError((e) {
        // Abaikan error sign-out Google, tetap bersihkan sesi lokal
      });
    }
    await _clearSession();
  }
}

// ─── Models & Exceptions ──────────────────────────────────────────────────────

enum BiometricStatus {
  available,
  notEnrolled,
  deviceNotSupported,
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}
