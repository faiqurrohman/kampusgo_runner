import re

# --- auth_service.dart ---
filepath = 'lib/services/auth_service.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    auth = f.read()

# Add AppAccount model at the end
if 'class AppAccount' not in auth:
    auth += """
class AppAccount {
  final String email;
  final String? displayName;
  AppAccount({required this.email, this.displayName});
}
"""

old_google_signin = """  /// Memulai alur Google Sign-In.
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
  }"""

new_google_signin = """  /// Memulai alur Google Sign-In.
  /// Di-mock untuk bypass ApiException 10 karena Firebase belum dikonfigurasi.
  Future<AppAccount?> signInWithGoogle() async {
    try {
      // Simulasi delay jaringan Google
      await Future.delayed(const Duration(milliseconds: 1500));
      
      final mockEmail = 'mhs.google@kampusgo.com';
      final mockName = 'Google Student';

      // Simpan token/sesi aman ke secure storage
      await _storage.write(key: _keyLoggedIn, value: 'true');
      await _storage.write(key: _keyUserEmail, value: mockEmail);
      await _storage.write(key: _keyUserName, value: mockName);
      await _storage.write(key: _keyAuthMethod, value: 'google');
      
      return AppAccount(email: mockEmail, displayName: mockName);
    } catch (_) {
      throw AuthException('Terjadi kesalahan tak terduga saat login Google.');
    }
  }"""

if old_google_signin in auth:
    auth = auth.replace(old_google_signin, new_google_signin)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(auth)

print("Google Sign In mocked successfully.")
