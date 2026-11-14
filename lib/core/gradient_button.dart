// CashWise AI — gradient primary button (v7.2).
//
// The app's main action button: the SAME clean teal as the
// language slider's gliding pill (deep teal fading into mid teal),
// flat — no dark glow, no shadow. Used on the Budget, Add
// Expense and Udhar save buttons so the primary action never
// looks like a flat built-in button.
//
// v7.2: fixed 48dp height (min height, 12dp vertical padding)
// and a label that never truncates or wraps — FittedBox
// scaleDown shrinks a long label instead of cutting it.

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
        constraints: const BoxConstraints(minHeight: 48),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: enabled
                ? const [Color(0xFF0C4444), Color(0xFF0F766E)]
                : const [Color(0xFF9CA3AF), Color(0xFF6B7280)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(14)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
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
      ),
    );
  }
}

/// The outline used for the "Mark pending" action on a settled
/// udhar entry: a teal-outlined button, flat like the rest — no
/// glow, so the user can see at a glance that the entry can go
/// back to pending.
///
/// v7.2: same treatment as GradientButton — consistent padding
/// (12dp vertical, 16dp horizontal), a single-line label that
/// shrinks instead of truncating, 48dp min height.
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
      constraints: const BoxConstraints(minHeight: 48),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CashWiseTheme.tealMid, width: 1.5),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          foregroundColor: const Color(0xFF0C4444),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            softWrap: false,
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
