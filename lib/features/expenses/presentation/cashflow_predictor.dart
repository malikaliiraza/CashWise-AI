// Hisaab Kitaab — cash-flow predictor card (v7.2).
// Local rule-based prediction only: daily average spend x days in the
// month. No server, no AI model, no network — it works offline.
// Place at: lib/features/expenses/presentation/cashflow_predictor.dart

import 'package:flutter/material.dart';

import '../../../core/amount_row.dart';
import '../../../core/page_transitions.dart';
import '../../../core/theme.dart';
import '../data/expense_store.dart';
import 'add_expense_screen.dart';
import 'budget_detail_screen.dart' show shortDate;
import 'category_chart.dart';

/// Predicts, before the month ends, when the money will run out.
///
/// - Daily average = total spent / day of month.
/// - Projected month-end = daily average x days in this month.
/// - Run-out date = today + (remaining / daily average), when that
///   date falls inside this month.
/// All labels come from the current locale only; the run-out date is
/// shown short ("12 Nov 2026") so it never wraps mid-phrase.
class CashFlowPredictorCard extends StatelessWidget {
  final ExpenseStore store;

  /// Optional: predict only this budget's pace (v7.2). Null =
  /// the active budget, as before.
  final String? budgetId;

  const CashFlowPredictorCard({super.key, required this.store, this.budgetId});

  @override
  Widget build(BuildContext context) {
    final strings = store.strings;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Scoped values (v7.2): when a budgetId is given, every
    // number comes from that budget alone.
    final scopedBudget = budgetId == null
        ? store.activeBudget
        : store.budgets
            .where((b) => b.id == budgetId)
            .firstOrNull ??
            store.activeBudget;
    final scopedExpenses = budgetId == null
        ? store.expenses
        : store.expensesForBudget(budgetId!);
    final scopedBudgetAmount = scopedBudget?.amount ?? 0;
    final scopedSpent = scopedExpenses.fold(
        0.0, (sum, e) => sum + e.amountPkr);
    final scopedRemaining = scopedBudgetAmount - scopedSpent;
    final scopedFraction = scopedBudgetAmount <= 0
        ? 0.0
        : scopedSpent / scopedBudgetAmount;
    final scopedDailyAverage = scopedBudget == null
        ? store.dailyAverageSpend
        : store.budgetDailyAverage(scopedBudget);
    final scopedProjected = scopedBudget == null
        ? store.projectedMonthEndSpend
        : store.budgetProjectedMonthEnd(scopedBudget);
    final scopedWillRunOut = scopedExpenses.isNotEmpty &&
        scopedFraction < 1 &&
        scopedProjected > scopedBudgetAmount;
    DateTime? scopedRunOut;
    if (scopedExpenses.isNotEmpty &&
        scopedDailyAverage > 0 &&
        scopedRemaining > 0) {
      final daysLeft = (scopedRemaining / scopedDailyAverage).ceil();
      final now = DateTime.now();
      final runOut = now.add(Duration(days: daysLeft));
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final monthEnd = DateTime(now.year, now.month, daysInMonth);
      if (!runOut.isAfter(monthEnd)) scopedRunOut = runOut;
    }
    final hasExpenses = scopedExpenses.isNotEmpty;
    final willRunOut = scopedWillRunOut;
    final runOut = scopedRunOut;
    final alreadySpent = scopedFraction >= 1;

    final statusColor = !hasExpenses
        ? (isDark
            ? CashWiseTheme.darkSecondaryText
            : CashWiseTheme.secondaryText)
        : alreadySpent || willRunOut
            ? CashWiseTheme.danger
            : CashWiseTheme.accentFor(context);
    final statusText = !hasExpenses
        ? strings.noExpensesPrediction
        : alreadySpent
            ? strings.overspendAlert
            : willRunOut
                ? strings.willRunOut
                : strings.onTrack;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 20,
                  color: CashWiseTheme.accentFor(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    strings.cashFlowPrediction,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!hasExpenses) ...[
              // Alert: no expenses yet — ask the user to add one,
              // with a direct Add Expense button.
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF451A03)
                      : const Color(0xFFE3EDE8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFF59E0B),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 20,
                      color: Color(0xFF92400E),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFFFDE68A)
                              : const Color(0xFF92400E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: _PrimaryButton(
                  label: strings.addExpense,
                  onPressed: () {
                    Navigator.of(context).push(
                      slideRoute(
                        AddExpenseScreen(budgetId: budgetId),
                      ),
                    );
                  },
                ),
              ),
            ] else
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (hasExpenses) ...[
              const SizedBox(height: 12),
              // AmountRow (v7.2): the label wraps, the amount
              // stays in its own right-aligned column — the two
              // can never run together.
              AmountRow(
                label: strings.projectedMonthEnd,
                amount: store.formatAmount(scopedProjected),
              ),
              AmountRow(
                label: strings.dailyAverage,
                amount: store.formatAmount(scopedDailyAverage),
              ),
              if (runOut != null)
                AmountRow(
                  label: strings.budgetRunsOut,
                  amount: shortDate(store, runOut),
                  amountStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: CashWiseTheme.danger,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Primary button (v7.2): fixed 48dp, label fully visible —
/// FittedBox scaleDown, one line, never ellipsised.
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: enabled
                ? const [Color(0xFF0C4444), Color(0xFF0F766E)]
                : const [Color(0xFF9CA3AF), Color(0xFF6B7280)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The predictor with its category pie chart underneath, used by
/// the AI Predictor page: when expenses exist the chart shows too.
class CashFlowPredictorWithChart extends StatelessWidget {
  final ExpenseStore store;

  /// Optional: scope predictor + chart to one budget (v7.2).
  final String? budgetId;

  const CashFlowPredictorWithChart({
    super.key,
    required this.store,
    this.budgetId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CashFlowPredictorCard(store: store, budgetId: budgetId),
        CategoryChartCard(store: store, budgetId: budgetId),
      ],
    );
  }
}
