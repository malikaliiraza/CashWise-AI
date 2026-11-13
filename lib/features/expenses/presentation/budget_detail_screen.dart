// CashWise AI — one budget's own screen (v7.0).
//
// Tapping a budget no longer just swaps the amount in the
// summary card: every budget has its own screen, its own
// system — its name (renameable), amount, spent, remaining,
// daily average, projected month-end, its categories with
// totals, and its own expense list. Going back shows the
// budget list again, with the other budgets.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/gradient_button.dart';
import '../../../core/page_transitions.dart';
import '../../../core/theme.dart';
import '../data/expense_store.dart';
import '../models/budget.dart';
import 'add_expense_screen.dart';
import 'budget_screen.dart';
import 'expense_detail_screen.dart';

class BudgetDetailScreen extends StatelessWidget {
  final BudgetPeriod budget;

  const BudgetDetailScreen({super.key, required this.budget});

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

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: CashWiseTheme.secondaryText),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
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
                                  strings.monthlyBudget,
                                  style: const TextStyle(
                                    color: CashWiseTheme.secondaryText,
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
                          const SizedBox(height: 4),
                          Text(
                            store.formatAmount(b.amount),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
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
                          const SizedBox(height: 12),
                          _summaryRow(
                            strings.spentThisMonth,
                            store.formatAmount(spent),
                          ),
                          _summaryRow(
                            strings.remaining,
                            store.formatAmount(remaining),
                          ),
                          _summaryRow(
                            strings.dailyAverage,
                            store.formatAmount(
                                store.budgetDailyAverage(b)),
                          ),
                          _summaryRow(
                            strings.projectedMonthEnd,
                            store.formatAmount(
                                store.budgetProjectedMonthEnd(b)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!isActive)
                    GradientButton(
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
                  if (!isActive) const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.edit, size: 18),
                          label: Text(strings.editBudget),
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(strings.addExpense),
                          onPressed: () async {
                            await store.switchBudget(b.id);
                            if (!context.mounted) return;
                            Navigator.of(context).push(
                              slideRoute(const AddExpenseScreen()),
                            );
                          },
                        ),
                      ),
                    ],
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
                      style: const TextStyle(
                        color: CashWiseTheme.secondaryText,
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(strings.categoryName(entry.key)),
                                  Text(
                                    store.formatAmount(entry.value),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
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
                      style: const TextStyle(
                        color: CashWiseTheme.secondaryText,
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
                            '${store.formatDate(e.date)}',
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
