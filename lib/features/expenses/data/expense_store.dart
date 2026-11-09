import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/localization.dart';
import '../models/expense.dart';

/// Offline-first local store. v2 keeps all data on the device.
/// Firebase sync is a roadmap feature, not part of v2.
///
/// NOTE on amounts: `monthlyBudgetPkr` / `Expense.amountPkr` keep their
/// v1 field and storage keys for backward compatibility — existing
/// expenses are never wiped. The numbers are now amounts in the
/// *currently selected locale's* currency; the store formats them with
/// that locale's currency symbol, so switching language also switches
/// the displayed currency.
class ExpenseStore extends ChangeNotifier {
  static const _expensesKey = 'cashwise_expenses_v1';
  static const _budgetKey = 'cashwise_monthly_budget_pkr';
  static const _localeKey = 'cashwise_locale_v1';

  final List<Expense> _expenses = [];
  double monthlyBudgetPkr = 50000;

  AppLocale _locale = appLocales.first;

  /// The currently selected language / country / currency profile.
  AppLocale get locale => _locale;

  /// Localised strings for the current locale.
  AppLocale get strings => _locale;

  List<Expense> get expenses => List.unmodifiable(_expenses);

  double get totalSpent =>
      _expenses.fold(0, (sum, e) => sum + e.amountPkr);

  double get remaining => monthlyBudgetPkr - totalSpent;

  double get spentFraction =>
      monthlyBudgetPkr <= 0 ? 0 : totalSpent / monthlyBudgetPkr;

  /// Alert in the CURRENT locale only — one language, never mixed.
  String? get alertMessage {
    if (spentFraction >= 1) {
      return _locale.overspendAlert;
    }
    if (spentFraction >= 0.8) {
      return _locale.warningAlert;
    }
    return null;
  }

  /// Format an amount with the current locale's currency symbol,
  /// e.g. "\$500", "Rs. 50,000", "₹40,000", "2,000 ر.س".
  String formatAmount(double amount) {
    final whole = amount.truncate();
    final formatted = _withCommas(whole);
    final value = amount == whole.toDouble()
        ? formatted
        : '$formatted.${((amount - whole) * 100).round().toString().padLeft(2, '0')}';
    // Arabic convention: symbol after the number.
    if (_locale.code == 'ar') {
      return '$value ${_locale.currencySymbol}';
    }
    final symbol = _locale.currencySymbol;
    final separator = symbol.endsWith('.') ? ' ' : '';
    return '$symbol$separator$value';
  }

  static String _withCommas(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    final result = buffer.toString();
    return value < 0 ? '-$result' : result;
  }

  /// Switch language + currency. The monthly budget resets to the new
  /// locale's default budget, and the choice is saved offline.
  Future<void> setLocale(String code) async {
    final next = localeByCode(code);
    if (next.code == _locale.code) return;
    _locale = next;
    monthlyBudgetPkr = next.defaultBudget;
    await _save();
    notifyListeners();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _locale = localeByCode(prefs.getString(_localeKey) ?? 'en');
    // Keep a previously saved budget; only fall back to the locale
    // default when nothing was saved yet.
    monthlyBudgetPkr =
        prefs.getDouble(_budgetKey) ?? _locale.defaultBudget;
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
    await prefs.setString(_localeKey, _locale.code);
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
