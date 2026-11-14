// CashWise AI — one icon + one colour per category, shared by the
// home list, the detail page and the statistics page, so a category
// always looks the same everywhere in the app.

import 'package:flutter/material.dart';

IconData categoryIcon(String category) {
  switch (category) {
    case 'Food':
      return Icons.restaurant;
    case 'Transport':
      return Icons.directions_car;
    case 'Bills':
      return Icons.receipt_long;
    case 'Shopping':
      return Icons.shopping_bag;
    case 'Health':
      return Icons.favorite;
    case 'Education':
      return Icons.school;
    default:
      return Icons.category;
  }
}

Color categoryColor(String category) {
  switch (category) {
    case 'Food':
      return const Color(0xFFEA580C);
    case 'Transport':
      return const Color(0xFF0F766E);
    case 'Bills':
      return const Color(0xFFF59E0B);
    case 'Shopping':
      return const Color(0xFFDB2777);
    case 'Health':
      return const Color(0xFFDC2626);
    case 'Education':
      return const Color(0xFF0D9488);
    default:
      return const Color(0xFF64748B);
  }
}
