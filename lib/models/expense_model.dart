class ExpenseModel {
  final String id;
  final String title;
  final String category;
  final int amount;
  final DateTime date;

  ExpenseModel({required this.id, required this.title, required this.category, required this.amount, required this.date});

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}
