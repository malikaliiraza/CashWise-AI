// CashWise AI — History page (v5.9).
//
// One place for the past: every budget (tap one to switch to
// its book), the full Loan Ledger history, and the deleted
// history — every expense and loan entry ever deleted, with a
// Restore button to put it back.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../data/expense_store.dart';
import '../models/udhar_entry.dart';
import 'udhar_detail_sheet.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseStore>();
    final strings = store.strings;
    final deleted = store.deletedHistory;

    Widget sectionTitle(String title) {
      return Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: CashWiseTheme.headerGradientOf(context),
        ),
        title: Text(strings.history),
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
                  sectionTitle(strings.budgetHistory),
                  if (store.budgets.isEmpty)
                    const Text(
                      '—',
                      style: TextStyle(
                        color: CashWiseTheme.secondaryText,
                      ),
                    )
                  else
                    ...store.budgets.asMap().entries.map((e) {
                      final i = e.key;
                      final b = e.value;
                      final isActive = b.id == store.activeBudgetId;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isActive
                                ? CashWiseTheme.gold
                                : CashWiseTheme.accentSoft,
                            foregroundColor: isActive
                                ? Colors.white
                                : CashWiseTheme.lightAccent,
                            child: Text('${i + 1}'),
                          ),
                          title: Text(
                            '${strings.budget} ${i + 1} — '
                            '${store.formatAmount(b.amount)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${strings.spentThisMonth}: '
                            '${store.formatAmount(store.budgetSpent(b))}'
                            ' • ${strings.remaining}: '
                            '${store.formatAmount(store.budgetRemaining(b))}',
                          ),
                          trailing: isActive
                              ? const Icon(
                                  Icons.check_circle,
                                  color: CashWiseTheme.gold,
                                )
                              : const Icon(Icons.chevron_right),
                          onTap: () => store.switchBudget(b.id),
                        ),
                      );
                    }),
                  sectionTitle(strings.loanHistory),
                  if (store.udharEntries.isEmpty)
                    const Text(
                      '—',
                      style: TextStyle(
                        color: CashWiseTheme.secondaryText,
                      ),
                    )
                  else
                    ...store.udharEntries.map((entry) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: entry.settled
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEF3C7),
                            foregroundColor: entry.settled
                                ? const Color(0xFF166534)
                                : const Color(0xFF92400E),
                            child: Icon(
                              entry.isLent
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                            ),
                          ),
                          title: Text(
                            store.displayPerson(entry.person),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${entry.isLent ? strings.moneyLent : strings.moneyBorrowed} • '
                            '${entry.settled ? strings.settled : strings.pending}',
                          ),
                          trailing: Text(
                            store.formatAmount(entry.amountPkr),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () =>
                              UdharDetailSheet.show(context, entry),
                        ),
                      );
                    }),
                  sectionTitle(strings.deletedItems),
                  if (deleted.isEmpty)
                    Text(
                      strings.noDeletedItems,
                      style: const TextStyle(
                        color: CashWiseTheme.secondaryText,
                      ),
                    )
                  else
                    ...deleted.asMap().entries.map((e) {
                      final i = e.key;
                      final item = e.value;
                      final deletedAt =
                          DateTime.tryParse(item['deletedAt'] as String? ?? '');
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFFEE2E2),
                            foregroundColor: CashWiseTheme.danger,
                            child: Icon(Icons.delete_outline),
                          ),
                          title: Text(
                            (item['label'] as String?) ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${store.formatAmount((item['amount'] as num?)?.toDouble() ?? 0)}'
                            '${deletedAt == null ? '' : ' • ${deletedAt.day}/${deletedAt.month}/${deletedAt.year}'}',
                          ),
                          trailing: TextButton.icon(
                            icon: const Icon(Icons.restore, size: 18),
                            label: Text(strings.restore),
                            onPressed: () => store.restoreDeleted(i),
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
