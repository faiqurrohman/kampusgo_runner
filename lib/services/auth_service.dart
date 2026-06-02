import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  static const _keySavedAccounts = 'kampusgo_saved_accounts';
  static const _keyUsersDb = 'kampusgo_users_db'; 


  // ─── Manual Auth (Lokal) ──────────────────────────────────────────────────

  Future<void> registerManual(String name, String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Update display name
      await userCredential.user?.updateDisplayName(name);
      await saveManualSession(email: email, name: name);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AuthException('Kata sandi terlalu lemah.');
      } else if (e.code == 'email-already-in-use') {
        throw AuthException('Email sudah terdaftar. Silakan gunakan email lain atau masuk ke akun Anda.');
      } else {
        throw AuthException('Terjadi kesalahan: ${e.message}');
      }
    } catch (e) {
      throw AuthException('Terjadi kesalahan: $e');
    }
  }

  Future<void> loginManual(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      String name = userCredential.user?.displayName ?? 'Pengguna';
      await saveManualSession(email: email, name: name);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-email' || e.code == 'invalid-credential') {
        throw AuthException('Akun tidak ditemukan. Periksa email Anda atau daftar terlebih dahulu.');
      } else if (e.code == 'wrong-password') {
        throw AuthException('Kata sandi yang Anda masukkan salah.');
      } else {
        throw AuthException('Terjadi kesalahan: ${e.message}');
      }
    } catch (e) {
      throw AuthException('Terjadi kesalahan: $e');
    }
  }

  // ─── Session Management ───────────────────────────────────────────────────

  /// Cek apakah ada sesi login tersimpan
  Future<bool> isLoggedIn() async {
    return FirebaseAuth.instance.currentUser != null;
  }

  /// Simpan sesi login manual (email/password).
  Future<void> saveManualSession({required String email, required String name}) async {
    await _storage.write(key: _keyLoggedIn, value: 'true');
    await _storage.write(key: _keyUserEmail, value: email);
    await _storage.write(key: _keyUserName, value: name);

    // Add to saved accounts list
    final accountsStr = await _storage.read(key: _keySavedAccounts);
    List<dynamic> accounts = [];
    if (accountsStr != null) {
      accounts = jsonDecode(accountsStr);
    }
    
    // Remove if already exists so we can update/move to top
    accounts.removeWhere((acc) => acc['email'] == email);
    accounts.insert(0, {'email': email, 'name': name});
    
    await _storage.write(key: _keySavedAccounts, value: jsonEncode(accounts));
  }


  Future<List<Map<String, String>>> getSavedAccounts() async {
    final accountsStr = await _storage.read(key: _keySavedAccounts);
    if (accountsStr == null) return [];
    final List<dynamic> dec = jsonDecode(accountsStr);
    return dec.map((e) => {'email': e['email'].toString(), 'name': e['name'].toString()}).toList();
  }

  Future<void> switchAccount(String email, String name) async {
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
    await FirebaseAuth.instance.signOut();
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
