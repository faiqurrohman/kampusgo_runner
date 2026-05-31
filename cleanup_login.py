import re

filepath = 'lib/screens/login_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Remove _checkBiometricAvailability function entirely
content = re.sub(r"\s+/// Memeriksa dukungan biometrik dan sesi sebelumnya saat screen dibuka\.\n\s+Future<void> _checkBiometricAvailability\(\) async \{[\s\S]*?\}\n", "", content)

# 2. Remove the dangling `await` from handleLogin
content = re.sub(r"\s+// Refresh status biometrik\n\s+await\n", "", content)

# 3. Remove _handleGoogleSignIn function entirely
content = re.sub(r"\s+// ─── Google Sign-In ───+[\s\S]*?_setError\('Gagal terhubung ke layanan Google\. Coba lagi\.'\);\n\s+\}\n\s+\}\n", "", content)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print("login_screen cleanup done.")
