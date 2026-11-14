// Hisaab Kitaab — Loan Ledger hub + side-specific add/edit form (v7.2).
//
// v7.2 — NO shared "Add udhar" form any more:
//   * Receivables and Payables each have their OWN add flow —
//     no Lent/Borrowed toggle anywhere in the form. The side is
//     fixed by how the form was opened (initialIsLent, or the
//     entry being edited), and the title + submit button read
//     "Add receivable" / "Add payable" for that side.
//   * UdharScreen() with no arguments is still the hub (kept
//     for home_screen.dart): summary, reminders, and the two
//     sides — each with its own Add button opening its own form.
//   * The form has THREE separate sections:
//       WHEN — when the money was given/taken (date + time,
//         stored on the entry's `date` as one DateTime);
//       DUE — due date + due time, unchanged semantics;
//       REMINDER (optional) — a bell switch; when ON, a
//         reminder date + time (strictly in the future) is
//         saved as a custom reminder linked to the entry.
//         Editing an entry with a linked reminder shows the
//         bell ON with that reminder's date/time.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/gradient_button.dart';
import '../../../core/page_transitions.dart';
import '../../../core/styled_date_picker.dart';
import '../../../core/theme.dart';
import '../data/expense_store.dart';
import '../models/udhar_entry.dart';
import 'reminders_screen.dart';
import 'udhar_list_screen.dart';

class UdharScreen extends StatefulWidget {
  /// Null = the hub (summary + the two sides). Set = edit that
  /// entry, on its own side. [initialIsLent] set = add a new
  /// entry on that side directly (Receivables = true,
  /// Payables = false).
  final UdharEntry? entry;

  /// Which side a fresh add opens on: the Receivables page
  /// passes true, the Payables page passes false, so each page
  /// adds its own kind directly — never a shared form.
  final bool? initialIsLent;

  const UdharScreen({super.key, this.entry, this.initialIsLent});

  @override
  State<UdharScreen> createState() => _UdharScreenState();
}

class _UdharScreenState extends State<UdharScreen> {
  final _personController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  /// The form's side, fixed at open time — never changeable
  /// in the form (v7.2: no Lent/Borrowed toggle).
  bool _isLent = true;

  /// WHEN the money changed hands: date + time, one DateTime.
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _whenTime = TimeOfDay.now();

  /// DUE date + time (unchanged semantics).
  DateTime? _dueDate;
  TimeOfDay? _dueTime;

  /// REMINDER (optional): bell switch + its date/time.
  bool _reminderOn = false;
  DateTime _reminderDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool _reminderLoaded = false;

  String? _error;
  String? _reminderError;

