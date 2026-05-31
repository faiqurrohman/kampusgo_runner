import re

# 1. Update app_data.dart
with open('lib/services/app_data.dart', 'r', encoding='utf-8') as f:
    app_data = f.read()

# Replace save methods
app_data = app_data.replace("prefs.setString('schedules_data'", "prefs.setString('${userEmail}_schedules_data'")
app_data = app_data.replace("prefs.setString('expenses_data'", "prefs.setString('${userEmail}_expenses_data'")
app_data = app_data.replace("prefs.setString('gpas_data'", "prefs.setString('${userEmail}_gpas_data'")
app_data = app_data.replace("prefs.setString('resources_data'", "prefs.setString('${userEmail}_resources_data'")

# Remove data loading from init()
app_data = re.sub(r"    final schedulesData = prefs.getString\('schedules_data'\);[\s\S]*?    final resourcesData = prefs.getString\('resources_data'\);\n    if \(resourcesData != null\) \{\n      final List dec = jsonDecode\(resourcesData\);\n      resources.clear\(\);\n      resources.addAll\(dec.map\(\(e\) => ResourceModel.fromJson\((e)\)\).toList\(\)\);\n    \}\n", "", app_data)

# Add loadUserData and clearUserData
extra_methods = """
  Future<void> loadUserData(String email) async {
    userEmail = email;
    final prefs = await SharedPreferences.getInstance();

    final schedulesData = prefs.getString('${userEmail}_schedules_data');
    schedules.clear();
    if (schedulesData != null) {
      final List dec = jsonDecode(schedulesData);
      schedules.addAll(dec.map((e) => ScheduleModel.fromJson(e)).toList());
    }

    final expensesData = prefs.getString('${userEmail}_expenses_data');
    expenses.clear();
    if (expensesData != null) {
      final List dec = jsonDecode(expensesData);
      expenses.addAll(dec.map((e) => ExpenseModel.fromJson(e)).toList());
    }

    final gpasData = prefs.getString('${userEmail}_gpas_data');
    gpaItems.clear();
    if (gpasData != null) {
      final List dec = jsonDecode(gpasData);
      gpaItems.addAll(dec.map((e) => GpaModel.fromJson(e)).toList());
    }

    final resourcesData = prefs.getString('${userEmail}_resources_data');
    resources.clear();
    if (resourcesData != null) {
      final List dec = jsonDecode(resourcesData);
      resources.addAll(dec.map((e) => ResourceModel.fromJson(e)).toList());
    }
    notifyListeners();
  }

  void clearUserData() {
    schedules.clear();
    expenses.clear();
    gpaItems.clear();
    resources.clear();
    userEmail = '';
    userName = '';
    notifyListeners();
  }
"""
app_data = app_data.replace("  final List<ScheduleModel> schedules = [];", extra_methods + "\n  final List<ScheduleModel> schedules = [];")

with open('lib/services/app_data.dart', 'w', encoding='utf-8') as f:
    f.write(app_data)

# 2. Update splash_screen.dart
with open('lib/screens/splash_screen.dart', 'r', encoding='utf-8') as f:
    splash = f.read()

splash = splash.replace("import '../services/auth_service.dart';", "import '../services/auth_service.dart';\nimport '../services/app_data.dart';")
splash = splash.replace("    if (loggedIn) {", "    if (loggedIn) {\n      final email = await AuthService.instance.getSavedEmail();\n      if (email != null) await AppData.instance.loadUserData(email);")

with open('lib/screens/splash_screen.dart', 'w', encoding='utf-8') as f:
    f.write(splash)

# 3. Update login_screen.dart
with open('lib/screens/login_screen.dart', 'r', encoding='utf-8') as f:
    login = f.read()

login = login.replace("await AuthService.instance.loginManual(inputEmail, inputPassword);", "await AuthService.instance.loginManual(inputEmail, inputPassword);\n      await AppData.instance.loadUserData(inputEmail);")
login = login.replace("await AuthService.instance.saveManualSession(email: mockEmail, name: mockName);", "await AuthService.instance.saveManualSession(email: mockEmail, name: mockName);\n      await AppData.instance.loadUserData(mockEmail);")

with open('lib/screens/login_screen.dart', 'w', encoding='utf-8') as f:
    f.write(login)

# 4. Update dashboard_screen.dart
with open('lib/screens/dashboard_screen.dart', 'r', encoding='utf-8') as f:
    dash = f.read()

dash = dash.replace("  void _logout() async {\n    await AuthService.instance.signOut();", "  void _logout() async {\n    AppData.instance.clearUserData();\n    await AuthService.instance.signOut();")

with open('lib/screens/dashboard_screen.dart', 'w', encoding='utf-8') as f:
    f.write(dash)

print("All files patched for multi-account isolation.")
