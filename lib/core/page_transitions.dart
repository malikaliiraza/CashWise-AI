// CashWise AI — page transitions (v4.8, reworked in v5.7.1).
//
// Every screen push in the app opens with a NEW transition that
// is not a scroll: the new page fades in while zooming up from a
// slight scale and a small rise, over 350ms — home -> category,
// page -> page, everywhere. No horizontal slide, so it never
// reads as scrolling. The transition is the page change: the
// new page opens only after it plays.
// Use instead of MaterialPageRoute.

import 'package:flutter/material.dart';

Route<T> slideRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      // A small rise (not a sideways slide) + zoom + fade: the
      // new page clearly OPENS, it never looks like scrolling.
      final rise = Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(curved);
      final scale = Tween<double>(begin: 0.94, end: 1.0).animate(curved);
      return SlideTransition(
        position: rise,
        child: ScaleTransition(
          scale: scale,
          child: FadeTransition(opacity: animation, child: child),
        ),
      );
    },
  );
}
