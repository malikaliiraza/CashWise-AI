// Hisaab Kitaab — one aligned label + amount row (v7.2).
//
// The rule the user set after the v7.1 screenshots: a label and
// its amount must NEVER overlap or run off the screen
// ("Projected month-end spendRs. 20,000" is forbidden), and
// every amount's "Rs." must sit directly under the previous
// line's "Rs." — a straight right-aligned amounts column.
//
// How it works: the label takes the flexible space and wraps
// onto a second line when it is long; the amount is a fixed
// right-aligned column that never wraps, never shrinks and
// never overlaps the label. Because every AmountRow in a card
// is full-width, all the amounts line up in one column
// automatically. Use this widget for EVERY label + amount row
// in the app (Summary cards, AI Predictor, Statistics,
// Summary-page person cards, record payment, detail sheets).

import 'package:flutter/material.dart';

class AmountRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool bold;
  final TextStyle? labelStyle;
  final TextStyle? amountStyle;

  const AmountRow({
    super.key,
    required this.label,
    required this.amount,
    this.bold = false,
    this.labelStyle,
    this.amountStyle,
  });

  @override
  Widget build(BuildContext context) {
    final defaultLabel = Theme.of(context).textTheme.bodyMedium;
    final defaultAmount = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              softWrap: true,
              maxLines: 2,
              style: (labelStyle ?? defaultLabel)?.copyWith(
                fontWeight: bold ? FontWeight.bold : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amount,
            maxLines: 1,
            softWrap: false,
            textAlign: TextAlign.right,
            style: (amountStyle ?? defaultAmount)?.copyWith(
              fontWeight: bold ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
}
