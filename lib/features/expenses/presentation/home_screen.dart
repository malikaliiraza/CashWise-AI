import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/expense_store.dart';
import '../models/expense.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _budgetController = TextEditingController();
  String _category = expenseCategories.first;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _addExpense() async {
    final amount = double.tryParse(_amountController.text.trim());
    final title = _titleController.text.trim();
    if (title.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a title and a valid PKR amount.')),
      );
      return;
    }
    await context.read<ExpenseStore>().addExpense(
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

  Future<void> _saveBudget() async {
    final amount = double.tryParse(_budgetController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid budget above Rs. 0.')),
      );
      return;
    }
    await context.read<ExpenseStore>().setMonthlyBudget(amount);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Monthly budget updated to Rs. ${amount.toStringAsFixed(0)}.',
        ),
      ),
    );
  }

  void _showBudgetSheet() {
    _budgetController.text =
        context.read<ExpenseStore>().monthlyBudgetPkr.toStringAsFixed(0);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Edit monthly budget',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monthly budget (PKR)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveBudget,
              child: const Text('Save budget'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add expense',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'What did you spend on?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (PKR)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: expenseCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addExpense,
              child: const Text('Save expense'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseStore>();
    final alert = store.alertMessage;

    return Scaffold(
      appBar: AppBar(title: const Text('CashWise AI')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spent this month: Rs. ${store.totalSpent.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Budget: Rs. ${store.monthlyBudgetPkr.toStringAsFixed(0)}  •  Remaining: Rs. ${store.remaining.toStringAsFixed(0)}',
                        ),
                      ),
                      IconButton(
                        onPressed: _showBudgetSheet,
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit budget',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: store.spentFraction.clamp(0, 1),
                  ),
                  if (alert != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      alert,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: store.expenses.isEmpty
                ? const Center(
                    child: Text(
                      'No expenses yet.\nTap + to add your first one.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: store.expenses.length,
                    itemBuilder: (context, index) {
                      final expense = store.expenses[index];
                      return Dismissible(
                        key: ValueKey(expense.id),
                        background: Container(color: Colors.red),
                        onDismissed: (_) =>
                            store.removeExpense(expense.id),
                        child: ListTile(
                          title: Text(expense.title),
                          subtitle: Text(expense.category),
                          trailing: Text(
                            'Rs. ${expense.amountPkr.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
