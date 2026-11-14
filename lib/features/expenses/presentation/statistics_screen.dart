// Hisaab Kitaab — details page (v7.2).
//
// Three options, one screen: Expenses (default — the full list with
// search, category filter and sort), AI Predictor (chart + cash-flow
// prediction), and Summary (spent, remaining, daily average,
// projected month-end, top category). The budget alert (80% warning
// / 100% overspend) shows as a banner at the top here, and the same
// alert also fires a mobile notification on phones. The AppBar back
// button returns home.
//
// Scoping (v7.2): pass [budgetId] and every tab reads ONLY that
// budget's expenses and totals. Without it, the active budget is
// used, exactly as before.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/amount_row.dart';
import '../../../core/confirm_dialog.dart';
import '../../../core/page_transitions.dart';
import '../../../core/theme.dart';
import '../data/expense_store.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';
import 'budget_detail_screen.dart' show shortDate;
import 'cashflow_predictor.dart';
import 'category_chart.dart';
import 'category_style.dart';
import 'expense_detail_screen.dart';

class StatisticsScreen extends StatefulWidget {
  /// Which tab to open on: 0 = Expenses, 1 = AI Predictor,
  /// 2 = Summary. Home menu options and the drawer open the
  /// page straight onto the tab they mean (v5.0).
  final int initialTab;

  /// Optional: scope the whole page to one budget (v7.2).
  /// Null = the active budget, as before.
  final String? budgetId;

  const StatisticsScreen({super.key, this.initialTab = 0, this.budgetId});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  // Null = all categories; otherwise an English category key.
  String? _filterCategory;
  // 'newest' | 'oldest' | 'highest' | 'lowest'.
  String _sortMode = 'newest';
  // 'expenses' | 'predictor' | 'summary' — expenses first.
  String _tab = 'expenses';

