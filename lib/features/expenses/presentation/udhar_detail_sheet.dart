// CashWise AI — Loan Ledger entry detail (v5.5).
//
// The full detail of one receivable/payable, opened by tapping
// an entry in the Receivables or Payables list:
//   - total amount, paid so far, remaining (what is still owed)
//   - due date + time, with a button to change them
//   - payment history: every partial payment with its date,
//     weekday and time ("Rs. 1,000 received on 12 November 2026,
//     Thursday, 9:42 PM")
//   - details only (v6.0): payments are recorded from the
//     Receivables / Payables pages, never from this sheet
//   - mark settled / mark pending, and a delete icon
// The sheet always reads the entry fresh from the store, so it
// updates live as payments are added.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/confirm_dialog.dart';
import '../../../core/delete_icon_button.dart';
import '../../../core/gradient_button.dart';
import '../../../core/page_transitions.dart';
import '../../../core/styled_date_picker.dart';
import '../../../core/theme.dart';
import '../data/expense_store.dart';
import '../models/udhar_entry.dart';
import 'add_reminder_screen.dart';

class UdharDetailSheet extends StatefulWidget {
  final UdharEntry entry;

  const UdharDetailSheet({super.key, required this.entry});

  static Future<void> show(BuildContext context, UdharEntry entry) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => UdharDetailSheet(entry: entry),
    );
  }

  @override
  State<UdharDetailSheet> createState() => _UdharDetailSheetState();
}

class _UdharDetailSheetState extends State<UdharDetailSheet> {

  Future<void> _changeDueDate(UdharEntry entry) async {
    final store = context.read<ExpenseStore>();
    final picked = await showStyledDatePicker(
      context: context,
      initialDate: entry.dueDate ?? DateTime.now(),
    );
    if (picked != null) {
      await store.updateUdhar(entry.copyWith(dueDate: picked));
    }
  }

