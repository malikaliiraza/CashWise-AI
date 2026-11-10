# CashWise AI — International Finance Coach

> **v2 international — published 2026-11-09.** A run/test of v2 on a real device is still pending; v1 was run-tested on 2026-11-09.

A Flutter finance app for everyone, in their own language and currency: offline-first expense tracking with language + currency switching, and a Clean Light theme (white + emerald, soft premium).

**Unique feature — AI Cash-Flow Predictor (roadmap):** predicts, before the month ends, when money will run out and warns before overspending, in the user's own language. Receipt scan (OCR) and Firebase sync are also on the roadmap.

## v2 — International

- **8 languages, each with its own country and currency** — pick a language in the AppBar and the whole app switches: every label, alert, category and amount, in that language's own script only. No mixed-language text, no Roman Urdu, no Roman English.
  | Language | Country | Currency | Default monthly budget |
  |---|---|---|---|
  | English | USA | USD ($) | $500 |
  | اردو | Pakistan | PKR (Rs.) | Rs. 50,000 |
  | العربية | Saudi Arabia | SAR (ر.س) | 2,000 ر.س |
  | हिन्दी | India | INR (₹) | ₹40,000 |
  | Español | Spain | EUR (€) | €500 |
  | Français | France | EUR (€) | €500 |
  | Türkçe | Türkiye | TRY (₺) | ₺20,000 |
  | 中文 | China | CNY (¥) | ¥3,500 |
- **Currency follows the language** — amounts are shown with the selected currency's symbol. The language choice is saved offline.
- **Right-to-left layout** for Urdu and Arabic; left-to-right for the other languages.
- **Clean Light theme** — white background, soft off-white surfaces, emerald primary (#059669), dark slate text, white cards with soft shadows and rounded corners. The v1 teal/gold theme is gone.
- Existing expenses are kept when switching language — only the display changes.

## MVP v1 — What is built now

- Manual expense entry with categories: Food, Transport, Bills, Shopping, Health, Education, Other
- Monthly budget in the selected currency, editable from the home screen, with total spent and remaining balance
- Overspend alert in the selected language when spending passes 80% and 100% of the budget
- Offline-first local storage — expenses are saved on the device, no internet needed
- Clean Architecture: models, data store, and UI kept in separate layers
- Category spending chart (fl_chart pie chart + legend) — totals per category in the selected language and currency

## What is NOT in v1 / v2

- Receipt scan (OCR)
- Firebase sync
- AI cash-flow prediction

Those are roadmap features, listed below, not claimed as built.

## Roadmap

| Stage | Feature |
|---|---|
| v1 | Manual entry, categories, PKR budget, offline storage, Urdu/English alerts — run-tested on a real device, 2026-11-09 |
| v2 | International: 8 languages + currency switching, Clean Light theme, RTL for Urdu/Arabic, inline validation errors in the sheets — published 2026-11-09, device run-test pending |
| v3 | Receipt scan (OCR) for automatic entry |
| v4 | Firebase sync across devices |
| v5 | AI Cash-Flow Predictor — predicts when money will run out |

## Tech Stack

Flutter, Dart, Clean Architecture, SharedPreferences (local storage), Provider (state management), fl_chart (category chart).

## Setup

```bash
flutter pub get
flutter run
```

Requires Flutter 3.0 or later. No API key or account is needed for v1 — all data stays on the device.

## Project Structure

```
lib/
  main.dart                 # App entry, theme, locale + RTL wiring
  core/
    theme.dart              # Clean Light theme (white + emerald)
    localization.dart       # 8 locales: strings, categories, currency
  features/expenses/
    models/expense.dart     # Expense model (category stored as English key)
    data/expense_store.dart # Offline local storage (SharedPreferences) + locale
    presentation/
      home_screen.dart      # Budget, list, add-expense UI, language menu
      category_chart.dart  # Spending-by-category pie chart + legend
```

## License

MIT
