// CashWise AI — language slider (v5.4).
//
// A small, professional sliding switch between English and اردو:
// one pill that glides from one side to the other when tapped.
// The labels are styled — English in letterspaced type, اردو in
// Nastaliq — and the pill is theme-aware: gold in light mode,
// navy in dark mode (no blue in light mode). Compact (32px),
// normal weight. It lives in the AppBar.

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
          color: active ? Colors.white : CashWiseTheme.secondaryText,
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
        color: CashWiseTheme.accentSoft,
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
              option('en', englishLabel, !isUrdu),
              option('ur', urduLabel, isUrdu),
            ],
          ),
        ],
      ),
    );
  }
}
