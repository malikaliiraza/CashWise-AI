// CashWise AI — gradient primary button (v5.5).
//
// The app's main action button: the SAME clean gold as the
// language slider's gliding pill (warm amber fading into gold),
// flat — no dark glow, no shadow. Used on the Budget, Add
// Expense and Udhar save buttons so the primary action never
// looks like a flat built-in button.

import 'package:flutter/material.dart';

import 'theme.dart';

class GradientButton extends StatelessWidget {
  final String label;

  /// Null = locked/disabled (greyed, not tappable) — used for
  /// settled loan entries, where Payable is locked.
  final VoidCallback? onPressed;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: enabled
              ? const [Color(0xFFD97706), Color(0xFFC9A227)]
              : const [Color(0xFF9CA3AF), Color(0xFF6B7280)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12,
            ),
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}

/// The outline used for the "Mark pending" action on a settled
/// udhar entry: a gold-outlined button, flat like the rest — no
/// glow, so the user can see at a glance that the entry can go
/// back to pending.
class GlowOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const GlowOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CashWiseTheme.gold, width: 1.5),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          foregroundColor: const Color(0xFF8A6D1B),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }
}
