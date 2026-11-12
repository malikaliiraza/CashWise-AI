# CashWise AI — Finance Coach

> **v5.9 — published 2026-11-12** (multi-budget + History page; also completes the v5.8 batch — the History page file and the compile fixes that stopped `flutter run` are now in). v1 and v3.3 were run-tested on the developer's PC; the v5.9 source compiled there with no Dart errors on 2026-11-12 (Chrome debug-service connection still pending); the full app has not been run/tested here (no Flutter SDK in this VM).

A Flutter finance app for everyone, in their own language: offline-first expense tracking in English and Urdu, with a premium deep marine navy + brass theme.

**Unique feature — Cash-Flow Predictor (v3):** predicts, before the month ends, when money will run out and warns before overspending, in the user's own language — from daily average spend, no server or AI model yet. Receipt scan (OCR) and Firebase sync are also on the roadmap.

## Languages — English and Urdu only

- **2 languages — English and Urdu only** (since v4.6, user's choice) — pick a language in the language slider and the whole app switches: every label, alert, category and amount, in that language's own script only. No mixed-language text, no Roman Urdu, no Roman English. Urdu is RTL. The picker shows only "English" and "اردو" — no country names, no currency codes (v4.8).
  | Language | Amounts shown as |
  |---|---|
  | English | Rs. (e.g. Rs. 2,383) |
  | اردو | روپے (e.g. 2,383 روپے) |
- **Amounts always carry Rs. / روپے** (since v5.8) — every amount in the app, in English and Urdu. The language choice is saved offline.
- **Right-to-left layout** for Urdu; left-to-right for English.
- **Theme** — deep marine navy + brass (light theme warm gold/brass, dark theme warm charcoal-brown). The v2 Clean Light theme (white + emerald) and the v1 teal/gold theme are gone.
- Existing expenses are kept when switching language — only the display changes.
- *History: v2 (2026-11-09) originally shipped 8 languages, each with its own currency (English/USD, Urdu/PKR, Arabic/SAR, Hindi/INR, Spanish/EUR, French/EUR, Turkish/TRY, Chinese/CNY). The other 6 languages were removed in v4.6 at the user's choice — the app now targets a Pakistani audience in English and Urdu only.*

## What is built now — v5.9

Current state is v5.9. The bullets below are the version history — a few details changed again later (v4.9's plain numbers were reversed by v5.8's Rs.-always rule; Royal Blue was replaced by navy + brass).

- Manual expense entry with categories: Food, Transport, Bills, Shopping, Health, Education, Other
- Monthly budget (Rs.), editable from the home screen, with total spent and remaining balance
- Overspend alert in the selected language when spending passes 80% and 100% of the budget
- Offline-first local storage — expenses are saved on the device, no internet needed
- Clean Architecture: models, data store, and UI kept in separate layers
- Category spending chart (fl_chart pie chart + legend) — totals per category in the selected language, amounts in Rs. / روپے
- Cash-flow prediction (v3) — daily average spend, projected month-end spend, and the date the budget runs out, in the selected language
- Expense edit — tap any expense to change its title, amount or category (same sheet as add, prefilled)
- Search + category filter — search expenses by title, filter by category with chips, in the selected language
- App feel (v3.3) — responsive centred layout (max 640 wide on desktop, full width on phone), summary stats row (spent / remaining / top category), category icons + colours in the list, date on each expense, richer empty state, soft off-white page so white cards pop
- Complete (v4) — navigation drawer menu (Home, Dark mode, Language, Clear all data, About), dark mode saved offline, expense sort (newest / oldest / highest / lowest amount), clear-all with confirm dialog, language picker dialog
- Complete v4.1 — professional Govt-style theme (deep official green + white, no bright gradients), login/register gate (local account on the device, app never opens straight into expenses), Log out in the drawer
- Complete v4.2 — language moved to the drawer only (home-screen globe icon deleted), name-initial avatar button in the AppBar opens Language / Dark mode / Log out, strong password (8+, 1 uppercase, 1 digit, 1 special character) + real email validation (name@domain.tld, .com etc. required) on register
- Complete v4.3 — password check back to one-by-one (length, then uppercase, then number, then special), professional error banner (white card, red left border, icon), Plus Jakarta Sans font (google_fonts package)
- Complete v4.4 — Royal Blue theme, user's choice (primary #1E40AF, accent #2563EB, light blue-grey page; dark mode accent #60A5FA), replaces deep-green theme
- Complete v4.5 — Inter font (whole app, professional + readable), softer theme (light royal blue softened, dark mode muted: soft dark surfaces, muted blue accent), separate pages (Expense Detail page on tap with Edit/Delete, Statistics page from drawer with chart + predictor + summary), bigger pie chart (200px, radius 64), email error under email field only after submit, password error under password field one rule at a time (length → upper → lower → number → special), Confirm Password field (empty → its own error, mismatch → "Passwords do not match" only), first-time use: Sign in hidden until an account exists, only Create account
- Complete v4.6 — Welcome home page (no details on home: user adds budget + expenses himself), Details page holds summary + chart + predictor + search/filter/sort + expense list, English + Urdu only (6 languages removed), rich Royal Blue header gradient + gold rule + soft blue glow, default light theme, About moved to the very bottom of the drawer menu, short email error ("Invalid email address.")
- Complete v4.7 — PKR only (English Rs., Urdu روپے, no USD), Budget screen (preset options + custom amount) and Add Expense screen (title, amount, category chips) as full pages with back buttons, Details card on home appears only after a budget AND an expense exist, avatar menu shows only name/email + Log out, home top row removed (Language lives in drawer only), deeper rich navy header + gold, welcome hero with decorative circles, email error names the missing provider ("Add the provider before .com (like gmail).") for `name@.com`, budget starts unset (0) until the user sets it
- Complete v4.8 — Udhar system (lent/borrowed, settled, saved on device), Details page with 3 tabs (Expenses first, AI Predictor with chart + prediction, Summary), budget alerts as in-app banner + mobile notification on phones (80% warning, 100% overspend), welcome page with short summary digits (spent / remaining / expenses) once data exists, slide+fade page transitions, + button removed, no "Pakistan" or "PKR" text anywhere in the UI (language picker shows only English / اردو, amounts show Rs. / روپے), Details card appears with budget OR expense, drawer header redesigned with avatar + name + email
- Complete v4.9 — Language slider (EN / اردو pill that glides, in the drawer, no dialog, no toast), amounts are plain numbers with no "Rs." or currency text at all, Add Expense button on the Details page, **Loan Ledger** (user's choice 2026-11-11; pages Receivables / Payables, no "Took"/"Gave", no Roman Urdu) with pending total + people at the top, calendar date picker on Add Expense / Udhar / expense edit, settled entries show a glowing gold "Mark pending" button, Quick actions grid on home (Budget / Add expense / Loan Ledger / View details, each with its own soft tint), gradient primary buttons on the form screens. Budget alert banner stays on the Details page (80% warning / 100% overspend, in-app only).
- Complete v5.0 — Budget first: no expense can be added until a monthly budget is set (the Add Expense screen shows "Set your monthly budget first" and opens the budget screen; the store refuses to save an expense without a budget). Compact language slider (32px, normal weight, in the AppBar — no longer in the drawer). Home menu with 6 options, each its own page: Budget, Add Expense, Loan Ledger, View Details, AI Predictor, Summary (Details page opens straight onto the tab). Budget details and Loan Ledger details are separate pages. Scrollable drawer with a small coloured Light/Dark theme slider (gold pill for light, indigo for dark) and expandable Budget (Budgets / Details / Expenses / AI Predictor) and Loan Ledger (Receivables / Payables / Details) sections that open with an arrow. Style refresh with the same colours: rounder cards (24px) with a thin outline, rounder buttons. 7 new localisation keys x 2 locales.
- Complete v5.1 — Drawer follows the selected theme (light header + dark text in light mode, navy gradient + white text in dark mode, so the name and email are always readable). Drawer shows "Theme" with the small coloured slider right next to it (sun/moon icons on the slider); the slider track also follows the theme. AppBar titles and icons are white in both themes — dark navy text on the navy header gradient was unreadable in light mode. Both sliders are the same compact 32px style (language in the AppBar, theme in the drawer). Budget and Loan Ledger expandable categories with their sub-options unchanged.
- Complete v5.2 — Two categories, never mixed. Home page shows only Budget and Loan Ledger as big cards, each previewing its own totals (Budget: budget + spent; Loan Ledger: receivables + payables pending). Each category has its own home screen: Budget home (summary + Set budget, Add Expense, Details, AI Predictor, Summary) and Loan Ledger home (summary with net balance + Receivables, Payables, Details, Summary). New Loan Ledger Summary page with totals and a per-person pending breakdown. The budget-only mini-stats are gone from the welcome — both categories are visible at a glance. Drawer sections updated to the same option lists. 3 new localisation keys x 2 locales.
- Complete v5.3 — Separate light theme for the whole app: AppBar headers and the welcome hero are now soft light blue with dark text in light mode (navy only in dark mode); AppBar titles follow the header again. Every sub-page (Details, Budget, Add Expense, expense detail, Loan Ledger hub, Receivables/Payables, Loan Ledger Summary) has a Home button in the AppBar that jumps straight home — the back arrow still goes to the parent category home, and only the Budget/Loan Ledger home screens go back to home. Continue with Google on the login/register screen: picks a Google account and creates the local account from its name + email (no password stored). NEEDS a Google Cloud OAuth Client ID to actually work — placeholder in lib/core/google_auth_service.dart (kGoogleClientId) + web/index.html meta tag, with setup steps in the service file; until the ID is pasted, the button shows "Google sign-in did not complete." 2 new localisation keys x 2 locales, new dependency google_sign_in ^6.2.1 (run flutter pub get).
- Complete v5.4 — Light theme has no blue at all: warm gold/brass replaces royal blue everywhere in light mode (buttons, chips, inputs, progress, headers, hero, slider pills, icons) via a new lightAccent + accentFor(context); dark mode keeps its blue. Budget icon is gold now (was blue). Language slider labels are styled (letterspaced English, Nastaliq اردو) and its pill is gold in light / navy in dark. Urdu mode shows the user's name in Urdu script (Malik Ali Raza → ملک علی رضا, via a transliteration map for common name parts) and the welcome line uses the proper Urdu comma (،) inside the translation, so it renders on the right side. Password eye icons fixed: slashed eye = hidden, plain eye = showing. Stylish date picker (rounded 24px dialog, theme colours, Inter font) on Add Expense, expense edit and Udhar. Google sign-in still needs the Client ID — the button, flow and setup steps are built; Google does not allow sign-in without a Client ID, so the user must create one (free, ~3 minutes, steps in APPLY.md) or do it together in the browser. 1 new localisation key (welcomeName) x 2 locales.
- Complete v5.5 — Loan Ledger due dates, times, partial payments and reminders: every entry can carry a due date + time ("this payment is due on this date at this time"); partial payments are recorded with their date (5,000 owed, 1,000 paid on 12/11 → 4,000 remaining, entry settles itself at zero); outstanding totals now count only the remaining amount. Reminders: overdue entries (due moment passed — from 12 AM after the due date when no time was set) and entries due within a week / tomorrow show in a reminders card on Home and on the Loan Ledger hub, plus a once-a-day mobile notification on phones (in-app banner on web). Loan Ledger Summary now has separate Receivables and Payables sections, each person with total, paid so far, remaining and next due date. Tapping any entry opens a detail sheet with full details, payment history, an add-payment form and due date/time editing. Details (Statistics) expense rows now show a visible edit button. The Home button is removed from all sub-page AppBars (user changed his mind). Dark mode is now warm and professional like the light theme (warm charcoal + gold, no bright blue glow, softer shadows). The calendar is a custom fixed-size dialog (always 6x7 = 42 cells, 340x460, same size every month). Name map extended (Muheeb → محیب and ~25 more common names). 20 new localisation keys x 2 locales.
- Complete v5.9 — Multi-budget (edit the active budget + add another budget; every budget has its own expenses, totals and alerts, switchable from Budget home chips / Set budget / History); Rs. prefix inside amount input fields; restyled home category cards; budget warnings live in the Reminders system (badge, swipe-to-dismiss); calendar/time pickers are modal (no background scroll) and clamp dates (no future expense/payment, no past loan date/due date); buttons flat slider gold, no dark glow; full Urdu audit (calendar months/weekdays/buttons now Urdu in Urdu mode); language moved from the home AppBar into the account menu; home/drawer reminders short (max 2 + arrow), details on tap; History page (budgets, loan history, deleted items with Restore); loan cards redesigned (Payable / Mark / Edit in one row, bin icon below Payable); Record Payment is the paid/received option (partial works); reminders say exact days ("Due in 4 days", never "one week left"); swipe-to-dismiss reminders/warnings in drawer + Reminders page; opening the drawer Reminders section/arrow clears the badge. Compile fixes included: the History page file and the files that stopped `flutter run` (broken login import, duplicate localisation keys, store typo, missing imports) are now in — the v5.9 source compiles.
- Complete v5.8 — Amounts always carry Rs. / روپے (reverses the v4.9 plain-numbers rule — user asked for Rs. always); unread-reminder badge on the hamburger menu (clears when the Reminders page is opened; only new reminders notify); Record Payment screen (full page: amount + date + time + weekday, full payment history with date/day/time — partial payments work even when not complete); time picker reworked (big selected time, hour/minute steppers with hold-to-repeat, no wall of numbers); Delete is an icon everywhere now (expense detail button, detail-sheet button next to Mark), never the written word. PartialPayment now keeps timeMinutes (backwards-compatible JSON).
- Complete v5.7.3 — Urdu name edit (Edit name shows an Urdu-name field in Urdu mode; the typed Urdu spelling is saved and shown instead of the transliteration) + full About (what the app does, all features, what's new in this version — updated with every version) + delete icons everywhere (every expense row, every loan entry, every single payment in the detail sheet, and a Delete button in the detail sheet), each asking once to confirm. Settled entries keep their lock: delete is disabled until marked pending again. Removing a payment that settled an entry puts it back to pending.
- Complete v5.7.2 — Welcome subtitle rewritten, fully professional and premium: "Your money, beautifully organized — every budget and every loan, always in your hands." (Urdu: "آپ کا پیسہ، خوبصورتی سے منظم — ہر بجٹ اور ہر قرض، ہمیشہ آپ کے ہاتھ میں۔")
- Complete v5.7.1 — Page transition reworked: no more horizontal slide (it read like scrolling) — every page now opens with fade + zoom + a small rise (350ms), so home → category clearly OPENS a new screen instead of scrolling.
- Complete v5.7 — Dedicated Reminders page (overdue first, then due soon) opened from the Home card, the Loan Ledger hub card, or "View all reminders" in the drawer; tapping one reminder opens its detail sheet. The reminders card now sits at the very top of Home, above the hero, so payments are visible without scrolling. Reminders are also a section in the drawer (with a count badge). Names: every person's name converts in Urdu mode — loan entries (Ahmad → احمد) in lists, detail sheet, summary, reminders and notifications, not just the account name; due times are Urdu too (Urdu digits + صبح/دوپہر/شام/رات); the account menu has Edit name. AI Predictor: no expenses → an amber alert + an Add Expense button; with expenses the category pie chart shows under the prediction. (Details already had an Add Expense button on its Expenses tab.) Loan entries: the record-payment action is called "Payable" again; on a settled entry Mark pending is a solid gold button (clearly clickable) and Edit/Delete/due-edit/Payable are locked, swipe-to-delete disabled too. Time picker: a styled fixed-size picker like the calendar (hour/minute wheels, AM/PM switch, Urdu digits in Urdu mode). Drawer: a floating panel now (transparent drawer + card with margins all round, 26px corners, deep shadow) — never full-screen. Navigation: every page change plays a visible transition (slide + fade + slight scale, 350ms). Roman English is gone from the app: every user-facing string is proper English or Urdu script only (audit found no Roman Urdu in any label, alert, toast or guide).
- Complete v5.6 — General transliteration system: any Roman name converts to Urdu script (dictionary of ~100 common names/words wins first for exact spellings; anything else goes through phonetic fallback rules — digraphs, dropped short vowels, kept long/final vowels — so ANY name converts, not just listed ones). Brand name follows the language too: "CashWise AI" → "کیش وائز اے آئی" in Urdu mode (AppBar, drawer header, login screen, About dialog). Drawer is now narrower (290px, not full screen), rounded right corners, and its content fades + slides in when it opens. After creating an account or signing in, an animated welcome screen plays (logo scales in with gold glow, "Welcome, <name>" slides up, gold bar grows, ~1.8s) before home; returning users skip it. Account menu is now a professional card anchored under the avatar (profile header with name + email, divider, Sign out). The Google setup guide panel is a live-web-only element — nothing to remove in Flutter.

## Not built yet — roadmap only

- Receipt scan (OCR)
- Firebase sync
- A server / ML-model AI predictor (the v3 predictor is local arithmetic only)

Those are roadmap features, listed below, not claimed as built.

## Roadmap

| Stage | Feature |
|---|---|
| v1 | Manual entry, categories, PKR budget, offline storage, Urdu/English alerts — run-tested on a real device, 2026-11-09 |
| v2 | International: 8 languages + currency switching, Clean Light theme, RTL for Urdu/Arabic, inline validation errors in the sheets — published 2026-11-09, device run-test pending |
| v3 | Charts (fl_chart pie + legend) + local cash-flow predictor (daily average, projected month-end, run-out date) + home-screen scroll fix — published 2026-11-11 |
| v3.2 | Expense edit (tap to edit) + search by title + category filter chips — published 2026-11-11 |
| v3.3 | App feel — responsive centred layout, summary stats row, category icons + colours, date on expenses, richer empty state, soft page background + chip theme — published 2026-11-11 |
| v4 | Complete — drawer menu, dark mode (saved offline), expense sort, clear-all with confirm, language picker dialog — published 2026-11-11 |
| v4.1 | Professional theme (deep official green) + login/register gate (local account, Log out in drawer) — published 2026-11-11 |
| v4.2 | Avatar menu (initial button: Language / Dark mode / Log out), globe icon removed, strong-password + email validation — published 2026-11-11 |
| v4.3 | Password check one-by-one again, professional error banner, Plus Jakarta Sans font — published 2026-11-11 |
| v4.4 | Royal Blue theme (user's choice) — published 2026-11-11 |
| v4.5 | Inter font, softer theme, Detail + Statistics pages, per-field errors, Confirm Password, first-time create-only — published 2026-11-11 |
| v4.6 | Welcome home page, Details page with list, English + Urdu only, rich Royal Blue + gold header, default light, About at menu bottom, short email error — published 2026-11-11 |
| v4.7 | PKR only, Budget + Add Expense screens, Details appears after budget+expense, minimal avatar menu, deeper rich theme, provider-missing email error — published 2026-11-11 |
| v4.8 | Udhar system, Details tabs, budget alerts + mobile notifications, welcome summary, slide transitions, no + button, no Pakistan/PKR text — published 2026-11-11 |
| v4.9 | Language slider, no Rs. at all, Details add-expense, Loan Ledger (Receivables / Payables), calendar date pickers, glowing mark-pending, premium home options grid — published 2026-11-11 |
| v5.0 | Budget-first gate, compact sliders, home menu (6 options, each its own page), scrollable drawer with theme slider + expandable Budget/Loan Ledger sections, style refresh (same colours) — published 2026-11-11 |
| v5.1 | Drawer follows theme, Theme label + slider row, light-theme text visibility fix — published 2026-11-11 |
| v5.2 | Two categories only on home, each with its own home screen, welcome upgraded — published 2026-11-11 |
| v5.3 | Separate light theme, Home button on sub-pages, Continue with Google — published 2026-11-11 |
| v5.4 | Gold light theme (no blue), styled slider labels, Urdu name + comma, eye slash, stylish calendar — published 2026-11-11 |
| v5.5 | Loan Ledger due dates/times, partial payments, reminders; warm professional dark mode; fixed calendar; no Home button — published 2026-11-11 |
| v5.6 | General name transliteration, Urdu brand, new drawer, welcome transition, professional account menu — published 2026-11-11 |
| v5.7 | Reminders page + drawer reminders, Urdu names everywhere + Edit name, predictor empty alert + pie chart, Payable rename, settled lock + solid Mark pending, styled time picker, floating drawer, page transitions — published 2026-11-11 |
| v5.7.1 | Page transition reworked (fade + zoom + rise, no horizontal slide/scroll feel) — published 2026-11-11 |
| v5.7.2 | Professional premium welcome subtitle (EN + Urdu) — published 2026-11-11 |
| v5.7.3 | Urdu name edit, full About (updated per version), delete icons everywhere + confirm — published 2026-11-11 |
| v5.8 | Rs. / روپے on every amount, unread reminder badge, Record Payment screen (date+time+day), clean time picker, Delete icon-only — published 2026-11-11 |
| v5.9 | Multi-budget + edit/add budget, History page, warnings in Reminders, date clamps, Urdu audit, compact reminders, loan card redesign, flat gold buttons — published 2026-11-12 (compile fixes included; full run/test still pending) |
| Future | Receipt scan (OCR) for automatic entry |
| Future | Firebase sync across devices |
| Future | Full AI Cash-Flow Predictor — server / ML model, learns spending patterns |

## Tech Stack

Flutter, Dart, Clean Architecture, SharedPreferences (local storage), Provider (state management), fl_chart (category chart), google_fonts, flutter_local_notifications (reminders + alerts), google_sign_in (optional Google sign-in).

## Setup

```bash
flutter pub get
flutter run
```

Requires Flutter 3.0 or later. No account is needed — all data stays on the device. Google sign-in is optional and needs a free Google Cloud OAuth Client ID (see `lib/core/google_auth_service.dart`).

## Project Structure

```
lib/
  main.dart                 # App entry, theme, locale + RTL wiring
  core/
    theme.dart              # Themes (light/dark, deep marine navy + brass)
    localization.dart       # English + Urdu strings, categories, currency (Rs. / روپے)
    confirm_dialog.dart     # Shared confirm dialog (delete actions)
    gradient_button.dart    # Gradient primary buttons
    page_transitions.dart   # Fade + zoom page transitions
    styled_date_picker.dart # Styled calendar + time picker
    roman_urdu.dart         # Name transliteration English -> Urdu script
    notification_service.dart # Local notifications (reminders, alerts)
    google_auth_service.dart  # Google sign-in (needs a Google Client ID)
  features/auth/presentation/
    login_screen.dart       # Sign in / create account, password + email rules
    welcome_transition_screen.dart # Animated welcome after login
  features/expenses/
    models/
      expense.dart          # Expense model (category stored as English key)
      budget.dart           # Budget model
      udhar_entry.dart      # Loan Ledger entry (Receivable/Payable, due date/time, partial payments)
    data/expense_store.dart # Offline storage (SharedPreferences) + locale + predictor + reminders
    presentation/
      home_screen.dart      # Home: welcome, summary, quick actions, reminders
      budget_screen.dart / budget_home_screen.dart # Budget home + set-budget screen
      add_expense_screen.dart # Add / edit expense (full screen, calendar)
      expense_detail_screen.dart # Expense detail + edit/delete
      statistics_screen.dart    # Statistics page
      category_chart.dart   # Spending-by-category pie chart + legend
      category_style.dart   # Category colours + icons
      cashflow_predictor.dart # Local cash-flow prediction card
      language_slider.dart / theme_slider.dart # EN/اردو + light/dark sliders
      udhar_screen.dart / udhar_list_screen.dart / udhar_detail_sheet.dart # Loan Ledger
      loan_ledger_home_screen.dart / loan_ledger_summary_screen.dart
      record_payment_screen.dart # Record a (partial) payment
      reminders_screen.dart # Reminders page (overdue first, then due soon)
```

## License

MIT
