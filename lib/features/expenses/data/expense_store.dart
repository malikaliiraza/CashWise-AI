import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense.dart';

/// Offline-first local store. v1 keeps all data on the device.
/// Firebase sync is a roadmap feature, not part of v1.
class ExpenseStore extends ChangeNotifier {
  static const _expensesKey = 'cashwise_expenses_v1';
  static const _budgetKey = 'cashwise_monthly_budget_pkr';

  final List<Expense> _expenses = [];
  double monthlyBudgetPkr = 50000;

  List<Expense> get expenses => List.unmodifiable(_expenses);

  double get totalSpent =>
      _expenses.fold(0, (sum, e) => sum + e.amountPkr);

  double get remaining => monthlyBudgetPkr - totalSpent;

  double get spentFraction =>
      monthlyBudgetPkr <= 0 ? 0 : totalSpent / monthlyBudgetPkr;

  /// Urdu / English overspend message for v1.
  String? get alertMessage {
    if (spentFraction >= 1) {
      return 'Overspend alert! Budget khatam ho gaya. / بجٹ ختم ہو گیا ہے!';
    }
    if (spentFraction >= 0.8) {
      return 'Warning: 80% budget use ho gaya. / خبردار: بجٹ کا 80٪ استعمال ہو گیا ہے۔';
    }
    return null;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    monthlyBudgetPkr = prefs.getDouble(_budgetKey) ?? 50000;
    final raw = prefs.getString(_expensesKey);
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _expenses
        ..clear()
        ..addAll(decoded.map(
            (e) => Expense.fromJson(e as Map<String, dynamic>)));
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_budgetKey, monthlyBudgetPkr);
    await prefs.setString(
      _expensesKey,
      jsonEncode(_expenses.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> addExpense(Expense expense) async {
    _expenses.insert(0, expense);
    await _save();
    notifyListeners();
  }

  Future<void> removeExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> setMonthlyBudget(double amount) async {
    monthlyBudgetPkr = amount;
    await _save();
    notifyListeners();
  }
}
