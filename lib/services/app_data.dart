import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../models/gpa_model.dart';
import '../models/resource_model.dart';
import '../models/schedule_model.dart';

class AppData extends ChangeNotifier {
  static final AppData instance = AppData._internal();
  AppData._internal();

  final List<ScheduleModel> schedules = [
    ScheduleModel(id: 's1', title: 'Tugas Mobile Programming', course: 'Flutter', deadline: DateTime.now().add(const Duration(days: 3)), priority: 'Tinggi'),
    ScheduleModel(id: 's2', title: 'Quiz Basis Data', course: 'Database', deadline: DateTime.now().add(const Duration(days: 6)), priority: 'Sedang'),
  ];

  final List<ExpenseModel> expenses = [
    ExpenseModel(id: 'e1', title: 'Kopi kampus', category: 'Makanan', amount: 18000, date: DateTime.now()),
    ExpenseModel(id: 'e2', title: 'Print tugas', category: 'Fotokopi', amount: 12000, date: DateTime.now()),
    ExpenseModel(id: 'e3', title: 'Bensin', category: 'Transportasi', amount: 25000, date: DateTime.now()),
  ];

  final List<GpaModel> gpaItems = [
    GpaModel(id: 'g1', course: 'Mobile Programming', sks: 3, gradePoint: 4.0),
    GpaModel(id: 'g2', course: 'Basis Data', sks: 3, gradePoint: 3.7),
    GpaModel(id: 'g3', course: 'UI/UX', sks: 2, gradePoint: 3.3),
  ];

  final List<ResourceModel> resources = [
    ResourceModel(id: 'r1', course: 'Flutter', title: 'Materi Minggu 1', link: 'https://drive.google.com', tag: 'Kuliah'),
    ResourceModel(id: 'r2', course: 'Database', title: 'Link Kelas Online', link: 'https://meet.google.com', tag: 'Kuliah'),
    ResourceModel(id: 'r3', course: 'BEM', title: 'Pedoman Kaderisasi', link: 'https://docs.google.com', tag: 'Organisasi'),
    ResourceModel(id: 'r4', course: 'Gemastik', title: 'Guidebook Lomba UI/UX', link: 'https://gemastik.kemdikbud.go.id', tag: 'Lomba'),
  ];

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  void addSchedule(String title, String course, DateTime deadline, String priority) {
    schedules.add(ScheduleModel(id: _id(), title: title, course: course, deadline: deadline, priority: priority));
    schedules.sort((a, b) => a.deadline.compareTo(b.deadline));
    notifyListeners();
  }

  void toggleSchedule(String id) {
    final i = schedules.indexWhere((e) => e.id == id);
    if (i != -1) schedules[i] = schedules[i].copyWith(done: !schedules[i].done);
    notifyListeners();
  }

  void deleteSchedule(String id) { schedules.removeWhere((e) => e.id == id); notifyListeners(); }

  void addExpense(String title, String category, int amount) {
    expenses.insert(0, ExpenseModel(id: _id(), title: title, category: category, amount: amount, date: DateTime.now()));
    notifyListeners();
  }

  void deleteExpense(String id) { expenses.removeWhere((e) => e.id == id); notifyListeners(); }

  void addGpa(String course, int sks, double gradePoint) {
    gpaItems.add(GpaModel(id: _id(), course: course, sks: sks, gradePoint: gradePoint));
    notifyListeners();
  }

  void deleteGpa(String id) { gpaItems.removeWhere((e) => e.id == id); notifyListeners(); }

  void addResource(String course, String title, String link, String tag) {
    resources.insert(0, ResourceModel(id: _id(), course: course, title: title, link: link, tag: tag));
    notifyListeners();
  }

  void deleteResource(String id) { resources.removeWhere((e) => e.id == id); notifyListeners(); }

  double calculateGpa() {
    final totalSks = gpaItems.fold<int>(0, (sum, item) => sum + item.sks);
    final totalPoint = gpaItems.fold<double>(0, (sum, item) => sum + item.sks * item.gradePoint);
    return totalSks == 0 ? 0 : totalPoint / totalSks;
  }

  int totalExpense() => expenses.fold<int>(0, (sum, item) => sum + item.amount);

  ThemeMode themeMode = ThemeMode.dark;

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  Map<String, int> expenseByCategory() {
    final map = <String, int>{};
    for (final e in expenses) { map[e.category] = (map[e.category] ?? 0) + e.amount; }
    return map;
  }
}