  bool get _isForm => widget.entry != null || widget.initialIsLent != null;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _isLent = entry?.isLent ?? widget.initialIsLent ?? true;
    if (entry != null) {
      _personController.text = entry.person;
      _amountController.text = entry.amountPkr.toStringAsFixed(0);
      _noteController.text = entry.note;
      _selectedDate =
          DateTime(entry.date.year, entry.date.month, entry.date.day);
      _whenTime =
          TimeOfDay(hour: entry.date.hour, minute: entry.date.minute);
      _dueDate = entry.dueDate;
      _dueTime = entry.dueTimeMinutes == null
          ? null
          : TimeOfDay(
              hour: entry.dueTimeMinutes! ~/ 60,
              minute: entry.dueTimeMinutes! % 60,
            );
      // Reminder defaults follow the due moment when there is
      // one; a linked reminder (loaded below) overrides them.
      if (_dueDate != null) {
        _reminderDate = _dueDate!;
        if (_dueTime != null) _reminderTime = _dueTime!;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Editing an entry that already has a linked reminder:
    // the bell starts ON with that reminder's date/time.
    if (!_reminderLoaded && widget.entry != null) {
      _reminderLoaded = true;
      final store = context.read<ExpenseStore>();
      final linked = store.customReminderForEntry(widget.entry!.id);
      if (linked != null) {
        final date = DateTime.tryParse(linked['date'] as String? ?? '');
        final minutes = linked['timeMinutes'] as int?;
        setState(() {
          _reminderOn = true;
          if (date != null) _reminderDate = date;
          if (minutes != null) {
            _reminderTime =
                TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _personController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// The linked reminder for [entryId] follows the bell: OFF
  /// removes any linked reminder, ON (re)creates it from the
  /// form's reminder date/time, in the existing custom-reminder
  /// map shape.
  Future<void> _syncReminder(
    ExpenseStore store,
    String entryId,
    String person,
    double amount,
  ) async {
    await store.removeCustomRemindersForEntry(entryId);
    if (!_reminderOn) return;
    final now = DateTime.now();
    await store.addCustomReminder({
      'id': 'rem_${entryId}_${now.millisecondsSinceEpoch}',
      'kind': 'loan',
      'person': person,
      'amount': amount,
      'date': DateTime(
        _reminderDate.year,
        _reminderDate.month,
        _reminderDate.day,
      ).toIso8601String(),
      'timeMinutes': _reminderTime.hour * 60 + _reminderTime.minute,
      'note': '',
      'entryId': entryId,
      'createdAt': now.toIso8601String(),
    });
  }

  Future<void> _save() async {
    final store = context.read<ExpenseStore>();
    final strings = store.strings;
    final amount = double.tryParse(_amountController.text.trim());
    final person = _personController.text.trim();
    if (person.isEmpty || amount == null || amount <= 0) {
      setState(() => _error = strings.enterTitleValidAmount);
      return;
    }
    if (_reminderOn &&
        !ExpenseStore.dueMomentIsFuture(_reminderDate, _reminderTime)) {
      setState(() => _reminderError = strings.reminderMustBeFuture);
      return;
    }
    // WHEN: the chosen date at the chosen time, one DateTime.
    final when = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _whenTime.hour,
      _whenTime.minute,
    );
    final dueMinutes = _dueTime == null
        ? null
        : _dueTime!.hour * 60 + _dueTime!.minute;
    final editing = widget.entry;
    if (editing != null) {
      await store.updateUdhar(
        editing.copyWith(
          person: person,
          amountPkr: amount,
          isLent: _isLent,
          date: when,
          note: _noteController.text.trim(),
          dueDate: _dueDate,
          dueTimeMinutes: dueMinutes,
        ),
      );
      await _syncReminder(store, editing.id, person, amount);
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await store.addUdhar(
      UdharEntry(
        id: id,
        person: person,
        amountPkr: amount,
        isLent: _isLent,
        date: when,
        note: _noteController.text.trim(),
        dueDate: _dueDate,
        dueTimeMinutes: dueMinutes,
      ),
    );
    await _syncReminder(store, id, person, amount);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Color _secondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? CashWiseTheme.darkSecondaryText
          : CashWiseTheme.secondaryText;

  Color _avatarTint(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF155E5E)
          : CashWiseTheme.accentSoft;

  /// One date/time button: label on one line, scaled down
  /// rather than ellipsised when the Urdu label is long.
  Widget _dateTimeButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, maxLines: 1, softWrap: false),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildForm(BuildContext context, ExpenseStore store) {
    final strings = store.strings;
    final editing = widget.entry != null;
    final addLabel = _isLent ? strings.addReceivable : strings.addPayable;

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      editing ? strings.edit : addLabel,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _personController,
                      decoration: InputDecoration(
                        labelText: strings.personName,
                      ),
                      onChanged: (_) {
                        if (_error != null) {
                          setState(() => _error = null);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: strings.amountLabel,
                        prefixText: store.currencyPrefix,
                      ),
                      onChanged: (_) {
                        if (_error != null) {
                          setState(() => _error = null);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: strings.note,
                      ),
                    ),
                    // WHEN — when the money was given/taken.
                    // A detail only, NOT the reminder.
                    _sectionLabel(
                      _isLent ? strings.lentWhen : strings.borrowedWhen,
                    ),
                    Row(
                      children: [
                        _dateTimeButton(
                          icon: Icons.calendar_today,
                          label:
                              '${_isLent ? strings.lentOn : strings.borrowedOn}: '
                              '${store.formatDate(_selectedDate)}',
                          onPressed: () async {
                            final picked = await showStyledDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = picked);
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        _dateTimeButton(
                          icon: Icons.access_time,
                          label:
                              '${_isLent ? strings.lentAt : strings.borrowedAt}: '
                              '${store.formatTimeOfDay(_whenTime)}',
                          onPressed: () async {
                            final picked = await showStyledTimePicker(
                              context: context,
                              initialTime: _whenTime,
                            );
                            if (picked != null) {
                              setState(() => _whenTime = picked);
                            }
                          },
                        ),
                      ],
                    ),
                    // DUE — when the remaining money is due.
                    _sectionLabel(strings.dueDate),
                    Row(
                      children: [
                        _dateTimeButton(
                          icon: Icons.calendar_today,
                          label: _dueDate == null
                              ? strings.setDueDate
                              : store.formatDate(_dueDate!),
                          onPressed: () async {
                            final picked = await showStyledDatePicker(
                              context: context,
                              initialDate: _dueDate ?? DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() => _dueDate = picked);
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        _dateTimeButton(
                          icon: Icons.access_time,
                          label: _dueTime == null
                              ? strings.setDueTime
                              : store.formatTimeOfDay(_dueTime!),
                          onPressed: () async {
                            final picked = await showStyledTimePicker(
                              context: context,
                              initialTime: _dueTime ?? TimeOfDay.now(),
                            );
                            if (picked != null) {
                              setState(() => _dueTime = picked);
                            }
                          },
                        ),
                      ],
                    ),
                    // REMINDER (optional) — below the date/time.
                    _sectionLabel(strings.reminderSection),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: Icon(
                        Icons.notifications_active,
                        color: CashWiseTheme.accentFor(context),
                      ),
                      title: Text(strings.setReminder),
                      value: _reminderOn,
                      onChanged: (value) {
                        setState(() {
                          _reminderOn = value;
                          _reminderError = null;
                        });
                      },
                    ),
                    if (_reminderOn) ...[
                      Row(
                        children: [
                          _dateTimeButton(
                            icon: Icons.calendar_today,
                            label:
                                '${strings.reminderDate}: '
                                '${store.formatDate(_reminderDate)}',
                            onPressed: () async {
                              final picked = await showStyledDatePicker(
                                context: context,
                                initialDate: _reminderDate,
                                firstDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() {
                                  _reminderDate = picked;
                                  _reminderError = null;
                                });
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          _dateTimeButton(
                            icon: Icons.access_time,
                            label:
                                '${strings.reminderTime}: '
                                '${store.formatTimeOfDay(_reminderTime)}',
                            onPressed: () async {
                              final picked = await showStyledTimePicker(
                                context: context,
                                initialTime: _reminderTime,
                              );
                              if (picked != null) {
                                setState(() {
                                  _reminderTime = picked;
                                  _reminderError = null;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      if (_reminderError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _reminderError!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: CashWiseTheme.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    GradientButton(
                      label: editing ? strings.save : addLabel,
                      onPressed: _save,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHub(BuildContext context, ExpenseStore store) {
    final strings = store.strings;

    Widget summaryCard(String label, String value, IconData icon) {
      return Expanded(
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 20, color: CashWiseTheme.accentFor(context)),
                const SizedBox(height: 8),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: _secondary(context),
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    softWrap: false,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget sideCard({
      required bool isLent,
      required IconData icon,
      required String title,
      required double pending,
    }) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: _avatarTint(context),
                  foregroundColor: CashWiseTheme.accentFor(context),
                  child: Icon(icon),
                ),
                title: Text(title),
                subtitle: Text(
                  '${strings.pending}: ${store.formatAmount(pending)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    slideRoute(UdharListScreen(isLent: isLent)),
                  );
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    slideRoute(UdharScreen(initialIsLent: isLent)),
                  );
                },
                icon: const Icon(Icons.add, size: 20),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    isLent ? strings.addReceivable : strings.addPayable,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Loan reminders the user set himself (v7.1):
                // due ones in red, upcoming ones below them.
                // Nothing here is automatic.
                if (store.customRemindersDue
                        .any((r) => r['kind'] == 'loan') ||
                    store.customRemindersUpcoming.isNotEmpty) ...[
                  Card(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? (store.customRemindersDue
                                .any((r) => r['kind'] == 'loan')
                            ? const Color(0xFF3D2323)
                            : CashWiseTheme.darkCard)
                        : (store.customRemindersDue
                                .any((r) => r['kind'] == 'loan')
                            ? const Color(0xFFFDECEC)
                            : const Color(0xFFF5F2EB)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        Navigator.of(context).push(
                          slideRoute(const RemindersScreen()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.notifications_active,
                                  size: 20,
                                  color: store.customRemindersDue
                                          .any((r) => r['kind'] == 'loan')
                                      ? CashWiseTheme.danger
                                      : CashWiseTheme.lightAccent,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  strings.reminders,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...store.customRemindersDue
                                .where((r) => r['kind'] == 'loan')
                                .map(
                              (r) => Text(
                                store.customReminderText(r),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: CashWiseTheme.danger,
                                ),
                              ),
                            ),
                            ...store.customRemindersUpcoming.map(
                              (r) => Text(
                                store.customReminderText(r),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    summaryCard(
                      strings.moneyLent,
                      store.formatAmount(store.totalLentOutstanding),
                      Icons.arrow_upward,
                    ),
                    const SizedBox(width: 8),
                    summaryCard(
                      strings.moneyBorrowed,
                      store.formatAmount(store.totalBorrowedOutstanding),
                      Icons.arrow_downward,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Receivables and Payables: separate cards, each
                // with its own Add button opening its own form.
                sideCard(
                  isLent: true,
                  icon: Icons.arrow_upward,
                  title: strings.moneyLent,
                  pending: store.totalLentOutstanding,
                ),
                const SizedBox(height: 12),
                sideCard(
                  isLent: false,
                  icon: Icons.arrow_downward,
                  title: strings.moneyBorrowed,
                  pending: store.totalBorrowedOutstanding,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseStore>();
    final strings = store.strings;
    final editing = widget.entry != null;
    final title = _isForm
        ? (editing
            ? strings.edit
            : (_isLent ? strings.addReceivable : strings.addPayable))
        : strings.udhar;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: CashWiseTheme.headerGradientOf(context),
        ),
        title: Text(title),
      ),
      body: _isForm ? _buildForm(context, store) : _buildHub(context, store),
    );
  }
}
