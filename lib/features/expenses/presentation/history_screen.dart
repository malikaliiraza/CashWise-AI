// CashWise AI — History page (v5.9).
//
// One place for the past: every budget (tap one to open its
// own screen), the full Loan Ledger history, and the Bin —
// every expense and loan entry ever deleted, kept for 30 days
// with a Restore button to put it back.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/page_transitions.dart';
import '../../../core/theme.dart';
import '../data/expense_store.dart';
import 'budget_detail_screen.dart';
import 'udhar_detail_sheet.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseStore>();
    final strings = store.strings;
    final deleted = store.deletedHistory;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary = isDark
        ? CashWiseTheme.darkSecondaryText
        : CashWiseTheme.secondaryText;

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
                    Text(
                      '—',
                      style: TextStyle(color: secondary),
                    )
                  else
                    ...store.budgets.map((b) {
                      final isActive = b.id == store.activeBudgetId;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isActive
                                ? CashWiseTheme.lightAccent
                                : isDark
                                    ? CashWiseTheme.darkCard
                                    : CashWiseTheme.accentSoft,
                            foregroundColor: isActive
                                ? Colors.white
                                : CashWiseTheme.lightAccent,
                            child: Text(
                              store
                                  .budgetDisplayName(b)
                                  .characters
                                  .first,
                            ),
                          ),
                          title: Text(
                            '${store.budgetDisplayName(b)} — '
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: isActive
                              ? const Icon(
                                  Icons.check_circle,
                                  color: CashWiseTheme.lightAccent,
                                )
                              : const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              slideRoute(
                                BudgetDetailScreen(budget: b),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  sectionTitle(strings.loanHistory),
                  if (store.udharEntries.isEmpty)
                    Text(
                      '—',
                      style: TextStyle(color: secondary),
                    )
                  else
                    ...store.udharEntries.map((entry) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: entry.settled
                                ? (isDark
                                    ? const Color(0xFF14532D)
                                    : const Color(0xFFDCFCE7))
                                : (isDark
                                    ? const Color(0xFF451A03)
                                    : const Color(0xFFE3EDE8)),
                            foregroundColor: entry.settled
                                ? (isDark
                                    ? const Color(0xFFBBF7D0)
                                    : const Color(0xFF166534))
                                : (isDark
                                    ? const Color(0xFFFDE68A)
                                    : const Color(0xFF92400E)),
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
                  sectionTitle(strings.bin),
                  Text(
                    strings.binAutoRemove,
                    style: TextStyle(color: secondary),
                  ),
                  const SizedBox(height: 8),
                  if (deleted.isEmpty)
                    Text(
                      strings.noDeletedItems,
                      style: TextStyle(color: secondary),
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
                          leading: CircleAvatar(
                            backgroundColor: isDark
                                ? const Color(0xFF450A0A)
                                : const Color(0xFFFEE2E2),
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
                            '${deletedAt == null ? '' : ' • ${shortDate(store, deletedAt)}'}'
                            ' • ${strings.daysLeftInBin(store.binDaysLeft(item))}',
                          ),
                          trailing: SizedBox(
                            height: 48,
                            child: TextButton.icon(
                              icon: const Icon(Icons.restore, size: 20),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  strings.restore,
                                  maxLines: 1,
                                ),
                              ),
                              onPressed: () => store.restoreDeleted(i),
                            ),
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
