// CashWise AI — add expense page (v4.7).
//
// A full screen, not a sheet: title, amount, and category chips.
// The AppBar back button returns home.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/styled_date_picker.dart';
import '../../../core/page_transitions.dart';
import '../../../core/theme.dart';
import '../data/expense_store.dart';
import '../models/expense.dart';
import 'budget_detail_screen.dart' show shortDate;
import 'budget_screen.dart';

class AddExpenseScreen extends StatefulWidget {
  /// Optional: add the expense to this budget (v7.2). Null =
  /// the active budget, as before.
  final String? budgetId;

  const AddExpenseScreen({super.key, this.budgetId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = expenseCategories.first;
  DateTime _selectedDate = DateTime.now();
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final store = context.read<ExpenseStore>();
    // Safety net: even if the date came from elsewhere, a
    // future expense is never saved.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_selectedDate.isAfter(today)) {
      setState(() => _selectedDate = today);
    }
    final strings = store.strings;
    final amount = double.tryParse(_amountController.text.trim());
    final title = _titleController.text.trim();
    if (title.isEmpty || amount == null || amount <= 0) {
      setState(() => _error = strings.enterTitleValidAmount);
      return;
    }
    // Scoped save (v7.2): addExpense stamps the ACTIVE
    // budget, so make the target budget active first — the
    // expense then lands in that budget's book, not the
    // previously active one.
    if (widget.budgetId != null &&
        widget.budgetId != store.activeBudgetId) {
      await store.switchBudget(widget.budgetId!);
    }
    await store.addExpense(
      Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        amountPkr: amount,
        category: _category,
        date: _selectedDate,
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseStore>();
    final strings = store.strings;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary = isDark
        ? CashWiseTheme.darkSecondaryText
        : CashWiseTheme.secondaryText;
    // The budget this expense goes to (v7.2): the scoped one
    // when budgetId is given, otherwise the active budget.
    final targetBudget = widget.budgetId == null
        ? store.activeBudget
        : store.budgets
            .where((b) => b.id == widget.budgetId)
            .firstOrNull ??
            store.activeBudget;
    final hasTargetBudget =
        targetBudget != null && targetBudget.amount > 0;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: CashWiseTheme.headerGradientOf(context),
        ),
        title: Text(strings.addExpense),
      ),
      // Budget first: no expense can be added until a monthly
      // budget exists. The screen explains why and opens the
      // budget screen instead of the form.
      body: !hasTargetBudget
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 56,
                      color: CashWiseTheme.accentFor(context),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      strings.setBudgetFirst,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      strings.budgetRequired,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: secondary),
                    ),
                    const SizedBox(height: 24),
                    _PrimaryButton(
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
            )
          : SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.budgetId != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        store.budgetDisplayName(targetBudget),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: strings.whatDidYouSpend,
                    ),
                    onChanged: (_) {
                      if (_error != null) {
                        setState(() => _error = null);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: strings.amountLabel,
                      prefixText: store.currencyPrefix,
                    ),
                    onChanged: (_) {
                      if (_error != null) {
                        setState(() => _error = null);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showStyledDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_today, size: 20),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${strings.date}: '
                          '${shortDate(store, _selectedDate)}',
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    strings.category,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: expenseCategories
                        .map(
                          (c) => ChoiceChip(
                            label: Text(strings.categoryName(c)),
                            selected: _category == c,
                            onSelected: (_) =>
                                setState(() => _category = c),
                          ),
                        )
                        .toList(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: CashWiseTheme.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _PrimaryButton(
                    label: strings.saveExpense,
                    onPressed: _save,
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

/// Primary button (v7.2): fixed 48dp, label fully visible —
/// FittedBox scaleDown, one line, never ellipsised.
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
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
}
