import re

# --- pubspec.yaml ---
filepath = 'pubspec.yaml'
with open(filepath, 'r', encoding='utf-8') as f:
    pubspec = f.read()

pubspec = re.sub(r"\s+google_sign_in: [^\n]+", "", pubspec)
pubspec = re.sub(r"\s+local_auth: [^\n]+", "", pubspec)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(pubspec)

# --- auth_service.dart ---
filepath = 'lib/services/auth_service.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    auth = f.read()

auth = re.sub(r"import 'package:google_sign_in/google_sign_in\.dart';\n", "", auth)
auth = re.sub(r"import 'package:local_auth/local_auth\.dart';\n", "", auth)

# Remove Google Sign-In init
auth = re.sub(r"\s+// ─── Google Sign-In ───+.*?final GoogleSignIn _googleSignIn = GoogleSignIn\([\s\S]*?\);", "", auth)

# Remove Local Auth init
auth = re.sub(r"\s+// ─── Local Auth \(Biometrik\) ───+.*?final LocalAuthentication _localAuth = LocalAuthentication\(\);", "", auth)

# Remove old google sign in method block if any
auth = re.sub(r"\s+// ─── Google Sign-In ───+.*?Future<AppAccount\?> signInWithGoogle\(\) async \{[\s\S]*?\}", "", auth)
auth = re.sub(r"\s+Future<void> signOutGoogle\(\) async \{[\s\S]*?\}", "", auth)

# Remove Biometric methods
auth = re.sub(r"\s+// ─── Biometric Auth ───+.*?Future<BiometricStatus> checkBiometricStatus\(\) async \{[\s\S]*?\}", "", auth)
auth = re.sub(r"\s+Future<bool> hasPreviousSession\(\) async \{[\s\S]*?\}", "", auth)
auth = re.sub(r"\s+Future<bool> authenticateWithBiometric\(\) async \{[\s\S]*?\}", "", auth)

# Update signOut
old_signout = """  Future<void> signOut() async {
    final method = await getAuthMethod();
    if (method == 'google') {
      await _googleSignIn.signOut().catchError((e) {
        // Abaikan error sign-out Google, tetap bersihkan sesi lokal
        return null;
      });
    }
    await _clearSession();
  }"""
new_signout = """  Future<void> signOut() async {
    await _clearSession();
  }"""
auth = auth.replace(old_signout, new_signout)

# Update saveManualSession (remove authMethod)
auth = re.sub(r"await _storage\.write\(key: _keyAuthMethod, value: 'manual'\);", "", auth)
auth = re.sub(r"await _storage\.write\(key: _keyAuthMethod, value: 'google'\);", "", auth)

# Remove getAuthMethod
auth = re.sub(r"\s+/// Membaca metode autentikasi terakhir\.\n\s+Future<String\?> getAuthMethod\(\) => _storage\.read\(key: _keyAuthMethod\);", "", auth)

# Remove clear auth method
auth = re.sub(r"\s+await _storage\.delete\(key: _keyAuthMethod\);", "", auth)

# Remove BiometricStatus Enum
auth = re.sub(r"\s+enum BiometricStatus \{[\s\S]*?\}", "", auth)

# Remove AppAccount
auth = re.sub(r"class AppAccount \{[\s\S]*?\}", "", auth)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(auth)


# --- login_screen.dart ---
filepath = 'lib/screens/login_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    login = f.read()

# remove variables
login = re.sub(r"\s+bool isGoogleLoading = false;\n\s+bool isBiometricLoading = false;", "", login)
login = re.sub(r"\s+// Status biometrik — diperiksa saat init\n\s+BiometricStatus _biometricStatus = BiometricStatus\.deviceNotSupported;\n\s+bool _hasPreviousSession = false;", "", login)
login = re.sub(r"\s+_checkBiometricAvailability\(\);", "", login)

# remove methods
login = re.sub(r"\s+/// Memeriksa dukungan biometrik[\s\S]*?_hasPreviousSession = hasSession;\n\s+\}\n\s+\}", "", login)
login = re.sub(r"\s+/// Apakah tombol biometrik aktif:[\s\S]*?=>\n\s+_biometricStatus == BiometricStatus\.available && _hasPreviousSession;", "", login)
login = re.sub(r"\s+/// Teks tooltip tombol biometrik[\s\S]*?return 'Masuk dengan sidik jari atau wajah';\n\s+\}", "", login)

login = login.replace("isLoading = false;\n      isGoogleLoading = false;\n      isBiometricLoading = false;", "isLoading = false;")

# remove checkBiometric from handleLogin
login = re.sub(r"\s+// Refresh status biometrik\n\s+await _checkBiometricAvailability\(\);", "", login)

# remove handleGoogleSignIn
login = re.sub(r"\s+// ─── Google Sign-In ───+[\s\S]*?\} catch \(_\) \{\n\s+_setError\('Terjadi kesalahan tak terduga saat login Google\.'\);\n\s+\}\n\s+\}", "", login)

# remove handleBiometricAuth
login = re.sub(r"\s+// ─── Biometric Auth ───+[\s\S]*?_setError\('Autentikasi biometrik gagal\. Coba lagi\.'\);\n\s+\}\n\s+\}", "", login)

# remove (isLoading || isGoogleLoading || isBiometricLoading)
login = login.replace("(isLoading || isGoogleLoading || isBiometricLoading)", "isLoading")

# remove UI block (ATAU MASUK DENGAN until before Daftar)
ui_block = r"\s+// ── Divider ATAU MASUK DENGAN ──[\s\S]*?// ── Daftar ──"
login = re.sub(ui_block, "\n          // ── Daftar ──", login)

# remove SocialButton, GoogleIcon, GoogleGPainter widgets at the end
login = re.sub(r"// ─── Widget Helper: Tombol Sosial ───+[\s\S]*?(?=// ─── Widget: Forgot Password Dialog \(Premium\) ───+)", "", login)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(login)


# --- register_screen.dart ---
filepath = 'lib/screens/register_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    register = f.read()

register = re.sub(r"\s+bool isGoogleLoading = false;", "", register)

register = register.replace("isLoading = false;\n      isGoogleLoading = false;", "isLoading = false;")

# remove handleGoogleSignUp
register = re.sub(r"\s+// ─── Pendaftaran OAuth Google ───+[\s\S]*?_setError\('Pendaftaran via Google gagal\. Silakan coba metode manual\.'\);\n\s+\}\n\s+\}", "", register)

# remove handleSsoSignUp
register = re.sub(r"\s+// ─── Pendaftaran SSO Kampus ───+[\s\S]*?child: Text\('Lanjutkan Autentikasi', style: TextStyle\(fontWeight: FontWeight\.bold\)\),\n\s+\),\n\s+\],\n\s+\),\n\s+\);\n\s+\}", "", register)

register = register.replace("(isLoading || isGoogleLoading)", "isLoading")

# remove Alternative Registration UI
ui_block = r"\s+// ─── Alternatif Pendaftaran \(SSO/OAuth\) ───[\s\S]*?SizedBox\(height: 24\.h\),"
register = re.sub(ui_block, "", register)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(register)

print("Features removed successfully.")
