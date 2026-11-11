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

  Widget _optionCard({
    required String label,
    required IconData icon,
    required Color tint,
    required Color iconColor,
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
                const SizedBox(height: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
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
                    children: [
                      _optionCard(
                        label: strings.moneyLent,
                        icon: Icons.call_received,
                        tint: const Color(0xFFECFDF5),
                        iconColor: const Color(0xFF047857),
                        onTap: () {
                          Navigator.of(context).push(
                            slideRoute(
                              const UdharListScreen(isLent: true),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _optionCard(
                        label: strings.moneyBorrowed,
                        icon: Icons.call_made,
                        tint: const Color(0xFFFFFBEB),
                        iconColor: const Color(0xFFB45309),
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
                  Row(
                    children: [
                      _optionCard(
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
                      const SizedBox(width: 12),
                      _optionCard(
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
