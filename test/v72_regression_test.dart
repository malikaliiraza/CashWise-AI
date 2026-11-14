// Hisaab Kitaab — v7.2 regression tests (coordinator).
//
// Covers the v7.2 rules that must never regress:
//  1. AmountRow: a long label never overlaps/cuts the amount, and
//     amounts in one card share one right edge (Rs. under Rs.).
//  2. GradientButton: a long label shrinks to one line instead of
//     truncating ("Mark settl..." is forbidden).
//  3. Edit Name dialog: BOTH fields (English + Urdu) in English mode.
//  4. Login / Create account fits a 360x640 phone with no overflow
//     (compact, no-scroll form).
//  5. Dark-mode home smoke: sub-button labels present, no overflow.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cashwise_ai/core/amount_row.dart';
import 'package:cashwise_ai/core/gradient_button.dart';
import 'package:cashwise_ai/features/auth/presentation/login_screen.dart';
import 'package:cashwise_ai/features/expenses/data/expense_store.dart';
import 'package:cashwise_ai/features/expenses/presentation/home_screen.dart';

Future<ExpenseStore> makeStore({
  String email = 'melicalyraza5@gmail.com',
  String name = 'Malik Ali Raza',
}) async {
  SharedPreferences.setMockInitialValues({});
  final store = ExpenseStore();
  await store.load();
  final created = await store.register(
    name: name,
    email: email,
    password: 'Strong1!',
  );
  expect(created, isTrue);
  return store;
}

Widget wrapWithStore(ExpenseStore store, Widget child) =>
    ChangeNotifierProvider<ExpenseStore>.value(
      value: store,
      child: MaterialApp(home: child),
    );

void main() {
  testWidgets('AmountRow: long label wraps, amounts share one right edge',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: Column(
              children: [
                AmountRow(
                  label: 'Projected month-end spend',
                  amount: 'Rs. 20,000',
                ),
                AmountRow(label: 'Budget', amount: 'Rs. 10,000'),
                AmountRow(label: 'Spent this month', amount: 'Rs. 8,000'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Projected month-end spend'), findsOneWidget);
    expect(find.text('Rs. 20,000'), findsOneWidget);
    // All three amounts end at the same x — one straight column.
    final right1 = tester.getTopRight(find.text('Rs. 20,000')).dx;
    final right2 = tester.getTopRight(find.text('Rs. 10,000')).dx;
    final right3 = tester.getTopRight(find.text('Rs. 8,000')).dx;
    expect(right1, right2);
    expect(right2, right3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('GradientButton: long label stays one line, never truncates',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 160,
            child: GradientButton(label: 'Mark settled', onPressed: () {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Full label text is rendered (a truncated label would still
    // carry the full string, so also assert it fits on one line:
    // the Text widget's height must be a single line).
    expect(find.text('Mark settled'), findsOneWidget);
    final textBox = tester.getSize(find.text('Mark settled'));
    expect(textBox.height, lessThanOrEqualTo(24));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Edit Name shows both fields in English mode', (tester) async {
    final store = await makeStore();
    await tester.pumpWidget(wrapWithStore(store, const HomeScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit name'));
    await tester.pumpAndSettle();

    expect(find.text('Name in English'), findsOneWidget);
    expect(find.text('Name in Urdu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Create account fits a 360x640 phone with no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final store = ExpenseStore();
    await store.load();
    await tester.pumpWidget(wrapWithStore(store, const LoginScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Create account'), findsWidgets);
    expect(find.text('Your money, beautifully organized.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark-mode home: sub-button labels present, no overflow',
      (tester) async {
    final store = await makeStore();
    await store.setDarkMode(true);
    await tester.pumpWidget(wrapWithStore(store, const HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Set monthly budget'), findsWidgets);
    expect(find.text('Add expense'), findsWidgets);
    expect(find.text('AI Predictor'), findsWidgets);
    expect(find.text('Summary'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
