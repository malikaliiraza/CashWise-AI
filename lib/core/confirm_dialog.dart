// CashWise AI — shared delete confirmation (v5.7.3).
//
// Every delete icon in the app (expense row, loan entry, single
// payment) asks once, so a stray tap never wipes data. Returns
// true only when the user taps Delete.

import 'package:flutter/material.dart';

import 'localization.dart';
import 'theme.dart';

Future<bool> confirmDelete(
  BuildContext context,
  AppLocale strings,
  String itemLabel,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(strings.delete),
      content: Text(itemLabel),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(strings.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            strings.delete,
            style: const TextStyle(
              color: CashWiseTheme.danger,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
  return confirmed == true;
}
