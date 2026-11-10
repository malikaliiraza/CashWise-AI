// CashWise AI — category spending chart (DRAFT for the 10:50 daily step,
// Tue 10 Nov 2026). NOT yet copied into ~/workspace/cashwise-ai, NOT
// published to GitHub, NOT run/tested here (no Flutter/Dart SDK in this VM).
//
// Place at: lib/features/expenses/presentation/category_chart.dart
// Requires: fl_chart (add with `flutter pub add fl_chart` on the PC —
// it resolves the latest version compatible with Flutter 3.47.5).
// API used (PieChart / PieChartData / PieChartSectionData) exists in
// both fl_chart 0.69 and 1.x.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/localization.dart';
import '../../../core/theme.dart';
import '../data/expense_store.dart';
import '../models/expense.dart';

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
/// - Totals come from [ExpenseStore.expenses]; categories are grouped by
///   their stored English key and displayed with [AppLocale.categoryName].
/// - Amounts use [ExpenseStore.formatAmount], so the currency follows the
///   selected language (no hardcoded "Rs." anywhere).
/// - Returns nothing visible when there are no expenses, so the home
///   screen's empty state stays clean.
class CategoryChartCard extends StatelessWidget {
  final ExpenseStore store;

  const CategoryChartCard({super.key, required this.store});

  Map<String, double> _totalsByCategory() {
    final totals = <String, double>{};
    for (final expense in store.expenses) {
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

    final totalSpent = store.totalSpent;
    // Biggest slice first, so the legend reads in spending order.
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  pieTouchData: PieTouchData(enabled: false),
                  sections: entries.map((entry) {
                    final fraction =
                        totalSpent <= 0 ? 0 : entry.value / totalSpent;
                    return PieChartSectionData(
                      value: entry.value,
                      color: categoryChartColors[entry.key] ??
                          CashWiseTheme.secondaryText,
                      radius: 60,
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
                      child: Text(strings.categoryName(entry.key)),
                    ),
                    Text(
                      store.formatAmount(entry.value),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 44,
                      child: Text(
                        '${(fraction * 100).round()}%',
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          color: CashWiseTheme.secondaryText,
                        ),
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
