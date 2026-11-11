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

  const BudgetPeriod({
    required this.id,
    required this.amount,
    required this.createdAt,
  });

  BudgetPeriod copyWith({double? amount}) => BudgetPeriod(
        id: id,
        amount: amount ?? this.amount,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'createdAt': createdAt.toIso8601String(),
      };

  factory BudgetPeriod.fromJson(Map<String, dynamic> json) =>
      BudgetPeriod(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
