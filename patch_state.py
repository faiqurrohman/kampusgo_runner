import re
import os

def update_main():
    with open('lib/main.dart', 'r', encoding='utf-8') as f:
        content = f.read()
    
    if "AppData.instance.init()" not in content:
        content = content.replace(
            "await initializeDateFormatting('id_ID', null);",
            "await initializeDateFormatting('id_ID', null);\n  await AppData.instance.init();"
        )
        with open('lib/main.dart', 'w', encoding='utf-8') as f:
            f.write(content)
            print("main.dart updated")

def update_app_data():
    with open('lib/services/app_data.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    if "package:shared_preferences/shared_preferences.dart" not in content:
        content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:shared_preferences/shared_preferences.dart';")

    init_str = """
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('theme_is_dark');
    if (isDark != null) {
      themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    }
    final readIds = prefs.getStringList('read_notifications');
    if (readIds != null) {
      readNotificationIds.addAll(readIds);
    }
  }
"""
    if "Future<void> init()" not in content:
        content = content.replace("AppData._internal();", "AppData._internal();\n" + init_str)

    set_theme_str = """  void setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('theme_is_dark', mode == ThemeMode.dark);
  }"""
    content = re.sub(r"  void setThemeMode\(ThemeMode mode\) \{[\s\S]*?notifyListeners\(\);\n  \}", set_theme_str, content)

    toggle_theme_str = """  void toggleTheme() async {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('theme_is_dark', themeMode == ThemeMode.dark);
  }"""
    content = re.sub(r"  void toggleTheme\(\) \{[\s\S]*?notifyListeners\(\);\n  \}", toggle_theme_str, content)

    mark_notif_str = """  void markNotificationRead(String id) async {
    readNotificationIds.add(id);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('read_notifications', readNotificationIds.toList());
  }"""
    content = re.sub(r"  void markNotificationRead\(String id\) \{[\s\S]*?notifyListeners\(\);\n  \}", mark_notif_str, content)

    mark_all_str = """  void markAllNotificationsRead(Iterable<String> ids) async {
    readNotificationIds.addAll(ids);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('read_notifications', readNotificationIds.toList());
  }"""
    content = re.sub(r"  void markAllNotificationsRead\(Iterable<String> ids\) \{[\s\S]*?notifyListeners\(\);\n  \}", mark_all_str, content)

    with open('lib/services/app_data.dart', 'w', encoding='utf-8') as f:
        f.write(content)
        print("app_data.dart updated")

update_main()
update_app_data()
