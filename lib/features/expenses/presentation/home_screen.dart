import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization.dart';
import '../../../core/theme.dart';
import '../data/expense_store.dart';
import '../models/expense.dart';
import 'category_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _budgetController = TextEditingController();
  // Stored as an English key; only the display name is translated.
  String _category = expenseCategories.first;
  // Inline errors shown INSIDE the open sheet. A SnackBar must not be
  // used for validation here: the modal bottom sheet sits on top of the
  // Scaffold, so a SnackBar ends up hidden behind the sheet, cut off
  // at the very bottom of the screen (the bug in the screenshot).
  String? _addError;
  String? _budgetError;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _addExpense(StateSetter setSheetState) async {
    final store = context.read<ExpenseStore>();
    final strings = store.strings;
    final amount = double.tryParse(_amountController.text.trim());
    final title = _titleController.text.trim();
    if (title.isEmpty || amount == null || amount <= 0) {
      setSheetState(() {
        _addError = strings.enterTitleValidAmount;
      });
      return;
    }
    _addError = null;
    await store.addExpense(
      Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        amountPkr: amount,
        category: _category,
        date: DateTime.now(),
      ),
    );
    _titleController.clear();
    _amountController.clear();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _saveBudget(StateSetter setSheetState) async {
    final store = context.read<ExpenseStore>();
    final strings = store.strings;
    final amount = double.tryParse(_budgetController.text.trim());
    if (amount == null || amount <= 0) {
      setSheetState(() {
        _budgetError = strings.enterValidBudget;
      });
      return;
    }
    _budgetError = null;
    await store.setMonthlyBudget(amount);
    if (!mounted) return;
    Navigator.of(context).pop();
    // Sheet is closed now, so a SnackBar is visible again. Floating
    // with a margin so it sits clearly above the bottom edge, not
    // hidden behind the navigation area.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        content: Text(strings.budgetUpdated(store.formatAmount(amount))),
      ),
    );
  }

  void _showBudgetSheet() {
    final store = context.read<ExpenseStore>();
    final strings = store.strings;
    _budgetController.text =
        store.monthlyBudgetPkr.toStringAsFixed(0);
    _budgetError = null;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                strings.editMonthlyBudget,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: strings.monthlyBudgetLabel,
                  errorText: _budgetError,
                ),
                onChanged: (_) {
                  if (_budgetError != null) {
                    setSheetState(() => _budgetError = null);
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _saveBudget(setSheetState),
                child: Text(strings.saveBudget),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSheet() {
    final store = context.read<ExpenseStore>();
    final strings = store.strings;
    _addError = null;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                strings.addExpense,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: strings.whatDidYouSpend,
                ),
                onChanged: (_) {
                  if (_addError != null) {
                    setSheetState(() => _addError = null);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: strings.amountLabel,
                ),
                onChanged: (_) {
                  if (_addError != null) {
                    setSheetState(() => _addError = null);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(
                  labelText: strings.category,
                ),
                items: expenseCategories
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(strings.categoryName(c)),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              if (_addError != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: CashWiseTheme.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 20,
                        color: CashWiseTheme.danger,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _addError!,
                          style: const TextStyle(
                            color: CashWiseTheme.danger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _addExpense(setSheetState),
                child: Text(strings.saveExpense),
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
    final locale = store.locale;
    final alert = store.alertMessage;
    final isWarning = alert != null && store.spentFraction < 1;

    return Directionality(
      textDirection: locale.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('CashWise AI'),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.language),
              tooltip: strings.language,
              onSelected: (code) => store.setLocale(code),
              itemBuilder: (context) => appLocales
                  .map(
                    (item) => PopupMenuItem<String>(
                      value: item.code,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.nativeName} · ${item.country}',
                            ),
                          ),
                          if (item.code == locale.code)
                            const Icon(
                              Icons.check,
                              size: 18,
                              color: CashWiseTheme.primary,
                            ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        body: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${strings.spentThisMonth}: ${store.formatAmount(store.totalSpent)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${strings.budget}: ${store.formatAmount(store.monthlyBudgetPkr)}  •  '
                            '${strings.remaining}: ${store.formatAmount(store.remaining)}',
                            style: const TextStyle(
                              color: CashWiseTheme.secondaryText,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _showBudgetSheet,
                          icon: const Icon(Icons.edit),
                          tooltip: strings.editMonthlyBudget,
                          color: CashWiseTheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: store.spentFraction.clamp(0, 1),
                        minHeight: 8,
                      ),
                    ),
                    if (alert != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        alert,
                        style: TextStyle(
                          color: isWarning
                              ? CashWiseTheme.warning
                              : CashWiseTheme.danger,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (store.expenses.isNotEmpty)
              CategoryChartCard(store: store),
            Expanded(
              child: store.expenses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                    )
                  : ListView.builder(
                      itemCount: store.expenses.length,
                      itemBuilder: (context, index) {
                        final expense = store.expenses[index];
                        return Dismissible(
                          key: ValueKey(expense.id),
                          background: Container(color: CashWiseTheme.danger),
                          onDismissed: (_) =>
                              store.removeExpense(expense.id),
                          child: ListTile(
                            title: Text(expense.title),
                            subtitle: Text(
                              strings.categoryName(expense.category),
                            ),
                            trailing: Text(
                              store.formatAmount(expense.amountPkr),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddSheet,
          tooltip: strings.addExpense,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
