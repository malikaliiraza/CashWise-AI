import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/localization.dart';
import '../../../core/roman_urdu.dart';
import '../../../core/notification_service.dart';
import '../models/budget.dart';
import '../models/expense.dart';
import '../models/udhar_entry.dart';

/// Offline-first local store. v2 keeps all data on the device.
/// Firebase sync is a roadmap feature, not part of v2.
///
/// NOTE on amounts: `monthlyBudgetPkr` / `Expense.amountPkr` keep their
/// v1 field and storage keys for backward compatibility — existing
/// expenses are never wiped. Since v4.7 the currency is PKR for both
/// languages (English "Rs.", Urdu "روپے"); switching language only
/// switches the script, never the currency.
class ExpenseStore extends ChangeNotifier {
  static const _expensesKey = 'cashwise_expenses_v1';
  static const _udharKey = 'cashwise_udhar_v1';
  static const _budgetKey = 'cashwise_monthly_budget_pkr';
  static const _localeKey = 'cashwise_locale_v1';
  static const _darkModeKey = 'cashwise_dark_mode_v1';
  static const _userNameKey = 'cashwise_user_name_v1';
  static const _userNameUrduKey = 'cashwise_user_name_ur_v1';
  static const _userEmailKey = 'cashwise_user_email_v1';
  static const _userPasswordKey = 'cashwise_user_password_v1';
  static const _loggedInKey = 'cashwise_logged_in_v1';
  static const _budgetsKey = 'cashwise_budgets_v1';
  static const _activeBudgetKey = 'cashwise_active_budget_v1';
  static const _deletedHistoryKey = 'cashwise_deleted_history_v1';
  static const _customRemindersKey = 'cashwise_custom_reminders_v1';
  static const _seenCustomRemindersKey =
      'cashwise_seen_custom_reminders_v1';

  /// The Bin keeps a deleted item for 30 days, then it is gone
  /// for good (v7.0).
  static const int binDays = 30;

  final List<Expense> _expenses = [];

  // --- Budgets (v5.9: several, not one) ---
  final List<BudgetPeriod> _budgets = [];
  String _activeBudgetId = '';

  // --- Udhar (lent & borrowed, v4.8) ---
  final List<UdharEntry> _udhar = [];

  List<UdharEntry> get udharEntries => List.unmodifiable(_udhar);

  /// Outstanding now counts what is STILL owed (v5.5): partial
  /// payments reduce it, so a 5,000 loan with 1,000 paid counts
  /// as 4,000 outstanding.
  double get totalLentOutstanding => _udhar
      .where((e) => e.isLent && !e.settled)
      .fold(0.0, (sum, e) => sum + e.remaining);

  double get totalBorrowedOutstanding => _udhar
      .where((e) => !e.isLent && !e.settled)
      .fold(0.0, (sum, e) => sum + e.remaining);

  /// Entries whose due moment passed without full payment.
  List<UdharEntry> get overdueUdhar =>
      _udhar.where((e) => e.isOverdue).toList();

  /// Entries due tomorrow (reminder: 1 day before).
  List<UdharEntry> get dueTomorrowUdhar => _udhar
      .where((e) => e.dueStatus == DueStatus.dueTomorrow)
      .toList();

  /// Entries due within the next 7 days, including today and
  /// tomorrow (reminder: 1 week before).
  List<UdharEntry> get dueWithinWeekUdhar => _udhar
      .where((e) =>
          e.dueStatus == DueStatus.dueInWeek ||
          e.dueStatus == DueStatus.dueTomorrow ||
          e.dueStatus == DueStatus.dueToday)
      .toList();

  /// Unread reminders — the number on the menu badge (v7.1:
  /// only reminders the user set himself count; nothing is
  /// automatic any more). Drops to zero once the Reminders
  /// page is opened (marks them read).
  int get unreadReminderCount => unreadCustomReminderCount;

  bool get hasUnreadReminders => unreadReminderCount > 0;

