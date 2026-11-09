import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'features/expenses/data/expense_store.dart';
import 'features/expenses/presentation/home_screen.dart';

void main() {
  runApp(const CashWiseApp());
}

class CashWiseApp extends StatelessWidget {
  const CashWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpenseStore()..load(),
      child: Consumer<ExpenseStore>(
        builder: (context, store, _) {
          final locale = store.locale;
          return MaterialApp(
            title: 'CashWise AI',
            debugShowCheckedModeBanner: false,
            theme: CashWiseTheme.light,
            locale: Locale(locale.code),
            // Right-to-left layout for Urdu and Arabic, left-to-right
            // for every other locale.
            builder: (context, child) => Directionality(
              textDirection:
                  locale.isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: child!,
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
