import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense_model.dart';
import '../models/gpa_model.dart';
import '../models/resource_model.dart';
import '../models/schedule_model.dart';

class AppData extends ChangeNotifier {
  static final AppData instance = AppData._internal();
  AppData._internal();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final schedulesData = prefs.getString('schedules_data');
    if (schedulesData != null) {
      final List dec = jsonDecode(schedulesData);
      schedules.clear();
      schedules.addAll(dec.map((e) => ScheduleModel.fromJson(e)).toList());
    }

    final expensesData = prefs.getString('expenses_data');
    if (expensesData != null) {
      final List dec = jsonDecode(expensesData);
      expenses.clear();
      expenses.addAll(dec.map((e) => ExpenseModel.fromJson(e)).toList());
    }

    final gpasData = prefs.getString('gpas_data');
    if (gpasData != null) {
      final List dec = jsonDecode(gpasData);
      gpaItems.clear();
      gpaItems.addAll(dec.map((e) => GpaModel.fromJson(e)).toList());
    }

    final resourcesData = prefs.getString('resources_data');
    if (resourcesData != null) {
      final List dec = jsonDecode(resourcesData);
      resources.clear();
      resources.addAll(dec.map((e) => ResourceModel.fromJson(e)).toList());
    }

    final isDark = prefs.getBool('theme_is_dark');
    if (isDark != null) {
      themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    }
    
    final limit = prefs.getInt('budget_limit');
    if (limit != null) {
      budgetLimit = limit;
    }

    final readIds = prefs.getStringList('read_notifications');
    if (readIds != null) {
      readNotificationIds.addAll(readIds);
    }
  }


  final List<ScheduleModel> schedules = [];

  final List<ExpenseModel> expenses = [];

  final List<GpaModel> gpaItems = [];

  final List<ResourceModel> resources = [];


  void _saveSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('schedules_data', jsonEncode(schedules.map((e) => e.toJson()).toList()));
  }
  
  void _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('expenses_data', jsonEncode(expenses.map((e) => e.toJson()).toList()));
  }

  void _saveGpas() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('gpas_data', jsonEncode(gpaItems.map((e) => e.toJson()).toList()));
  }

  void _saveResources() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('resources_data', jsonEncode(resources.map((e) => e.toJson()).toList()));
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  void addSchedule(String title, String course, DateTime deadline, String priority) {
    schedules.add(ScheduleModel(id: _id(), title: title, course: course, deadline: deadline, priority: priority));
    schedules.sort((a, b) => a.deadline.compareTo(b.deadline));
    _saveSchedules();
    notifyListeners();
  }

  void toggleSchedule(String id) {
    final i = schedules.indexWhere((e) => e.id == id);
    if (i != -1) schedules[i] = schedules[i].copyWith(done: !schedules[i].done);
    _saveSchedules();
    notifyListeners();
  }

  void deleteSchedule(String id) { schedules.removeWhere((e) => e.id == id); _saveSchedules(); notifyListeners(); }

  void addExpense(String title, String category, int amount) {
    expenses.insert(0, ExpenseModel(id: _id(), title: title, category: category, amount: amount, date: DateTime.now()));
    _saveExpenses();
    notifyListeners();
  }

  void deleteExpense(String id) { expenses.removeWhere((e) => e.id == id); _saveExpenses(); notifyListeners(); }

  void addGpa(String course, int sks, double gradePoint) {
    gpaItems.add(GpaModel(id: _id(), course: course, sks: sks, gradePoint: gradePoint));
    _saveGpas();
    notifyListeners();
  }

  void deleteGpa(String id) { gpaItems.removeWhere((e) => e.id == id); _saveGpas(); notifyListeners(); }

  void addResource(String course, String title, String link, String tag) {
    resources.insert(0, ResourceModel(id: _id(), course: course, title: title, link: link, tag: tag));
    _saveResources();
    notifyListeners();
  }

  void deleteResource(String id) { resources.removeWhere((e) => e.id == id); _saveResources(); notifyListeners(); }

  double calculateGpa() {
    final totalSks = gpaItems.fold<int>(0, (sum, item) => sum + item.sks);
    final totalPoint = gpaItems.fold<double>(0, (sum, item) => sum + item.sks * item.gradePoint);
    return totalSks == 0 ? 0 : totalPoint / totalSks;
  }

  int totalExpense() => expenses.fold<int>(0, (sum, item) => sum + item.amount);

  ThemeMode themeMode = ThemeMode.dark;

  void setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('theme_is_dark', mode == ThemeMode.dark);
  }

  void toggleTheme() async {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('theme_is_dark', themeMode == ThemeMode.dark);
  }

  String appLanguage = 'Bahasa Indonesia';
  int notificationReminderHours = 24;

  void updateLanguage(String lang) {
    appLanguage = lang;
    notifyListeners();
  }

  void updateNotificationReminder(int hours) {
    notificationReminderHours = hours;
    notifyListeners();
  }

  final Set<String> readNotificationIds = {};

  void markNotificationRead(String id) async {
    readNotificationIds.add(id);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('read_notifications', readNotificationIds.toList());
  }

  void markAllNotificationsRead(Iterable<String> ids) async {
    readNotificationIds.addAll(ids);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('read_notifications', readNotificationIds.toList());
  }

  double targetGpa = 3.80;
  double previousGpa = 3.66;

  String userName = 'Mahasiswa';
  String userEmail = 'mahasiswa@kampusgo.ac.id';
  String userProdi = 'Teknik Informatika';
  int activeSemester = 5;
  bool calendarIntegration = true;
  bool preciseNotifications = true;
  bool biometricAuth = true;
  String lastBackupDate = 'Kemarin, 14:20';
  String userAvatarUrl = '🧑‍🎓';

  void updateProfile({String? name, String? email, String? prodi, int? semester, double? target, String? avatar}) {
    if (name != null && name.trim().isNotEmpty) userName = name;
    if (email != null && email.trim().isNotEmpty) userEmail = email;
    if (prodi != null && prodi.trim().isNotEmpty) userProdi = prodi;
    if (semester != null) activeSemester = semester;
    if (target != null) targetGpa = target;
    if (avatar != null) userAvatarUrl = avatar;
    notifyListeners();
  }

  void toggleCalendarIntegration(bool val) {
    calendarIntegration = val;
    notifyListeners();
  }

  void togglePreciseNotifications(bool val) {
    preciseNotifications = val;
    notifyListeners();
  }

  void toggleBiometricAuth(bool val) {
    biometricAuth = val;
    notifyListeners();
  }

  void performBackup(String dateStr) {
    lastBackupDate = dateStr;
    notifyListeners();
  }

  void updateTargetGpa(double val) {
    targetGpa = val;
    notifyListeners();
  }

  int budgetLimit = 500000; // Contoh anggaran mingguan default Rp500.000

  void updateBudgetLimit(int limit) async {
    budgetLimit = limit;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('budget_limit', limit);
  }

  List<String> expenseCategories = ['Makanan', 'Fotokopi', 'Transportasi', 'Hiburan', 'Lainnya'];

  void addExpenseCategory(String cat) {
    final trimmed = cat.trim();
    if (trimmed.isNotEmpty && !expenseCategories.contains(trimmed)) {
      expenseCategories.add(trimmed);
      notifyListeners();
    }
  }

  void removeExpenseCategory(String cat) {
    if (expenseCategories.length > 1) {
      expenseCategories.remove(cat);
      notifyListeners();
    }
  }

  Map<String, int> expenseByCategory() {
    final map = <String, int>{};
    for (final e in expenses) { map[e.category] = (map[e.category] ?? 0) + e.amount; }
    return map;
  }
}
