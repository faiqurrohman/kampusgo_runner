import re

with open('lib/services/auth_service.dart', 'r', encoding='utf-8') as f:
    content = f.read()

if "import 'dart:convert';" not in content:
    content = content.replace("import 'package:flutter_secure_storage/flutter_secure_storage.dart';", "import 'dart:convert';\nimport 'package:flutter_secure_storage/flutter_secure_storage.dart';")

if "const _keySavedAccounts = 'kampusgo_saved_accounts';" not in content:
    content = content.replace("  const _keyUserName = 'kampusgo_user_name';", "  const _keyUserName = 'kampusgo_user_name';\n  const _keySavedAccounts = 'kampusgo_saved_accounts';")

# Replace saveManualSession
save_manual = """
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
"""

content = re.sub(r"  /// Simpan sesi login manual \(email/password\)\.\n  Future<void> saveManualSession\(\{required String email, required String name\}\) async \{[\s\S]*?\}", save_manual.strip('\n'), content)

# Add new methods for Switch Account
switch_account = """
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
"""

if "Future<List<Map<String, String>>> getSavedAccounts()" not in content:
    content = content.replace("  /// Membaca email user yang tersimpan.", switch_account + "\n  /// Membaca email user yang tersimpan.")

with open('lib/services/auth_service.dart', 'w', encoding='utf-8') as f:
    f.write(content)
