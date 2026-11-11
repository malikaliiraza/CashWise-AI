// CashWise AI — udhar entry (v5.5).
//
// Money lent to someone or borrowed from someone. `isLent` true =
// we gave the money (they owe us); false = we took it (we owe them).
// `settled` true = paid back. Amounts are in the same unit as
// expenses (PKR, stored as a plain number).
//
// v5.5 — due dates, due times and partial payments:
// every entry can have a due date + time ("this payment is due on
// this date at this time") and a list of partial payments, so a
// 5,000 loan with 1,000 already paid shows 1,000 received on its
// date, 4,000 still due, and the next due date/time. When the due
// moment passes without full payment, the entry is overdue —
// from 12 AM after the due date when no time was set.

/// One partial payment towards an entry: how much, on which day,
/// at what time (minutes since midnight, null for older payments
/// recorded before times were kept).
class PartialPayment {
  final double amount;
  final DateTime date;
  final int? timeMinutes;

  const PartialPayment({
    required this.amount,
    required this.date,
    this.timeMinutes,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'date': date.toIso8601String(),
        if (timeMinutes != null) 'timeMinutes': timeMinutes,
      };

  factory PartialPayment.fromJson(Map<String, dynamic> json) =>
      PartialPayment(
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
        timeMinutes: (json['timeMinutes'] as num?)?.toInt(),
      );
}

/// Where an entry stands against its due date.
enum DueStatus {
  /// No due date, settled, or fully paid.
  none,
  /// Due later than 7 days from now.
  future,
  /// Due within the next 7 days.
  dueInWeek,
  /// Due tomorrow.
  dueTomorrow,
  /// Due today.
  dueToday,
  /// The due moment passed and money is still owed.
  overdue,
}

class UdharEntry {
  final String id;
  final String person;
  final double amountPkr;
  final bool isLent;
  final DateTime date;
  final String note;
  final bool settled;

  /// The date the remaining money is due (null = no due date).
  final DateTime? dueDate;

  /// The time on the due date, as minutes since midnight
  /// (null = no time set; the payment is then due by 12 AM
  /// after the due date).
  final int? dueTimeMinutes;

  /// Partial payments already made towards this entry.
  final List<PartialPayment> payments;

  const UdharEntry({
    required this.id,
    required this.person,
    required this.amountPkr,
    required this.isLent,
    required this.date,
    this.note = '',
    this.settled = false,
    this.dueDate,
    this.dueTimeMinutes,
    this.payments = const [],
  });

  /// How much has already been paid towards this entry.
  double get paidSoFar =>
      payments.fold(0.0, (sum, p) => sum + p.amount);

  /// How much is still owed (never below zero).
  double get remaining =>
      (amountPkr - paidSoFar).clamp(0.0, double.infinity);

  /// The exact moment the payment is due: the due date at the
  /// chosen time, or midnight after the due date when no time
  /// was set (so it turns overdue from 12 AM the next day).
  DateTime? get dueDateTime {
    if (dueDate == null) return null;
    final d = dueDate!;
    if (dueTimeMinutes == null) {
      return DateTime(d.year, d.month, d.day + 1);
    }
    return DateTime(
      d.year,
      d.month,
      d.day,
      dueTimeMinutes! ~/ 60,
      dueTimeMinutes! % 60,
    );
  }

  /// Whole calendar days from today until the due date
  /// (negative when the due date has passed).
  int? get daysUntilDue {
    if (dueDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due.difference(today).inDays;
  }

  bool get isOverdue {
    if (settled || remaining <= 0) return false;
    final due = dueDateTime;
    return due != null && DateTime.now().isAfter(due);
  }

  DueStatus get dueStatus {
    if (settled || remaining <= 0 || dueDate == null) {
      return DueStatus.none;
    }
    if (isOverdue) return DueStatus.overdue;
    final days = daysUntilDue;
    if (days == null) return DueStatus.none;
    if (days == 0) return DueStatus.dueToday;
    if (days == 1) return DueStatus.dueTomorrow;
    if (days <= 7) return DueStatus.dueInWeek;
    return DueStatus.future;
  }

  /// The due time as "2:30 PM" (null when no time was set).
  String? get dueTimeLabel {
    if (dueTimeMinutes == null) return null;
    final hour = dueTimeMinutes! ~/ 60;
    final minute = dueTimeMinutes! % 60;
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12:${minute.toString().padLeft(2, '0')} $period';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'person': person,
        'amountPkr': amountPkr,
        'isLent': isLent,
        'date': date.toIso8601String(),
        'note': note,
        'settled': settled,
        'dueDate': dueDate?.toIso8601String(),
        'dueTimeMinutes': dueTimeMinutes,
        'payments': payments.map((p) => p.toJson()).toList(),
      };

  factory UdharEntry.fromJson(Map<String, dynamic> json) {
    final rawPayments = json['payments'] as List<dynamic>?;
    return UdharEntry(
      id: json['id'] as String,
      person: json['person'] as String,
      amountPkr: (json['amountPkr'] as num).toDouble(),
      isLent: json['isLent'] as bool,
      date: DateTime.parse(json['date'] as String),
      note: (json['note'] as String?) ?? '',
      settled: (json['settled'] as bool?) ?? false,
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      dueTimeMinutes: json['dueTimeMinutes'] as int?,
      payments: rawPayments == null
          ? const []
          : rawPayments
              .map((p) =>
                  PartialPayment.fromJson(p as Map<String, dynamic>))
              .toList(),
    );
  }

  UdharEntry copyWith({
    String? person,
    double? amountPkr,
    bool? isLent,
    DateTime? date,
    String? note,
    bool? settled,
    DateTime? dueDate,
    int? dueTimeMinutes,
    List<PartialPayment>? payments,
    bool clearDue = false,
  }) =>
      UdharEntry(
        id: id,
        person: person ?? this.person,
        amountPkr: amountPkr ?? this.amountPkr,
        isLent: isLent ?? this.isLent,
        date: date ?? this.date,
        note: note ?? this.note,
        settled: settled ?? this.settled,
        dueDate: clearDue ? null : (dueDate ?? this.dueDate),
        dueTimeMinutes:
            clearDue ? null : (dueTimeMinutes ?? this.dueTimeMinutes),
        payments: payments ?? this.payments,
      );
}