  Future<void> _changeDueTime(UdharEntry entry) async {
    final store = context.read<ExpenseStore>();
    final current = entry.dueTimeMinutes;
    final picked = await showStyledTimePicker(
      context: context,
      initialTime: current == null
          ? TimeOfDay.now()
          : TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (picked != null) {
      await store.updateUdhar(
        entry.copyWith(dueTimeMinutes: picked.hour * 60 + picked.minute),
      );
    }
  }

  /// One payment's full details (v7.0): who, how much, when
  /// (date, weekday, time), and what was left after it.
  Future<void> _showPaymentDetails(
    BuildContext context,
    UdharEntry entry,
    int paymentIndex,
  ) async {
    final store = context.read<ExpenseStore>();
    final strings = store.strings;
    final p = entry.payments[paymentIndex];
    final paidAfter = entry.payments
        .take(paymentIndex + 1)
        .fold(0.0, (s, x) => s + x.amount);
    final remainingAfter =
        (entry.amountPkr - paidAfter).clamp(0.0, double.infinity);
    Widget detailRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: CashWiseTheme.secondaryText),
            ),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.paymentDetails),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            detailRow(
              strings.personName,
              store.displayPerson(entry.person),
            ),
            detailRow(
              strings.totalAmount,
              store.formatAmount(entry.amountPkr),
            ),
            detailRow(
              strings.thisPayment,
              store.formatAmount(p.amount),
            ),
            detailRow(
              strings.date,
              '${store.formatDate(p.date)} • ${store.weekdayName(p.date)}',
            ),
            if (p.timeMinutes != null)
              detailRow(
                strings.paymentTime,
                store.formatMinutes(p.timeMinutes!),
              ),
            detailRow(
              strings.paidSoFar,
              store.formatAmount(paidAfter),
            ),
            detailRow(
              strings.remainingAfterPayment,
              store.formatAmount(remainingAfter),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseStore>();
    final strings = store.strings;
    // Always read the entry fresh — it changes as payments land.
    final entry = store.udharEntries.firstWhere(
      (e) => e.id == widget.entry.id,
      orElse: () => widget.entry,
    );
    final status = entry.dueStatus;
    final statusText = status == DueStatus.overdue
        ? strings.overdue
        : status == DueStatus.dueToday
            ? strings.dueToday
            : status == DueStatus.dueTomorrow
                ? strings.dueTomorrow
                : status == DueStatus.dueInWeek
                    ? strings.dueInDays(entry.daysUntilDue ?? 0)
                    : entry.dueDate == null
                        ? strings.noDueDate
                        : store.formatDate(entry.dueDate!);

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
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
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
              entry.isLent ? strings.moneyLent : strings.moneyBorrowed,
              style: const TextStyle(color: CashWiseTheme.secondaryText),
            ),
            const SizedBox(height: 12),
            row(strings.totalAmount, store.formatAmount(entry.amountPkr)),
            row(strings.paidSoFar, store.formatAmount(entry.paidSoFar)),
            row(
              strings.remainingAmount,
              store.formatAmount(entry.remaining),
              valueColor: entry.remaining > 0
                  ? CashWiseTheme.danger
                  : CashWiseTheme.success,
            ),
            row(
              strings.dueDate,
              entry.dueDate == null
                  ? strings.noDueDate
                  : store.formatDate(entry.dueDate!),
            ),
            row(
              strings.dueTime,
              store.formatDueTime(entry) ?? strings.noDueDate,
            ),
            row(strings.nextDue, statusText),
            if (entry.note.isNotEmpty)
              row(strings.note, entry.note),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    // Locked once settled: tap Mark pending first.
                    onPressed: entry.settled
                        ? null
                        : () => _changeDueDate(entry),
                    icon: Icon(
                      entry.settled
                          ? Icons.lock
                          : Icons.calendar_today,
                      size: 18,
                    ),
                    label: Text(
                      strings.setDueDate,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: entry.settled
                        ? null
                        : () => _changeDueTime(entry),
                    icon: Icon(
                      entry.settled
                          ? Icons.lock
                          : Icons.access_time,
                      size: 18,
                    ),
                    label: Text(
                      strings.setDueTime,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            if (entry.dueDate != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: entry.settled
                    ? null
                    : () async {
                        await context
                            .read<ExpenseStore>()
                            .updateUdhar(entry.copyWith(clearDue: true));
                      },
                child: Text(strings.removeDueDate),
              ),
            ],
            const SizedBox(height: 16),
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
              ...entry.payments.asMap().entries.map(
                (e) {
                  final p = e.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(store.formatAmount(p.amount)),
                        Text(
                          '${store.formatDate(p.date)}'
                          ' • ${store.weekdayName(p.date)}'
                          '${p.timeMinutes == null ? '' : ' • ${store.formatMinutes(p.timeMinutes!)}'}',
                          style: const TextStyle(
                            color: CashWiseTheme.secondaryText,
                          ),
                        ),
                        // A small Details button for this one
                        // payment (v7.0): the full story of
                        // when and how much was paid.
                        IconButton(
                          icon: const Icon(
                            Icons.info_outline,
                            size: 20,
                            color: CashWiseTheme.lightAccent,
                          ),
                          tooltip: strings.details,
                          onPressed: () => _showPaymentDetails(
                            context,
                            entry,
                            e.key,
                          ),
                        ),
                        // Set reminder for this one payment
                        // (v7.1): prefilled with the person
                        // and this payment's amount.
                        IconButton(
                          icon: const Icon(
                            Icons.add_alert,
                            size: 20,
                          ),
                          tooltip: strings.setReminder,
                          color: CashWiseTheme.accentFor(context),
                          onPressed: () {
                            Navigator.of(context).push(
                              slideRoute(
                                AddReminderScreen(
                                  initialPerson:
                                      store.displayPerson(entry.person),
                                  initialAmount: p.amount,
                                  entryId: entry.id,
                                ),
                              ),
                            );
                          },
                        ),
                        DeleteIconButton(
                          tooltip: strings.delete,
                          // Locked while settled.
                          onPressed: entry.settled
                              ? null
                              : () async {
                                  final confirmed =
                                      await confirmDelete(
                                    context,
                                    strings,
                                    store.formatAmount(p.amount),
                                  );
                                  if (confirmed) {
                                    await context
                                        .read<ExpenseStore>()
                                        .removeUdharPayment(
                                            entry.id, e.key);
                                  }
                                },
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
            // Set reminder for this entry (v7.1): the form
            // opens prefilled with the person and the amount
            // still owed.
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  slideRoute(
                    AddReminderScreen(
                      initialPerson:
                          store.displayPerson(entry.person),
                      initialAmount: entry.remaining,
                      entryId: entry.id,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add_alert),
              label: Text(strings.setReminder),
            ),
            const SizedBox(height: 12),
            // Details only (v6.0): amounts are added from the
            // Receivables / Payables pages, never from here.
            // Mark settled/pending + a delete ICON next to it
            // (never the written word). Locked while settled.
            Row(
              children: [
                Expanded(
                  child: entry.settled
                      // Solid gold Mark pending, clearly clickable.
                      ? GradientButton(
                          label: strings.markPending,
                          onPressed: () {
                            context
                                .read<ExpenseStore>()
                                .toggleUdharSettled(entry.id);
                            Navigator.of(context).pop();
                          },
                        )
                      : OutlinedButton(
                          onPressed: () {
                            context
                                .read<ExpenseStore>()
                                .toggleUdharSettled(entry.id);
                            Navigator.of(context).pop();
                          },
                          child: Text(strings.markSettled),
                        ),
                ),
                const SizedBox(width: 8),
                DeleteIconButton(
                  tooltip: strings.delete,
                  onPressed: entry.settled
                      ? null
                      : () async {
                          final confirmed = await confirmDelete(
                            context,
                            strings,
                            store.displayPerson(entry.person),
                          );
                          if (confirmed) {
                            await context
                                .read<ExpenseStore>()
                                .removeUdhar(entry.id);
                            if (!mounted) return;
                            Navigator.of(context).pop();
                          }
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
