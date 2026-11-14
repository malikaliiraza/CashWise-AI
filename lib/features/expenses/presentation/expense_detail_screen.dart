// CashWise AI — expense detail page (v4.5).
//
// Tapping an expense in the list opens this page instead of editing
// inline: title, amount, category and date, with Edit and Delete.
// Edit opens the same prefilled form on this page; Delete asks first.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/delete_icon_button.dart';
import '../../../core/gradient_button.dart';
import '../../../core/styled_date_picker.dart';
import '../../../core/theme.dart';
import '../data/expense_store.dart';
import '../models/expense.dart';
import 'category_style.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final Expense expense;

  const ExpenseDetailScreen({super.key, required this.expense});

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late String _category;
  late DateTime _selectedDate;
  bool _editing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense.title);
    _amountController = TextEditingController(
      text: widget.expense.amountPkr.toStringAsFixed(0),
    );
    _category = widget.expense.category;
    _selectedDate = widget.expense.date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final store = context.read<ExpenseStore>();
    final strings = store.strings;
    final amount = double.tryParse(_amountController.text.trim());
    final title = _titleController.text.trim();
    if (title.isEmpty || amount == null || amount <= 0) {
      setState(() => _error = strings.enterTitleValidAmount);
      return;
    }
    await store.updateExpense(
      Expense(
        id: widget.expense.id,
        title: title,
        amountPkr: amount,
        category: _category,
        date: _selectedDate,
      ),
    );
    if (mounted) setState(() => _editing = false);
  }

  Future<void> _confirmDelete() async {
    final store = context.read<ExpenseStore>();
    final strings = store.strings;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.delete),
        content: Text(strings.deleteExpenseConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              strings.delete,
              style: const TextStyle(color: CashWiseTheme.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await store.removeExpense(widget.expense.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseStore>();
    final strings = store.strings;
    final expense = widget.expense;
    final date = expense.date;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: CashWiseTheme.headerGradientOf(context),
        ),
        title: Text(strings.categoryName(expense.category)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: categoryColor(
                                expense.category,
                              ).withValues(alpha: 0.12),
                              foregroundColor:
                                  categoryColor(expense.category),
                              child: Icon(
                                categoryIcon(expense.category),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                expense.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          store.formatAmount(expense.amountPkr),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: CashWiseTheme.accentFor(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${strings.categoryName(expense.category)} • '
                          '${store.formatDate(date)}',
                          style: TextStyle(
                            color:
                                CashWiseTheme.secondaryTextFor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_editing) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            strings.editExpense,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: strings.whatDidYouSpend,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: strings.amountLabel,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _category,
                            decoration: InputDecoration(
                              labelText: strings.category,
                            ),
                            items: expenseCategories
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(strings.categoryName(c)),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _category = value);
                              }
                            },
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _error!,
                              style: const TextStyle(
                                color: CashWiseTheme.danger,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showStyledDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                              );
                              if (picked != null) {
                                setState(() => _selectedDate = picked);
                              }
                            },
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              '${strings.date}: '
                              '${store.formatDate(_selectedDate)}',
                            ),
                          ),
                          const SizedBox(height: 16),
                          GradientButton(
                            label: strings.updateExpense,
                            onPressed: _save,
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // v7.2: balanced row — the standard 48dp
                  // GradientButton (normal 16px bold label, never
                  // oversized) beside a proper-size bin: 22dp
                  // icon on a 40dp tap target.
                  Row(
                    children: [
                      Expanded(
                        child: GradientButton(
                          label: strings.editExpense,
                          onPressed: () =>
                              setState(() => _editing = true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      DeleteIconButton(
                        iconSize: 22,
                        tooltip: strings.delete,
                        onPressed: _confirmDelete,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
