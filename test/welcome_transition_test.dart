// CashWise AI — regression test for the welcome transition (v7.0).
//
// The belt-strap wallet is a Stack with a rotating cover and a
// Positioned belt. A Positioned that is not a direct Stack child
// crashes at runtime, so this test pumps the screen and plays
// the whole animation through to the dismiss.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cashwise_ai/features/auth/presentation/welcome_transition_screen.dart';
import 'package:cashwise_ai/features/expenses/data/expense_store.dart';

void main() {
  testWidgets('welcome wallet plays and dismisses without crashing',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = ExpenseStore();
    await store.load();
    expect(store.showLaunchWelcome, isTrue);

    await tester.pumpWidget(
      ChangeNotifierProvider<ExpenseStore>.value(
        value: store,
        child: const MaterialApp(home: WelcomeTransitionScreen()),
      ),
    );
    // Play the animation in steps: belt, then cover, then dismiss.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1000));

    expect(store.showLaunchWelcome, isFalse);
    expect(store.showWelcome, isFalse);
  });
}
