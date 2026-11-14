// CashWise AI — stylish fixed-size calendar (v5.5).
//
// A custom date picker dialog with a FIXED size: the same
// height and width every month, because the grid is always
// 6 rows x 7 days (42 cells) — leading and trailing days of
// the neighbouring months fill the spare cells, so the dialog
// never grows or shrinks as the days change. Rounded 24px,
// the theme's colours (deep teal in light mode, light teal in
// dark mode), professional Inter type. Used everywhere the
// user picks a date: Add Expense, expense edit, Udhar.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

/// The range limits are optional (v7.1): by default the
/// calendar is fully open — every date is pickable, none is
/// greyed out. Pass [firstDate]/[lastDate] only for a picker
/// that must be bounded (a reminder, which is always in the
/// future). The dialog itself is modal, so scrolling or
/// tapping on it never scrolls the page behind.
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
        isDark ? const Color(0xFF5EEAD4) : CashWiseTheme.lightAccent;
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
                              color: isDark
                                  ? CashWiseTheme.darkSecondaryText
                                  : CashWiseTheme.secondaryText,
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
                      // Tapping a day of the next/previous month
                      // opens that month with the day selected
                      // (v6.0) — it no longer just selects it
                      // while staying on the old month.
                      onTap: enabled
                          ? () => setState(() {
                                _selected = day;
                                if (day.month != _month.month) {
                                  _month =
                                      DateTime(day.year, day.month);
                                }
                              })
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
                            _digits('${day.day}', isUrdu),
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

/// A stylish fixed-size time picker, matching the calendar
/// (v6.0, v7.2): hour + minute + AM/PM as THREE SCROLL WHEELS
/// — flick or drag to spin through the values, the selected one
/// big and clear on a teal band that exactly fits one row, so
/// nothing is clipped. In Urdu mode the digits and AM/PM labels
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
  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;
  late final FixedExtentScrollController _periodController;

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
    _hourController =
        FixedExtentScrollController(initialItem: _hour12 - 1);
    _minuteController = FixedExtentScrollController(initialItem: _minute);
    _periodController =
        FixedExtentScrollController(initialItem: _isPm ? 1 : 0);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  /// One scroll wheel (v7.2): itemExtent, row height, font size
  /// and the teal selection band all agree at 56dp, so the
  /// selected row is FULLY visible — the selected digits are
  /// 30sp inside a 56dp row, never clipped by the band.
  /// [labels] are the strings shown per index (digits for hour
  /// and minute, AM/PM for the period wheel).
  Widget _wheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required int selected,
    required ValueChanged<int> onSelected,
    required Color accent,
    required bool urdu,
    required List<String> labels,
    double width = 84,
    double selectedFontSize = 30,
  }) {
    return SizedBox(
      width: width,
      height: 168,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 56,
        perspective: 0.003,
        diameterRatio: 1.6,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onSelected,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: itemCount,
          builder: (context, index) {
            final isSelected = index == selected;
            return Center(
              child: Text(
                labels[index],
                maxLines: 1,
                softWrap: false,
                style: GoogleFonts.inter(
                  fontSize: isSelected ? selectedFontSize : 20,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? accent
                      : (Theme.of(context).brightness == Brightness.dark
                          ? CashWiseTheme.darkSecondaryText
                          : CashWiseTheme.secondaryText),
                ),
              ),
            );
          },
        ),
      ),
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
              // Scroll wheels with a teal band on the selected row
              // (v7.2): hour + minute + AM/PM as a THIRD wheel —
              // no AM/PM toggle buttons any more. The band is
              // 56dp, exactly one itemExtent tall, so the
              // selected row sits fully inside it.
              SizedBox(
                height: 168,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.08),
                        border: Border.symmetric(
                          horizontal: BorderSide(
                            color: accent.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _wheel(
                          controller: _hourController,
                          itemCount: 12,
                          selected: _hour12 - 1,
                          onSelected: (i) =>
                              setState(() => _hour12 = i + 1),
                          accent: accent,
                          urdu: isUrdu,
                          labels: List.generate(
                            12,
                            (i) => _digits(
                                (i + 1).toString().padLeft(2, '0'),
                                isUrdu),
                          ),
                        ),
                        Text(
                          ':',
                          style: GoogleFonts.inter(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: accent,
                          ),
                        ),
                        _wheel(
                          controller: _minuteController,
                          itemCount: 60,
                          selected: _minute,
                          onSelected: (i) =>
                              setState(() => _minute = i),
                          accent: accent,
                          urdu: isUrdu,
                          labels: List.generate(
                            60,
                            (i) => _digits(
                                i.toString().padLeft(2, '0'), isUrdu),
                          ),
                        ),
                        const SizedBox(width: 4),
                        _wheel(
                          controller: _periodController,
                          itemCount: 2,
                          selected: _isPm ? 1 : 0,
                          onSelected: (i) =>
                              setState(() => _isPm = i == 1),
                          accent: accent,
                          urdu: isUrdu,
                          width: 68,
                          selectedFontSize: 24,
                          labels: isUrdu
                              ? const ['صبح', 'شام']
                              : const ['AM', 'PM'],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
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
