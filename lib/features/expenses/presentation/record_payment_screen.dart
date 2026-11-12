// CashWise AI — Record Payment screen (v5.8).
//
// A full page (not a sheet) for recording a payment — full or
// partial, it works even when the payment is not complete. The
// user enters the amount, the date and the time, and saves: the
// payment is stored with its amount, date, weekday and time.
// Below the form, the full history of this entry's payments:
// how much was added/paid, on which date, which day, at what
// time. Opened from the detail sheet's Payable button.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/gradient_button.dart';
import '../../../core/styled_date_picker.dart';
import '../../../core/theme.dart';
import '../data/expense_store.dart';
import '../models/udhar_entry.dart';

class RecordPaymentScreen extends StatefulWidget {
  final UdharEntry entry;

  const RecordPaymentScreen({super.key, required this.entry});

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final _amountController = TextEditingController();
  DateTime _date = DateTime.now();
  TimeOfDay? _time;
  String? _error;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final store = context.read<ExpenseStore>();
    final strings = store.strings;
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = strings.enterTitleValidAmount);
      return;
    }
    // A payment can never be in the future: not a later date,
    // and not a later time today.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(_date.year, _date.month, _date.day);
    if (day.isAfter(today)) {
      setState(() => _date = today);
    }
    if (day == today &&
        _time != null &&
        (_time!.hour * 60 + _time!.minute) >
            now.hour * 60 + now.minute) {
      setState(() => _time = TimeOfDay(
            hour: now.hour,
            minute: now.minute,
          ));
    }
    final entry = store.udharEntries.firstWhere(
      (e) => e.id == widget.entry.id,
      orElse: () => widget.entry,
    );
    await store.addUdharPayment(
      id: entry.id,
      amount: amount,
      date: _date,
      timeMinutes: _time == null ? null : _time!.hour * 60 + _time!.minute,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseStore>();
    final strings = store.strings;
    final entry = store.udharEntries.firstWhere(
      (e) => e.id == widget.entry.id,
      orElse: () => widget.entry,
    );

    Widget row(String label, String value, {Color? valueColor}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: CashWiseTheme.secondaryText),
            ),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: CashWiseTheme.headerGradientOf(context),
        ),
        title: Text(strings.addPayment),
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
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.displayPerson(entry.person),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.isLent
                                ? strings.moneyLent
                                : strings.moneyBorrowed,
                            style: const TextStyle(
                              color: CashWiseTheme.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          row(
                            strings.totalAmount,
                            store.formatAmount(entry.amountPkr),
                          ),
                          row(
                            strings.paidSoFar,
                            store.formatAmount(entry.paidSoFar),
                          ),
                          row(
                            strings.remainingAmount,
                            store.formatAmount(entry.remaining),
                            valueColor: entry.remaining > 0
                                ? CashWiseTheme.danger
                                : CashWiseTheme.success,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: strings.paymentAmount,
                      prefixText: store.currencyPrefix,
                    ),
                    onChanged: (_) {
                      if (_error != null) setState(() => _error = null);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showStyledDatePicker(
                              context: context,
                              initialDate: _date,
                              // A payment can never be dated in the future.
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() => _date = picked);
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            '${strings.date}: '
                            '${_date.day}/${_date.month}/${_date.year} '
                            '(${store.weekdayName(_date)})',
                          ),
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
                                ? strings.paymentTime
                                : store.formatTimeOfDay(_time!),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: CashWiseTheme.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  GradientButton(
                    label: strings.addPayment,
                    onPressed: entry.settled ? null : _save,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    strings.paymentHistory,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (entry.payments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        strings.noPaymentsYet,
                        style: const TextStyle(
                          color: CashWiseTheme.secondaryText,
                        ),
                      ),
                    )
                  else
                    ...entry.payments.asMap().entries.map((e) {
                      final p = e.value;
                      final time = p.timeMinutes == null
                          ? null
                          : store.formatMinutes(p.timeMinutes!);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(store.formatAmount(p.amount)),
                          subtitle: Text(
                            '${p.date.day}/${p.date.month}/${p.date.year}'
                            ' • ${store.weekdayName(p.date)}'
                            '${time == null ? '' : ' • $time'}',
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: entry.settled
                                  ? CashWiseTheme.secondaryText
                                  : CashWiseTheme.danger,
                            ),
                            tooltip: strings.delete,
                            onPressed: entry.settled
                                ? null
                                : () async {
                                    await context
                                        .read<ExpenseStore>()
                                        .removeUdharPayment(
                                            entry.id, e.key);
                                  },
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
