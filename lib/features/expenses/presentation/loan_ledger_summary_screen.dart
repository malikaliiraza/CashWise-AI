// Hisaab Kitaab — Loan Ledger summary (v7.2).
//
// Totals plus a per-person breakdown of pending amounts: who
// owes you what, and whom you owe what. Settled entries are
// excluded — only what is still pending counts here.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/amount_row.dart';
import '../../../core/theme.dart';
import '../data/expense_store.dart';
import '../models/udhar_entry.dart';
import 'budget_detail_screen.dart' show shortDate;

class LoanLedgerSummaryScreen extends StatelessWidget {
  const LoanLedgerSummaryScreen({super.key});

  static Color _secondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? CashWiseTheme.darkSecondaryText
          : CashWiseTheme.secondaryText;

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
                          AmountRow(
                            label: strings.moneyLent,
                            amount: store.formatAmount(
                                store.totalLentOutstanding),
                          ),
                          AmountRow(
                            label: strings.moneyBorrowed,
                            amount: store.formatAmount(
                                store.totalBorrowedOutstanding),
                          ),
                          AmountRow(
                            label: strings.netBalance,
                            amount: netText,
                            bold: true,
                          ),
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
  /// so far, remaining, and next due date/time — each detail as
  /// its own AmountRow, so all amounts sit in one straight
  /// right-aligned column and "Next due" never breaks mid-phrase.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                style: TextStyle(color: _secondary(context)),
              ),
            ),
          )
        else
          ...people.map((person) {
            final totals = sideTotals(byPerson[person]!);
            final remaining = totals.total - totals.paid;
            final nextDue = totals.nextDue;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: isDark
                          ? CashWiseTheme.darkCard
                          : CashWiseTheme.accentSoft,
                      foregroundColor:
                          CashWiseTheme.accentFor(context),
                      child: Text(
                        store.displayPerson(person).isNotEmpty
                            ? store.displayPerson(person)[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.displayPerson(person),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          AmountRow(
                            label: strings.totalAmount,
                            amount:
                                store.formatAmount(totals.total),
                          ),
                          AmountRow(
                            label: strings.paidSoFar,
                            amount: store.formatAmount(totals.paid),
                          ),
                          AmountRow(
                            label: strings.remainingAmount,
                            amount: store.formatAmount(remaining),
                          ),
                          AmountRow(
                            label: strings.nextDue,
                            amount: nextDue == null
                                ? strings.noDueDate
                                : shortDate(store, nextDue),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
