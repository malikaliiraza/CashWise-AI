// CashWise AI — dedicated Reminders page (v5.7, v7.1).
//
// Only reminders the user set himself ever live here (v7.1):
// nothing is automatic. Two sections — "Due now" (the moment
// has arrived, highlighted) and "Upcoming" (scheduled for a
// future moment) — plus the "Add reminder" button. A reminder
// can be set from any loan entry or payment, or from this page.
// Deleting a loan entry removes the reminders set on it.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/amount_row.dart';
import '../../../core/delete_icon_button.dart';
import '../../../core/page_transitions.dart';
import '../../../core/theme.dart';
import '../data/expense_store.dart';
import 'add_reminder_screen.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  @override
  void initState() {
    super.initState();
    // Opening this page reads the reminders: the menu badge
    // clears and no further notification fires for them.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseStore>().markRemindersRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseStore>();
    final strings = store.strings;
    final due = store.customRemindersDue;
    final upcoming = store.customRemindersUpcoming;

    Widget sectionHeader(String title, int count, IconData icon) {
      return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: CashWiseTheme.accentFor(context)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 11,
              backgroundColor: CashWiseTheme.accentFor(context),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget reminderCard(Map<String, dynamic> r, {required bool isDue}) {
      final isBudget = r['kind'] == 'budget';
      final note = r['note'] as String? ?? '';
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final secondary = isDark
          ? CashWiseTheme.darkSecondaryText
          : CashWiseTheme.secondaryText;
      // One-line details, amounts in their own right-aligned
      // column: person on top, date/time below, amount aligned.
      final person = r['person'] as String? ?? '';
      final amount = (r['amount'] as num?)?.toDouble() ??
          (r['threshold'] as num?)?.toDouble();
      final date = DateTime.tryParse(r['date'] as String? ?? '');
      final timeMinutes = r['timeMinutes'] as int?;
      final detail = isBudget
          ? strings.budgetReminder
          : [
              if (date != null) store.formatDate(date),
              if (timeMinutes != null) store.formatMinutes(timeMinutes),
            ].join(' • ');
      return Card(
        color: isDue
            ? (isDark
                ? const Color(0xFF3D2323)
                : const Color(0xFFFDECEC))
            : null,
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: isDue
                    ? (isDark
                        ? const Color(0xFF4C1D1D)
                        : const Color(0xFFFEE2E2))
                    : (isDark
                        ? const Color(0xFF451A03)
                        : const Color(0xFFE3EDE8)),
                foregroundColor: isDue
                    ? CashWiseTheme.danger
                    : (isDark
                        ? const Color(0xFFFCD34D)
                        : const Color(0xFF92400E)),
                child: Icon(
                  isBudget
                      ? Icons.account_balance_wallet
                      : Icons.handshake,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBudget
                          ? strings.budgetReminder
                          : store.displayPerson(person),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (detail.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: secondary),
                      ),
                    ],
                    if (amount != null)
                      AmountRow(
                        label: isBudget
                            ? strings.remindWhenRemaining
                            : strings.amount,
                        amount: store.formatAmount(amount),
                        labelStyle: TextStyle(color: secondary),
                      ),
                    if (note.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: secondary),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(
                width: 40,
                height: 40,
                child: DeleteIconButton(
                  iconSize: 22,
                  tooltip: strings.delete,
                  onPressed: () => store.removeCustomReminder(
                    r['id'] as String,
                  ),
                ),
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
        title: Text(strings.reminders),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            slideRoute(const AddReminderScreen()),
          );
        },
        icon: const Icon(Icons.add_alert),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            strings.addReminder,
            maxLines: 1,
            softWrap: false,
          ),
        ),
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
                  if (due.isNotEmpty) ...[
                    sectionHeader(
                      strings.dueReminders,
                      due.length,
                      Icons.notifications_active,
                    ),
                    ...due.map(
                      (r) => reminderCard(r, isDue: true),
                    ),
                  ],
                  if (upcoming.isNotEmpty) ...[
                    sectionHeader(
                      strings.upcomingReminders,
                      upcoming.length,
                      Icons.schedule,
                    ),
                    ...upcoming.map(
                      (r) => reminderCard(r, isDue: false),
                    ),
                  ],
                  if (due.isEmpty && upcoming.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          strings.noReminders,
                          style: TextStyle(
                            color: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? CashWiseTheme.darkSecondaryText
                                : CashWiseTheme.secondaryText,
                          ),
                        ),
                      ),
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
