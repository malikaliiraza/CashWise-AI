import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/notification_service.dart';
import 'core/theme.dart';
import 'features/expenses/data/expense_store.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/welcome_transition_screen.dart';
import 'features/expenses/presentation/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Budget alerts as mobile notifications (no-op on web).
  await NotificationService.init();
  runApp(const CashWiseApp());
}

class CashWiseApp extends StatelessWidget {
  const CashWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final store = ExpenseStore();
        // After loading, fire the once-a-day Loan Ledger due
        // reminders (overdue / due tomorrow) as a phone alert.
        store.load().then((_) => store.maybeNotifyDueReminders());
        return store;
      },
      child: Consumer<ExpenseStore>(
        builder: (context, store, _) {
          final locale = store.locale;
          return MaterialApp(
            title: 'Hisaab Kitaab',
            debugShowCheckedModeBanner: false,
            theme: CashWiseTheme.light,
            darkTheme: CashWiseTheme.dark,
            themeMode:
                store.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            locale: Locale(locale.code),
            // Right-to-left layout for Urdu and Arabic, left-to-right
            // for every other locale.
            builder: (context, child) => Directionality(
              textDirection:
                  locale.isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: child!,
            ),
            // Login / register first — the app never opens
            // straight into the expenses (v4.1).
            // The welcome screen plays on every app open
            // (v6.0): the wallet opens, then home. After a
            // login/register it plays too (showWelcome).
            home: !store.isLoggedIn
                ? const LoginScreen()
                : store.showWelcome || store.showLaunchWelcome
                    ? const WelcomeTransitionScreen()
                    : const HomeScreen(),
          );
        },
      ),
    );
  }
}
