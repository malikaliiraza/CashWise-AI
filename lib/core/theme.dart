import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// CashWise AI v4.6 — Rich Royal Blue theme (user's choice, 10 Nov
/// 2026): deep royal blue + white + a thin gold rule, with a subtle
/// gradient header and soft glow on cards. The v4.5 flat look was
/// too faded, so the richness is back — but the soft dark mode stays.
// v5.0 style refresh: the colours stay exactly as the user chose
// (royal blue + gold) — only the shapes change: rounder cards with
// a thin outline, rounder buttons, softer shadows. A new style,
// the same theme.
class CashWiseTheme {
  static const Color primary = Color(0xFF1E40AF); // rich royal blue
  static const Color accent = Color(0xFF2563EB); // blue 600
  static const Color accentSoft = Color(0xFFFEF3C7); // warm cream
  static const Color gold = Color(0xFFC9A227); // rich gold accent
  /// Light theme's accent (v5.4): dark brass. Light mode must not
  /// show royal blue anywhere — this replaces primary there.
  static const Color lightAccent = Color(0xFF9C7A1A);

  /// The accent for the current theme: warm brass in light mode,
  /// soft blue in dark mode. Use this for icons and text accents
  /// instead of the raw primary (royal blue).
  static Color accentFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFD4A017)
          : lightAccent;
  /// Rich header: deep royal blue fading into bright blue, with a
  /// thin gold rule at the bottom — the professional, premium look
  /// (v4.6). Used as AppBar flexibleSpace and drawer header.
  static const BoxDecoration headerGradient = BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF292524), Color(0xFF44403C), Color(0xFF57534E)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    border: Border(bottom: BorderSide(color: gold, width: 2)),
  );

  /// Light header (v5.3): soft light-blue gradient + the same gold
  /// rule. Light mode gets its own light colours for the whole app
  /// — the navy header no longer stays navy in light mode.
  static const BoxDecoration lightHeaderGradient = BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    border: Border(bottom: BorderSide(color: gold, width: 2)),
  );

  /// The header for the current theme: navy in dark mode, soft
  /// light blue in light mode. Every AppBar uses this.
  static BoxDecoration headerGradientOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? headerGradient
          : lightHeaderGradient;
  static const Color surface = Color(0xFFF3F6FB); // light blue-grey page
  static const Color darkText = Color(0xFF0F1E3D); // near-black blue
  static const Color secondaryText = Color(0xFF64748B); // slate 500
  static const Color danger = Color(0xFFDC2626);
  static const Color warning = Color(0xFFD97706);

  // Dark mode surfaces — softened (v4.5): the old deep slate + bright
  // blue accent was too harsh on the eyes at night.
  static const Color darkSurface = Color(0xFF1C1917); // warm charcoal (stone 900)
  static const Color darkCard = Color(0xFF292524); // warm stone 800
  static const Color darkTextOnDark = Color(0xFFE8EDF5); // soft white
  static const Color darkSecondaryText = Color(0xFFA8A29E); // warm stone grey

  static final ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: lightAccent,
      primary: lightAccent,
      secondary: gold,
      surface: Colors.white,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    // Soft off-white page so the white cards read as cards,
    // not as flat white on white — the main 'empty' complaint.
    scaffoldBackgroundColor: surface,
    // Professional font (v4.5): Inter — clean, highly readable,
    // the standard for government and banking apps. Falls back to
    // Roboto if the font has not downloaded yet (needs internet once).
    textTheme: GoogleFonts.interTextTheme().copyWith(
      bodyMedium: const TextStyle(color: darkText),
      bodyLarge: const TextStyle(color: darkText),
      titleLarge: const TextStyle(color: darkText, fontWeight: FontWeight.bold),
      titleMedium: const TextStyle(color: darkText, fontWeight: FontWeight.w600),
    ),
    appBarTheme: const AppBarTheme(
      // Titles follow the header: the header is light in light
      // mode and navy in dark mode (v5.3), so dark text here is
      // readable again — the v5.1 white title was only needed
      // while the header stayed navy in light mode.
      backgroundColor: Colors.white,
      foregroundColor: darkText,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        color: darkText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: accentSoft,
      labelStyle: const TextStyle(color: darkText),
      secondaryLabelStyle: const TextStyle(
        color: lightAccent,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(color: Colors.grey.shade300),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      showCheckmark: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 1,
      shadowColor: const Color(0x141E40AF), // soft blue glow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.shade200),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: lightAccent,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightAccent, width: 1.5),
      ),
      floatingLabelStyle: const TextStyle(color: lightAccent),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: lightAccent,
      linearTrackColor: accentSoft,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkText,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
  );

  /// Dark mode: warm stone surfaces, gold accent — the same family
  /// as the light theme, muted and professional, no bright blue glow.
  static final ThemeData dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: gold,
      primary: gold,
      secondary: const Color(0xFFD4A017),
      surface: darkCard,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: darkSurface,
    textTheme: GoogleFonts.interTextTheme().copyWith(
      bodyMedium: const TextStyle(color: darkTextOnDark),
      bodyLarge: const TextStyle(color: darkTextOnDark),
      titleLarge: const TextStyle(color: darkTextOnDark, fontWeight: FontWeight.bold),
      titleMedium: const TextStyle(color: darkTextOnDark, fontWeight: FontWeight.w600),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: darkTextOnDark,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        color: darkTextOnDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: darkCard,
      surfaceTintColor: darkCard,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFF44403C)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: gold,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: gold,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF44403C)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF44403C)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: gold, width: 1.5),
      ),
      floatingLabelStyle: const TextStyle(color: gold),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: gold,
      linearTrackColor: Color(0xFF44403C),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkCard,
      contentTextStyle: const TextStyle(color: darkTextOnDark),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: darkCard,
      selectedColor: const Color(0xFF44403C),
      labelStyle: const TextStyle(color: darkTextOnDark),
      secondaryLabelStyle: const TextStyle(
        color: gold,
        fontWeight: FontWeight.w600,
      ),
      side: const BorderSide(color: Color(0xFF44403C)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      showCheckmark: false,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: darkSurface,
    ),
  );
}
