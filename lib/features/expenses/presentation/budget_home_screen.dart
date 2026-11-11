// CashWise AI — Budget home screen (v5.2).
//
// The Budget category's own home: its summary (budget, spent,
// remaining, daily average, projected month-end) and its five
// options — Set budget, Add Expense, Details, AI Predictor,
// Summary. Nothing from the Loan Ledger lives here; the two
// categories are never mixed.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/gradient_button.dart';
import '../../../core/page_transitions.dart';
import '../../../core/theme.dart';
import '../data/expense_store.dart';
import 'add_expense_screen.dart';
import 'budget_screen.dart';
import 'statistics_screen.dart';

class BudgetHomeScreen extends StatelessWidget {
  const BudgetHomeScreen({super.key});

  Widget _optionCard({
    required String label,
    required IconData icon,
    required Color tint,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: tint,
                  foregroundColor: iconColor,
                  child: Icon(icon),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

    void openDetails(int tab) {
      Navigator.of(context).push(
        slideRoute(StatisticsScreen(initialTab: tab)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: CashWiseTheme.headerGradientOf(context),
        ),
        title: Text(strings.budget),
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
                  // Budget switcher: tap a chip to open that
                  // budget's book; the pencil edits it.
                  if (store.budgets.isNotEmpty) ...[
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (var i = 0;
                                    i < store.budgets.length;
                                    i++)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      label: Text(
                                        '${strings.budget} ${i + 1}',
                                      ),
                                      selected: store.budgets[i].id ==
                                          store.activeBudgetId,
                                      onSelected: (_) => store.switchBudget(
                                          store.budgets[i].id),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          tooltip: strings.editBudget,
                          onPressed: () {
                            Navigator.of(context).push(
                              slideRoute(const BudgetScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: store.hasBudget
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  strings.summary,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _summaryRow(
                                  strings.budget,
                                  store.formatAmount(
                                      store.monthlyBudgetPkr),
                                ),
                                _summaryRow(
                                  strings.spentThisMonth,
                                  store.formatAmount(store.totalSpent),
                                ),
                                _summaryRow(
                                  strings.remaining,
                                  store.formatAmount(store.remaining),
                                ),
                                _summaryRow(
                                  strings.dailyAverage,
                                  store.formatAmount(
                                      store.dailyAverageSpend),
                                ),
                                _summaryRow(
                                  strings.projectedMonthEnd,
                                  store.formatAmount(
                                      store.projectedMonthEndSpend),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  strings.setBudgetFirst,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  strings.budgetRequired,
                                  style: const TextStyle(
                                    color: CashWiseTheme.secondaryText,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                GradientButton(
                                  label: strings.setMonthlyBudget,
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      slideRoute(const BudgetScreen()),
                                    );
                                  },
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    strings.quickActions,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _optionCard(
                        label: strings.setMonthlyBudget,
                        icon: Icons.edit,
                        tint: const Color(0xFFFEF3C7),
                        iconColor: const Color(0xFF92400E),
                        onTap: () {
                          Navigator.of(context).push(
                            slideRoute(const BudgetScreen()),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _optionCard(
                        label: strings.addExpense,
                        icon: Icons.add,
                        tint: const Color(0xFFECFDF5),
                        iconColor: const Color(0xFF047857),
                        onTap: () {
                          Navigator.of(context).push(
                            slideRoute(const AddExpenseScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _optionCard(
                        label: strings.details,
                        icon: Icons.bar_chart,
                        tint: const Color(0xFFF5F3FF),
                        iconColor: const Color(0xFF6D28D9),
                        onTap: () => openDetails(0),
                      ),
                      const SizedBox(width: 12),
                      _optionCard(
                        label: strings.aiPredictor,
                        icon: Icons.psychology,
                        tint: const Color(0xFFFEF3C7),
                        iconColor: const Color(0xFFB45309),
                        onTap: () => openDetails(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _optionCard(
                        label: strings.summary,
                        icon: Icons.summarize,
                        tint: const Color(0xFFE0E7FF),
                        iconColor: const Color(0xFF3730A3),
                        onTap: () => openDetails(2),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(child: SizedBox.shrink()),
                    ],
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
