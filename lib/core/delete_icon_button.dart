// CashWise AI — a delete (bin) icon with a hover effect (v7.2).
//
// On a desktop or in the browser the icon gets a soft red
// circle behind it and grows slightly while the pointer is
// over it; on a phone it is just a small red bin icon. Every
// delete icon in the app uses this widget, so the behaviour
// is the same everywhere — and a locked (disabled) icon never
// reacts to a hover.
//
// v7.2: 40x40 tap target (was 36), default icon 22dp.

import 'package:flutter/material.dart';

import 'theme.dart';

class DeleteIconButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final double iconSize;
  final String? tooltip;

  const DeleteIconButton({
    super.key,
    required this.onPressed,
    this.iconSize = 22,
    this.tooltip,
  });

  @override
  State<DeleteIconButton> createState() => _DeleteIconButtonState();
}

class _DeleteIconButtonState extends State<DeleteIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enabled = widget.onPressed != null;
    final iconColor = !enabled
        ? CashWiseTheme.secondaryTextFor(context)
        : _hovered
            ? CashWiseTheme.danger
            : CashWiseTheme.danger.withValues(alpha: 0.75);
    return MouseRegion(
      onEnter: (_) {
        if (enabled) setState(() => _hovered = true);
      },
      onExit: (_) {
        if (_hovered) setState(() => _hovered = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _hovered
              ? (isDark
                  ? const Color(0xFF4C1D1D)
                  : const Color(0xFFFEE2E2))
              : Colors.transparent,
        ),
        child: Tooltip(
          message: widget.tooltip ?? '',
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: widget.onPressed,
            child: Center(
              child: AnimatedScale(
                scale: _hovered ? 1.18 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  Icons.delete_outline,
                  size: widget.iconSize,
                  color: iconColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
