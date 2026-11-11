// CashWise AI — theme slider (v5.1).
//
// A small, coloured sliding switch between Light and Dark, in the
// same compact 32px style as the language slider: one pill that
// glides from one side to the other when tapped, with a sun/moon
// icon and normal-weight text. Lives in the drawer.
// The slider follows the selected theme too: light track in light
// mode, dark track in dark mode (v5.1).

import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../data/expense_store.dart';

class ThemeSlider extends StatelessWidget {
  final ExpenseStore store;

  const ThemeSlider({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final isDark = store.isDarkMode;
    final strings = store.strings;
    // Inactive side follows the theme, so it reads in both modes.
    final inactiveColor =
        isDark ? CashWiseTheme.darkSecondaryText : CashWiseTheme.secondaryText;

    Widget option(bool dark, String label, IconData icon, bool active) {
      return Expanded(
        child: InkWell(
          onTap: () {
            if (store.isDarkMode != dark) {
              store.setDarkMode(dark);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: active ? Colors.white : inactiveColor,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: active ? Colors.white : inactiveColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: 32,
      decoration: BoxDecoration(
        // Track follows the selected theme: warm cream in light
        // mode, warm stone in dark mode.
        color: isDark
            ? const Color(0xFF44403C)
            : CashWiseTheme.accentSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment:
                isDark ? Alignment.centerRight : Alignment.centerLeft,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  // Gold pill in both themes.
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD97706), Color(0xFFC9A227)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1FB45309),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              option(false, strings.light, Icons.light_mode, !isDark),
              option(true, strings.dark, Icons.dark_mode, isDark),
            ],
          ),
        ],
      ),
    );
  }
}
