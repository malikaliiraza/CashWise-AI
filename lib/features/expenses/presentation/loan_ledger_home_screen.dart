// CashWise AI — Loan Ledger home screen (v5.2).
//
// The Loan Ledger category's own home: its summary (receivables
// pending, payables pending, net balance) and its four options —
// Receivables, Payables, Details, Summary. Nothing from the
// Budget lives here; the two categories are never mixed.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/page_transitions.dart';
import '../../../core/theme.dart';
import '../data/expense_store.dart';
import 'loan_ledger_summary_screen.dart';
import 'udhar_list_screen.dart';
import 'udhar_screen.dart';

class LoanLedgerHomeScreen extends StatelessWidget {
  const LoanLedgerHomeScreen({super.key});

  /// A big card for one side of the ledger (v7.1): icon, label,
  /// the pending amount and how many people owe it — the two
  /// sides sit side by side, so the ledger opens with its own
  /// numbers, not a grid of identical buttons.
  Widget _bigCard({
    required String label,
    required IconData icon,
    required Color tint,
    required Color iconColor,
    required String amount,
    required String count,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: tint,
                  foregroundColor: iconColor,
                  child: Icon(icon),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CashWiseTheme.secondaryText,
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
    required String label,
    required IconData icon,
    required Color tint,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
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
              const Icon(
                Icons.chevron_right,
                color: CashWiseTheme.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
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

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseStore>();
    final strings = store.strings;
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
                        label: strings.moneyLent,
                        icon: Icons.call_received,
                        tint: const Color(0xFFECFDF5),
                        iconColor: const Color(0xFF047857),
                        amount: store.formatAmount(
                            store.totalLentOutstanding),
                        count:
                            '${store.udharEntries.where((e) => e.isLent && !e.settled).length} ${strings.people}',
                        onTap: () {
                          Navigator.of(context).push(
                            slideRoute(
                              const UdharListScreen(isLent: true),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _bigCard(
                        label: strings.moneyBorrowed,
                        icon: Icons.call_made,
                        tint: const Color(0xFFFFFBEB),
                        iconColor: const Color(0xFFB45309),
                        amount: store.formatAmount(
                            store.totalBorrowedOutstanding),
                        count:
                            '${store.udharEntries.where((e) => !e.isLent && !e.settled).length} ${strings.people}',
                        onTap: () {
                          Navigator.of(context).push(
                            slideRoute(
                              const UdharListScreen(isLent: false),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _actionRow(
                    label: strings.details,
                    icon: Icons.bar_chart,
                    tint: const Color(0xFFF5F3FF),
                    iconColor: const Color(0xFF6D28D9),
                    onTap: () {
                      Navigator.of(context).push(
                        slideRoute(const UdharScreen()),
                      );
                    },
                  ),
                  _actionRow(
                    label: strings.summary,
                    icon: Icons.summarize,
                    tint: const Color(0xFFE0E7FF),
                    iconColor: const Color(0xFF3730A3),
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
