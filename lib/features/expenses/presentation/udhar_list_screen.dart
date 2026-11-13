// CashWise AI — one side of the Udhar system (v4.9).
//
// A separate page for each side, with its own attractive name:
// "Receivables" (money you gave — people owe you) and
// "Payables" (money you took — you owe them). The top of the
// page always says what is pending: the pending total, how many
// people, and the full pending list. Settled entries sit below with
// a glowing "Mark pending" button, so the user can see the entry
// can go back to pending. Swipe an entry to delete it.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/confirm_dialog.dart';
import '../../../core/delete_icon_button.dart';
import '../../../core/page_transitions.dart';
import '../../../core/theme.dart';
import '../data/expense_store.dart';
import '../models/udhar_entry.dart';
import 'add_reminder_screen.dart';
import 'record_payment_screen.dart';
import 'udhar_detail_sheet.dart';
import 'udhar_screen.dart';

class UdharListScreen extends StatelessWidget {
  /// true = Receivables (you gave), false = Payables (you took).
  final bool isLent;

  const UdharListScreen({super.key, required this.isLent});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseStore>();
    final strings = store.strings;
    final side = store.udharEntries.where((e) => e.isLent == isLent).toList();
    final pending = side.where((e) => !e.settled).toList();
    final settled = side.where((e) => e.settled).toList();
    final pendingTotal =
        pending.fold(0.0, (sum, e) => sum + e.amountPkr);

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
      return '${store.formatDate(entry.dueDate!)}'
          '${time == null ? '' : ', $time'}';
    }

    Widget entryTile(BuildContext context, UdharEntry entry) {
      final isOverdue = entry.dueStatus == DueStatus.overdue;

      Widget actionButton({
        required String label,
        required VoidCallback? onPressed,
        bool primary = false,
      }) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: primary
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: onPressed,
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: onPressed,
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
          ),
        );
      }

      return Dismissible(
        key: ValueKey(entry.id),
        // Settled entries are locked: no swipe-to-delete.
        direction: entry.settled
            ? DismissDirection.none
            : DismissDirection.endToStart,
        background: Container(color: CashWiseTheme.danger),
        onDismissed: (_) => store.removeUdhar(entry.id),
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => UdharDetailSheet.show(context, entry),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: CashWiseTheme.accentSoft,
                        foregroundColor:
                            CashWiseTheme.accentFor(context),
                        child: Icon(
                          isLent
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          store.displayPerson(entry.person),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: entry.settled
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          entry.settled
                              ? strings.settled
                              : strings.pending,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: entry.settled
                                ? const Color(0xFF166534)
                                : const Color(0xFF92400E),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Amount with the small bin icon directly
                      // below it (v6.0) — never a delete button —
                      // and a bell for "Set reminder" (v7.1).
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            store.formatAmount(entry.amountPkr),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Set reminder: opens the form
                              // prefilled with this person and
                              // the amount still owed.
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
                                        initialPerson: store.displayPerson(
                                            entry.person),
                                        initialAmount: entry.remaining,
                                        entryId: entry.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Small bin icon with a hover effect
                              // (v7.0) — red circle + slightly bigger
                              // icon while the pointer is over it.
                              DeleteIconButton(
                                tooltip: strings.delete,
                                // Settled entries are locked: delete
                                // is disabled until marked pending.
                                onPressed: entry.settled
                                    ? null
                                    : () async {
                                        final confirmed =
                                            await confirmDelete(
                                          context,
                                          strings,
                                          store.displayPerson(
                                              entry.person),
                                        );
                                        if (confirmed) {
                                          await store
                                              .removeUdhar(entry.id);
                                        }
                                      },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${store.formatDate(entry.date)}'
                    ' • ${strings.dueDate}: ${dueLabel(entry)}',
                    style: TextStyle(
                      color: isOverdue
                          ? CashWiseTheme.danger
                          : CashWiseTheme.secondaryText,
                      fontWeight:
                          isOverdue ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (entry.paidSoFar > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${strings.paidSoFar}: '
                      '${store.formatAmount(entry.paidSoFar)}'
                      ' • ${strings.remainingAmount}: '
                      '${store.formatAmount(entry.remaining)}',
                      style: const TextStyle(
                        color: CashWiseTheme.secondaryText,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  // All three actions in ONE row: Payable, Mark
                  // settled/pending, Edit — one fixed height, so
                  // a long Urdu label never makes one button
                  // taller than the others (v6.0).
                  SizedBox(
                    height: 42,
                    child: Row(
                    children: [
                      actionButton(
                        label: strings.addPayment,
                        onPressed: entry.settled
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  slideRoute(
                                    RecordPaymentScreen(entry: entry),
                                  ),
                                );
                              },
                      ),
                      actionButton(
                        label: entry.settled
                            ? strings.markPending
                            : strings.markSettled,
                        primary: entry.settled,
                        onPressed: () =>
                            store.toggleUdharSettled(entry.id),
                      ),
                      actionButton(
                        label: strings.edit,
                        onPressed: entry.settled
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  slideRoute(
                                    UdharScreen(entry: entry),
                                  ),
                                );
                              },
                      ),
                    ],
                    ),
                  ),
                ],
              ),
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
        title: Text(isLent ? strings.moneyLent : strings.moneyBorrowed),
      ),
      // Add on the page itself (v6.0): Receivables adds a
      // receivable, Payables adds a payable — no detour through
      // Details.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            slideRoute(UdharScreen(initialIsLent: isLent)),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(
          isLent ? strings.addReceivable : strings.addPayable,
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
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: Theme.of(context).brightness ==
                                Brightness.dark
                            ? const [
                                Color(0xFF292524),
                                Color(0xFF44403C),
                              ]
                            : const [
                                Color(0xFFD97706),
                                Color(0xFFC9A227),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1F000000),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.pending,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          store.formatAmount(pendingTotal),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isLent
                              ? '${pending.length} ${strings.pending} • ${strings.youLent}'
                              : '${pending.length} ${strings.pending} • ${strings.youBorrowed}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (pending.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          strings.noUdharEntries,
                          style: const TextStyle(
                            color: CashWiseTheme.secondaryText,
                          ),
                        ),
                      ),
                    )
                  else
                    ...pending.map((e) => entryTile(context, e)),
                  if (settled.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      strings.settled,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...settled.map((e) => entryTile(context, e)),
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
