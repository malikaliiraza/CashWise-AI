// Hisaab Kitaab — one budget's own home page (v7.2).
//
// Tapping a budget opens its OWN home: its name, its totals,
// then its own options as full-width rows — Details, Add
// Expense, AI Predictor, Summary — ALL scoped to this budget
// (StatisticsScreen / AddExpenseScreen with budgetId), never
// the global active budget. Below the options: its categories
// with totals and its own expense list. Going back shows the
// budget list again.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/amount_row.dart';
import '../../../core/page_transitions.dart';
import '../../../core/theme.dart';
import '../data/expense_store.dart';
import '../models/budget.dart';
import 'add_expense_screen.dart';
import 'budget_screen.dart';
import 'expense_detail_screen.dart';
import 'statistics_screen.dart';

/// Short date, one line: "12 Nov 2026" in English; Urdu months
/// are already short, so the store format is used as-is there.
String shortDate(ExpenseStore store, DateTime date) {
  if (store.locale.code == 'ur') return store.formatDate(date);
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

class BudgetDetailScreen extends StatelessWidget {
  final BudgetPeriod budget;

  const BudgetDetailScreen({super.key, required this.budget});

  static Color _secondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? CashWiseTheme.darkSecondaryText
          : CashWiseTheme.secondaryText;

  Future<void> _rename(BuildContext context, ExpenseStore store) async {
    final strings = store.strings;
    final controller =
        TextEditingController(text: store.budgetDisplayName(budget));
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.renameBudget),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: strings.budgetName,
            hintText: strings.budgetNameHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(strings.save),
          ),
        ],
      ),
    );
    if (saved == true && controller.text.trim().isNotEmpty) {
      await store.renameBudget(budget.id, controller.text);
    }
  }

  /// Primary button (v7.2): fixed 48dp, label fully visible —
  /// FittedBox scaleDown, one line, never ellipsised.
  Widget _primaryButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: SizedBox(
        height: 48,
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
      ),
    );
  }

  /// One full-width option row: a tinted icon, a bold label
  /// and a chevron.
  Widget _actionRow({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color tint,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    isDark ? CashWiseTheme.darkCard : tint,
                foregroundColor: iconColor,
                child: Icon(icon, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: _secondary(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseStore>();
    final strings = store.strings;
    // Re-read the budget from the store, so a rename shows
    // immediately without leaving the screen.
    final b = store.budgets.firstWhere(
      (x) => x.id == budget.id,
      orElse: () => budget,
    );
    final name = store.budgetDisplayName(b);
    final spent = store.budgetSpent(b);
    final remaining = store.budgetRemaining(b);
    final fraction =
        b.amount <= 0 ? 0.0 : (spent / b.amount).clamp(0.0, 1.0);
    final expenses = store.expensesForBudget(b.id);
    final isActive = b.id == store.activeBudgetId;

    // Category totals for this budget only.
    final Map<String, double> byCategory = {};
    for (final e in expenses) {
      byCategory[e.category] =
          (byCategory[e.category] ?? 0) + e.amountPkr;
    }
    final sortedCategories = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCategory =
        sortedCategories.isEmpty ? 1.0 : sortedCategories.first.value;

    void openDetails(int tab) {
      Navigator.of(context).push(
        slideRoute(
          StatisticsScreen(initialTab: tab, budgetId: b.id),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: CashWiseTheme.headerGradientOf(context),
        ),
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            tooltip: strings.renameBudget,
            onPressed: () => _rename(context, store),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: CashWiseTheme.lightAccent
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    strings.active,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: CashWiseTheme.lightAccent,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          AmountRow(
                            label: strings.budget,
                            amount: store.formatAmount(b.amount),
                          ),
                          AmountRow(
                            label: strings.spentThisMonth,
                            amount: store.formatAmount(spent),
                          ),
                          AmountRow(
                            label: strings.remaining,
                            amount: store.formatAmount(remaining),
                          ),
                          AmountRow(
                            label: strings.dailyAverage,
                            amount: store.formatAmount(
                                store.budgetDailyAverage(b)),
                          ),
                          AmountRow(
                            label: strings.projectedMonthEnd,
                            amount: store.formatAmount(
                                store.budgetProjectedMonthEnd(b)),
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: fraction,
                              minHeight: 10,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                fraction >= 1
                                    ? CashWiseTheme.danger
                                    : fraction >= 0.8
                                        ? CashWiseTheme.warning
                                        : CashWiseTheme.lightAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!isActive) ...[
                    _primaryButton(
                      label: strings.useThisBudget,
                      onPressed: () async {
                        await store.switchBudget(b.id);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              strings.budgetNowActive(name),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  // This budget's own options (v7.2) — every one
                  // scoped to this budget, not the active one.
                  _actionRow(
                    context: context,
                    label: strings.details,
                    icon: Icons.bar_chart,
                    tint: const Color(0xFFF5F3FF),
                    iconColor: const Color(0xFF6D28D9),
                    onTap: () => openDetails(0),
                  ),
                  _actionRow(
                    context: context,
                    label: strings.addExpense,
                    icon: Icons.add,
                    tint: const Color(0xFFECFDF5),
                    iconColor: const Color(0xFF047857),
                    onTap: () {
                      Navigator.of(context).push(
                        slideRoute(
                          AddExpenseScreen(budgetId: b.id),
                        ),
                      );
                    },
                  ),
                  _actionRow(
                    context: context,
                    label: strings.aiPredictor,
                    icon: Icons.psychology,
                    tint: const Color(0xFFE3EDE8),
                    iconColor: const Color(0xFF0F766E),
                    onTap: () => openDetails(1),
                  ),
                  _actionRow(
                    context: context,
                    label: strings.summary,
                    icon: Icons.summarize,
                    tint: const Color(0xFFE0E7FF),
                    iconColor: const Color(0xFF3730A3),
                    onTap: () => openDetails(2),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit, size: 20),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          strings.editBudget,
                          maxLines: 1,
                        ),
                      ),
                      onPressed: () async {
                        // The Set budget screen edits the
                        // active budget, so make this one
                        // active first.
                        await store.switchBudget(b.id);
                        if (!context.mounted) return;
                        Navigator.of(context).push(
                          slideRoute(const BudgetScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    strings.categories,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (sortedCategories.isEmpty)
                    Text(
                      strings.noExpenses,
                      style: TextStyle(
                        color: _secondary(context),
                      ),
                    )
                  else
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            for (final entry in sortedCategories) ...[
                              // Category name WITH its total (v7.2):
                              // the amount sits in one straight
                              // right-aligned column.
                              AmountRow(
                                label: strings.categoryName(entry.key),
                                amount:
                                    store.formatAmount(entry.value),
                                bold: true,
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: maxCategory <= 0
                                      ? 0
                                      : entry.value / maxCategory,
                                  minHeight: 8,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    CashWiseTheme.lightAccent,
                                  ),
                                ),
                              ),
                              if (entry != sortedCategories.last)
                                const SizedBox(height: 12),
                            ],
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    strings.expenses,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (expenses.isEmpty)
                    Text(
                      strings.noExpenses,
                      style: TextStyle(
                        color: _secondary(context),
                      ),
                    )
                  else
                    ...expenses.map(
                      (e) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: CashWiseTheme.lightAccent
                                .withValues(alpha: 0.15),
                            foregroundColor: CashWiseTheme.lightAccent,
                            child: const Icon(Icons.receipt, size: 20),
                          ),
                          title: Text(
                            e.title.isEmpty
                                ? strings.categoryName(e.category)
                                : e.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${strings.categoryName(e.category)} • '
                            '${shortDate(store, e.date)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            store.formatAmount(e.amountPkr),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              slideRoute(
                                  ExpenseDetailScreen(expense: e)),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
