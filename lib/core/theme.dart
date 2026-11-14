import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Hisaab Kitaab theme (v7.3): Deep Midnight Teal + Soft Pearl —
/// primary deep midnight teal #0C4444, background soft pearl
/// #F5F2EB. The old warm ivory + gold + brass family is gone as the
/// main accent; gold survives only as a small accent where the logo
/// needs it (see `gold` below). Dark mode is deep teal-dark with
/// pearl text, so nothing is light-on-light or dark-on-dark.
class CashWiseTheme {
  /// Deep midnight teal — the app's primary (THEME 4 anchor).
  static const Color teal = Color(0xFF0C4444);
  /// Mid teal — gradient end, dark-mode buttons, secondary accent.
  static const Color tealMid = Color(0xFF0F766E);
  /// Bright teal — dark-mode primary for framework widgets.
  static const Color tealBright = Color(0xFF14B8A6);
  /// Light teal — readable accent text/icons on deep teal-dark.
  static const Color tealAccent = Color(0xFF5EEAD4);
  /// Soft pearl — the app's background (THEME 4 anchor).
  static const Color pearl = Color(0xFFF5F2EB);
  /// Pale teal-pearl tint — light-mode soft surfaces.
  static const Color pearlTint = Color(0xFFE3EDE8);

  static const Color primary = teal; // deep midnight teal
  static const Color accent = tealMid; // teal 700
  static const Color accentSoft = pearlTint; // pale teal-pearl tint
  /// Kept for the welcome transition / logo, where gold is still a
  /// small accent. It is no longer the app's main accent.
  static const Color gold = Color(0xFFC9A227); // rich gold accent
  /// Light theme's accent (v7.3): deep midnight teal. Light mode
  /// must not show royal blue anywhere — this replaces primary there.
  static const Color lightAccent = teal;

  /// The accent for the current theme: light teal in dark mode,
  /// deep teal in light mode. Use this for icons and text accents
  /// instead of the raw primary.
  static Color accentFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? tealAccent
          : lightAccent;

  /// Sub-action button background (v7.2): pale teal-pearl in light
  /// mode, deep teal card in dark mode. accentSoft is
  /// LIGHT-ONLY — it must never be a background in dark mode
  /// (light text on a pale tint was invisible).
  static Color subButtonBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkCard
          : accentSoft;

  /// Subtle border for a sub-action button: a faint light-teal line
  /// in dark mode (so the teal button still reads as a button
  /// against the teal card), none needed in light mode.
  static Color? subButtonBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? tealAccent.withValues(alpha: 0.35)
          : null;

  /// Sub-action button label colour (v7.2): dark text on the
  /// pearl tint in light mode, pearl on the teal card in dark mode.
  static Color subButtonFg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkTextOnDark
          : darkText;

  /// Secondary text for the current theme (v7.2): teal-slate in
  /// light mode, muted teal-grey in dark mode. The raw
  /// secondaryText is LIGHT-ONLY — it must never be a text colour
  /// in dark mode.
  static Color secondaryTextFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkSecondaryText
          : secondaryText;
  /// Rich header: deep teal-dark fading into mid teal, with a
  /// thin light-teal rule at the bottom — the professional,
  /// premium look (v4.6). Used as AppBar flexibleSpace and drawer
  /// header.
  static const BoxDecoration headerGradient = BoxDecoration(    gradient: LinearGradient(
      colors: [Color(0xFF072E2E), Color(0xFF0C4444), Color(0xFF155E5E)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    border: Border(bottom: BorderSide(color: tealAccent, width: 2)),
  );

  /// Light header (v5.3): soft pearl gradient + the same teal
  /// rule. Light mode gets its own light colours for the whole app
  /// — the teal header no longer stays dark in light mode.
  static const BoxDecoration lightHeaderGradient = BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFFF5F2EB), Color(0xFFE3EDE8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    border: Border(bottom: BorderSide(color: teal, width: 2)),
  );

  /// The header for the current theme: deep teal in dark mode, soft
  /// pearl in light mode. Every AppBar uses this.
  static BoxDecoration headerGradientOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? headerGradient
          : lightHeaderGradient;
  static const Color surface = pearl; // soft pearl page
  static const Color darkText = Color(0xFF0A2E2E); // near-black teal
  static const Color secondaryText = Color(0xFF5A7370); // teal-slate
  static const Color danger = Color(0xFFDC2626);
  static const Color warning = Color(0xFFD97706);
  static const Color success = Color(0xFF16A34A); // green: paid / settled

  // Dark mode surfaces (v7.3): deep teal-dark, not warm charcoal.
  static const Color darkSurface = Color(0xFF072E2E); // deep teal-dark
  static const Color darkCard = teal; // deep midnight teal
  static const Color darkBorder = Color(0xFF155E5E); // teal-dark border
  static const Color darkTextOnDark = pearl; // soft pearl
  static const Color darkSecondaryText = Color(0xFFB7CFC7); // muted teal-grey

  static final ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: lightAccent,
      primary: lightAccent,
      secondary: tealMid,
      surface: Colors.white,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    // Soft pearl page so the white cards read as cards,
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
      // mode and deep teal in dark mode (v5.3), so dark text here is
      // readable again — the v5.1 white title was only needed
      // while the header stayed dark in light mode.
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
      shadowColor: const Color(0x14000000), // soft neutral shadow
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

  /// Dark mode: deep teal-dark surfaces, light-teal accent — the
  /// same family as the light theme, muted and professional, no
  /// bright blue glow.
  static final ThemeData dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: tealAccent,
      primary: tealBright,
      secondary: tealAccent,
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
        side: const BorderSide(color: darkBorder),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: tealMid,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: tealMid,
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
        borderSide: const BorderSide(color: darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: tealAccent, width: 1.5),
      ),
      floatingLabelStyle: const TextStyle(color: tealAccent),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: tealAccent,
      linearTrackColor: darkBorder,
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
      selectedColor: darkBorder,
      labelStyle: const TextStyle(color: darkTextOnDark),
      secondaryLabelStyle: const TextStyle(
        color: tealAccent,
        fontWeight: FontWeight.w600,
      ),
      side: const BorderSide(color: darkBorder),
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
