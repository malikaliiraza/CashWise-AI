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
import 'add_expense_screen.dart';
import 'budget_home_screen.dart';
import 'budget_screen.dart';
import 'language_slider.dart';
import 'loan_ledger_home_screen.dart';
import 'loan_ledger_summary_screen.dart';
import 'history_screen.dart';
import 'reminders_screen.dart';
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
                'v7.3',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                strings.aboutText,
                style: const TextStyle(fontStyle: FontStyle.italic),
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
              const SizedBox(height: 16),
              Text(
                strings.aboutDeveloperTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(strings.aboutDeveloper),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                strings.aboutPrivacy,
                style: const TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
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

  /// One option button for the two-column grid: a tinted tile
  /// with the icon above the label. v7.2: theme-aware colours
  /// (cream/dark-text in light mode, stone/soft-white in dark
  /// mode — never light text on cream) and a label that shrinks
  /// instead of truncating: FittedBox scaleDown, one line, no
  /// ellipsis — "Set monthly..." is forbidden.
  Widget _subButton(
    ({String label, IconData icon, VoidCallback onTap}) a,
    Color iconColor,
  ) {
    final border = CashWiseTheme.subButtonBorder(context);
    return Container(
      decoration: BoxDecoration(
        color: CashWiseTheme.subButtonBg(context),
        borderRadius: BorderRadius.circular(12),
        border: border == null ? null : Border.all(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: a.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(a.icon, size: 20, color: iconColor),
                const SizedBox(width: 6),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      a.label,
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: CashWiseTheme.subButtonFg(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// One option button for the full-width rows (v7.2): a tinted
  /// row with the icon in a small tinted chip, the label and a
  /// chevron at the end. Slightly larger corner radius (16dp)
  /// than the old 12dp rows, theme-aware colours, and a label
  /// that shrinks instead of truncating — one line, no ellipsis.
  Widget _subButtonRow(
    ({String label, IconData icon, VoidCallback onTap}) a,
    Color iconColor,
  ) {
    final border = CashWiseTheme.subButtonBorder(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: CashWiseTheme.subButtonBg(context),
          borderRadius: BorderRadius.circular(16),
          border: border == null ? null : Border.all(color: border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: a.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(a.icon, size: 20, color: iconColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        a.label,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: CashWiseTheme.subButtonFg(context),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: CashWiseTheme.secondaryTextFor(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The Home reminders card (v7.1): SHORT rows only — a few
  /// words each, at most two reminders. Only reminders the user
  /// set himself ever appear here; nothing is automatic. The
  /// chevron opens the Reminders page for the rest.
  Widget _remindersCard(ExpenseStore store) {
    final strings = store.strings;
    // Due reminders only, two rows at most — the rest live
    // behind "View all".
    final customDue = store.customRemindersDue;
    final customShown = customDue.take(2).toList();
    final hasMore = customDue.length > 2;

    // Theme-aware card (v6.0): the old light pink/cream card
    // was unreadable in dark mode (light text on a light card).
    final isDark = store.isDarkMode;
    final hasDue = customDue.isNotEmpty;
    return Card(
      color: isDark
          ? (hasDue
              ? const Color(0xFF3D2323)
              : CashWiseTheme.darkCard)
          : (hasDue
              ? const Color(0xFFFDECEC)
              : const Color(0xFFF5F2EB)),
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
                  color: hasDue
                      ? CashWiseTheme.danger
                      : CashWiseTheme.accentFor(context),
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
            ...customShown.map(
              (r) => _reminderRow(
                icon: Icons.schedule,
                color: CashWiseTheme.accentFor(context),
                text: store.customReminderText(r),
                onTap: () {
                  Navigator.of(context).push(
                    slideRoute(const RemindersScreen()),
                  );
                },
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
  /// preview of that category's own totals, a chevron — and below
  /// it, the category's options as REAL buttons (v7.1): each with
  /// its own icon and a tinted background, so they look like
  /// buttons, not plain rows. v7.2: BOTH cards show full-width
  /// rows — the Budget card's two-column grid left an empty
  /// space under its 5th (odd) button. The two categories stay
  /// separate — each card only ever shows its own numbers and
  /// its own options.
  Widget _categoryCard({
    required String label,
    required IconData icon,
    required Color tint,
    required Color iconColor,
    required String preview,
    required VoidCallback onTap,
    required List<({String label, IconData icon, VoidCallback onTap})>
        subActions,
    required bool subActionsAsGrid,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: CashWiseTheme.tealMid.withValues(alpha: 0.45),
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
          child: Column(
            children: [
              Row(
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
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                CashWiseTheme.secondaryTextFor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: CashWiseTheme.secondaryTextFor(context),
                  ),
                ],
              ),
              if (subActions.isNotEmpty) ...[
                const SizedBox(height: 14),
                if (subActionsAsGrid)
                  // Two-column tiles: icon above the label.
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.9,
                    children: subActions
                        .map((a) => _subButton(a, iconColor))
                        .toList(),
                  )
                else
                  // Full-width rows: icon, label, chevron.
                  Column(
                    children: subActions
                        .map((a) => _subButtonRow(a, iconColor))
                        .toList(),
                  ),
              ],
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
  /// Edit the account name from the avatar menu. v7.2: BOTH
  /// fields are always shown — Name in English and Name in Urdu
  /// — in BOTH language modes (the old Urdu-only gate hid the
  /// Urdu field in English mode), and both are always saved;
  /// the Urdu spelling is only stored when it is non-empty.
  Future<void> _showEditNameDialog() async {
    final store = context.read<ExpenseStore>();
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
          title: Text(
            strings.editName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: enController,
                decoration:
                    InputDecoration(labelText: strings.nameInEnglish),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urController,
                decoration:
                    InputDecoration(labelText: strings.nameInUrdu),
                textDirection: TextDirection.rtl,
              ),
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
      final urdu = urController.text.trim();
      await store.updateUserName(
        enController.text.trim(),
        nameUrdu: urdu.isNotEmpty ? urdu : null,
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
                  // v7.2: taller, and the name/email wrap onto a
                  // second line instead of truncating — the same
                  // permanent fix as the drawer header.
                  height: 88,
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              store.displayName,
                              maxLines: 2,
                              softWrap: true,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              store.userEmail,
                              maxLines: 2,
                              softWrap: true,
                              style: TextStyle(
                                fontSize: 12,
                                color: CashWiseTheme.secondaryTextFor(
                                  context,
                                ),
                              ),
                            ),
                          ],
                        ),
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
          // v7.2: 320dp wide so a long email has room to wrap
          // instead of truncating (this regressed before).
          width: 320,
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
              // v7.2: a transparent Material INSIDE the decorated
              // panel — without it the drawer's ListTiles throw
              // ("background color or ink splashes may be
              // invisible") because their nearest Material sits
              // above the panel's background.
              child: Material(
                color: Colors.transparent,
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
              // v7.2: a plain Container, NOT DrawerHeader —
              // DrawerHeader has a fixed 161px height, so a name
              // or email wrapping onto a second line overflowed
              // and got clipped. This header grows to fit: the
              // full name and the full email always show, wrapped
              // over two lines at most, never with an ellipsis.
              Container(
                decoration: store.isDarkMode
                    ? CashWiseTheme.headerGradientOf(context)
                    : const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: CashWiseTheme.tealMid,
                            width: 2,
                          ),
                        ),
                      ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
                        maxLines: 2,
                        softWrap: true,
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
                        maxLines: 2,
                        softWrap: true,
                        style: TextStyle(
                          color: store.isDarkMode
                              ? Colors.white70
                              : CashWiseTheme.secondaryTextFor(
                                  context),
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
              // Reminders section — only reminders the user set
              // himself live in the drawer too (v7.1); tapping
              // one opens the full page.
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
                  if (!store.hasCustomRemindersDue)
                    ListTile(
                      title: Text(strings.noReminders),
                      enabled: false,
                    )
                  else ...[
                    ...store.customRemindersDue.take(2).map(
                      (r) => ListTile(
                        leading: const Icon(Icons.schedule, size: 18),
                        title: Text(store.customReminderText(r)),
                        onTap: () {
                          store.markRemindersRead();
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            slideRoute(const RemindersScreen()),
                          );
                        },
                      ),
                    ),
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
                    // Welcome hero — rich gradient + teal rule.
                    Container(
                      // The welcome hero follows the theme too:
                      // navy in dark mode, soft light blue in
                      // light mode, with matching text colours.
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: store.isDarkMode
                              ? const [
                                  Color(0xFF072E2E),
                                  Color(0xFF0C4444),
                                  Color(0xFF155E5E),
                                ]
                              : const [
                                  Color(0xFFF5F2EB),
                                  Color(0xFFE3EDE8),
                                  Color(0xFFCDE4DA),
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
                                        : CashWiseTheme.tealMid)
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
                                color: CashWiseTheme.tealMid
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
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.asset(
                                    'assets/logo.png',
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                  ),
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
                            color: CashWiseTheme.tealMid,
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
                    // Reminders sit directly under the Welcome
                    // note (v6.0) — never above it.
                    if (store.hasCustomRemindersDue) ...[
                      const SizedBox(height: 16),
                      _remindersCard(store),
                    ],
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
                      tint: const Color(0xFFE3EDE8),
                      iconColor: const Color(0xFF0C4444),
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
                      // Full-width rows (v7.2) — both cards use
                      // rows now; the Budget grid left an empty
                      // space under its 5th (odd) button.
                      subActionsAsGrid: false,
                      subActions: [
                        (
                          label: strings.setMonthlyBudget,
                          icon: Icons.edit,
                          onTap: _openBudget,
                        ),
                        (
                          label: strings.addExpense,
                          icon: Icons.add,
                          onTap: _openAddExpense,
                        ),
                        (
                          label: strings.details,
                          icon: Icons.bar_chart,
                          onTap: () => _openDetails(0),
                        ),
                        (
                          label: strings.aiPredictor,
                          icon: Icons.psychology,
                          onTap: () => _openDetails(1),
                        ),
                        (
                          label: strings.summary,
                          icon: Icons.summarize,
                          onTap: () => _openDetails(2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _categoryCard(
                      label: strings.udhar,
                      icon: Icons.handshake,
                      tint: const Color(0xFFF5F2EB),
                      iconColor: const Color(0xFF0F766E),
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
                      // Full-width rows (v7.1) — a different
                      // sequence from the Budget card on purpose.
                      subActionsAsGrid: false,
                      subActions: [
                        (
                          label: strings.moneyLent,
                          icon: Icons.arrow_upward,
                          onTap: () => _openLoanLedgerList(true),
                        ),
                        (
                          label: strings.moneyBorrowed,
                          icon: Icons.arrow_downward,
                          onTap: () => _openLoanLedgerList(false),
                        ),
                        (
                          label: strings.details,
                          icon: Icons.list,
                          onTap: () {
                            Navigator.of(context).push(
                              slideRoute(const UdharScreen()),
                            );
                          },
                        ),
                        (
                          label: strings.summary,
                          icon: Icons.summarize,
                          onTap: () {
                            Navigator.of(context).push(
                              slideRoute(
                                  const LoanLedgerSummaryScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      strings.aboutText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: CashWiseTheme.secondaryTextFor(context),
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
