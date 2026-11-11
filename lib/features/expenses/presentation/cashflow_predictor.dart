// CashWise AI — cash-flow predictor card (DRAFT, Tue 10 Nov 2026).
// Local rule-based prediction only: daily average spend x days in the
// month. No server, no AI model, no network — it works offline.
// Place at: lib/features/expenses/presentation/cashflow_predictor.dart

import 'package:flutter/material.dart';

import '../../../core/gradient_button.dart';
import '../../../core/page_transitions.dart';
import '../../../core/theme.dart';
import '../data/expense_store.dart';
import 'add_expense_screen.dart';
import 'category_chart.dart';

/// Predicts, before the month ends, when the money will run out.
///
/// - Daily average = total spent / day of month.
/// - Projected month-end = daily average x days in this month.
/// - Run-out date = today + (remaining / daily average), when that
///   date falls inside this month.
/// All labels come from the current locale only; the run-out date is
/// shown numerically (day/month/year) so no month name mixes languages.
class CashFlowPredictorCard extends StatelessWidget {
  final ExpenseStore store;

  const CashFlowPredictorCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final strings = store.strings;
    final hasExpenses = store.expenses.isNotEmpty;
    final willRunOut = store.willOverspend;
    final runOut = store.predictedRunOutDate;
    final alreadySpent = store.spentFraction >= 1;

    final statusColor = !hasExpenses
        ? CashWiseTheme.secondaryText
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
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFF92400E),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        statusText,
                        style: const TextStyle(
                          color: Color(0xFF92400E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GradientButton(
                label: strings.addExpense,
                onPressed: () {
                  Navigator.of(context).push(
                    slideRoute(const AddExpenseScreen()),
                  );
                },
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings.projectedMonthEnd,
                    style: const TextStyle(
                      color: CashWiseTheme.secondaryText,
                    ),
                  ),
                  Text(
                    store.formatAmount(store.projectedMonthEndSpend),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings.dailyAverage,
                    style: const TextStyle(
                      color: CashWiseTheme.secondaryText,
                    ),
                  ),
                  Text(
                    store.formatAmount(store.dailyAverageSpend),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (runOut != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      strings.budgetRunsOut,
                      style: const TextStyle(
                        color: CashWiseTheme.secondaryText,
                      ),
                    ),
                    Text(
                      '${runOut.day}/${runOut.month}/${runOut.year}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: CashWiseTheme.danger,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// The predictor with its category pie chart underneath, used by
/// the AI Predictor page: when expenses exist the chart shows too.
class CashFlowPredictorWithChart extends StatelessWidget {
  final ExpenseStore store;

  const CashFlowPredictorWithChart({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CashFlowPredictorCard(store: store),
        CategoryChartCard(store: store),
      ],
    );
  }
}
