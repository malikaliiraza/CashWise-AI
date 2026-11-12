// CashWise AI — Loan Ledger summary (v5.2).
//
// Totals plus a per-person breakdown of pending amounts: who
// owes you what, and whom you owe what. Settled entries are
// excluded — only what is still pending counts here.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../data/expense_store.dart';
import '../models/udhar_entry.dart';

class LoanLedgerSummaryScreen extends StatelessWidget {
  const LoanLedgerSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseStore>();
    final strings = store.strings;
    final net = store.totalLentOutstanding -
        store.totalBorrowedOutstanding;
    final netText =
        '${net < 0 ? '-' : ''}${store.formatAmount(net.abs())}';

    // Pending amounts grouped by person and by side, with full
    // detail: total, paid so far, remaining, and the next due
    // date/time among that person's entries.
    ({double total, double paid, DateTime? nextDue}) sideTotals(
      List<UdharEntry> entries,
    ) {
      var total = 0.0;
      var paid = 0.0;
      DateTime? nextDue;
      for (final e in entries) {
        total += e.amountPkr;
        paid += e.paidSoFar;
        final due = e.dueDateTime;
        if (due != null && (nextDue == null || due.isBefore(nextDue))) {
          nextDue = due;
        }
      }
      return (total: total, paid: paid, nextDue: nextDue);
    }

    final Map<String, List<UdharEntry>> lentByPerson = {};
    final Map<String, List<UdharEntry>> borrowedByPerson = {};
    for (final entry in store.udharEntries) {
      if (entry.settled) continue;
      final map = entry.isLent ? lentByPerson : borrowedByPerson;
      (map[entry.person] ??= []).add(entry);
    }
    final lentPeople = lentByPerson.keys.toList()..sort();
    final borrowedPeople = borrowedByPerson.keys.toList()..sort();

    Widget summaryRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: CashWiseTheme.secondaryText),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
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
        title: Text(strings.summary),
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
                            strings.summary,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          summaryRow(
                            strings.moneyLent,
                            store.formatAmount(
                                store.totalLentOutstanding),
                          ),
                          summaryRow(
                            strings.moneyBorrowed,
                            store.formatAmount(
                                store.totalBorrowedOutstanding),
                          ),
                          summaryRow(strings.netBalance, netText),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _personSection(
                    context,
                    store,
                    strings.moneyLent,
                    lentPeople,
                    lentByPerson,
                    sideTotals,
                  ),
                  const SizedBox(height: 16),
                  _personSection(
                    context,
                    store,
                    strings.moneyBorrowed,
                    borrowedPeople,
                    borrowedByPerson,
                    sideTotals,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// One side of the ledger: every person with their total, paid
  /// so far, remaining, and next due date/time.
  Widget _personSection(
    BuildContext context,
    ExpenseStore store,
    String heading,
    List<String> people,
    Map<String, List<UdharEntry>> byPerson,
    ({double total, double paid, DateTime? nextDue}) Function(
            List<UdharEntry>)
        sideTotals,
  ) {
    final strings = store.strings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          heading,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (people.isEmpty)
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                strings.noUdharEntries,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CashWiseTheme.secondaryText,
                ),
              ),
            ),
          )
        else
          ...people.map((person) {
            final totals = sideTotals(byPerson[person]!);
            final remaining = totals.total - totals.paid;
            final nextDue = totals.nextDue;
            final lines = <String>[
              '${strings.totalAmount}: '
                  '${store.formatAmount(totals.total)}',
              '${strings.paidSoFar}: '
                  '${store.formatAmount(totals.paid)}',
              '${strings.remainingAmount}: '
                  '${store.formatAmount(remaining)}',
              nextDue == null
                  ? strings.noDueDate
                  : '${strings.nextDue}: '
                      '${nextDue.day}/${nextDue.month}/${nextDue.year}',
            ];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: CashWiseTheme.accentSoft,
                  foregroundColor:
                      CashWiseTheme.accentFor(context),
                  child: Text(
                    store.displayPerson(person).isNotEmpty
                        ? store.displayPerson(person)[0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(store.displayPerson(person)),
                subtitle: Text(lines.join(' • ')),
                isThreeLine: true,
              ),
            );
          }),
      ],
    );
  }
}
