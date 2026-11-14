// Hisaab Kitaab — Budget home screen (v7.2).
//
// The Budget category's own home: every budget is a PROMINENT
// card — its name, its own totals (Budget / Spent / Remaining
// as aligned AmountRow lines), a progress bar and a chevron.
// No small chips for budgets. Tapping a card makes that budget
// the active one (when it is not already) and opens its own
// home page (BudgetDetailScreen). Below the cards, the quick
// actions for the active budget.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/amount_row.dart';
import '../../../core/page_transitions.dart';
import '../../../core/theme.dart';
import '../data/expense_store.dart';
import 'add_expense_screen.dart';
import 'budget_detail_screen.dart';
import 'budget_screen.dart';
import 'statistics_screen.dart';

class BudgetHomeScreen extends StatelessWidget {
  const BudgetHomeScreen({super.key});

  static Color _secondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? CashWiseTheme.darkSecondaryText
          : CashWiseTheme.secondaryText;

  /// Primary button (v7.2): fixed 48dp, label fully visible —
  /// FittedBox scaleDown, one line, never ellipsised.
  Widget _primaryButton({
    required BuildContext context,
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

  /// One full-width action row (v7.1): a tinted icon, a bold
  /// label and a chevron — every option on its own line, so
  /// nothing is cramped and the order reads top to bottom.
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
                  if (store.budgets.isEmpty) ...[
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.noBudgetsYet,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              strings.budgetRequired,
                              style: TextStyle(
                                color: _secondary(context),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _primaryButton(
                              context: context,
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
                  ] else ...[
                    // One prominent card per budget (v7.2) — no
                    // chips. Tapping a card makes it the active
                    // budget and opens its own home page.
                    for (final b in store.budgets) ...[
                      Builder(
                        builder: (context) {
                          final spent = store.budgetSpent(b);
                          final remaining = store.budgetRemaining(b);
                          final fraction = b.amount <= 0
                              ? 0.0
                              : (spent / b.amount).clamp(0.0, 1.0);
                          final isActive =
                              b.id == store.activeBudgetId;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () async {
                                if (!isActive) {
                                  await store.switchBudget(b.id);
                                }
                                if (!context.mounted) return;
                                Navigator.of(context).push(
                                  slideRoute(
                                    BudgetDetailScreen(budget: b),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(24),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            store.budgetDisplayName(b),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (isActive)
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: CashWiseTheme
                                                  .lightAccent
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              strings.active,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: CashWiseTheme
                                                    .lightAccent,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.chevron_right,
                                          color: _secondary(context),
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
                                      amount:
                                          store.formatAmount(spent),
                                    ),
                                    AmountRow(
                                      label: strings.remaining,
                                      amount: store
                                          .formatAmount(remaining),
                                    ),
                                    const SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: fraction,
                                        minHeight: 10,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          fraction >= 1
                                              ? CashWiseTheme.danger
                                              : fraction >= 0.8
                                                  ? CashWiseTheme.warning
                                                  : CashWiseTheme
                                                      .lightAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 4),
                    _primaryButton(
                      context: context,
                      label: strings.addAnotherBudget,
                      onPressed: () {
                        Navigator.of(context).push(
                          slideRoute(const BudgetScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    strings.quickActions,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _actionRow(
                    context: context,
                    label: strings.setMonthlyBudget,
                    icon: Icons.edit,
                    tint: const Color(0xFFE3EDE8),
                    iconColor: const Color(0xFF0C4444),
                    onTap: () {
                      Navigator.of(context).push(
                        slideRoute(const BudgetScreen()),
                      );
                    },
                  ),
                  _actionRow(
                    context: context,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
