// Hisaab Kitaab — animated welcome screen (v7.3).
//
// Shown on EVERY app open, and right after an account is created or
// the user signs in, before the home page. The artwork is the wallet
// + phone from the Hisaab Kitaab launch card
// (assets/welcome_wallet.png / assets/welcome_phone.png): the wallet scales in, the phone
// rises OUT of the wallet and its screen lights up with a gold glow,
// then the home page grows out of the phone screen to full screen and
// takes over after ~2 seconds.
//
// The PNGs were cut from the launch card and their navy card
// background was flattened to the transition background
// (0xFF0C4444) so the crop rectangles are invisible; the wallet's
// navy body is preserved inside its gold outline. The screen is
// deep midnight teal in both light and dark mode, so the artwork
// always sits on the colour it was cleaned against.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../../expenses/data/expense_store.dart';

/// Deep midnight teal (v7.3 theme-4 anchor): the transition
/// background, and the colour the wallet/phone PNGs were cleaned
/// against — the two must stay identical.
const Color _midnightTeal = Color(0xFF0C4444);

/// Soft pearl (v7.3 theme-4 anchor): welcome text on the teal.
const Color _pearl = Color(0xFFF5F2EB);

class WelcomeTransitionScreen extends StatefulWidget {
  const WelcomeTransitionScreen({super.key});

  @override
  State<WelcomeTransitionScreen> createState() =>
      _WelcomeTransitionScreenState();
}

class _WelcomeTransitionScreenState extends State<WelcomeTransitionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  // The wallet scaling in.
  late final Animation<double> _walletScale;
  late final Animation<double> _walletFade;
  // The phone rising out of the wallet (0 = hidden inside it,
  // 1 = fully risen) and its screen lighting up.
  late final Animation<double> _rise;
  late final Animation<double> _glow;
  // The home content growing out of the phone screen.
  late final Animation<double> _reveal;
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
    _walletScale = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.32, curve: Curves.easeOutBack),
      ),
    );
    _walletFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.25, curve: Curves.easeOut),
      ),
    );
    _rise = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.68, curve: Curves.easeOutCubic),
      ),
    );
    _glow = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.85, curve: Curves.easeOut),
      ),
    );
    _reveal = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.62, 1, curve: Curves.easeOutCubic),
      ),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.68, 0.92, curve: Curves.easeOut),
      ),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.68, 0.92, curve: Curves.easeOut),
      ),
    );
    _barWidth = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.72, 1, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
    // Hand over to the home page once the animation has played.
    Timer(const Duration(milliseconds: 2000), () {
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

  /// Gold radial glow, used behind the phone as its screen lights
  /// up and at the wallet's mouth as the phone rises out of it.
  Widget _goldGlow(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            CashWiseTheme.gold.withValues(alpha: 0.45),
            CashWiseTheme.gold.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }

  /// The wallet with the phone rising out of it.
  ///
  /// The phone is painted first and the wallet over it, so the
  /// phone's lower half stays hidden inside the wallet until it
  /// rises; the wallet PNG's background is the same midnight teal
  /// as the screen, so the overlap reads as occlusion, not a box.
  /// Every Positioned here is a direct Stack child.
  Widget _buildWalletAndPhone() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final rise = _rise.value;
        return SizedBox(
          width: 280,
          height: 400,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Glow behind the phone: the screen lighting up.
              Positioned(
                left: 10,
                top: -20,
                child: Opacity(
                  opacity: _glow.value,
                  child: _goldGlow(260, 300),
                ),
              ),
              // The phone, rising out of the wallet.
              Positioned(
                left: 65,
                top: 0,
                width: 150,
                height: 258,
                child: Transform.translate(
                  offset: Offset(0, 110 * (1 - rise)),
                  child: Transform.scale(
                    scale: 0.86 + 0.14 * rise,
                    child: Image.asset(
                      'assets/welcome_phone.png',
                      width: 150,
                      height: 258,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(
                        Icons.smartphone,
                        size: 120,
                        color: _pearl,
                      ),
                    ),
                  ),
                ),
              ),
              // Gold glow at the wallet's mouth as the phone rises.
              Positioned(
                left: 55,
                top: 100,
                child: Opacity(
                  opacity: rise * 0.8,
                  child: _goldGlow(170, 60),
                ),
              ),
              // The wallet, scaled in over the phone's lower half.
              Positioned(
                left: 15,
                bottom: 0,
                width: 250,
                height: 272,
                child: Opacity(
                  opacity: _walletFade.value,
                  child: Transform.scale(
                    scale: _walletScale.value,
                    child: Image.asset(
                      'assets/welcome_wallet.png',
                      width: 250,
                      height: 272,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(
                        Icons.account_balance_wallet,
                        size: 120,
                        color: _pearl,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseStore>();
    final strings = store.strings;

    return Scaffold(
      backgroundColor: _midnightTeal,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // The wallet + phone, fading out as the home reveal
          // takes over.
          Center(
            child: AnimatedBuilder(
              animation: _reveal,
              builder: (context, _) {
                final artOpacity =
                    (1 - ((_reveal.value - 0.65) / 0.35))
                        .clamp(0.0, 1.0);
                return Opacity(
                  opacity: artOpacity,
                  child: _buildWalletAndPhone(),
                );
              },
            ),
          ),
          // The home page growing out of the phone screen: the
          // welcome content scales up from just above centre
          // (where the phone sits) to fill the screen.
          ClipRect(
            child: AnimatedBuilder(
              animation: _reveal,
              builder: (context, _) => Opacity(
                opacity: _reveal.value,
                child: Transform.scale(
                  scale: 0.12 + 0.88 * _reveal.value,
                  alignment: const Alignment(0, -0.2),
                  child: Container(
                    color: _midnightTeal,
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeTransition(
                            opacity: _fade,
                            child: SlideTransition(
                              position: _slide,
                              child: Text(
                                store.userName.isNotEmpty
                                    ? strings
                                        .welcomeName(store.displayName)
                                    : strings.welcomeTitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: _pearl,
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
                              style: TextStyle(
                                fontSize: 15,
                                color:
                                    _pearl.withValues(alpha: 0.75),
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
                                    borderRadius:
                                        BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
