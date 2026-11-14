// Hisaab Kitaab — regression test for the drawer email (v7.2).
//
// The drawer email truncated / overflowed before (this regressed
// once already): the drawer was 300dp wide, the email Text was
// maxLines: 1 with an ellipsis, and the DrawerHeader itself had
// a fixed 161px height, so a wrapped name/email could not fit.
// v7.2 fixes all three: drawer width 320, name and email wrap
// over two lines with no ellipsis, and the header is a flexible
// Container that grows to fit.
//
// The test pumps the real HomeScreen with a long email, opens
// the drawer, and asserts the FULL email text is present with
// no overflow exception.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

Widget wrap(ExpenseStore store) =>
    ChangeNotifierProvider<ExpenseStore>.value(
      value: store,
      child: MaterialApp(home: const HomeScreen(), theme: store.isDarkMode ? ThemeData.dark() : ThemeData.light()),
    );

Future<void> openDrawer(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('drawer shows the full email, no truncation or overflow',
      (tester) async {
    final store = await makeStore();
    await tester.pumpWidget(wrap(store));
    await tester.pumpAndSettle();
    await openDrawer(tester);

    expect(find.text('melicalyraza5@gmail.com'), findsOneWidget);
    expect(find.text('Malik Ali Raza'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('drawer is 320dp wide and fits a very long email',
      (tester) async {
    final store = await makeStore(
      email: 'malik.ali.raza.verylongname@example.com',
    );
    await tester.pumpWidget(wrap(store));
    await tester.pumpAndSettle();
    await openDrawer(tester);

    final drawer = tester.widget<Drawer>(find.byType(Drawer));
    expect(drawer.width, 320);
    expect(
      find.text('malik.ali.raza.verylongname@example.com'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('drawer shows the full email in dark mode too',
      (tester) async {
    final store = await makeStore();
    await store.setDarkMode(true);
    await tester.pumpWidget(wrap(store));
    await tester.pumpAndSettle();
    await openDrawer(tester);

    expect(find.text('melicalyraza5@gmail.com'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
