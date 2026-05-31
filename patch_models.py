import re

# 1. Update Models to add toJson and fromJson
def patch_model(filepath, model_name, from_json_body, to_json_body):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if "fromJson" not in content:
        # Find the end of the class
        idx = content.rfind('}')
        if idx != -1:
            insertion = f"\n  factory {model_name}.fromJson(Map<String, dynamic> json) {{\n    return {model_name}(\n{from_json_body}\n    );\n  }}\n\n  Map<String, dynamic> toJson() {{\n    return {{\n{to_json_body}\n    }};\n  }}\n"
            content = content[:idx] + insertion + content[idx:]
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Patched {filepath}")

patch_model('lib/models/schedule_model.dart', 'ScheduleModel',
    "      id: json['id'],\n      title: json['title'],\n      course: json['course'],\n      deadline: DateTime.parse(json['deadline']),\n      priority: json['priority'],\n      done: json['done'] ?? false,",
    "      'id': id,\n      'title': title,\n      'course': course,\n      'deadline': deadline.toIso8601String(),\n      'priority': priority,\n      'done': done,"
)

patch_model('lib/models/expense_model.dart', 'ExpenseModel',
    "      id: json['id'],\n      title: json['title'],\n      category: json['category'],\n      amount: json['amount'],\n      date: DateTime.parse(json['date']),",
    "      'id': id,\n      'title': title,\n      'category': category,\n      'amount': amount,\n      'date': date.toIso8601String(),"
)

patch_model('lib/models/gpa_model.dart', 'GpaModel',
    "      id: json['id'],\n      course: json['course'],\n      sks: json['sks'],\n      gradePoint: json['gradePoint'].toDouble(),",
    "      'id': id,\n      'course': course,\n      'sks': sks,\n      'gradePoint': gradePoint,"
)

patch_model('lib/models/resource_model.dart', 'ResourceModel',
    "      id: json['id'],\n      course: json['course'],\n      title: json['title'],\n      link: json['link'],\n      tag: json['tag'] ?? 'Kuliah',",
    "      'id': id,\n      'course': course,\n      'title': title,\n      'link': link,\n      'tag': tag,"
)

# 2. Update app_data.dart
with open('lib/services/app_data.dart', 'r', encoding='utf-8') as f:
    app_data = f.read()

if "import 'dart:convert';" not in app_data:
    app_data = app_data.replace("import 'package:flutter/material.dart';", "import 'dart:convert';\nimport 'package:flutter/material.dart';")

# Add saving methods
if "void _saveSchedules()" not in app_data:
    saving_methods = """
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
"""
    app_data = app_data.replace("  String _id()", saving_methods + "\n  String _id()")

# Replace notifyListeners() with _saveXXX(); notifyListeners(); in relevant methods
app_data = re.sub(r"(schedules\.add\(.*?\);\n    schedules\.sort\(.*?\);\n    )notifyListeners\(\);", r"\1_saveSchedules();\n    notifyListeners();", app_data)
app_data = re.sub(r"(schedules\[i\] = .*?;\n    )notifyListeners\(\);", r"\1_saveSchedules();\n    notifyListeners();", app_data)
app_data = re.sub(r"(schedules\.removeWhere\(.*?\); )notifyListeners\(\);", r"\1_saveSchedules(); notifyListeners();", app_data)

app_data = re.sub(r"(expenses\.insert\(.*?\);\n    )notifyListeners\(\);", r"\1_saveExpenses();\n    notifyListeners();", app_data)
app_data = re.sub(r"(expenses\.removeWhere\(.*?\); )notifyListeners\(\);", r"\1_saveExpenses(); notifyListeners();", app_data)

app_data = re.sub(r"(gpaItems\.add\(.*?\);\n    )notifyListeners\(\);", r"\1_saveGpas();\n    notifyListeners();", app_data)
app_data = re.sub(r"(gpaItems\.removeWhere\(.*?\); )notifyListeners\(\);", r"\1_saveGpas(); notifyListeners();", app_data)

app_data = re.sub(r"(resources\.insert\(.*?\);\n    )notifyListeners\(\);", r"\1_saveResources();\n    notifyListeners();", app_data)
app_data = re.sub(r"(resources\.removeWhere\(.*?\); )notifyListeners\(\);", r"\1_saveResources(); notifyListeners();", app_data)

# Inject loading logic into init()
init_loading = """
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
"""

if "schedulesData = prefs.getString" not in app_data:
    app_data = app_data.replace("  Future<void> init() async {", "  Future<void> init() async {\n" + init_loading)

# Also remove the hardcoded final List initializations and make them empty by default, BUT wait,
# If there's no data, we should probably keep them empty instead of the dummy data.
# The user said "hilang malah tidak tersimpan". This means if they delete dummy data, it also comes back!
# So replacing the dummy data with empty lists is a good idea.
app_data = re.sub(r"final List<ScheduleModel> schedules = \[[\s\S]*?\];", "final List<ScheduleModel> schedules = [];", app_data)
app_data = re.sub(r"final List<ExpenseModel> expenses = \[[\s\S]*?\];", "final List<ExpenseModel> expenses = [];", app_data)
app_data = re.sub(r"final List<GpaModel> gpaItems = \[[\s\S]*?\];", "final List<GpaModel> gpaItems = [];", app_data)
app_data = re.sub(r"final List<ResourceModel> resources = \[[\s\S]*?\];", "final List<ResourceModel> resources = [];", app_data)


with open('lib/services/app_data.dart', 'w', encoding='utf-8') as f:
    f.write(app_data)
    print("Patched app_data.dart")

