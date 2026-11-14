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

import '../../../core/amount_row.dart';
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary =
        isDark ? CashWiseTheme.darkSecondaryText : CashWiseTheme.secondaryText;

    /// Short date, one clean line: "12 Nov 2026" (Urdu keeps
    /// the store's single date format).
    String shortDate(DateTime date) {
      if (store.locale.code == 'ur') return store.formatDate(date);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }

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
      return '${shortDate(entry.dueDate!)}'
          '${time == null ? '' : ', $time'}';
    }

    Widget entryTile(BuildContext context, UdharEntry entry) {
      final isOverdue = entry.dueStatus == DueStatus.overdue;

      Widget actionButton({
        required String label,
        required VoidCallback? onPressed,
        bool primary = false,
      }) {
        // One line, fully visible: the label scales down
        // instead of ellipsising ("Mark settl..." is forbidden).
        final buttonChild = FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            softWrap: false,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: primary ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: primary
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 6,
                      ),
                    ),
                    onPressed: onPressed,
                    child: buttonChild,
                  )
                : OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 6,
                      ),
                    ),
                    onPressed: onPressed,
                    child: buttonChild,
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
                        backgroundColor: isDark
                            ? const Color(0xFF155E5E)
                            : CashWiseTheme.accentSoft,
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
                              ? (isDark
                                  ? const Color(0xFF14532D)
                                  : const Color(0xFFDCFCE7))
                              : (isDark
                                  ? const Color(0xFF451A03)
                                  : const Color(0xFFE3EDE8)),
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
                                ? (isDark
                                    ? const Color(0xFF86EFAC)
                                    : const Color(0xFF166534))
                                : (isDark
                                    ? const Color(0xFFFCD34D)
                                    : const Color(0xFF92400E)),
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
                              // the amount still owed. 22dp icon
                              // on a 40dp tap target.
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.add_alert,
                                    size: 22,
                                  ),
                                  tooltip: strings.setReminder,
                                  color:
                                      CashWiseTheme.accentFor(context),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 40,
                                    minHeight: 40,
                                  ),
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
                              ),
                              // Small bin icon with a hover effect
                              // (v7.0) — red circle + slightly bigger
                              // icon while the pointer is over it.
                              // 22dp icon on a 40dp tap target.
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: DeleteIconButton(
                                  iconSize: 22,
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
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // One clean line, short dates:
                  // "12 Nov 2026 • Due 20 Nov 2026, 8:53 PM".
                  Text(
                    '${shortDate(entry.date)}'
                    ' • ${strings.dueDate}: ${dueLabel(entry)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isOverdue ? CashWiseTheme.danger : secondary,
                      fontWeight:
                          isOverdue ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (entry.paidSoFar > 0) ...[
                    AmountRow(
                      label: strings.paidSoFar,
                      amount: store.formatAmount(entry.paidSoFar),
                      labelStyle: TextStyle(color: secondary),
                    ),
                    AmountRow(
                      label: strings.remainingAmount,
                      amount: store.formatAmount(entry.remaining),
                      labelStyle: TextStyle(color: secondary),
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
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            isLent ? strings.addReceivable : strings.addPayable,
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
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: Theme.of(context).brightness ==
                                Brightness.dark
                            ? const [
                                Color(0xFF072E2E),
                                Color(0xFF0C4444),
                              ]
                            : const [
                                Color(0xFF0C4444),
                                Color(0xFF0F766E),
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
                          style: TextStyle(
                            color: secondary,
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
