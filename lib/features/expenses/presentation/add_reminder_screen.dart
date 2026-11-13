// CashWise AI — add your own reminder (v7.0, v7.1).
//
// Two kinds, both set by the user:
//  * Budget — remind me when the remaining amount of the active
//    budget falls to a number I choose.
//  * Loan — remind me on a date (and time) to pay or receive
//    a person's amount.
// A reminder is ALWAYS in the future — never in the past or
// right now (v7.1). The screen can be opened prefilled from a
// loan entry or a single payment ("Set reminder"), so the user
// never has to type the person or amount again. Reminders only
// ever exist because the user set them: nothing is automatic.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/gradient_button.dart';
import '../../../core/styled_date_picker.dart';
import '../../../core/theme.dart';
import '../data/expense_store.dart';

class AddReminderScreen extends StatefulWidget {
  /// Open prefilled from a loan entry or one of its payments:
  /// the person and amount are filled in, the screen starts in
  /// loan mode, and the reminder is linked to that entry (so
  /// deleting the entry removes its reminders too).
  const AddReminderScreen({
    super.key,
    this.initialPerson,
    this.initialAmount,
    this.entryId,
  });

  final String? initialPerson;
  final double? initialAmount;
  final String? entryId;

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  bool _isLoan = false;
  final _thresholdController = TextEditingController();
  final _personController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay? _time;
  String? _error;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    // Opened from a loan entry or payment: start in loan mode
    // with the person and amount already filled in.
    if (widget.initialPerson != null || widget.entryId != null) {
      _isLoan = true;
      if (widget.initialPerson != null) {
        _personController.text = widget.initialPerson!;
      }
      if (widget.initialAmount != null) {
        _amountController.text =
            widget.initialAmount!.toStringAsFixed(0);
      }
    }
  }

  @override
  void dispose() {
    _thresholdController.dispose();
    _personController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final store = context.read<ExpenseStore>();
    final strings = store.strings;
    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch.toString();
    if (_isLoan) {
      if (_personController.text.trim().isEmpty) {
        setState(() => _error = strings.enterPersonName);
        return;
      }
      // A reminder is always in the future — never in the
      // past, and never right now (v7.1).
      if (!ExpenseStore.dueMomentIsFuture(_date, _time)) {
        setState(() => _dateError = strings.reminderMustBeFuture);
        return;
      }
      final amount = double.tryParse(_amountController.text.trim());
      await store.addCustomReminder({
        'id': id,
        'kind': 'loan',
        'person': _personController.text.trim(),
        'amount': amount,
        'date': DateTime(_date.year, _date.month, _date.day)
            .toIso8601String(),
        'timeMinutes': _time == null
            ? null
            : _time!.hour * 60 + _time!.minute,
        'note': _noteController.text.trim(),
        'entryId': widget.entryId,
        'createdAt': now.toIso8601String(),
      });
    } else {
      final threshold =
          double.tryParse(_thresholdController.text.trim());
      if (threshold == null || threshold < 0) {
        setState(() => _error = strings.enterValidBudget);
        return;
      }
      await store.addCustomReminder({
        'id': id,
        'kind': 'budget',
        'threshold': threshold,
        'note': _noteController.text.trim(),
        'createdAt': now.toIso8601String(),
      });
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.reminderAdded)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseStore>();
    final strings = store.strings;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: CashWiseTheme.headerGradientOf(context),
        ),
        title: Text(strings.addReminder),
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
                  SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: false,
                        label: Text(strings.budgetReminder),
                        icon: const Icon(Icons.account_balance_wallet),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text(strings.loanReminder),
                        icon: const Icon(Icons.handshake),
                      ),
                    ],
                    selected: {_isLoan},
                    onSelectionChanged: (s) {
                      setState(() {
                        _isLoan = s.first;
                        _error = null;
                        _dateError = null;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  if (!_isLoan) ...[
                    Text(
                      strings.remindWhenRemaining,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _thresholdController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: strings.remainingAmount,
                        errorText: _error,
                        prefixText: store.currencyPrefix,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${strings.remaining}: '
                      '${store.formatAmount(store.remaining)}',
                      style: const TextStyle(
                        color: CashWiseTheme.secondaryText,
                      ),
                    ),
                  ] else ...[
                    TextField(
                      controller: _personController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: strings.personName,
                        errorText: _error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: strings.amount,
                        prefixText: store.currencyPrefix,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showStyledDatePicker(
                                context: context,
                                initialDate: _date,
                                firstDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() => _date = picked);
                              }
                            },
                            icon: const Icon(Icons.calendar_today),
                            label: Text(store.formatDate(_date)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showStyledTimePicker(
                                context: context,
                                initialTime: _time ?? TimeOfDay.now(),
                              );
                              if (picked != null) {
                                setState(() => _time = picked);
                              }
                            },
                            icon: const Icon(Icons.access_time),
                            label: Text(
                              _time == null
                                  ? strings.setDueTime
                                  : store.formatTimeOfDay(_time!),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_dateError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _dateError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: strings.note,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    label: strings.saveReminder,
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
