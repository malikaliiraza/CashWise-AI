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
      return Card(
        color: isDue
            ? (store.isDarkMode
                ? const Color(0xFF3D2323)
                : const Color(0xFFFDECEC))
            : null,
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isDue
                ? const Color(0xFFFEE2E2)
                : const Color(0xFFFEF3C7),
            foregroundColor: isDue
                ? CashWiseTheme.danger
                : const Color(0xFF92400E),
            child: Icon(
              isBudget
                  ? Icons.account_balance_wallet
                  : Icons.handshake,
            ),
          ),
          title: Text(
            store.customReminderText(r),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: note.isEmpty ? null : Text(note),
          trailing: DeleteIconButton(
            tooltip: strings.delete,
            onPressed: () => store.removeCustomReminder(
              r['id'] as String,
            ),
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
        label: Text(strings.addReminder),
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
                          style: const TextStyle(
                            color: CashWiseTheme.secondaryText,
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