  /// Mark every due user-set reminder as read (called when the
  /// Reminders page opens, or the drawer's Reminders arrow is
  /// tapped — reading them all is not required).
  Future<void> markRemindersRead() async {
    var changed = false;
    for (final r in customRemindersDue) {
      changed = _seenCustomReminderIds.add(r['id'] as String) || changed;
    }
    if (!changed) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _seenCustomRemindersKey, _seenCustomReminderIds.toList());
    notifyListeners();
  }

  // --- Budget warnings (v5.9) ---
  // The 80% / 100% budget alerts live ONLY as the in-app
  // banner on the Details page now (v7.1): they are not
  // reminders, so they never show on Home, never count
  // towards the badge, and never notify on their own.
  /// 0 = no warning, 80 = 80% used, 100 = budget spent.
  int get warningLevel {
    if (spentFraction >= 1) return 100;
    if (spentFraction >= 0.8) return 80;
    return 0;
  }

  bool get hasBudgetWarning => warningLevel > 0;

  // --- Deleted history (v5.9) ---
  /// What was deleted, newest first: {kind, label, amount,
  /// deletedAt, data} — data is the full JSON of the deleted
  /// object, so it can be restored.
  final List<Map<String, dynamic>> _deletedItems = [];

  List<Map<String, dynamic>> get deletedHistory =>
      List.unmodifiable(_deletedItems);

  void _recordDeleted(
    String kind,
    String label,
    double amount,
    Map<String, dynamic> data,
  ) {
    _deletedItems.insert(0, {
      'kind': kind,
      'label': label,
      'amount': amount,
      'deletedAt': DateTime.now().toIso8601String(),
      'data': data,
    });
  }

  /// Put a deleted expense or loan entry back.
  Future<void> restoreDeleted(int index) async {
    if (index < 0 || index >= _deletedItems.length) return;
    final item = _deletedItems[index];
    final data = item['data'] as Map<String, dynamic>;
    if (item['kind'] == 'expense') {
      _expenses.insert(0, Expense.fromJson(data));
    } else if (item['kind'] == 'udhar') {
      _udhar.insert(0, UdharEntry.fromJson(data));
    }
    _deletedItems.removeAt(index);
    await _save();
    notifyListeners();
  }

  // --- Custom reminders (v7.0) ---
  // Reminders the user adds themselves: {id, kind, threshold,
  // person, amount, date, timeMinutes, note, createdAt}.
  // kind 'budget': remind when the remaining amount of the ACTIVE
  // budget falls to `threshold`. kind 'loan': remind on `date`
  // (at `timeMinutes`) to pay or receive `person`'s `amount`.
  final List<Map<String, dynamic>> _customReminders = [];
  final Set<String> _seenCustomReminderIds = {};

  List<Map<String, dynamic>> get customReminders =>
      List.unmodifiable(_customReminders);

  /// The moment a loan reminder fires: its date, at its time
  /// if one was set, otherwise the end of that day (v7.1).
  DateTime? _customReminderMoment(Map<String, dynamic> r) {
    final date = DateTime.tryParse(r['date'] as String? ?? '');
    if (date == null) return null;
    final timeMinutes = r['timeMinutes'] as int?;
    if (timeMinutes == null) {
      return DateTime(date.year, date.month, date.day, 23, 59);
    }
    return DateTime(date.year, date.month, date.day,
        timeMinutes ~/ 60, timeMinutes % 60);
  }

  /// True when a custom reminder's moment has arrived: the
  /// budget's remaining amount is at or below the threshold,
  /// or the loan reminder's date + time has passed (v7.1).
  bool _customReminderDue(Map<String, dynamic> r) {
    if (r['kind'] == 'budget') {
      final threshold = (r['threshold'] as num?)?.toDouble() ?? 0;
      return hasBudget && remaining <= threshold;
    }
    final moment = _customReminderMoment(r);
    return moment != null && !moment.isAfter(DateTime.now());
  }

  List<Map<String, dynamic>> get customRemindersDue =>
      _customReminders.where(_customReminderDue).toList();

  /// User-set loan reminders whose moment has not arrived yet
  /// (v7.1): scheduled, shown on the Reminders page, but they
  /// do not count as due and never badge the menu.
  List<Map<String, dynamic>> get customRemindersUpcoming =>
      _customReminders
          .where((r) =>
              r['kind'] != 'budget' &&
              !_customReminderDue(r))
          .toList();

  /// Public version of the due check, for the Reminders page
  /// and the Home card (v7.0).
  bool isCustomReminderDue(Map<String, dynamic> r) =>
      _customReminderDue(r);

  /// One-line text for a custom reminder, in the current locale
  /// (v7.0) — used by the Home card and the Reminders page.
  String customReminderText(Map<String, dynamic> r) {
    if (r['kind'] == 'budget') {
      final threshold = (r['threshold'] as num?)?.toDouble() ?? 0;
      return '${strings.budgetReminder}: '
          '${strings.remindWhenRemaining} ${formatAmount(threshold)}';
    }
    final person = r['person'] as String? ?? '';
    final amount = (r['amount'] as num?)?.toDouble();
    final date = DateTime.tryParse(r['date'] as String? ?? '');
    final timeMinutes = r['timeMinutes'] as int?;
    final time = timeMinutes == null
        ? null
        : formatTimeOfDay(TimeOfDay(
            hour: timeMinutes ~/ 60, minute: timeMinutes % 60));
    var s = person;
    if (amount != null) s += ' — ${formatAmount(amount)}';
    if (date != null) s += ' • ${formatDate(date)}';
    if (time != null) s += ', $time';
    return s;
  }

  bool get hasCustomRemindersDue => customRemindersDue.isNotEmpty;

  int get unreadCustomReminderCount => customRemindersDue
      .where((r) => !_seenCustomReminderIds.contains(r['id'] as String))
      .length;

  Future<void> addCustomReminder(Map<String, dynamic> reminder) async {
    _customReminders.insert(0, reminder);
    await _save();
    notifyListeners();
  }

  Future<void> removeCustomReminder(String id) async {
    _customReminders.removeWhere((r) => r['id'] == id);
    _seenCustomReminderIds.remove(id);
    await _save();
    notifyListeners();
  }

  // --- The Bin (v7.0) ---
  /// Drop deleted items older than [binDays] days. Returns how
  /// many were dropped.
  int _purgeExpiredBin() {
    final cutoff =
        DateTime.now().subtract(const Duration(days: binDays));
    final before = _deletedItems.length;
    _deletedItems.removeWhere((item) {
      final at = DateTime.tryParse(item['deletedAt'] as String? ?? '');
      return at != null && at.isBefore(cutoff);
    });
    return before - _deletedItems.length;
  }

  /// Days an item has left in the Bin (0 = it leaves today).
  int binDaysLeft(Map<String, dynamic> item) {
    final at = DateTime.tryParse(item['deletedAt'] as String? ?? '');
    if (at == null) return binDays;
    final age = DateTime.now().difference(at).inDays;
    return (binDays - age).clamp(0, binDays);
  }

  /// True when a due moment (date + optional time) is still in
  /// the future. No time = due by the end of that day, so today
  /// with no time is still future; today WITH a time is future
  /// only while the time has not passed yet (v7.0).
  static bool dueMomentIsFuture(DateTime date, TimeOfDay? time) {
    final now = DateTime.now();
    final day = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    if (day.isAfter(today)) return true;
    if (day.isBefore(today)) return false;
    if (time == null) return true;
    final minutes = time.hour * 60 + time.minute;
    return minutes > now.hour * 60 + now.minute;
  }

  /// The currency prefix for amount INPUT fields: "Rs. " in
  /// English, "روپے " in Urdu.
  String get currencyPrefix =>
      locale.code == 'ur' ? 'روپے ' : 'Rs. ';

  /// Fire the due reminders (mobile notification) once per
  /// day — but ONLY for reminders the user set himself (v7.1):
  /// nothing automatic ever notifies. Only NEW (unread)
  /// reminders notify — read ones stay quiet.
  Future<void> maybeNotifyDueReminders() async {
    final due = customRemindersDue
        .where((r) => !_seenCustomReminderIds.contains(r['id'] as String))
        .toList();
    if (due.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    const key = 'cashwise_last_due_notify_v1';
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    if (prefs.getString(key) == todayKey) return;
    final parts = due.map(customReminderText).toList();
    if (parts.isEmpty) return;
    await prefs.setString(key, todayKey);
    await NotificationService.showDueReminder(parts.join(' • '));
  }

  Future<void> addUdhar(UdharEntry entry) async {
    _udhar.insert(0, entry);
    await _save();
    notifyListeners();
  }

  Future<void> toggleUdharSettled(String id) async {
    final index = _udhar.indexWhere((e) => e.id == id);
    if (index < 0) return;
    _udhar[index] = _udhar[index].copyWith(settled: !_udhar[index].settled);
    await _save();
    notifyListeners();
  }

  /// Replace an entry (due date/time edits from the detail
  /// sheet). The id must already exist.
  Future<void> updateUdhar(UdharEntry entry) async {
    final index = _udhar.indexWhere((e) => e.id == entry.id);
    if (index < 0) return;
    _udhar[index] = entry;
    await _save();
    notifyListeners();
  }

  /// Record a partial payment towards an entry: "1,000 received
  /// on this day". When the remaining amount reaches zero the
  /// entry settles itself.
  Future<void> addUdharPayment({
    required String id,
    required double amount,
    required DateTime date,
    int? timeMinutes,
  }) async {
    final index = _udhar.indexWhere((e) => e.id == id);
    if (index < 0 || amount <= 0) return;
    final entry = _udhar[index];
    final payments = [
      ...entry.payments,
      PartialPayment(
        amount: amount,
        date: date,
        timeMinutes: timeMinutes,
      ),
    ];
    final settled = entry.amountPkr - entry.paidSoFar - amount <= 0;
    _udhar[index] = entry.copyWith(
      payments: payments,
      settled: settled || entry.settled,
    );
    await _save();
    notifyListeners();
  }

  Future<void> removeUdhar(String id) async {
    final index = _udhar.indexWhere((e) => e.id == id);
    if (index < 0) return;
    final removed = _udhar[index];
    _recordDeleted(
      'udhar',
      displayPerson(removed.person),
      removed.amountPkr,
      removed.toJson(),
    );
    _udhar.removeAt(index);
    // The entry is gone, so reminders set on it go too (v7.1).
    _customReminders.removeWhere((r) => r['entryId'] == id);
    await _save();
    notifyListeners();
  }
  // No budget until the user sets one himself (v4.7): the home
  // page starts empty, and Details only appears once a budget and
  // an expense exist.
  /// All budgets, oldest first.
  List<BudgetPeriod> get budgets => List.unmodifiable(_budgets);

  /// The budget the home screens, chart and predictor read.
  BudgetPeriod? get activeBudget {
    if (_budgets.isEmpty) return null;
    return _budgets.firstWhere(
      (b) => b.id == _activeBudgetId,
      orElse: () => _budgets.first,
    );
  }

  String get activeBudgetId => _activeBudgetId;

  /// The active budget's amount (0 when no budget exists).
  /// Kept as the name the rest of the app already uses.
  double get monthlyBudgetPkr => activeBudget?.amount ?? 0;

  /// Spent / remaining for one budget (used by History).
  double budgetSpent(BudgetPeriod b) => _expenses
      .where((e) => e.budgetId == b.id)
      .fold(0.0, (sum, e) => sum + e.amountPkr);

  double budgetRemaining(BudgetPeriod b) => b.amount - budgetSpent(b);

  AppLocale _locale = appLocales.first;

  bool _isDarkMode = false;

  // --- Local login (v4.1, no server) ---
  // The account lives only on this device, in SharedPreferences.
  // It is a local gate so the app does not open straight into the
  // expenses — it is NOT a secure server account.
  String _userName = '';
  // The name as the user typed it in Urdu script (optional
  // override, set from Edit name in Urdu mode). When set, Urdu
  // mode shows this instead of the transliteration.
  String _userNameUrdu = '';
  String _userEmail = '';
  String _userPassword = '';
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;



  /// The name as it should be shown: in Urdu mode the Urdu
  /// spelling the user typed (if any) wins, otherwise the
  /// transliteration engine converts any name; in English mode
  /// the name stays as typed.
  String get displayName {
    if (locale.code != 'ur' || _userName.isEmpty) return _userName;
    if (_userNameUrdu.isNotEmpty) return _userNameUrdu;
    return transliterate(_userName);
  }

  /// The Urdu spelling of the account name ('' when none set).
  String get userNameUrdu => _userNameUrdu;

  /// Any person's name as it should be shown — the same rule as
  /// the account name: in Urdu mode EVERY name converts (a loan
  /// entry's "Ahmad" shows as احمد, not Latin), in English mode
  /// names stay as typed. Use this wherever a person's name is
  /// displayed: lists, detail sheet, summary, reminders.
  String displayPerson(String name) {
    if (locale.code != 'ur' || name.isEmpty) return name;
    return transliterate(name);
  }

  /// Rename the account (from the account menu's Edit name).
  /// Pass [nameUrdu] to set (or clear, with '') the Urdu
  /// spelling; pass null to leave it untouched.
  Future<void> updateUserName(String name, {String? nameUrdu}) async {
    if (name.trim().isEmpty) return;
    _userName = name.trim();
    if (nameUrdu != null) _userNameUrdu = nameUrdu.trim();
    await _save();
    notifyListeners();
  }

  /// Remove one partial payment from an entry. If the entry was
  /// settled only because of that payment, it goes back to
  /// pending (something is remaining again).
  Future<void> removeUdharPayment(String id, int paymentIndex) async {
    final index = _udhar.indexWhere((e) => e.id == id);
    if (index < 0) return;
    final entry = _udhar[index];
    if (paymentIndex < 0 || paymentIndex >= entry.payments.length) {
      return;
    }
    final payments = List<PartialPayment>.from(entry.payments)
      ..removeAt(paymentIndex);
    final remaining =
        entry.amountPkr - payments.fold(0.0, (s, p) => s + p.amount);
    _udhar[index] = entry.copyWith(
      payments: payments,
      settled: remaining <= 0 ? entry.settled : false,
    );
    await _save();
    notifyListeners();
  }

  static const Map<String, String> _urduDigitsMap = {
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

  String _urduDigits(String input) => input
      .split('')
      .map((c) => _urduDigitsMap[c] ?? c)
      .join();

  /// Minutes-since-midnight in the current language: "9:12 PM"
  /// in English, Urdu digits with صبح / دوپہر / شام / رات in
  /// Urdu mode. Used for due times and payment times alike.
  String formatMinutes(int minutes) {
    final hour24 = minutes ~/ 60;
    final minute = minutes % 60;
    if (locale.code != 'ur') {
      final period = hour24 >= 12 ? 'PM' : 'AM';
      final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
      return '$hour12:${minute.toString().padLeft(2, '0')} $period';
    }
    final period = hour24 < 5
        ? 'رات'
        : hour24 < 12
            ? 'صبح'
            : hour24 < 17
                ? 'دوپہر'
                : hour24 < 20
                    ? 'شام'
                    : 'رات';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return '${_urduDigits('$hour12')}:${_urduDigits(minute.toString().padLeft(2, '0'))} $period';
  }

  /// A due time in the current language
  /// (null when the entry has no due time).
  String? formatDueTime(UdharEntry entry) {
    final minutes = entry.dueTimeMinutes;
    if (minutes == null) return null;
    return formatMinutes(minutes);
  }

  /// One date format everywhere (v6.0): "12 November 2026" in
  /// English, "۱۲ نومبر ۲۰۲۶" in Urdu mode — Urdu month names
  /// and Urdu digits, so no date ever shows Latin digits or a
  /// bare dd/mm/yyyy in Urdu mode.
  String formatDate(DateTime date) {
    const enMonths = [
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
    const urMonths = [
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
    if (locale.code == 'ur') {
      return '${_urduDigits('${date.day}')} '
          '${urMonths[date.month - 1]} '
          '${_urduDigits('${date.year}')}';
    }
    return '${date.day} ${enMonths[date.month - 1]} ${date.year}';
  }

  /// The weekday of a date in the current language.
  String weekdayName(DateTime date) {
    const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const ur = ['پیر', 'منگل', 'بدھ', 'جمعرات', 'جمعہ', 'ہفتہ', 'اتوار'];
    final names = locale.code == 'ur' ? ur : en;
    return names[date.weekday - 1];
  }

  /// A TimeOfDay in the current language (for the due-time
  /// button in the add form).
  String formatTimeOfDay(TimeOfDay time) {
    final hour24 = time.hour;
    if (locale.code != 'ur') {
      final period = hour24 >= 12 ? 'PM' : 'AM';
      final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
      return '$hour12:${time.minute.toString().padLeft(2, '0')} $period';
    }
    final period = hour24 < 5
        ? 'رات'
        : hour24 < 12
            ? 'صبح'
            : hour24 < 17
                ? 'دوپہر'
                : hour24 < 20
                    ? 'شام'
                    : 'رات';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return '${_urduDigits('$hour12')}:${_urduDigits(time.minute.toString().padLeft(2, '0'))} $period';
  }

  /// The brand name: "CashWise AI" in English, "کیش وائز اے آئی"
  /// in Urdu mode.
  String get displayBrand =>
      locale.code == 'ur' ? transliterate('CashWise AI') : 'CashWise AI';

  /// True right after a successful login / registration, so the
  /// app can show the animated welcome screen once before the
  /// home page (v5.6). Cleared by [dismissWelcome].
  bool _showWelcome = false;
  bool get showWelcome => _showWelcome;

  /// The welcome screen also plays on EVERY app open (v6.0):
  /// the wallet opens, then home. Not persisted — it starts
  /// true on every launch and is cleared by [dismissWelcome].
  bool _launchWelcome = true;
  bool get showLaunchWelcome => _launchWelcome;

  void dismissWelcome() {
    if (!_showWelcome && !_launchWelcome) return;
    _showWelcome = false;
    _launchWelcome = false;
    notifyListeners();
  }

  /// A real email shape: name@domain.tld — no spaces, a domain with a
  /// dot, and a 2+ letter ending (.com, .gmail is a domain, not an
  /// ending). Random letters without '@' and a dot are rejected.
  static bool isValidEmail(String email) {
    final value = email.trim();
    if (value.isEmpty || value.contains(' ')) return false;
    return RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$',
    ).hasMatch(value);
  }

  /// Mail providers people actually use (v6.0): the sign-in
  /// screen rejects an address whose provider is not on this
  /// list and not an institution — so "melicalyraza5@l.com"
  /// gets "The provider 'l.com' is not a recognised provider."
  /// instead of a bare "invalid email".
  static const _knownEmailProviders = {
    'gmail.com',
    'googlemail.com',
    'yahoo.com',
    'yahoo.co.uk',
    'yahoo.in',
    'yahoo.ca',
    'yahoo.com.au',
    'hotmail.com',
    'hotmail.co.uk',
    'hotmail.fr',
    'outlook.com',
    'outlook.co.uk',
    'live.com',
    'msn.com',
    'icloud.com',
    'me.com',
    'mac.com',
    'protonmail.com',
    'proton.me',
    'aol.com',
    'mail.com',
    'yandex.com',
    'zoho.com',
    'gmx.com',
    'gmx.net',
    'inbox.com',
    'fastmail.com',
  };

  /// The domain after '@', or null when there is none.
  static String? emailDomain(String email) {
    final value = email.trim();
    final at = value.lastIndexOf('@');
    if (at < 0 || at == value.length - 1) return null;
    return value.substring(at + 1).toLowerCase();
  }

  /// A real provider: a known mail host, or an institution
  /// (.edu, .ac, .gov, .org, .pk) — anything else that merely
  /// looks like a domain is not accepted.
  static bool isKnownProvider(String domain) {
    final d = domain.toLowerCase();
    if (_knownEmailProviders.contains(d)) return true;
    return d.endsWith('.edu') ||
        d.endsWith('.edu.pk') ||
        d.endsWith('.edu.au') ||
        d.endsWith('.ac.uk') ||
        d.endsWith('.gov') ||
        d.endsWith('.gov.pk') ||
        d.endsWith('.org') ||
        d.endsWith('.com.pk') ||
        d.endsWith('.org.pk') ||
        d.endsWith('.net.pk');
  }

  /// Strong password: 8+ characters, with 1 uppercase letter, 1
  /// lowercase letter, 1 digit and 1 special character (anything
  /// that is not a letter or digit).
  static bool isStrongPassword(String password) {
    if (password.length < 8) return false;
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[^A-Za-z0-9]'));
    return hasUpper && hasLower && hasDigit && hasSpecial;
  }

  /// Create the local account and log in. Returns false when a field
  /// is empty, the email is not a real email shape, or the password
  /// is not strong (8+, 1 uppercase, 1 digit, 1 special character).
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        password.isEmpty ||
        !isValidEmail(email) ||
        !isStrongPassword(password)) {
      return false;
    }
    _userName = name.trim();
    _userEmail = email.trim();
    _userPassword = password;
    _isLoggedIn = true;
    _showWelcome = true;
    await _save();
    notifyListeners();
    return true;
  }

  /// Log in with the account created on this device.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (_userEmail.isEmpty ||
        email.trim() != _userEmail ||
        password != _userPassword) {
      return false;
    }
    _isLoggedIn = true;
    _showWelcome = true;
    await _save();
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _showWelcome = false;
    await _save();
    notifyListeners();
  }

  /// Log in with a Google profile (Continue with Google): the
  /// local account is created from the Google name + email, with
  /// no password stored — Google is the credential. If an account
  /// already exists on this device it is replaced by the Google
  /// profile, so one Google account means one CashWise account.
  Future<void> loginWithGoogle({
    required String name,
    required String email,
  }) async {
    _userName = name.trim();
    _userEmail = email.trim();
    _userPassword = '';
    _isLoggedIn = true;
    _showWelcome = true;
    await _save();
    notifyListeners();
  }

  /// Dark mode on/off, saved offline like the locale.
  bool get isDarkMode => _isDarkMode;

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _save();
    notifyListeners();
  }

  /// The currently selected language / country / currency profile.
  AppLocale get locale => _locale;

  /// Localised strings for the current locale.
  AppLocale get strings => _locale;

  /// Expenses of the ACTIVE budget only — the whole system
  /// (chart, predictor, summary, alerts) reads this list, so
  /// every budget behaves like its own book.
  List<Expense> get expenses => List.unmodifiable(_activeExpenses);

  /// Every expense of every budget (History page).
  List<Expense> get allExpenses => List.unmodifiable(_expenses);

  List<Expense> get _activeExpenses => _expenses
      .where((e) =>
          e.budgetId.isEmpty || e.budgetId == _activeBudgetId)
      .toList();

  double get totalSpent =>
      _activeExpenses.fold(0, (sum, e) => sum + e.amountPkr);

  double get remaining => monthlyBudgetPkr - totalSpent;

  double get spentFraction =>
      monthlyBudgetPkr <= 0 ? 0 : totalSpent / monthlyBudgetPkr;

  // --- Cash-flow prediction (local, rule-based, v3 draft) ---
  // Assumes the stored expenses are this month's spending — the app
  // has no month filter yet, so expenses from an earlier month would
  // also count. Daily average = total spent / day of month.
  // Projected month-end = daily average x days in this month.
  // No server, no AI model, no network: pure local arithmetic, so it
  // works offline in every locale and currency.
  int get _daysInMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0).day;
  }

  double get dailyAverageSpend {
    final day = DateTime.now().day;
    if (day <= 0 || _activeExpenses.isEmpty) return 0;
    return totalSpent / day;
  }

  double get projectedMonthEndSpend =>
      dailyAverageSpend * _daysInMonth;

  /// True when the current pace would pass the budget before the
  /// month ends (and the budget is not already spent).
  bool get willOverspend =>
      _activeExpenses.isNotEmpty &&
      spentFraction < 1 &&
      projectedMonthEndSpend > monthlyBudgetPkr;

  /// The date the money runs out at the current daily pace, or null
  /// when there is no pace yet (no expenses) or the budget is already
  /// spent / will last the month. Shown as a plain numeric date
  /// (day/month/year) so no month name mixes languages.
  DateTime? get predictedRunOutDate {
    if (_activeExpenses.isEmpty || dailyAverageSpend <= 0) return null;
    if (remaining <= 0) return null;
    final daysLeft = (remaining / dailyAverageSpend).ceil();
    final now = DateTime.now();
    final runOut = now.add(Duration(days: daysLeft));
    final monthEnd = DateTime(now.year, now.month, _daysInMonth);
    if (runOut.isAfter(monthEnd)) return null;
    return runOut;
  }

  /// Alert in the CURRENT locale only — one language, never mixed.
  String? get alertMessage {
    if (spentFraction >= 1) {
      return _locale.overspendAlert;
    }
    if (spentFraction >= 0.8) {
      return _locale.warningAlert;
    }
    return null;
  }

  /// Every amount, everywhere, carries its currency: "Rs. 2,383"
  /// in English, "2,383 روپے" in Urdu. (v5.8 reverses the v4.9
  /// plain-numbers rule — the user asked for Rs. always.)
  String formatAmount(double amount) {
    final whole = amount.truncate();
    final formatted = _withCommas(whole);
    final value = amount == whole.toDouble()
        ? formatted
        : '$formatted.${((amount - whole) * 100).round().toString().padLeft(2, '0')}';
    if (locale.code == 'ur') return '$value روپے';
    return 'Rs. $value';
  }

  static String _withCommas(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    final result = buffer.toString();
    return value < 0 ? '-$result' : result;
  }

  /// Switch language + currency. The monthly budget resets to the new
  /// locale's default budget, and the choice is saved offline.
  Future<void> setLocale(String code) async {
    final next = localeByCode(code);
    if (next.code == _locale.code) return;
    _locale = next;
    // Language switch never touches the budget: PKR either way.
    await _save();
    notifyListeners();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _locale = localeByCode(prefs.getString(_localeKey) ?? 'en');
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    _userName = prefs.getString(_userNameKey) ?? '';
    _userNameUrdu = prefs.getString(_userNameUrduKey) ?? '';
    _userEmail = prefs.getString(_userEmailKey) ?? '';
    _userPassword = prefs.getString(_userPasswordKey) ?? '';
    _isLoggedIn = prefs.getBool(_loggedInKey) ?? false;
    // Budgets (v5.9): load the list; migrate the old single
    // budget into the first budget, and give its expenses the
    // first budget's id.
    final rawBudgets = prefs.getString(_budgetsKey);
    if (rawBudgets != null && rawBudgets.isNotEmpty) {
      final decoded = jsonDecode(rawBudgets) as List<dynamic>;
      _budgets
        ..clear()
        ..addAll(decoded.map(
            (e) => BudgetPeriod.fromJson(e as Map<String, dynamic>)));
    } else {
      final oldBudget = prefs.getDouble(_budgetKey) ?? 0;
      if (oldBudget > 0) {
        _budgets.add(BudgetPeriod(
          id: 'b1',
          amount: oldBudget,
          createdAt: DateTime.now(),
        ));
      }
    }
    _activeBudgetId = prefs.getString(_activeBudgetKey) ?? '';
    if (_budgets.isNotEmpty &&
        !_budgets.any((b) => b.id == _activeBudgetId)) {
      _activeBudgetId = _budgets.first.id;
    }
    final rawDeleted = prefs.getString(_deletedHistoryKey);
    if (rawDeleted != null && rawDeleted.isNotEmpty) {
      final decoded = jsonDecode(rawDeleted) as List<dynamic>;
      _deletedItems
        ..clear()
        ..addAll(decoded.map((e) => Map<String, dynamic>.from(
            e as Map<String, dynamic>)));
      // The Bin never keeps anything past 30 days (v7.0).
      _purgeExpiredBin();
    }
    final rawCustom = prefs.getString(_customRemindersKey);
    if (rawCustom != null && rawCustom.isNotEmpty) {
      final decoded = jsonDecode(rawCustom) as List<dynamic>;
      _customReminders
        ..clear()
        ..addAll(decoded.map((e) => Map<String, dynamic>.from(
            e as Map<String, dynamic>)));
    }
    _seenCustomReminderIds
      ..clear()
      ..addAll(prefs.getStringList(_seenCustomRemindersKey) ?? []);
    final raw = prefs.getString(_expensesKey);
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _expenses
        ..clear()
        ..addAll(decoded.map(
            (e) => Expense.fromJson(e as Map<String, dynamic>)));
      // Pre-multi-budget expenses carry no budget id: they
      // belong to the first budget.
      if (_budgets.isNotEmpty) {
        for (var i = 0; i < _expenses.length; i++) {
          if (_expenses[i].budgetId.isEmpty) {
            final e = _expenses[i];
            _expenses[i] = Expense(
              id: e.id,
              title: e.title,
              amountPkr: e.amountPkr,
              category: e.category,
              date: e.date,
              budgetId: _budgets.first.id,
            );
          }
        }
      }
    }
    final rawUdhar = prefs.getString(_udharKey);
    if (rawUdhar != null && rawUdhar.isNotEmpty) {
      final decoded = jsonDecode(rawUdhar) as List<dynamic>;
      _udhar
        ..clear()
        ..addAll(decoded.map(
            (e) => UdharEntry.fromJson(e as Map<String, dynamic>)));
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, _locale.code);
    await prefs.setDouble(_budgetKey, monthlyBudgetPkr);
    await prefs.setString(
      _budgetsKey,
      jsonEncode(_budgets.map((b) => b.toJson()).toList()),
    );
    await prefs.setString(_activeBudgetKey, _activeBudgetId);
    _purgeExpiredBin();
    await prefs.setString(
      _deletedHistoryKey,
      jsonEncode(_deletedItems),
    );
    await prefs.setString(
      _customRemindersKey,
      jsonEncode(_customReminders),
    );
    await prefs.setStringList(
        _seenCustomRemindersKey, _seenCustomReminderIds.toList());
    await prefs.setBool(_darkModeKey, _isDarkMode);
    await prefs.setString(_userNameKey, _userName);
    await prefs.setString(_userNameUrduKey, _userNameUrdu);
    await prefs.setString(_userEmailKey, _userEmail);
    await prefs.setString(_userPasswordKey, _userPassword);
    await prefs.setBool(_loggedInKey, _isLoggedIn);
    await prefs.setString(
      _expensesKey,
      jsonEncode(_expenses.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      _udharKey,
      jsonEncode(_udhar.map((e) => e.toJson()).toList()),
    );
  }

  /// True once a monthly budget is set. Adding an expense without
  /// a budget is a bug the user reported (v5.0) — expenses only
  /// make sense against a budget, so the gate lives here and in
  /// the Add Expense screen.
  bool get hasBudget => monthlyBudgetPkr > 0;

  Future<void> addExpense(Expense expense) async {
    if (!hasBudget) return;
    // The expense belongs to the active budget's book.
    final stamped = Expense(
      id: expense.id,
      title: expense.title,
      amountPkr: expense.amountPkr,
      category: expense.category,
      date: expense.date,
      budgetId: _activeBudgetId,
    );
    _expenses.insert(0, stamped);
    await _save();
    notifyListeners();
  }

  /// Replace an existing expense (same id, keeps its original date).
  /// Used by the edit-expense sheet; does nothing if the id is gone.
  Future<void> updateExpense(Expense expense) async {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index < 0) return;
    _expenses[index] = expense;
    await _save();
    notifyListeners();
  }

  Future<void> removeExpense(String id) async {
    final index = _expenses.indexWhere((e) => e.id == id);
    if (index < 0) return;
    final removed = _expenses[index];
    _recordDeleted(
      'expense',
      removed.title,
      removed.amountPkr,
      removed.toJson(),
    );
    _expenses.removeAt(index);
    await _save();
    notifyListeners();
  }

  /// Edit the ACTIVE budget's amount (the Set budget screen
  /// with a budget already set). Creates the first budget when
  /// there is none yet. The name is only used when the first
  /// budget is created — editing an amount never renames it.
  Future<void> setMonthlyBudget(double amount, {String name = ''}) async {
    if (_budgets.isEmpty) {
      await addBudget(amount, name: name);
      return;
    }
    final index =
        _budgets.indexWhere((b) => b.id == _activeBudgetId);
    final target = index >= 0 ? index : 0;
    _budgets[target] = _budgets[target].copyWith(amount: amount);
    _activeBudgetId = _budgets[target].id;
    await _save();
    notifyListeners();
  }

  /// Add another budget: a new book with its own expenses, and
  /// the whole system switches to it. The old budget keeps its
  /// own expenses (switch back anytime).
  Future<void> addBudget(double amount, {String name = ''}) async {
    final budget = BudgetPeriod(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      createdAt: DateTime.now(),
      name: name.trim(),
    );
    _budgets.add(budget);
    _activeBudgetId = budget.id;
    await _save();
    notifyListeners();
  }

  /// Rename a budget (v7.0) — anytime, from its own screen.
  Future<void> renameBudget(String id, String name) async {
    final index = _budgets.indexWhere((b) => b.id == id);
    if (index < 0) return;
    _budgets[index] = _budgets[index].copyWith(name: name.trim());
    await _save();
    notifyListeners();
  }

  /// The name to show for a budget: the user's own name, or
  /// "Budget 1", "Budget 2", ... for unnamed budgets (v7.0).
  String budgetDisplayName(BudgetPeriod b) {
    if (b.name.trim().isNotEmpty) return b.name.trim();
    final index = _budgets.indexWhere((x) => x.id == b.id);
    return '${strings.budget} ${index < 0 ? 1 : index + 1}';
  }

  /// Every expense of one budget (its own screen, v7.0).
  List<Expense> expensesForBudget(String id) =>
      _expenses.where((e) => e.budgetId == id).toList();

  /// A budget's daily average, from its own expenses only.
  double budgetDailyAverage(BudgetPeriod b) {
    final day = DateTime.now().day;
    final list = expensesForBudget(b.id);
    if (day <= 0 || list.isEmpty) return 0;
    return budgetSpent(b) / day;
  }

  /// A budget's projected month-end spend, from its own pace.
  double budgetProjectedMonthEnd(BudgetPeriod b) =>
      budgetDailyAverage(b) * _daysInMonth;

  /// Switch the active budget (Budget home chips, History page).
  Future<void> switchBudget(String id) async {
    if (!_budgets.any((b) => b.id == id)) return;
    _activeBudgetId = id;
    await _save();
    notifyListeners();
  }

  /// Delete every expense of the ACTIVE budget (menu > Clear all
  /// data, after a confirm dialog). The budget and language are
  /// kept, and other budgets keep their expenses.
  Future<void> clearAllExpenses() async {
    _expenses.removeWhere((e) => e.budgetId == _activeBudgetId);
    await _save();
    notifyListeners();
  }
}
