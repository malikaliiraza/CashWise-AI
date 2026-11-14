// Hisaab Kitaab — category spending chart (v7.2).
//
// Pie chart of spending by category (fl_chart) + legend, in the current
// locale. Requires fl_chart (see pubspec.yaml).
//
// API used (PieChart / PieChartData / PieChartSectionData) exists in
// both fl_chart 0.69 and 1.x.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../data/expense_store.dart';

/// One fixed colour per category (English key). Emerald leads, matching
/// the Clean Light theme; the other six are distinct so slices and the
/// legend stay readable. Colours never change with locale — only the
/// category names and amounts do.
const Map<String, Color> categoryChartColors = {
  'Food': Color(0xFF059669), // emerald — theme primary
  'Transport': Color(0xFF0EA5E9), // sky
  'Bills': Color(0xFFF59E0B), // amber
  'Shopping': Color(0xFF8B5CF6), // violet
  'Health': Color(0xFFEC4899), // pink
  'Education': Color(0xFF6366F1), // indigo
  'Other': Color(0xFF64748B), // slate
};

/// Pie chart of spending by category + legend, in the current locale.
///
/// - Totals come from [ExpenseStore.expenses], or from
///   [ExpenseStore.expensesForBudget] when [budgetId] is given, so a
///   budget's own Details page charts only that budget.
/// - Amounts use [ExpenseStore.formatAmount], so the currency follows the
///   selected language (no hardcoded "Rs." anywhere).
/// - Returns nothing visible when there are no expenses, so the home
///   screen's empty state stays clean.
class CategoryChartCard extends StatelessWidget {
  final ExpenseStore store;

  /// Optional: chart only this budget's expenses (v7.2). Null =
  /// the active budget, as before.
  final String? budgetId;

  const CategoryChartCard({super.key, required this.store, this.budgetId});

  Map<String, double> _totalsByCategory() {
    final totals = <String, double>{};
    final list = budgetId == null
        ? store.expenses
        : store.expensesForBudget(budgetId!);
    for (final expense in list) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amountPkr;
    }
    totals.removeWhere((_, total) => total <= 0);
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    final strings = store.strings;
    final totals = _totalsByCategory();
    if (totals.isEmpty) return const SizedBox.shrink();

    final list = budgetId == null
        ? store.expenses
        : store.expensesForBudget(budgetId!);
    final totalSpent =
        list.fold(0.0, (sum, e) => sum + e.amountPkr);
    // Biggest slice first, so the legend reads in spending order.
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final secondary =
        Theme.of(context).brightness == Brightness.dark
            ? CashWiseTheme.darkSecondaryText
            : CashWiseTheme.secondaryText;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.spendingByCategory,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 44,
                  pieTouchData: PieTouchData(enabled: false),
                  sections: entries.map((entry) {
                    final fraction =
                        totalSpent <= 0 ? 0 : entry.value / totalSpent;
                    return PieChartSectionData(
                      value: entry.value,
                      color: categoryChartColors[entry.key] ??
                          CashWiseTheme.secondaryText,
                      radius: 64,
                      showTitle: fraction >= 0.05,
                      title: '${(fraction * 100).round()}%',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Legend (v7.2): every category shows its total
            // amount next to its name — name flexes, amount is
            // a fixed right-aligned column, so nothing overlaps.
            ...entries.map((entry) {
              final fraction =
                  totalSpent <= 0 ? 0 : entry.value / totalSpent;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: categoryChartColors[entry.key] ??
                            CashWiseTheme.secondaryText,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        strings.categoryName(entry.key),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      store.formatAmount(entry.value),
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 44,
                      child: Text(
                        '${(fraction * 100).round()}%',
                        textAlign: TextAlign.end,
                        style: TextStyle(color: secondary),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
