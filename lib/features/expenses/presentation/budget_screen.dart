// CashWise AI — set monthly budget page (v4.7).
//
// A full screen, not a sheet: preset budget options (Rs. 10,000 –
// Rs. 100,000) plus a custom amount field. The user's current budget
// is shown and prefilled. The AppBar back button returns home.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../data/expense_store.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  static const List<double> _presets = [
    10000,
    25000,
    50000,
    75000,
    100000,
  ];

  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  double? _selectedPreset;
  String? _error;

  /// False = edit the active budget's amount; true = add
  /// another budget (a new book with its own expenses).
  bool _addingNew = false;

  @override
  void initState() {
    super.initState();
    final store = context.read<ExpenseStore>();
    final budget = store.monthlyBudgetPkr;
    if (budget > 0) {
      _amountController.text = budget.toStringAsFixed(0);
      if (_presets.contains(budget)) _selectedPreset = budget;
      _nameController.text = store.activeBudget?.name ?? '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final store = context.read<ExpenseStore>();
    final strings = store.strings;
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = strings.enterValidBudget);
      return;
    }
    if (_addingNew) {
      await store.addBudget(amount, name: _nameController.text);
    } else {
      await store.setMonthlyBudget(amount, name: _nameController.text);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        content: Text(strings.budgetUpdated(store.formatAmount(amount))),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseStore>();
    final strings = store.strings;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary = isDark
        ? CashWiseTheme.darkSecondaryText
        : CashWiseTheme.secondaryText;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: CashWiseTheme.headerGradientOf(context),
        ),
        title: Text(strings.setMonthlyBudget),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    strings.chooseBudget,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (store.monthlyBudgetPkr > 0)
                    Text(
                      '${strings.budget}: '
                      '${store.formatAmount(store.monthlyBudgetPkr)}',
                      style: TextStyle(color: secondary),
                    ),
                  // Edit the active budget, or add another one.
                  // The whole system works the same on every
                  // budget: each has its own expenses and totals.
                  if (store.budgets.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(
                          value: false,
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              strings.editBudget,
                              maxLines: 1,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                        ButtonSegment(
                          value: true,
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              strings.addAnotherBudget,
                              maxLines: 1,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                      selected: {_addingNew},
                      onSelectionChanged: (s) {
                        setState(() {
                          _addingNew = s.first;
                          if (_addingNew) {
                            _amountController.clear();
                            _nameController.clear();
                            _selectedPreset = null;
                          } else {
                            final budget = store.monthlyBudgetPkr;
                            if (budget > 0) {
                              _amountController.text =
                                  budget.toStringAsFixed(0);
                            }
                            _nameController.text =
                                store.activeBudget?.name ?? '';
                          }
                          _error = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      strings.yourBudgets,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (var i = 0; i < store.budgets.length; i++)
                          ChoiceChip(
                            label: Text(
                              '${store.budgetDisplayName(store.budgets[i])} — '
                              '${store.formatAmount(store.budgets[i].amount)}',
                            ),
                            selected: store.budgets[i].id ==
                                store.activeBudgetId,
                            onSelected: (_) async {
                              await store
                                  .switchBudget(store.budgets[i].id);
                              if (!mounted) return;
                              setState(() {
                                _addingNew = false;
                                _amountController.text = store
                                    .monthlyBudgetPkr
                                    .toStringAsFixed(0);
                                _nameController.text =
                                    store.activeBudget?.name ?? '';
                                _selectedPreset = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _presets
                        .map(
                          (preset) => ChoiceChip(
                            label: Text(store.formatAmount(preset)),
                            selected: _selectedPreset == preset,
                            onSelected: (_) {
                              setState(() {
                                _selectedPreset = preset;
                                _amountController.text =
                                    preset.toStringAsFixed(0);
                                _error = null;
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: strings.budgetName,
                      hintText: strings.budgetNameHint,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: strings.customAmount,
                      errorText: _error,
                      prefixText: store.currencyPrefix,
                    ),
                    onChanged: (_) {
                      if (_error != null) {
                        setState(() => _error = null);
                      }
                      final value =
                          double.tryParse(_amountController.text.trim());
                      setState(() {
                        _selectedPreset =
                            value != null && _presets.contains(value)
                                ? value
                                : null;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _PrimaryButton(
                    label: strings.saveBudget,
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
