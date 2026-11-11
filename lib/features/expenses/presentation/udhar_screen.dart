// CashWise AI — Loan Ledger hub (v4.9.1).
//
// The overview: outstanding totals, an add form (person, amount,
// Lent/Borrowed, date from the calendar, note), and two big cards
// that open the separate pages — Receivables and Payables —
// each showing its own pending list. Everything is saved on the
// device with the expenses. The AppBar back button returns home.

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
  /// Null = add a new entry (the hub form); set = edit that
  /// entry (opened from a loan card's Edit button).
  final UdharEntry? entry;

  const UdharScreen({super.key, this.entry});

  @override
  State<UdharScreen> createState() => _UdharScreenState();
}

class _UdharScreenState extends State<UdharScreen> {
  final _personController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLent = true;
  DateTime _selectedDate = DateTime.now();
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  String? _error;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    if (entry != null) {
      _personController.text = entry.person;
      _amountController.text = entry.amountPkr.toStringAsFixed(0);
      _noteController.text = entry.note;
      _isLent = entry.isLent;
      _selectedDate = entry.date;
      _dueDate = entry.dueDate;
      _dueTime = entry.dueTimeMinutes == null
          ? null
          : TimeOfDay(
              hour: entry.dueTimeMinutes! ~/ 60,
              minute: entry.dueTimeMinutes! % 60,
            );
    }
  }

  @override
  void dispose() {
    _personController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
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
          date: _selectedDate,
          note: _noteController.text.trim(),
          dueDate: _dueDate,
          dueTimeMinutes: dueMinutes,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }
    await store.addUdhar(
      UdharEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        person: person,
        amountPkr: amount,
        isLent: _isLent,
        date: _selectedDate,
        note: _noteController.text.trim(),
        dueDate: _dueDate,
        dueTimeMinutes: dueMinutes,
      ),
    );
    _personController.clear();
    _amountController.clear();
    _noteController.clear();
    setState(() {
      _error = null;
      _dueDate = null;
      _dueTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseStore>();
    final strings = store.strings;
    final editing = widget.entry != null;

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
                  style: const TextStyle(
                    fontSize: 12,
                    color: CashWiseTheme.secondaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: CashWiseTheme.headerGradientOf(context),
        ),
        title: Text(editing ? strings.edit : strings.udhar),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!editing && store.hasUdharReminders) ...[
                    Card(
                      color: store.overdueUdhar.isNotEmpty
                          ? const Color(0xFFFDECEC)
                          : const Color(0xFFFFFBEB),
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
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.notifications_active,
                                  size: 20,
                                  color: store.overdueUdhar.isNotEmpty
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
                            ...store.overdueUdhar.map(
                              (e) => Text(
                                strings.dueReminderOverdue(
                                  store.displayPerson(e.person),
                                  store.formatAmount(e.remaining),
                                ),
                                style: const TextStyle(
                                  color: CashWiseTheme.danger,
                                ),
                              ),
                            ),
                            ...store.dueWithinWeekUdhar.map(
                              (e) => Text(
                                e.dueStatus == DueStatus.dueToday
                                    ? strings.dueToday
                                    : e.dueStatus == DueStatus.dueTomorrow
                                        ? strings.dueReminderTomorrow(
                                            store.displayPerson(e.person),
                                            store.formatAmount(
                                                e.remaining),
                                          )
                                        : '${strings.dueInDays(e.daysUntilDue ?? 0)}: '
                                            '${store.displayPerson(e.person)} — '
                                            '${store.formatAmount(e.remaining)}',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                    const SizedBox(height: 16),
                  ],
                  if (!editing) ...[
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
                  ],
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            strings.addUdhar,
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
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showStyledDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() => _selectedDate = picked);
                              }
                            },
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              '${strings.date}: '
                              '${_selectedDate.day}/${_selectedDate.month}/'
                              '${_selectedDate.year}',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final picked =
                                        await showStyledDatePicker(
                                      context: context,
                                      initialDate:
                                          _dueDate ?? DateTime.now(),
                                      firstDate: DateTime.now(),
                                    );
                                    if (picked != null) {
                                      setState(
                                          () => _dueDate = picked);
                                    }
                                  },
                                  icon: const Icon(
                                      Icons.calendar_today),
                                  label: Text(
                                    _dueDate == null
                                        ? strings.setDueDate
                                        : '${_dueDate!.day}/${_dueDate!.month}/'
                                            '${_dueDate!.year}',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final picked =
                                        await showStyledTimePicker(
                                      context: context,
                                      initialTime:
                                          _dueTime ?? TimeOfDay.now(),
                                    );
                                    if (picked != null) {
                                      setState(
                                          () => _dueTime = picked);
                                    }
                                  },
                                  icon:
                                      const Icon(Icons.access_time),
                                  label: Text(
                                    _dueTime == null
                                        ? strings.setDueTime
                                        : store.formatTimeOfDay(_dueTime!),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: [
                              ChoiceChip(
                                label: Text(strings.lent),
                                selected: _isLent,
                                onSelected: (_) =>
                                    setState(() => _isLent = true),
                              ),
                              ChoiceChip(
                                label: Text(strings.borrowed),
                                selected: !_isLent,
                                onSelected: (_) =>
                                    setState(() => _isLent = false),
                              ),
                            ],
                          ),
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
                            label: editing
                                ? strings.save
                                : strings.addUdhar,
                            onPressed: _save,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!editing) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: CashWiseTheme.accentSoft,
                          foregroundColor: CashWiseTheme.accentFor(context),
                          child: Icon(Icons.arrow_upward),
                        ),
                        title: Text(strings.moneyLent),
                      subtitle: Text(
                        '${strings.pending}: '
                        '${store.formatAmount(store.totalLentOutstanding)}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          slideRoute(
                            const UdharListScreen(isLent: true),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: CashWiseTheme.accentSoft,
                        foregroundColor: CashWiseTheme.accentFor(context),
                        child: Icon(Icons.arrow_downward),
                      ),
                      title: Text(strings.moneyBorrowed),
                      subtitle: Text(
                        '${strings.pending}: '
                        '${store.formatAmount(store.totalBorrowedOutstanding)}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            slideRoute(
                              const UdharListScreen(isLent: false),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
