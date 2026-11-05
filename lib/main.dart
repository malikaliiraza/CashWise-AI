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
      child: MaterialApp(
        title: 'CashWise AI',
        debugShowCheckedModeBanner: false,
        theme: CashWiseTheme.light,
        home: const HomeScreen(),
      ),
    );
  }
}
