import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// AuthService: Mengelola semua alur autentikasi KAMPUSGO
/// - Manual (Email/Password)
/// - Secure Token Storage
class AuthService {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  // ─── Secure Storage ───────────────────────────────────────────────────────
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Storage keys
  static const _keyLoggedIn = 'kampusgo_is_logged_in';
  static const _keyUserEmail = 'kampusgo_user_email';
  static const _keyUserName = 'kampusgo_user_name';
  static const _keyUsersDb = 'kampusgo_users_db'; 


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

  /// Cek apakah ada sesi login tersimpan
  Future<bool> isLoggedIn() async {
    final val = await _storage.read(key: _keyLoggedIn);
    return val == 'true';
  }

  /// Simpan sesi login manual (email/password).
  Future<void> saveManualSession({required String email, required String name}) async {
    await _storage.write(key: _keyLoggedIn, value: 'true');
    await _storage.write(key: _keyUserEmail, value: email);
    await _storage.write(key: _keyUserName, value: name);
  }

  /// Membaca email user yang tersimpan.
  Future<String?> getSavedEmail() => _storage.read(key: _keyUserEmail);

  /// Membaca nama user yang tersimpan.
  Future<String?> getSavedName() => _storage.read(key: _keyUserName);

  /// Menghapus seluruh sesi (logout).
  Future<void> _clearSession() async {
    await _storage.delete(key: _keyLoggedIn);
    await _storage.delete(key: _keyUserEmail);
    await _storage.delete(key: _keyUserName);
  }

  Future<void> signOut() async {
    await _clearSession();
  }
}

// ─── Models & Exceptions ──────────────────────────────────────────────────────

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}
