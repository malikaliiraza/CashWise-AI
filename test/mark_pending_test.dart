// CashWise AI — regression test for the "Mark pending" button (v7.0).
//
// The user reported the Mark pending button does not work. This test
// taps it on a settled entry in the Receivables list and checks the
// entry actually flips back to pending — including a fully-paid
// entry, which must stay pending after the tap.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cashwise_ai/features/expenses/data/expense_store.dart';
import 'package:cashwise_ai/features/expenses/models/udhar_entry.dart';
import 'package:cashwise_ai/features/expenses/presentation/udhar_list_screen.dart';
import 'package:cashwise_ai/core/gradient_button.dart';

Future<ExpenseStore> makeStore() async {
  SharedPreferences.setMockInitialValues({});
  final store = ExpenseStore();
  await store.load();
  return store;
}

Widget wrap(ExpenseStore store) =>
    ChangeNotifierProvider<ExpenseStore>.value(
      value: store,
      child: const MaterialApp(home: UdharListScreen(isLent: true)),
    );

void main() {
  testWidgets('Mark pending flips a settled entry back to pending',
      (tester) async {
    final store = await makeStore();
    await store.addUdhar(UdharEntry(
      id: 't1',
      person: 'Ali',
      amountPkr: 3000,
      isLent: true,
      date: DateTime.now(),
      settled: true,
    ));
    await tester.pumpWidget(wrap(store));
    await tester.pumpAndSettle();

    expect(find.text('Mark pending'), findsOneWidget);
    await tester.tap(find.text('Mark pending'));
    await tester.pumpAndSettle();

    expect(store.udharEntries.first.settled, isFalse);
    expect(find.text('Mark settled'), findsOneWidget);
  });

  testWidgets('Mark pending inside the detail sheet works too',
      (tester) async {
    final store = await makeStore();
    await store.addUdhar(UdharEntry(
      id: 't3',
      person: 'Chand',
      amountPkr: 1500,
      isLent: true,
      date: DateTime.now(),
      settled: true,
    ));
    await tester.pumpWidget(wrap(store));
    await tester.pumpAndSettle();

    // Open the detail sheet by tapping the entry card.
    await tester.tap(find.text('Chand'));
    await tester.pumpAndSettle();

    // The sheet's Mark pending is the gold GradientButton.
    expect(find.byType(GradientButton), findsOneWidget);
    await tester.tap(find.byType(GradientButton));
    await tester.pumpAndSettle();

    expect(store.udharEntries.first.settled, isFalse);
  });

  testWidgets('Mark pending on a fully-paid entry stays pending',
      (tester) async {
    final store = await makeStore();
    await store.addUdhar(UdharEntry(
      id: 't2',
      person: 'Badar',
      amountPkr: 2000,
      isLent: true,
      date: DateTime.now(),
      settled: true,
      payments: [
        PartialPayment(amount: 2000, date: DateTime.now()),
      ],
    ));
    await tester.pumpWidget(wrap(store));
    await tester.pumpAndSettle();

    expect(find.text('Mark pending'), findsOneWidget);
    await tester.tap(find.text('Mark pending'));
    await tester.pumpAndSettle();

    expect(store.udharEntries.first.settled, isFalse);
  });
}
