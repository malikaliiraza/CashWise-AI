class Expense {
  final String id;
  final String title;
  final double amountPkr;
  final String category;
  final DateTime date;

  const Expense({
    required this.id,
    required this.title,
    required this.amountPkr,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amountPkr': amountPkr,
        'category': category,
        'date': date.toIso8601String(),
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] as String,
        title: json['title'] as String,
        amountPkr: (json['amountPkr'] as num).toDouble(),
        category: json['category'] as String,
        date: DateTime.parse(json['date'] as String),
      );
}

const List<String> expenseCategories = [
  'Food',
  'Transport',
  'Bills',
  'Shopping',
  'Health',
  'Education',
  'Other',
];
