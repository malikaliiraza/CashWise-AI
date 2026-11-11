// CashWise AI — animated welcome screen (v5.6).
//
// Shown once right after an account is created or the user
// signs in, before the home page: the logo scales in with a
// soft gold glow, "Welcome, <name>" slides up, and a gold bar
// grows — then the home page takes over after ~1.8 seconds.
// Returning users (already logged in) skip it and go straight
// to home.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../../expenses/data/expense_store.dart';

class WelcomeTransitionScreen extends StatefulWidget {
  const WelcomeTransitionScreen({super.key});

  @override
  State<WelcomeTransitionScreen> createState() =>
      _WelcomeTransitionScreenState();
}

class _WelcomeTransitionScreenState extends State<WelcomeTransitionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _barWidth;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _logoScale = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.7, curve: Curves.easeOut),
      ),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.8, curve: Curves.easeOut),
      ),
    );
    _barWidth = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
    // Hand over to the home page once the animation has played.
    Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        context.read<ExpenseStore>().dismissWelcome();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseStore>();
    final strings = store.strings;
    final isDark = store.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? CashWiseTheme.darkSurface : const Color(0xFFFFFBEB),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _logoScale,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD97706), Color(0xFFC9A227)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC9A227)
                            .withValues(alpha: 0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Text(
                    store.userName.isNotEmpty
                        ? strings.welcomeName(store.displayName)
                        : strings.welcomeTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? CashWiseTheme.darkTextOnDark
                          : CashWiseTheme.darkText,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeTransition(
                opacity: _fade,
                child: Text(
                  strings.welcomeSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: CashWiseTheme.secondaryText,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 120,
                height: 4,
                child: AnimatedBuilder(
                  animation: _barWidth,
                  builder: (context, _) => Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 120 * _barWidth.value,
                      height: 4,
                      decoration: BoxDecoration(
                        color: CashWiseTheme.gold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
