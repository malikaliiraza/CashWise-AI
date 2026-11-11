// CashWise AI — home screen (v5.2).
//
// Welcome page + two categories. After login the user sees a
// clean welcome hero and exactly two category cards — Budget and
// Loan Ledger, never mixed. Each category has its own home
// screen holding its whole system (Budget home: Set budget, Add
// Expense, Details, AI Predictor, Summary; Loan Ledger home:
// Receivables, Payables, Details, Summary). The welcome no
// longer shows only the budget's numbers — each card previews
// its own category's totals, so both are visible at a glance.
//   - Budget first: no expense can be added until a budget is set.
//   - Language            -> small slider in the AppBar
//   - Theme               -> small coloured slider in the drawer
//   - Drawer              -> scrollable, follows the selected
//     theme, with the same two expandable categories (arrow
//     opens their sub-options).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../data/expense_store.dart';
import '../models/udhar_entry.dart';
import 'add_expense_screen.dart';
import 'budget_home_screen.dart';
import 'budget_screen.dart';
import 'language_slider.dart';
import 'loan_ledger_home_screen.dart';
import 'loan_ledger_summary_screen.dart';
import 'history_screen.dart';
import 'reminders_screen.dart';
import 'udhar_detail_sheet.dart';
import 'statistics_screen.dart';
import 'theme_slider.dart';
import 'udhar_list_screen.dart';
import 'udhar_screen.dart';
import '../../../core/page_transitions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// True while the drawer is open — drives its fade/slide
  /// entrance animation (v5.6).
  bool _drawerOpen = false;

  Future<void> _confirmClearAll() async {
    final store = context.read<ExpenseStore>();
    final strings = store.strings;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.clearAllData),
        content: Text(strings.clearAllConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              strings.delete,
              style: const TextStyle(color: CashWiseTheme.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) await store.clearAllExpenses();
  }

  /// About: everything about the app — what it does, all its
  /// features, and what's new in this version. The What's new
  /// text is updated with every version (see localization).
  Future<void> _showAboutDialog() async {
    final store = context.read<ExpenseStore>();
    final strings = store.strings;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(store.displayBrand),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'v5.7.3',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(strings.aboutDescription),
              const SizedBox(height: 16),
              Text(
                strings.features,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(strings.aboutFeatures),
              const SizedBox(height: 16),
              Text(
                strings.whatsNew,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(strings.whatsNewText),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.cancel),
          ),
        ],
      ),
    );
  }

  /// Language, from the account menu: the same EN ⇄ اردو slider,
  /// in a small dialog.
  Future<void> _showLanguageDialog() async {
    final store = context.read<ExpenseStore>();
    final strings = store.strings;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.language),
        content: SizedBox(
          width: 220,
          child: LanguageSlider(store: store),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.cancel),
          ),
        ],
      ),
    );
  }

  /// The Home reminders card: SHORT rows only — a few words
  /// each, at most two reminders plus the budget warning when
  /// there is one. Full details open on tap; the chevron opens
  /// the Reminders page for the rest.
  Widget _remindersCard(ExpenseStore store) {
    final strings = store.strings;
    final entries = <UdharEntry>[
      ...store.overdueUdhar,
      ...store.dueWithinWeekUdhar
          .where((e) => !store.overdueUdhar.contains(e)),
    ];
    final shown = entries.take(2).toList();
    final hasMore = entries.length > shown.length;

    String shortDue(UdharEntry e) {
      final status = e.dueStatus;
      if (status == DueStatus.overdue) return strings.overdue;
      if (status == DueStatus.dueToday) return strings.dueToday;
      if (status == DueStatus.dueTomorrow) return strings.dueTomorrow;
      return strings.dueInDays(e.daysUntilDue ?? 0);
    }

    return Card(
      color: store.overdueUdhar.isNotEmpty
          ? const Color(0xFFFDECEC)
          : const Color(0xFFFFFBEB),
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
                  color: store.overdueUdhar.isNotEmpty
                      ? CashWiseTheme.danger
                      : CashWiseTheme.lightAccent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    strings.reminders,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  tooltip: strings.viewAllReminders,
                  onPressed: () {
                    Navigator.of(context).push(
                      slideRoute(const RemindersScreen()),
                    );
                  },
                ),
              ],
            ),
            if (store.hasBudgetWarning)
              _reminderRow(
                icon: Icons.warning_amber,
                color: CashWiseTheme.danger,
                text: store.warningLevel >= 100
                    ? strings.warning100
                    : strings.warning80,
                onTap: () {
                  Navigator.of(context).push(
                    slideRoute(const RemindersScreen()),
                  );
                },
              ),
            ...shown.map(
              (e) => _reminderRow(
                icon: e.isOverdue
                    ? Icons.notifications_active
                    : Icons.schedule,
                color: e.isOverdue
                    ? CashWiseTheme.danger
                    : CashWiseTheme.lightAccent,
                text: '${store.displayPerson(e.person)} — '
                    '${store.formatAmount(e.remaining)} · ${shortDue(e)}',
                onTap: () => UdharDetailSheet.show(context, e),
              ),
            ),
            if (hasMore)
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    slideRoute(const RemindersScreen()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Text(
                        strings.viewAllReminders,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _reminderRow({
    required IconData icon,
    required Color color,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// One big category card on the home page: icon, name, a short
  /// preview of that category's own totals, and a chevron. The
  /// two categories stay separate — each card only ever shows
  /// its own numbers.
  Widget _categoryCard({
    required String label,
    required IconData icon,
    required Color tint,
    required Color iconColor,
    required String preview,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: CashWiseTheme.gold.withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 22,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: tint,
                foregroundColor: iconColor,
                child: Icon(icon, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: CashWiseTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: CashWiseTheme.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Opens the budget details page on the given tab:
  /// 0 = Expenses, 1 = AI Predictor, 2 = Summary.
  void _openDetails([int tab = 0]) {
    Navigator.of(context).push(
      slideRoute(StatisticsScreen(initialTab: tab)),
    );
  }

  void _openLoanLedgerList(bool isLent) {
    Navigator.of(context).push(
      slideRoute(UdharListScreen(isLent: isLent)),
    );
  }

  void _openBudget() {
    Navigator.of(context).push(
      slideRoute(const BudgetScreen()),
    );
  }

  void _openAddExpense() {
    Navigator.of(context).push(
      slideRoute(const AddExpenseScreen()),
    );
  }

  @override
  /// Edit the account name from the avatar menu. In Urdu mode
  /// there are two fields: the English name and the Urdu name —
  /// so the user can type (or fix) the Urdu spelling directly
  /// instead of relying on the transliteration.
  Future<void> _showEditNameDialog() async {
    final store = context.read<ExpenseStore>();
    final isUrdu = store.locale.code == 'ur';
    final enController = TextEditingController(text: store.userName);
    final urController = TextEditingController(
      text: store.userNameUrdu.isNotEmpty
          ? store.userNameUrdu
          : store.displayName,
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        final strings = store.strings;
        return AlertDialog(
          title: Text(strings.editName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: enController,
                decoration:
                    InputDecoration(labelText: strings.nameInEnglish),
                textCapitalization: TextCapitalization.words,
              ),
              if (isUrdu) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: urController,
                  decoration:
                      InputDecoration(labelText: strings.nameInUrdu),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(strings.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(strings.save),
            ),
          ],
        );
      },
    );
    if (saved == true && enController.text.trim().isNotEmpty) {
      await store.updateUserName(
        enController.text.trim(),
        nameUrdu: isUrdu ? urController.text.trim() : null,
      );
    }
    enController.dispose();
    urController.dispose();
  }

  Widget build(BuildContext context) {
    final store = context.watch<ExpenseStore>();
    final strings = store.strings;
    final locale = store.locale;

    return Directionality(
      textDirection: locale.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        onDrawerChanged: (open) {
          setState(() => _drawerOpen = open);
        },
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: CashWiseTheme.headerGradientOf(context),
          ),
          // Hamburger with an unread-reminders badge: the number
          // shows while reminders are unread, and clears once
          // the Reminders page is opened.
          leading: Builder(
            builder: (context) {
              final unread = store.unreadReminderCount;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                  if (unread > 0)
                    Positioned(
                      top: 8,
                      right: 6,
                      child: CircleAvatar(
                        radius: 9,
                        backgroundColor: CashWiseTheme.danger,
                        child: Text(
                          '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          title: Text(store.displayBrand),
          actions: [
            // The language option lives in the account menu now,
            // not on the home screen.
            PopupMenuButton<String>(
              // The user's name initial as a button. Tapping it
              // opens a professional account card anchored under
              // the avatar: name + email, then Sign out.
              icon: CircleAvatar(
                backgroundColor: store.isDarkMode
                    ? Colors.white.withValues(alpha: 0.2)
                    : CashWiseTheme.lightAccent,
                foregroundColor: Colors.white,
                child: Text(
                  store.userName.isNotEmpty
                      ? store.displayName[0].toUpperCase()
                      : 'C',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              tooltip: store.userName,
              offset: const Offset(0, 48),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: store.isDarkMode
                  ? CashWiseTheme.darkCard
                  : Colors.white,
              onSelected: (value) async {
                if (value == 'editName') {
                  await _showEditNameDialog();
                } else if (value == 'language') {
                  await _showLanguageDialog();
                } else if (value == 'logout') {
                  await store.logout();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  enabled: false,
                  height: 64,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: store.isDarkMode
                            ? Colors.white.withValues(alpha: 0.2)
                            : CashWiseTheme.lightAccent,
                        foregroundColor: Colors.white,
                        child: Text(
                          store.userName.isNotEmpty
                              ? store.displayName[0].toUpperCase()
                              : 'C',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            store.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            store.userEmail,
                            style: const TextStyle(
                              fontSize: 12,
                              color: CashWiseTheme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'editName',
                  child: Row(
                    children: [
                      const Icon(Icons.edit, size: 20),
                      const SizedBox(width: 8),
                      Text(strings.editName),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'language',
                  child: Row(
                    children: [
                      const Icon(Icons.language, size: 20),
                      const SizedBox(width: 8),
                      Text(strings.language),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      const Icon(Icons.logout, size: 20),
                      const SizedBox(width: 8),
                      Text(strings.logout),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        drawer: Drawer(
          // Floating panel: a transparent drawer holding a
          // card with margins on every side, 26px corners and
          // a deep soft shadow — it never fills the screen.
          width: 300,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 24, 16, 24),
            decoration: BoxDecoration(
              color: store.isDarkMode
                  ? CashWiseTheme.darkCard
                  : Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 28,
                  offset: Offset(6, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: AnimatedSlide(
                offset: _drawerOpen
                    ? Offset.zero
                    : const Offset(-0.15, 0),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                child: AnimatedOpacity(
                  opacity: _drawerOpen ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
              DrawerHeader(
                // The drawer follows the selected theme: light
                // header with dark text in light mode, navy
                // gradient with white text in dark mode — so the
                // name and email are always readable.
                decoration: store.isDarkMode
                    ? CashWiseTheme.headerGradientOf(context)
                    : const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: CashWiseTheme.gold,
                            width: 2,
                          ),
                        ),
                      ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      backgroundColor: store.isDarkMode
                          ? Colors.white.withValues(alpha: 0.2)
                          : CashWiseTheme.accentSoft,
                      foregroundColor: store.isDarkMode
                          ? Colors.white
                          : CashWiseTheme.lightAccent,
                      child: Text(
                        store.userName.isNotEmpty
                            ? store.displayName[0].toUpperCase()
                            : 'C',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      store.displayBrand,
                      style: TextStyle(
                        color: store.isDarkMode
                            ? Colors.white
                            : CashWiseTheme.darkText,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (store.userName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        store.displayName,
                        style: TextStyle(
                          color: store.isDarkMode
                              ? Colors.white
                              : CashWiseTheme.darkText,
                        ),
                      ),
                    ],
                    if (store.userEmail.isNotEmpty) ...[
                      Text(
                        store.userEmail,
                        style: TextStyle(
                          color: store.isDarkMode
                              ? Colors.white70
                              : CashWiseTheme.secondaryText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: Text(strings.home),
                onTap: () => Navigator.of(context).pop(),
              ),
              // Reminders section — overdue + due-soon entries
              // live in the drawer too; tapping one opens its
              // detail, "View all reminders" opens the full page.
              ExpansionTile(
                leading: const Icon(Icons.notifications_active),
                title: Text(strings.reminders),
                // Opening the section counts as seeing them:
                // the menu badge clears without having to open
                // and read every reminder.
                onExpansionChanged: (expanded) {
                  if (expanded) store.markRemindersRead();
                },
                trailing: store.hasUnreadReminders
                    ? CircleAvatar(
                        radius: 11,
                        backgroundColor: CashWiseTheme.danger,
                        child: Text(
                          '${store.unreadReminderCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
                children: [
                  if (!store.hasUdharReminders)
                    ListTile(
                      title: Text(strings.noReminders),
                      enabled: false,
                    )
                  else ...[
                    // At most two rows here — the rest live
                    // behind "View all reminders".
                    ...[
                      ...store.overdueUdhar,
                      ...store.dueWithinWeekUdhar.where(
                          (e) => !store.overdueUdhar.contains(e)),
                    ].take(2).map(
                      (e) => Dismissible(
                        key: ValueKey(e.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          color: CashWiseTheme.danger,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (_) =>
                            store.dismissReminder(e),
                        child: ListTile(
                          leading: Icon(
                            e.isOverdue
                                ? Icons.notifications_active
                                : Icons.schedule,
                            size: 18,
                            color: e.isOverdue
                                ? CashWiseTheme.danger
                                : null,
                          ),
                          title: Text(store.displayPerson(e.person)),
                          subtitle: Text(
                            '${strings.remainingAmount}: '
                            '${store.formatAmount(e.remaining)}',
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            UdharDetailSheet.show(context, e);
                          },
                        ),
                      ),
                    ),
                  ],
                  ListTile(
                    leading: const Icon(Icons.list),
                    title: Text(strings.viewAllReminders),
                    onTap: () {
                      store.markRemindersRead();
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        slideRoute(const RemindersScreen()),
                      );
                    },
                  ),
                ],
              ),
              // Budget section — arrow opens Set budget, Add
              // Expense, Details, AI Predictor and Summary below it.
              ExpansionTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: Text(strings.budget),
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: Text(strings.setMonthlyBudget),
                    onTap: () {
                      Navigator.of(context).pop();
                      _openBudget();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: Text(strings.addExpense),
                    onTap: () {
                      Navigator.of(context).pop();
                      _openAddExpense();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.bar_chart),
                    title: Text(strings.details),
                    onTap: () {
                      Navigator.of(context).pop();
                      _openDetails(0);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.psychology),
                    title: Text(strings.aiPredictor),
                    onTap: () {
                      Navigator.of(context).pop();
                      _openDetails(1);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.summarize),
                    title: Text(strings.summary),
                    onTap: () {
                      Navigator.of(context).pop();
                      _openDetails(2);
                    },
                  ),
                ],
              ),
              // Loan Ledger section — arrow opens Receivables,
              // Payables, Details and Summary below it.
              ExpansionTile(
                leading: const Icon(Icons.handshake),
                title: Text(strings.udhar),
                children: [
                  ListTile(
                    leading: const Icon(Icons.call_received),
                    title: Text(strings.moneyLent),
                    onTap: () {
                      Navigator.of(context).pop();
                      _openLoanLedgerList(true);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.call_made),
                    title: Text(strings.moneyBorrowed),
                    onTap: () {
                      Navigator.of(context).pop();
                      _openLoanLedgerList(false);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.bar_chart),
                    title: Text(strings.details),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        slideRoute(const UdharScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.summarize),
                    title: Text(strings.summary),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        slideRoute(
                          const LoanLedgerSummaryScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              // "Theme" label with the small coloured slider right
              // next to it; the slider carries the sun/moon icons.
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Text(
                      strings.theme,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: ThemeSlider(store: store)),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_forever,
                  color: CashWiseTheme.danger,
                ),
                title: Text(strings.clearAllData),
                onTap: () {
                  Navigator.of(context).pop();
                  _confirmClearAll();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(strings.logout),
                onTap: () {
                  Navigator.of(context).pop();
                  store.logout();
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: Text(strings.history),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    slideRoute(const HistoryScreen()),
                  );
                },
              ),
              // About is last in the menu, at the very bottom.
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(strings.about),
                onTap: () {
                  Navigator.of(context).pop();
                  _showAboutDialog();
                },
              ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
                    if (store.hasUdharReminders || store.hasBudgetWarning)
                      _remindersCard(store),
                    const SizedBox(height: 16),
                    // Welcome hero — rich gradient + gold rule.
                    Container(
                      // The welcome hero follows the theme too:
                      // navy in dark mode, soft light blue in
                      // light mode, with matching text colours.
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: store.isDarkMode
                              ? const [
                                  Color(0xFF292524),
                                  Color(0xFF44403C),
                                  Color(0xFF57534E),
                                ]
                              : const [
                                  Color(0xFFFFFBEB),
                                  Color(0xFFFEF3C7),
                                  Color(0xFFFDE68A),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(24)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1F000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -30,
                            top: -30,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (store.isDarkMode
                                        ? Colors.white
                                        : CashWiseTheme.gold)
                                    .withValues(alpha: 0.12),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 60,
                            bottom: -40,
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: CashWiseTheme.gold
                                    .withValues(alpha: 0.15),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.account_balance_wallet,
                                  size: 44,
                                  color: store.isDarkMode
                                      ? Colors.white
                                      : CashWiseTheme.lightAccent,
                                ),
                          const SizedBox(height: 12),
                          Text(
                            store.userName.isNotEmpty
                                ? strings.welcomeName(store.displayName)
                                : strings.welcomeTitle,
                            style: TextStyle(
                              color: store.isDarkMode
                                  ? Colors.white
                                  : CashWiseTheme.darkText,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 2,
                            width: 48,
                            color: CashWiseTheme.gold,
                          ),
                          const SizedBox(height: 12),
                                Text(
                                  strings.welcomeSubtitle,
                                  style: TextStyle(
                                    color: store.isDarkMode
                                        ? Colors.white
                                        : CashWiseTheme.darkText,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      strings.categories,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _categoryCard(
                      label: strings.budget,
                      icon: Icons.account_balance_wallet,
                      tint: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFF92400E),
                      preview: store.hasBudget
                          ? '${strings.budget}: '
                              '${store.formatAmount(store.monthlyBudgetPkr)}'
                              ' • ${strings.spentThisMonth}: '
                              '${store.formatAmount(store.totalSpent)}'
                          : strings.setBudgetFirst,
                      onTap: () {
                        Navigator.of(context).push(
                          slideRoute(const BudgetHomeScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _categoryCard(
                      label: strings.udhar,
                      icon: Icons.handshake,
                      tint: const Color(0xFFFFFBEB),
                      iconColor: const Color(0xFFB45309),
                      preview:
                          '${strings.moneyLent}: '
                          '${store.formatAmount(store.totalLentOutstanding)}'
                          ' • ${strings.moneyBorrowed}: '
                          '${store.formatAmount(store.totalBorrowedOutstanding)}',
                      onTap: () {
                        Navigator.of(context).push(
                          slideRoute(const LoanLedgerHomeScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      strings.aboutText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: CashWiseTheme.secondaryText,
                      ),
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
}
