// CashWise AI — stylish fixed-size calendar (v5.5).
//
// A custom date picker dialog with a FIXED size: the same
// height and width every month, because the grid is always
// 6 rows x 7 days (42 cells) — leading and trailing days of
// the neighbouring months fill the spare cells, so the dialog
// never grows or shrinks as the days change. Rounded 24px,
// the theme's colours (warm brass in light mode, soft gold in
// dark mode), professional Inter type. Used everywhere the
// user picks a date: Add Expense, expense edit, Udhar.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

/// The range limits (v5.9): pass [firstDate] to forbid picking
/// a day before it (loan entry dates can never be in the past)
/// and [lastDate] to forbid picking after it (an expense can
/// never be dated in the future). Days outside the range are
/// greyed out and not tappable; the dialog itself is modal, so
/// scrolling or tapping on it never scrolls the page behind.
Future<DateTime?> showStyledDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (context) => _FixedCalendarDialog(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    ),
  );
}

class _FixedCalendarDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const _FixedCalendarDialog({
    required this.initialDate,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<_FixedCalendarDialog> createState() => _FixedCalendarDialogState();
}

class _FixedCalendarDialogState extends State<_FixedCalendarDialog> {
  late DateTime _month;
  late DateTime _selected;

  static const _weekdays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
  static const _weekdaysUr =
      ['ات', 'پیر', 'منگ', 'بدھ', 'جمعرات', 'جمعہ', 'ہفتہ'];
  static const _urduDigitMap = {
    '0': '۰',
    '1': '۱',
    '2': '۲',
    '3': '۳',
    '4': '۴',
    '5': '۵',
    '6': '۶',
    '7': '۷',
    '8': '۸',
    '9': '۹',
  };

  String _digits(String input, bool urdu) => urdu
      ? input.split('').map((c) => _urduDigitMap[c] ?? c).join()
      : input;

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _inRange(DateTime day) {
    final d = _dayOnly(day);
    if (widget.firstDate != null &&
        d.isBefore(_dayOnly(widget.firstDate!))) {
      return false;
    }
    if (widget.lastDate != null &&
        d.isAfter(_dayOnly(widget.lastDate!))) {
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
    _month = DateTime(_selected.year, _selected.month);
  }

  /// The 42 cells of the grid: always 6 rows, whatever the month.
  List<DateTime> get _cells {
    // Sunday-first week: how many days of the previous month to show.
    final firstWeekday = DateTime(_month.year, _month.month).weekday % 7;
    final firstCell = DateTime(_month.year, _month.month)
        .subtract(Duration(days: firstWeekday));
    return List.generate(42, (i) => firstCell.add(Duration(days: i)));
  }

  void _shiftMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUrdu =
        Localizations.localeOf(context).languageCode == 'ur';
    final accent =
        isDark ? const Color(0xFFD4A017) : CashWiseTheme.lightAccent;
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const monthNamesUr = [
      'جنوری',
      'فروری',
      'مارچ',
      'اپریل',
      'مئی',
      'جون',
      'جولائی',
      'اگست',
      'ستمبر',
      'اکتوبر',
      'نومبر',
      'دسمبر',
    ];

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      // FIXED size: 340 wide, 460 tall — the same every month.
      child: SizedBox(
        width: 340,
        height: 460,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => _shiftMonth(-1),
                  ),
                  Text(
                    isUrdu
                        ? '${monthNamesUr[_month.month - 1]} '
                            '${_digits('${_month.year}', true)}'
                        : '${monthNames[_month.month - 1]} ${_month.year}',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => _shiftMonth(1),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: (isUrdu ? _weekdaysUr : _weekdays)
                    .map(
                      (d) => Expanded(
                        child: Center(
                          child: Text(
                            d,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: CashWiseTheme.secondaryText,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 8),
              // The fixed 6-row grid.
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: 42,
                  itemBuilder: (context, index) {
                    final day = _cells[index];
                    final inMonth = day.month == _month.month;
                    final isSelected = day.year == _selected.year &&
                        day.month == _selected.month &&
                        day.day == _selected.day;
                    final isToday = day == todayDay;
                    final enabled = _inRange(day);
                    return InkWell(
                      onTap: enabled
                          ? () => setState(() => _selected = day)
                          : null,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? accent : null,
                          border: isToday && !isSelected
                              ? Border.all(color: accent, width: 1.5)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : !enabled
                                      ? CashWiseTheme.secondaryText
                                          .withValues(alpha: 0.25)
                                      : inMonth
                                          ? null
                                          : CashWiseTheme.secondaryText
                                              .withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _inRange(todayDay)
                        ? () {
                            setState(() {
                              _selected = todayDay;
                              _month =
                                  DateTime(today.year, today.month);
                            });
                          }
                        : null,
                    child: Text(isUrdu ? 'آج' : 'Today'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(isUrdu ? 'منسوخ کریں' : 'Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_selected),
                    child: Text(isUrdu ? 'ٹھیک ہے' : 'OK'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A stylish fixed-size time picker, matching the calendar:
/// hour + minute wheels, an AM/PM switch, gold accents, fixed
/// size (340 x 400) so it never resizes. In Urdu mode the digits
/// and AM/PM labels are Urdu too. Used for due times.
/// A clean, professional time picker (v5.8 rework).
///
/// The old wheel version showed far too many numbers at once.
/// This one shows only the selected time, big and clear, with
/// two stepper columns (hour / minute: tap a chevron to step by
/// one, hold it to run through fast) and an AM/PM switch. Fixed
/// size (340 x 400). In Urdu mode the digits and AM/PM labels
/// are Urdu too. Used for due times and payment times.
Future<TimeOfDay?> showStyledTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  return showDialog<TimeOfDay>(
    context: context,
    builder: (context) => _FixedTimeDialog(initialTime: initialTime),
  );
}

class _FixedTimeDialog extends StatefulWidget {
  final TimeOfDay initialTime;

  const _FixedTimeDialog({required this.initialTime});

  @override
  State<_FixedTimeDialog> createState() => _FixedTimeDialogState();
}

class _FixedTimeDialogState extends State<_FixedTimeDialog> {
  late int _hour12;
  late int _minute;
  late bool _isPm;
  Timer? _repeatTimer;

  static const _urduDigits = {
    '0': '۰',
    '1': '۱',
    '2': '۲',
    '3': '۳',
    '4': '۴',
    '5': '۵',
    '6': '۶',
    '7': '۷',
    '8': '۸',
    '9': '۹',
  };

  String _digits(String input, bool urdu) => urdu
      ? input.split('').map((c) => _urduDigits[c] ?? c).join()
      : input;

  @override
  void initState() {
    super.initState();
    final h = widget.initialTime.hour;
    _isPm = h >= 12;
    _hour12 = h % 12 == 0 ? 12 : h % 12;
    _minute = widget.initialTime.minute;
  }

  @override
  void dispose() {
    _repeatTimer?.cancel();
    super.dispose();
  }

  void _stepHour(int delta) {
    setState(() {
      _hour12 = ((_hour12 - 1 + delta) % 12 + 12) % 12 + 1;
    });
  }

  void _stepMinute(int delta) {
    setState(() {
      _minute = (_minute + delta) % 60;
      if (_minute < 0) _minute += 60;
    });
  }

  void _startRepeat(void Function() step) {
    step();
    _repeatTimer?.cancel();
    _repeatTimer = Timer.periodic(
      const Duration(milliseconds: 110),
      (_) => step(),
    );
  }

  void _stopRepeat() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  /// One stepper column: chevron up, the big value, chevron
  /// down. Tap steps once, hold runs through fast.
  Widget _stepper({
    required String value,
    required VoidCallback onUp,
    required VoidCallback onDown,
    required Color accent,
    required bool urdu,
  }) {
    Widget chevron(IconData icon, VoidCallback step) {
      return GestureDetector(
        onTap: step,
        onLongPressStart: (_) => _startRepeat(step),
        onLongPressEnd: (_) => _stopRepeat(),
        onLongPressCancel: _stopRepeat,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withValues(alpha: 0.12),
          ),
          child: Icon(icon, color: accent, size: 26),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        chevron(Icons.keyboard_arrow_up, onUp),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 44,
            fontWeight: FontWeight.bold,
            color: accent,
          ),
        ),
        const SizedBox(height: 4),
        chevron(Icons.keyboard_arrow_down, onDown),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUrdu =
        Localizations.localeOf(context).languageCode == 'ur';
    final accent = CashWiseTheme.accentFor(context);
    final okTime = TimeOfDay(
      hour: _isPm ? _hour12 % 12 + 12 : _hour12 % 12,
      minute: _minute,
    );
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: SizedBox(
        width: 340,
        height: 400,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, color: accent),
                  const SizedBox(width: 8),
                  Text(
                    isUrdu ? 'وقت' : 'Time',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: false,
                    label: Text(isUrdu ? 'صبح' : 'AM'),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text(isUrdu ? 'شام' : 'PM'),
                  ),
                ],
                selected: {_isPm},
                onSelectionChanged: (s) =>
                    setState(() => _isPm = s.first),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _stepper(
                      value: _digits(
                        _hour12.toString().padLeft(2, '0'),
                        isUrdu,
                      ),
                      onUp: () => _stepHour(1),
                      onDown: () => _stepHour(-1),
                      accent: accent,
                      urdu: isUrdu,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        ':',
                        style: GoogleFonts.inter(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: accent,
                        ),
                      ),
                    ),
                    _stepper(
                      value: _digits(
                        _minute.toString().padLeft(2, '0'),
                        isUrdu,
                      ),
                      onUp: () => _stepMinute(1),
                      onDown: () => _stepMinute(-1),
                      accent: accent,
                      urdu: isUrdu,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(isUrdu ? 'منسوخ کریں' : 'Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(okTime),
                    child: Text(isUrdu ? 'ٹھیک ہے' : 'OK'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
