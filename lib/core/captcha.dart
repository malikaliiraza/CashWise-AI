// Hisaab Kitaab — local in-app captcha (v7.2).
//
// A random 4-digit code rendered as styled text: large bold letters,
// each slightly rotated with its own colour, on a light tile with a
// few scribbled lines. A refresh button regenerates the code, and an
// input field takes the typed code. A wrong code blocks submit with
// the error under the field, and a fresh code is generated so the old
// one cannot be retried.
//
// Captcha state lives only in this widget's State — it is never
// persisted. The parent checks it through the state's [validate]
// (via a GlobalKey<CaptchaFieldState>) before submitting.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme.dart';

class CaptchaField extends StatefulWidget {
  const CaptchaField({
    super.key,
    required this.controller,
    required this.captchaLabel,
    required this.enterLabel,
    required this.wrongMessage,
    required this.refreshTooltip,
  });

  /// The input field's controller, owned by the parent screen.
  final TextEditingController controller;

  /// e.g. strings.captcha — the small label next to the tile.
  final String captchaLabel;

  /// e.g. strings.enterCaptcha — the input field's label.
  final String enterLabel;

  /// e.g. strings.captchaWrong — shown under the field on failure.
  final String wrongMessage;

  /// e.g. strings.refreshCaptcha — the refresh button's tooltip.
  final String refreshTooltip;

  @override
  CaptchaFieldState createState() => CaptchaFieldState();
}

class CaptchaFieldState extends State<CaptchaField> {
  final _random = Random();
  late String _code;
  late List<double> _tilts;
  late List<Color> _colours;
  late List<Offset> _scribble;
  String? _error;

  // Dark, readable letter colours on the light captcha tile.
  static const _letterColours = <Color>[
    Color(0xFF92400E),
    Color(0xFF0C4444),
    Color(0xFFB91C1C),
    Color(0xFF166534),
  ];

  @override
  void initState() {
    super.initState();
    _regenerate();
  }

  void _regenerate() {
    _code = (_random.nextInt(9000) + 1000).toString();
    _tilts =
        List.generate(4, (_) => (_random.nextDouble() - 0.5) * 0.5);
    _colours = List.generate(
      4,
      (_) => _letterColours[_random.nextInt(_letterColours.length)],
    );
    _scribble = List.generate(
      6,
      (_) => Offset(_random.nextDouble(), _random.nextDouble()),
    );
  }

  /// Fresh code, cleared input, cleared error (e.g. on form switch).
  void reset() {
    setState(() {
      _regenerate();
      widget.controller.clear();
      _error = null;
    });
  }

  void clearError() {
    if (_error != null) setState(() => _error = null);
  }

  /// True when the typed code matches. On failure the error is shown
  /// and a fresh code is generated, so the old code cannot be retried.
  bool validate() {
    if (widget.controller.text.trim() == _code) {
      if (_error != null) setState(() => _error = null);
      return true;
    }
    setState(() {
      _error = widget.wrongMessage;
      _regenerate();
      widget.controller.clear();
    });
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              widget.captchaLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  // A printed-captcha tile: intentionally light in
                  // both themes, like a real captcha image, so the
                  // dark letters stay readable in dark mode too.
                  color: const Color(0xFFE3EDE8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CashWiseTheme.tealMid),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: _ScribblePainter(_scribble),
                    ),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < _code.length; i++)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: Transform.rotate(
                                angle: _tilts[i],
                                child: Text(
                                  _code[i],
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: _colours[i],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: widget.refreshTooltip,
              onPressed: () => setState(() {
                _regenerate();
                widget.controller.clear();
                _error = null;
              }),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: widget.controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          decoration: InputDecoration(
            labelText: widget.enterLabel,
            errorText: _error,
            errorMaxLines: 3,
            counterText: '',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
          ),
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
        ),
      ],
    );
  }
}

/// A few faint diagonal lines across the captcha tile, as noise.
class _ScribblePainter extends CustomPainter {
  const _ScribblePainter(this.points);

  /// Line endpoints as fractions (0..1) of the tile size.
  final List<Offset> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F766E).withValues(alpha: 0.55)
      ..strokeWidth = 1.5;
    for (var i = 0; i + 1 < points.length; i += 2) {
      canvas.drawLine(
        Offset(points[i].dx * size.width, points[i].dy * size.height),
        Offset(
          points[i + 1].dx * size.width,
          points[i + 1].dy * size.height,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScribblePainter oldDelegate) =>
      oldDelegate.points != points;
}
