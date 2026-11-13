// CashWise AI — a budget period (v5.9).
//
// One monthly budget. The app used to have a single budget; since
// v5.9 the user can keep several (e.g. one per month, or one per
// purpose) and switch between them — every budget has its own
// expenses, spent/remaining and alerts, and the whole system
// works the same on each one. Expenses carry the id of the
// budget they belong to; the active budget is the one the home
// screens, chart and predictor read.

class BudgetPeriod {
  final String id;
  final double amount;
  final DateTime createdAt;

  /// The name the user gave this budget (v7.0) — empty for
  /// budgets made before naming existed; the screens then fall
  /// back to "Budget 1", "Budget 2", ...
  final String name;

  const BudgetPeriod({
    required this.id,
    required this.amount,
    required this.createdAt,
    this.name = '',
  });

  BudgetPeriod copyWith({double? amount, String? name}) => BudgetPeriod(
        id: id,
        amount: amount ?? this.amount,
        createdAt: createdAt,
        name: name ?? this.name,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'createdAt': createdAt.toIso8601String(),
        'name': name,
      };

  factory BudgetPeriod.fromJson(Map<String, dynamic> json) =>
      BudgetPeriod(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        name: json['name'] as String? ?? '',
      );
}
