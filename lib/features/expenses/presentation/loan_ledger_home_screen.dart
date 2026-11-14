// CashWise AI — Loan Ledger home screen (v5.2).
//
// The Loan Ledger category's own home: its summary (receivables
// pending, payables pending, net balance) and its four options —
// Receivables, Payables, Details, Summary. Nothing from the
// Budget lives here; the two categories are never mixed.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/amount_row.dart';
import '../../../core/page_transitions.dart';
import '../../../core/theme.dart';
import '../data/expense_store.dart';
import 'loan_ledger_summary_screen.dart';
import 'udhar_list_screen.dart';
import 'udhar_screen.dart';

class LoanLedgerHomeScreen extends StatelessWidget {
  const LoanLedgerHomeScreen({super.key});

  /// A big card for one side of the ledger (v7.1, v7.2): icon,
  /// label, the pending amount and how many people owe it —
  /// plus its OWN Add button, opening that side's form only.
  /// The two sides are separate cards, never mixed.
  Widget _bigCard({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color tint,
    required Color iconColor,
    required String amount,
    required String count,
    required String addLabel,
    required VoidCallback onTap,
    required VoidCallback onAdd,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary = isDark
        ? CashWiseTheme.darkSecondaryText
        : CashWiseTheme.secondaryText;
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CircleAvatar(
                  backgroundColor: tint,
                  foregroundColor: iconColor,
                  child: Icon(icon),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    amount,
                    maxLines: 1,
                    softWrap: false,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  count,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: secondary,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 20),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      addLabel,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// A full-width action row, matching the Budget screen's rows
  /// in spirit but used here only for Details and Summary —
  /// the two sides above already carry the ledger's main actions.
  Widget _actionRow({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color tint,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: tint,
                foregroundColor: iconColor,
                child: Icon(icon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark
                    ? CashWiseTheme.darkSecondaryText
                    : CashWiseTheme.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return AmountRow(label: label, amount: value, bold: true);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseStore>();
    final strings = store.strings;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final net = store.totalLentOutstanding -
        store.totalBorrowedOutstanding;
    final netText =
        '${net < 0 ? '-' : ''}${store.formatAmount(net.abs())}';

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: CashWiseTheme.headerGradientOf(context),
        ),
        title: Text(strings.udhar),
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
                          _summaryRow(
                            strings.moneyLent,
                            store.formatAmount(
                                store.totalLentOutstanding),
                          ),
                          _summaryRow(
                            strings.moneyBorrowed,
                            store.formatAmount(
                                store.totalBorrowedOutstanding),
                          ),
                          _summaryRow(strings.netBalance, netText),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    strings.quickActions,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bigCard(
                        context: context,
                        label: strings.moneyLent,
                        icon: Icons.call_received,
                        tint: Theme.of(context).brightness ==
                                Brightness.dark
                            ? const Color(0xFF14532D)
                            : const Color(0xFFECFDF5),
                        iconColor: Theme.of(context).brightness ==
                                Brightness.dark
                            ? const Color(0xFF86EFAC)
                            : const Color(0xFF047857),
                        amount: store.formatAmount(
                            store.totalLentOutstanding),
                        count:
                            '${store.udharEntries.where((e) => e.isLent && !e.settled).length} ${strings.people}',
                        addLabel: strings.addReceivable,
                        onTap: () {
                          Navigator.of(context).push(
                            slideRoute(
                              const UdharListScreen(isLent: true),
                            ),
                          );
                        },
                        onAdd: () {
                          Navigator.of(context).push(
                            slideRoute(
                              const UdharScreen(initialIsLent: true),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _bigCard(
                        context: context,
                        label: strings.moneyBorrowed,
                        icon: Icons.call_made,
                        tint: Theme.of(context).brightness ==
                                Brightness.dark
                            ? const Color(0xFF451A03)
                            : const Color(0xFFF5F2EB),
                        iconColor: Theme.of(context).brightness ==
                                Brightness.dark
                            ? const Color(0xFFFCD34D)
                            : const Color(0xFFB45309),
                        amount: store.formatAmount(
                            store.totalBorrowedOutstanding),
                        count:
                            '${store.udharEntries.where((e) => !e.isLent && !e.settled).length} ${strings.people}',
                        addLabel: strings.addPayable,
                        onTap: () {
                          Navigator.of(context).push(
                            slideRoute(
                              const UdharListScreen(isLent: false),
                            ),
                          );
                        },
                        onAdd: () {
                          Navigator.of(context).push(
                            slideRoute(
                              const UdharScreen(initialIsLent: false),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _actionRow(
                    context: context,
                    label: strings.details,
                    icon: Icons.bar_chart,
                    tint: isDark
                        ? const Color(0xFF2E1065)
                        : const Color(0xFFF5F3FF),
                    iconColor: isDark
                        ? const Color(0xFFC4B5FD)
                        : const Color(0xFF6D28D9),
                    onTap: () {
                      Navigator.of(context).push(
                        slideRoute(const UdharScreen()),
                      );
                    },
                  ),
                  _actionRow(
                    context: context,
                    label: strings.summary,
                    icon: Icons.summarize,
                    tint: isDark
                        ? const Color(0xFF1E1B4B)
                        : const Color(0xFFE0E7FF),
                    iconColor: isDark
                        ? const Color(0xFFA5B4FC)
                        : const Color(0xFF3730A3),
                    onTap: () {
                      Navigator.of(context).push(
                        slideRoute(
                          const LoanLedgerSummaryScreen(),
                        ),
                      );
                    },
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
