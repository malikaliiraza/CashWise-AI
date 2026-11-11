// CashWise AI — details page (v4.8).
//
// Three options, one screen: Expenses (default — the full list with
// search, category filter and sort), AI Predictor (chart + cash-flow
// prediction), and Summary (spent, remaining, daily average,
// projected month-end, top category). The budget alert (80% warning
// / 100% overspend) shows as a banner at the top here, and the same
// alert also fires a mobile notification on phones. The AppBar back
// button returns home.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/confirm_dialog.dart';
import '../../../core/gradient_button.dart';
import '../../../core/page_transitions.dart';
import '../../../core/theme.dart';
import '../data/expense_store.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';
import 'cashflow_predictor.dart';
import 'category_chart.dart';
import 'category_style.dart';
import 'expense_detail_screen.dart';

class StatisticsScreen extends StatefulWidget {
  /// Which tab to open on: 0 = Expenses, 1 = AI Predictor,
  /// 2 = Summary. Home menu options and the drawer open the
  /// page straight onto the tab they mean (v5.0).
  final int initialTab;

  const StatisticsScreen({super.key, this.initialTab = 0});

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

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseStore>();
    final strings = store.strings;
    final alert = store.alertMessage;
    final isWarning = alert != null && store.spentFraction < 1;

    final query = _searchQuery.trim().toLowerCase();
    final filteredExpenses = store.expenses.where((e) {
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
    for (final e in store.expenses) {
      byCategory[e.category] =
          (byCategory[e.category] ?? 0) + e.amountPkr;
    }
    final topCategory = byCategory.entries.isEmpty
        ? null
        : byCategory.entries
            .reduce((a, b) => a.value >= b.value ? a : b);

    Widget summaryRow(String label, String value) {
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

    Widget tabChip(String key, String label) {
      return ChoiceChip(
        label: Text(label),
        selected: _tab == key,
        onSelected: (_) => setState(() => _tab = key),
      );
    }

    Widget expensesTab() {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: GradientButton(
              label: strings.addExpense,
              onPressed: () {
                Navigator.of(context).push(
                  slideRoute(const AddExpenseScreen()),
                );
              },
            ),
          ),
          if (store.expenses.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: strings.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
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
                    style: const TextStyle(
                      color: CashWiseTheme.secondaryText,
                    ),
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
          if (store.expenses.isEmpty)
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
                      style: const TextStyle(
                        color: CashWiseTheme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strings.tapToAdd,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: CashWiseTheme.secondaryText,
                      ),
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
                  style: const TextStyle(
                    color: CashWiseTheme.secondaryText,
                  ),
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
                    title: Text(expense.title),
                    subtitle: Text(
                      '${strings.categoryName(expense.category)} • '
                      '${expense.date.day}/${expense.date.month}/'
                      '${expense.date.year}',
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
          if (store.expenses.isNotEmpty)
            CategoryChartCard(store: store),
          CashFlowPredictorWithChart(store: store),
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
              summaryRow(
                strings.budget,
                store.formatAmount(store.monthlyBudgetPkr),
              ),
              summaryRow(
                strings.spentThisMonth,
                store.formatAmount(store.totalSpent),
              ),
              summaryRow(
                strings.remaining,
                store.formatAmount(store.remaining),
              ),
              summaryRow(
                strings.dailyAverage,
                store.formatAmount(store.dailyAverageSpend),
              ),
              summaryRow(
                strings.projectedMonthEnd,
                store.formatAmount(store.projectedMonthEndSpend),
              ),
              if (topCategory != null)
                summaryRow(
                  strings.topCategory,
                  strings.categoryName(topCategory.key),
                ),
            ],
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
                  child: Wrap(
                    spacing: 8,
                    children: [
                      tabChip('expenses', strings.expenses),
                      tabChip('predictor', strings.aiPredictor),
                      tabChip('summary', strings.summary),
                    ],
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
