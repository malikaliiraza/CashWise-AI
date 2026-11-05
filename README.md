# CashWise AI — Pakistan-first Finance Coach

A Flutter finance app built for Pakistan: PKR budgets, offline-first expense tracking, and Urdu / English overspend alerts.

**Unique feature — AI Cash-Flow Predictor (roadmap):** predicts, before the month ends, when money will run out and warns before overspending, in Urdu and English. Receipt scan (OCR) and Firebase sync are also on the roadmap.

## MVP v1 — What is built now

- Manual expense entry with categories: Food, Transport, Bills, Shopping, Health, Education, Other
- Monthly budget in PKR, with total spent and remaining balance
- Overspend alert in English and Urdu when spending passes 80% and 100% of the budget
- Offline-first local storage — expenses are saved on the device, no internet needed
- Clean Architecture: models, data store, and UI kept in separate layers

## What is NOT in v1

- Receipt scan (OCR)
- Firebase sync
- AI cash-flow prediction

Those are roadmap features, listed below, not claimed as built.

## Roadmap

| Stage | Feature |
|---|---|
| v1 | Manual entry, categories, PKR budget, offline storage, Urdu/English alerts |
| v2 | Receipt scan (OCR) for automatic entry |
| v3 | Firebase sync across devices |
| v4 | AI Cash-Flow Predictor — predicts when money will run out |

## Tech Stack

Flutter, Dart, Clean Architecture, SharedPreferences (local storage), Provider (state management).

## Setup

```bash
flutter pub get
flutter run
```

Requires Flutter 3.0 or later. No API key or account is needed for v1 — all data stays on the device.

## Project Structure

```
lib/
  main.dart                 # App entry, theme, home screen wiring
  core/
    theme.dart              # App colours and text styles
  features/expenses/
    models/expense.dart     # Expense model
    data/expense_store.dart # Offline local storage (SharedPreferences)
    presentation/
      home_screen.dart      # Budget, list, and add-expense UI
```

## License

MIT
