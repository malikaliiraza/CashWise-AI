// CashWise AI — dedicated Reminders page (v5.7).
//
// Tapping the reminders card on Home (or in the drawer, or on the
// Loan Ledger hub) opens this page: every reminder in one place —
// overdue first, then due soon (today, tomorrow, within a week).
// Tapping one reminder opens that entry's detail sheet, so its
// full data (total, paid, remaining, due date/time, payment
// history) is one tap away.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../data/expense_store.dart';
import '../models/udhar_entry.dart';
import 'udhar_detail_sheet.dart';

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
    final entries = store.reminderEntries;
    final overdue = entries.where((e) => e.isOverdue).toList();
    final dueSoon = entries.where((e) => !e.isOverdue).toList();

    String dueLabel(UdharEntry entry) {
      final status = entry.dueStatus;
      if (status == DueStatus.overdue) return strings.overdue;
      if (status == DueStatus.dueToday) return strings.dueToday;
      if (status == DueStatus.dueTomorrow) return strings.dueTomorrow;
      if (status == DueStatus.dueInWeek) {
        return strings.dueInDays(entry.daysUntilDue ?? 0);
      }
      if (entry.dueDate == null) return strings.noDueDate;
      final time = store.formatDueTime(entry);
      return '${entry.dueDate!.day}/${entry.dueDate!.month}/'
          '${entry.dueDate!.year}'
          '${time == null ? '' : ', $time'}';
    }

    Widget reminderTile(UdharEntry entry, {required bool isOverdue}) {
      return Dismissible(
        key: ValueKey(entry.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          color: CashWiseTheme.danger,
          padding: const EdgeInsets.only(right: 16),
          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
          ),
        ),
        onDismissed: (_) => store.dismissReminder(entry),
        child: Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            onTap: () => UdharDetailSheet.show(context, entry),
            leading: CircleAvatar(
              backgroundColor: isOverdue
                  ? const Color(0xFFFEE2E2)
                  : const Color(0xFFFEF3C7),
              foregroundColor: isOverdue
                  ? CashWiseTheme.danger
                  : const Color(0xFF92400E),
              child: Icon(
                isOverdue
                    ? Icons.notifications_active
                    : Icons.schedule,
              ),
            ),
            title: Text(
              store.displayPerson(entry.person),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${strings.remainingAmount}: '
              '${store.formatAmount(entry.remaining)}'
              ' • ${strings.dueDate}: ${dueLabel(entry)}',
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: CashWiseTheme.accentFor(context),
            ),
          ),
        ),
      );
    }

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

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: CashWiseTheme.headerGradientOf(context),
        ),
        title: Text(strings.reminders),
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
                  // Budget warnings live here too, as a reminder:
                  // swipe it away to mark it read.
                  if (store.hasBudgetWarning)
                    Dismissible(
                      key: const ValueKey('budget-warning'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        color: CashWiseTheme.danger,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (_) => store.markWarningRead(),
                      child: Card(
                        color: const Color(0xFFFDECEC),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(
                            Icons.warning_amber,
                            color: CashWiseTheme.danger,
                          ),
                          title: Text(
                            store.warningLevel >= 100
                                ? strings.warning100
                                : strings.warning80,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${strings.spentThisMonth}: '
                            '${store.formatAmount(store.totalSpent)}'
                            ' / ${store.formatAmount(store.monthlyBudgetPkr)}',
                          ),
                        ),
                      ),
                    ),
                  if (overdue.isEmpty &&
                      dueSoon.isEmpty &&
                      !store.hasBudgetWarning)
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
                  if (overdue.isNotEmpty) ...[
                    sectionHeader(
                      strings.overdue,
                      overdue.length,
                      Icons.notifications_active,
                    ),
                    ...overdue.map(
                      (e) => reminderTile(e, isOverdue: true),
                    ),
                  ],
                  if (dueSoon.isNotEmpty) ...[
                    sectionHeader(
                      strings.dueSoon,
                      dueSoon.length,
                      Icons.schedule,
                    ),
                    ...dueSoon.map(
                      (e) => reminderTile(e, isOverdue: false),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