  @override
  void initState() {
    super.initState();
    _tab = switch (widget.initialTab) {
      1 => 'predictor',
      2 => 'summary',
      _ => 'expenses',
    };
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static Color _secondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? CashWiseTheme.darkSecondaryText
          : CashWiseTheme.secondaryText;

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

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseStore>();
    final strings = store.strings;

    // --- Scoped data (v7.2) ---
    final scopedBudget = widget.budgetId == null
        ? store.activeBudget
        : store.budgets
            .where((b) => b.id == widget.budgetId)
            .firstOrNull ??
            store.activeBudget;
    final scopedExpenses = widget.budgetId == null
        ? store.expenses
        : store.expensesForBudget(widget.budgetId!);
    final scopedBudgetAmount = scopedBudget?.amount ?? 0;
    final scopedSpent =
        scopedExpenses.fold(0.0, (sum, e) => sum + e.amountPkr);
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
    final alert = scopedFraction >= 1
        ? strings.overspendAlert
        : scopedFraction >= 0.8
            ? strings.warningAlert
            : null;
    final isWarning = alert != null && scopedFraction < 1;

    final query = _searchQuery.trim().toLowerCase();
    final filteredExpenses = scopedExpenses.where((e) {
      final matchesCategory =
          _filterCategory == null || e.category == _filterCategory;
      final matchesQuery =
          query.isEmpty || e.title.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
    switch (_sortMode) {
      case 'oldest':
        filteredExpenses.sort((a, b) => a.date.compareTo(b.date));
      case 'highest':
        filteredExpenses
            .sort((a, b) => b.amountPkr.compareTo(a.amountPkr));
      case 'lowest':
        filteredExpenses
            .sort((a, b) => a.amountPkr.compareTo(b.amountPkr));
      default:
        filteredExpenses.sort((a, b) => b.date.compareTo(a.date));
    }

    final Map<String, double> byCategory = {};
    for (final e in scopedExpenses) {
      byCategory[e.category] =
          (byCategory[e.category] ?? 0) + e.amountPkr;
    }
    final topCategory = byCategory.entries.isEmpty
        ? null
        : byCategory.entries
            .reduce((a, b) => a.value >= b.value ? a : b);

    Widget expensesTab() {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _primaryButton(
              label: strings.addExpense,
              onPressed: () {
                Navigator.of(context).push(
                  slideRoute(
                    AddExpenseScreen(budgetId: widget.budgetId),
                  ),
                );
              },
            ),
          ),
          if (scopedExpenses.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: strings.searchHint,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          tooltip: strings.searchExpenses,
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        ),
                ),
                onChanged: (value) =>
                    setState(() => _searchQuery = value),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Text(
                    strings.sortBy,
                    style: TextStyle(color: _secondary(context)),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _sortMode,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(
                        value: 'newest',
                        child: Text(strings.newestFirst),
                      ),
                      DropdownMenuItem(
                        value: 'oldest',
                        child: Text(strings.oldestFirst),
                      ),
                      DropdownMenuItem(
                        value: 'highest',
                        child: Text(strings.highestAmount),
                      ),
                      DropdownMenuItem(
                        value: 'lowest',
                        child: Text(strings.lowestAmount),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _sortMode = value);
                      }
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ChoiceChip(
                    label: Text(strings.allCategories),
                    selected: _filterCategory == null,
                    onSelected: (_) =>
                        setState(() => _filterCategory = null),
                  ),
                  ...expenseCategories.map(
                    (c) => ChoiceChip(
                      label: Text(strings.categoryName(c)),
                      selected: _filterCategory == c,
                      onSelected: (_) =>
                          setState(() => _filterCategory = c),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (scopedExpenses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 48,
                      color: CashWiseTheme.accentFor(context),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      strings.noExpenses,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _secondary(context)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strings.tapToAdd,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _secondary(context)),
                    ),
                  ],
                ),
              ),
            )
          else if (filteredExpenses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  strings.noMatchingExpenses,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _secondary(context)),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredExpenses.length,
              itemBuilder: (context, index) {
                final expense = filteredExpenses[index];
                return Dismissible(
                  key: ValueKey(expense.id),
                  background: Container(color: CashWiseTheme.danger),
                  onDismissed: (_) =>
                      store.removeExpense(expense.id),
                  child: ListTile(
                    onTap: () => Navigator.of(context).push(
                      slideRoute(
                        ExpenseDetailScreen(expense: expense),
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: categoryColor(expense.category)
                          .withValues(alpha: 0.12),
                      foregroundColor:
                          categoryColor(expense.category),
                      child: Icon(
                        categoryIcon(expense.category),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      expense.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // One clean line (v7.2): short date, so the
                    // detail never wraps to three lines.
                    subtitle: Text(
                      '${strings.categoryName(expense.category)} • '
                      '${shortDate(store, expense.date)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          store.formatAmount(expense.amountPkr),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          tooltip: strings.updateExpense,
                          onPressed: () =>
                              Navigator.of(context).push(
                            slideRoute(
                              ExpenseDetailScreen(expense: expense),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: CashWiseTheme.danger,
                          ),
                          tooltip: strings.delete,
                          onPressed: () async {
                            final confirmed = await confirmDelete(
                              context,
                              strings,
                              expense.title,
                            );
                            if (confirmed) {
                              await store.removeExpense(expense.id);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      );
    }

    Widget predictorTab() {
      return Column(
        children: [
          if (scopedExpenses.isNotEmpty)
            CategoryChartCard(store: store, budgetId: widget.budgetId),
          CashFlowPredictorWithChart(
            store: store,
            budgetId: widget.budgetId,
          ),
        ],
      );
    }

    Widget summaryTab() {
      return Card(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
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
              AmountRow(
                label: strings.budget,
                amount: store.formatAmount(scopedBudgetAmount),
              ),
              AmountRow(
                label: strings.spentThisMonth,
                amount: store.formatAmount(scopedSpent),
              ),
              AmountRow(
                label: strings.remaining,
                amount: store.formatAmount(scopedRemaining),
              ),
              AmountRow(
                label: strings.dailyAverage,
                amount: store.formatAmount(scopedDailyAverage),
              ),
              AmountRow(
                label: strings.projectedMonthEnd,
                amount: store.formatAmount(scopedProjected),
              ),
              if (topCategory != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(strings.topCategory),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          '${strings.categoryName(topCategory.key)} — '
                          '${store.formatAmount(topCategory.value)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // The three tabs in ONE prominent line (v7.2): a 3-way
    // segmented control of equal Expanded buttons, 13px labels
    // that scale down instead of wrapping — "Summary" never
    // drops to a second line.
    Widget tabSegment(String key, String label) {
      final selected = _tab == key;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _tab = key),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: selected
                  ? CashWiseTheme.lightAccent
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: CashWiseTheme.headerGradientOf(context),
        ),
        title: Text(strings.statistics),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                const SizedBox(height: 16),
                if (alert != null)
                  Card(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            size: 20,
                            color: isWarning
                                ? CashWiseTheme.warning
                                : CashWiseTheme.danger,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              alert,
                              style: TextStyle(
                                color: isWarning
                                    ? CashWiseTheme.warning
                                    : CashWiseTheme.danger,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        tabSegment('expenses', strings.expenses),
                        tabSegment('predictor', strings.aiPredictor),
                        tabSegment('summary', strings.summary),
                      ],
                    ),
                  ),
                ),
                if (_tab == 'expenses')
                  expensesTab()
                else if (_tab == 'predictor')
                  predictorTab()
                else
                  summaryTab(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
