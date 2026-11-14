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

import '../../../core/amount_row.dart';
import '../../../core/styled_date_picker.dart';
import '../../../core/theme.dart';
import '../data/expense_store.dart';
import '../models/udhar_entry.dart';
import 'budget_detail_screen.dart' show shortDate;

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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary = isDark
        ? CashWiseTheme.darkSecondaryText
        : CashWiseTheme.secondaryText;
    Widget row(String label, String value, {Color? valueColor}) {
      // AmountRow (v7.2): label wraps, amount stays in its own
      // right-aligned column.
      return AmountRow(
        label: label,
        amount: value,
        amountStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: valueColor,
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
                            style: TextStyle(color: secondary),
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
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showStyledDatePicker(
                                context: context,
                                initialDate: _date,
                              );
                              if (picked != null) {
                                setState(() => _date = picked);
                              }
                            },
                            icon:
                                const Icon(Icons.calendar_today, size: 20),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${strings.date}: '
                                '${shortDate(store, _date)} '
                                '(${store.weekdayName(_date)})',
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 48,
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
                            icon:
                                const Icon(Icons.access_time, size: 20),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _time == null
                                    ? strings.paymentTime
                                    : store.formatTimeOfDay(_time!),
                                maxLines: 1,
                              ),
                            ),
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
                  _PrimaryButton(
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
                        style: TextStyle(color: secondary),
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
                            '${shortDate(store, p.date)}'
                            ' • ${store.weekdayName(p.date)}'
                            '${time == null ? '' : ' • $time'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: entry.settled
                                  ? secondary
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
