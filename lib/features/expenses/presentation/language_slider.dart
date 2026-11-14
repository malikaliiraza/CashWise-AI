// CashWise AI — language slider (v7.2).
//
// A small, professional sliding switch between English and اردو:
// one pill that glides from one side to the other when tapped.
// The labels are styled — English in letterspaced type, اردو in
// Nastaliq — and the pill is theme-aware: teal in light mode,
// navy in dark mode (no blue in light mode). Compact (32px),
// normal weight. It lives in the AppBar.
//
// v7.2: the track AND the inactive label are theme-aware — the
// old fixed cream track with a slate inactive label left اردو
// unreadable (white-on-light when the pill sat on the other
// side). Both options are now clearly readable in light and
// dark mode: active = white on the teal pill, inactive = the
// theme's main text colour on the theme's track.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme.dart';
import '../data/expense_store.dart';

class LanguageSlider extends StatelessWidget {
  final ExpenseStore store;

  const LanguageSlider({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final isUrdu = store.locale.code == 'ur';
    final isDark = store.isDarkMode;
    // Inactive label: the theme's main text colour — dark text
    // on the cream track in light mode, soft white on the stone
    // track in dark mode. Never white, never slate-on-dark.
    final inactiveColor = CashWiseTheme.subButtonFg(context);

    Widget option(String code, Widget label, bool active) {
      return Expanded(
        child: InkWell(
          onTap: () {
            if (store.locale.code != code) {
              store.setLocale(code);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Center(child: label),
        ),
      );
    }

    TextStyle labelStyle(bool active) => TextStyle(
          color: active ? Colors.white : inactiveColor,
          fontSize: 12,
        );

    // Styled labels: letterspaced English, Nastaliq اردو.
    final englishLabel = Text(
      'English',
      style: labelStyle(!isUrdu).copyWith(letterSpacing: 0.8),
    );
    final urduLabel = Text(
      'اردو',
      style: GoogleFonts.notoNastaliqUrdu(
        textStyle: labelStyle(isUrdu).copyWith(fontSize: 13),
      ),
    );

    return Container(
      height: 32,
      decoration: BoxDecoration(
        // Track follows the theme, like the theme slider:
        // pearl tint in light mode, teal-dark in dark mode.
        color: isDark
            ? const Color(0xFF155E5E)
            : CashWiseTheme.accentSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment:
                isUrdu ? Alignment.centerRight : Alignment.centerLeft,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0C4444), Color(0xFF0F766E)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F0C4444),
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
              option('en', englishLabel, !isUrdu),
              option('ur', urduLabel, isUrdu),
            ],
          ),
        ],
      ),
    );
  }
}
