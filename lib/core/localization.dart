// CashWise AI v2 — international localization.
//
// Custom localization system with no extra packages. Every user-facing
// string is translated into each locale's own script only: no mixed
// language strings, no Roman Urdu, no Roman English.
//
// Expense categories are stored internally as English keys
// ('Food', 'Transport', ...) and only DISPLAYED in the current locale.

/// One supported language profile.
class AppLocale {
  final String code;
  final String nativeName;
  final String currencySymbol;
  final double defaultBudget;
  final bool isRtl;
  final Map<String, String> strings;
  final Map<String, String> categoryNames;

  const AppLocale({
    required this.code,
    required this.nativeName,
    required this.currencySymbol,
    required this.defaultBudget,
    required this.isRtl,
    required this.strings,
    required this.categoryNames,
  });

  String _get(String key) => strings[key] ?? key;

  String get spentThisMonth => _get('spentThisMonth');
  String get budget => _get('budget');
  String get remaining => _get('remaining');
  String get overspendAlert => _get('overspendAlert');
  String get warningAlert => _get('warningAlert');
  String get noExpenses => _get('noExpenses');
  String get tapToAdd => _get('tapToAdd');
  String get addExpense => _get('addExpense');
  String get whatDidYouSpend => _get('whatDidYouSpend');
  String get amount => _get('amount');
  String get category => _get('category');
  String get saveExpense => _get('saveExpense');
  String get editMonthlyBudget => _get('editMonthlyBudget');
  String get monthlyBudget => _get('monthlyBudget');
  String get saveBudget => _get('saveBudget');
  String get enterTitleValidAmount => _get('enterTitleValidAmount');
  String get enterValidBudget => _get('enterValidBudget');
  String get language => _get('language');
  String get spendingByCategory => _get('spendingByCategory');
  String get cashFlowPrediction => _get('cashFlowPrediction');
  String get projectedMonthEnd => _get('projectedMonthEnd');
  String get dailyAverage => _get('dailyAverage');
  String get budgetRunsOut => _get('budgetRunsOut');
  String get onTrack => _get('onTrack');
  String get willRunOut => _get('willRunOut');
  String get noExpensesPrediction => _get('noExpensesPrediction');
  String get editExpense => _get('editExpense');
  String get searchExpenses => _get('searchExpenses');
  String get searchHint => _get('searchHint');
  String get allCategories => _get('allCategories');
  String get updateExpense => _get('updateExpense');
  String get noMatchingExpenses => _get('noMatchingExpenses');
  String get topCategory => _get('topCategory');
  String get home => _get('home');
  String get darkMode => _get('darkMode');
  String get about => _get('about');
  String get aboutText => _get('aboutText');
  String get sortBy => _get('sortBy');
  String get newestFirst => _get('newestFirst');
  String get oldestFirst => _get('oldestFirst');
  String get highestAmount => _get('highestAmount');
  String get lowestAmount => _get('lowestAmount');
  String get clearAllData => _get('clearAllData');
  String get clearAllConfirm => _get('clearAllConfirm');
  String get cancel => _get('cancel');
  String get delete => _get('delete');
  String get login => _get('login');
  String get register => _get('register');
  String get emailAddress => _get('emailAddress');
  String get password => _get('password');
  String get fullName => _get('fullName');
  String get createAccount => _get('createAccount');
  String get alreadyHaveAccount => _get('alreadyHaveAccount');
  String get dontHaveAccount => _get('dontHaveAccount');
  String get invalidCredentials => _get('invalidCredentials');
  String get fillAllFields => _get('fillAllFields');
  String get logout => _get('logout');
  String get passwordRequirements => _get('passwordRequirements');
  String get invalidEmail => _get('invalidEmail');

  /// "The provider 'l.com' is not a recognised provider."
  String unknownProvider(String domain) =>
      _get('unknownProvider').replaceFirst('{d}', domain);

  String get addReceivable => _get('addReceivable');
  String get addPayable => _get('addPayable');
  String get passwordTooShort => _get('passwordTooShort');
  String get passwordNeedsUppercase => _get('passwordNeedsUppercase');
  String get passwordNeedsNumber => _get('passwordNeedsNumber');
  String get passwordNeedsSpecial => _get('passwordNeedsSpecial');
  String get passwordNeedsLowercase => _get('passwordNeedsLowercase');
  String get confirmPassword => _get('confirmPassword');
  String get confirmPasswordRequired => _get('confirmPasswordRequired');
  String get passwordsDoNotMatch => _get('passwordsDoNotMatch');
  String get deleteExpenseConfirm => _get('deleteExpenseConfirm');
  String get statistics => _get('statistics');
  String get welcomeTitle => _get('welcomeTitle');
  String get welcomeSubtitle => _get('welcomeSubtitle');
  String get viewDetails => _get('viewDetails');
  String get emailMissingProvider => _get('emailMissingProvider');
  String get chooseBudget => _get('chooseBudget');
  String get customAmount => _get('customAmount');
  String get setMonthlyBudget => _get('setMonthlyBudget');
  String get expenses => _get('expenses');
  String get aiPredictor => _get('aiPredictor');
  String get summary => _get('summary');
  String get udhar => _get('udhar');
  String get lent => _get('lent');
  String get borrowed => _get('borrowed');
  String get personName => _get('personName');
  String get youLent => _get('youLent');
  String get youBorrowed => _get('youBorrowed');
  String get addUdhar => _get('addUdhar');
  String get settled => _get('settled');
  String get noUdharEntries => _get('noUdharEntries');
  String get note => _get('note');
  String get moneyLent => _get('moneyLent');
  String get moneyBorrowed => _get('moneyBorrowed');
  String get pending => _get('pending');
  String get markSettled => _get('markSettled');
  String get markPending => _get('markPending');
  String get selectDate => _get('selectDate');
  String get date => _get('date');
  String get quickActions => _get('quickActions');
  String get light => _get('light');
  String get dark => _get('dark');
  String get details => _get('details');
  String get budgets => _get('budgets');
  String get theme => _get('theme');
  String get setBudgetFirst => _get('setBudgetFirst');
  String get budgetRequired => _get('budgetRequired');
  String get categories => _get('categories');
  String get netBalance => _get('netBalance');
  String get perPerson => _get('perPerson');

  /// e.g. "Welcome, Malik Ali Raza" — the comma lives inside the
  /// translation, so Urdu gets its own comma (،) in the right
  /// place for RTL (v5.4).
  String get dueDate => _get('dueDate');
  String get dueTime => _get('dueTime');
  String get noDueDate => _get('noDueDate');
  String get setDueDate => _get('setDueDate');
  String get setDueTime => _get('setDueTime');
  String get addPayment => _get('addPayment');
  String get paymentAmount => _get('paymentAmount');
  String get paidSoFar => _get('paidSoFar');
  String get remainingAmount => _get('remainingAmount');
  String get overdue => _get('overdue');
  String get dueToday => _get('dueToday');
  String get dueTomorrow => _get('dueTomorrow');
  String get reminders => _get('reminders');
  String get paymentHistory => _get('paymentHistory');
  String get editDue => _get('editDue');
  String get removeDueDate => _get('removeDueDate');
  String get editName => _get('editName');
  String get save => _get('save');
  String get nextDue => _get('nextDue');
  String get totalAmount => _get('totalAmount');
  String get noPaymentsYet => _get('noPaymentsYet');
  String get oneDayLeft => _get('oneDayLeft');
  String get noReminders => _get('noReminders');
  String get dueSoon => _get('dueSoon');
  String get viewAllReminders => _get('viewAllReminders');
  String get nameInEnglish => _get('nameInEnglish');
  String get nameInUrdu => _get('nameInUrdu');
  String get features => _get('features');
  String get aboutDescription => _get('aboutDescription');
  String get aboutFeatures => _get('aboutFeatures');
  String get aboutPrivacy => _get('aboutPrivacy');
  String get aboutDeveloper => _get('aboutDeveloper');
  String get aboutDeveloperTitle => _get('aboutDeveloperTitle');
  String get whatsNew => _get('whatsNew');
  String get whatsNewText => _get('whatsNewText');
  String get paymentTime => _get('paymentTime');
  String get history => _get('history');
  String get editBudget => _get('editBudget');
  String get addAnotherBudget => _get('addAnotherBudget');
  String get yourBudgets => _get('yourBudgets');
  String get active => _get('active');
  String get people => _get('people');
  String budgetNowActive(String name) =>
      _get('budgetNowActive').replaceAll('{name}', name);
  String get enterPersonName => _get('enterPersonName');
  String get reminderAdded => _get('reminderAdded');
  String get saveReminder => _get('saveReminder');
  String get reminderMustBeFuture => _get('reminderMustBeFuture');
  String get setReminder => _get('setReminder');
  String get upcomingReminders => _get('upcomingReminders');
  String get dueReminders => _get('dueReminders');
  String get budgetName => _get('budgetName');
  String get budgetNameHint => _get('budgetNameHint');
  String get renameBudget => _get('renameBudget');
  String get useThisBudget => _get('useThisBudget');
  String get addReminder => _get('addReminder');
  String get customReminders => _get('customReminders');
  String get budgetReminder => _get('budgetReminder');
  String get loanReminder => _get('loanReminder');
  String get remindWhenRemaining => _get('remindWhenRemaining');
  String get dueMustBeFuture => _get('dueMustBeFuture');
  String get bin => _get('bin');
  String daysLeftInBin(int n) =>
      _get('daysLeftInBin').replaceAll('{n}', '$n');
  String get binAutoRemove => _get('binAutoRemove');
  String get paymentDetails => _get('paymentDetails');
  String get remainingAfterPayment => _get('remainingAfterPayment');
  String get thisPayment => _get('thisPayment');
  String get budgetHistory => _get('budgetHistory');
  String get loanHistory => _get('loanHistory');
  String get deletedItems => _get('deletedItems');
  String get restore => _get('restore');
  String get noDeletedItems => _get('noDeletedItems');
  String get today => _get('today');
  String get ok => _get('ok');
  String get warning80 => _get('warning80');
  String get warning100 => _get('warning100');
  String get edit => _get('edit');
  String dueInDays(int n) => _get('dueInDays').replaceAll('{n}', '$n');
  String dueReminderOverdue(String person, String amount) =>
      _get('dueReminderOverdue')
          .replaceAll('{person}', person)
          .replaceAll('{amount}', amount);
  String dueReminderTomorrow(String person, String amount) =>
      _get('dueReminderTomorrow')
          .replaceAll('{person}', person)
          .replaceAll('{amount}', amount);

  String welcomeName(String name) =>
      _get('welcomeName').replaceAll('{name}', name);
  String get continueWithGoogle => _get('continueWithGoogle');
  String get googleSignInError => _get('googleSignInError');

  /// e.g. "Monthly budget updated to $500." — {amount} is replaced with
  /// the already-formatted amount, so no language mixing is introduced.
  String budgetUpdated(String amount) =>
      _get('budgetUpdated').replaceAll('{amount}', amount);

  /// Translated display name for an internally-stored English category key.
  String categoryName(String key) => categoryNames[key] ?? key;

  /// Label for an amount field — no currency code shown (v4.8).
  String get amountLabel => amount;

  /// Label for a budget field — no currency code shown (v4.8).
  String get monthlyBudgetLabel => monthlyBudget;
}

const List<AppLocale> appLocales = [
  AppLocale(
    code: 'en',
    nativeName: 'English',
    currencySymbol: 'Rs. ',
    defaultBudget: 50000,
    isRtl: false,
    strings: {
      'spentThisMonth': 'Spent this month',
      'budget': 'Budget',
      'remaining': 'Remaining',
      'overspendAlert': 'Overspend alert! Your budget is finished.',
      'warningAlert': 'Warning: 80% of your budget has been used.',
      'noExpenses': 'No expenses yet.',
      'tapToAdd': 'Add your first expense from the home page.',
      'addExpense': 'Add expense',
      'whatDidYouSpend': 'What did you spend on?',
      'amount': 'Amount',
      'category': 'Category',
      'saveExpense': 'Save expense',
      'editMonthlyBudget': 'Edit monthly budget',
      'monthlyBudget': 'Monthly budget',
      'saveBudget': 'Save budget',
      'budgetUpdated': 'Monthly budget updated to {amount}.',
      'enterTitleValidAmount': 'Enter a title and a valid amount.',
      'enterValidBudget': 'Enter a valid budget above 0.',
      'language': 'Language',
      'spendingByCategory': 'Spending by category',
      'topCategory': 'Top category',
      'home': 'Home',
      'darkMode': 'Dark mode',
      'about': 'About',
      'aboutText': 'Your money, beautifully organized \u2014 budgets, expenses, loans and reminders, all in one place, fully offline.',
      'sortBy': 'Sort by',
      'newestFirst': 'Newest first',
      'oldestFirst': 'Oldest first',
      'highestAmount': 'Highest amount',
      'lowestAmount': 'Lowest amount',
      'clearAllData': 'Clear all data',
      'clearAllConfirm': 'This will delete all your expenses. This cannot be undone.',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'login': 'Log in',
      'register': 'Register',
      'emailAddress': 'Email address',
      'password': 'Password',
      'fullName': 'Full name',
      'createAccount': 'Create account',
      'alreadyHaveAccount': 'Already have an account? Log in',
      'dontHaveAccount': "Don't have an account? Register",
      'invalidCredentials': 'Wrong email or password.',
      'fillAllFields': 'Please fill in all fields.',
      'logout': 'Log out',
      'passwordRequirements': 'Password must be 8+ characters with 1 uppercase letter, 1 number and 1 special character.',
      'invalidEmail': 'Invalid email address.',
      'unknownProvider':
          "The provider '{d}' is not a recognised provider.",
      'addReceivable': 'Add receivable',
      'addPayable': 'Add payable',
      'passwordTooShort': 'Password must be at least 8 characters.',
      'passwordNeedsUppercase': 'Password must contain 1 uppercase letter.',
      'passwordNeedsNumber': 'Password must contain 1 number.',
      'passwordNeedsSpecial': 'Password must contain 1 special character.',
      'passwordNeedsLowercase': 'Password must contain 1 lowercase letter.',
      'confirmPassword': 'Confirm password',
      'confirmPasswordRequired': 'Please re-enter your password to confirm.',
      'passwordsDoNotMatch': 'Passwords do not match.',
      'deleteExpenseConfirm': 'Are you sure you want to delete this expense?',
      'statistics': 'Statistics',
      'welcomeTitle': 'Welcome to CashWise AI',
      'welcomeSubtitle':
          'Your money, beautifully organized — every budget and every loan, always in your hands.',
      'viewDetails': 'View details',
      'emailMissingProvider': 'Add the provider before .com (like gmail).',
      'chooseBudget': 'Choose your monthly budget',
      'customAmount': 'Custom amount',
      'setMonthlyBudget': 'Set monthly budget',
      'expenses': 'Expenses',
      'aiPredictor': 'AI Predictor',
      'summary': 'Summary',
      'udhar': 'Loan Ledger',
      'lent': 'Lent',
      'borrowed': 'Borrowed',
      'personName': 'Person name',
      'youLent': 'You lent',
      'youBorrowed': 'You borrowed',
      'addUdhar': 'Add udhar',
      'settled': 'Settled',
      'noUdharEntries': 'No udhar entries yet.',
      'note': 'Note',
      'moneyLent': 'Receivables',
      'moneyBorrowed': 'Payables',
      'pending': 'Pending',
      'markSettled': 'Mark settled',
      'markPending': 'Mark pending',
      'selectDate': 'Select date',
      'date': 'Date',
      'quickActions': 'Quick actions',
      'light': 'Light',
      'dark': 'Dark',
      'details': 'Details',
      'budgets': 'Budgets',
      'theme': 'Theme',
      'setBudgetFirst': 'Set your monthly budget first',
      'budgetRequired':
          'Add a budget before adding expenses — your budget keeps '
          'spending in check.',
      'categories': 'Categories',
      'netBalance': 'Net balance',
      'perPerson': 'Per person',
      'welcomeName': 'Welcome, {name}',
      'dueDate': 'Due date',
      'dueTime': 'Due time',
      'noDueDate': 'No due date',
      'setDueDate': 'Set due date',
      'setDueTime': 'Set time',
      'addPayment': 'Payable',
      'paymentAmount': 'Payment amount',
      'paidSoFar': 'Paid so far',
      'remainingAmount': 'Remaining',
      'overdue': 'Overdue',
      'dueToday': 'Due today',
      'dueTomorrow': 'Due tomorrow',
      'reminders': 'Reminders',
      'paymentHistory': 'Payment history',
      'editDue': 'Change due date & time',
      'removeDueDate': 'Remove due date',
      'editName': 'Edit name',
      'save': 'Save',
      'nextDue': 'Next due',
      'totalAmount': 'Total amount',
      'noPaymentsYet': 'No payments yet',
      'oneDayLeft': '1 day left',
      'noReminders': 'No reminders',
      'dueSoon': 'Due soon',
      'viewAllReminders': 'View all reminders',
      'nameInEnglish': 'Name in English',
      'nameInUrdu': 'Name in Urdu',
      'features': 'Features',
      'aboutDescription':
          'CashWise AI is a personal finance companion built for everyday money in Pakistan. Set monthly budgets \u2014 one or several \u2014 track every expense by category, lend and borrow with due dates, times and partial payments in the Loan Ledger, and set your own reminders for any payment — the app only ever reminds you when you asked it to. A local cash-flow predictor shows when your budget will run out, before it happens. Everything works offline, in English or Urdu, with your data staying on your device.',
      'aboutFeatures':
          '\u2022 Monthly budgets \u2014 named by you, each with its own screen, expenses and alerts\n\u2022 Expenses \u2014 categories, search, filters and a pie chart of where the money goes\n\u2022 Loan Ledger \u2014 Receivables and Payables, due dates and times, partial payments, full history\n\u2022 Reminders \u2014 only the ones you set yourself, for any payment or budget, always in the future — plus a Bin that keeps deleted items for 30 days\n\u2022 AI cash-flow predictor \u2014 daily average, projected month-end spend and run-out date\n\u2022 English and Urdu \u2014 full translation, Urdu script throughout, right-to-left layout\n\u2022 Light and dark themes, and a wallet welcome every time the app opens\n\u2022 Works fully offline \u2014 no account, no server, no internet needed',
      'aboutDeveloperTitle': 'About the developer',
      'aboutDeveloper':
          'CashWise AI is built by Malik Ali Raza — a Flutter & Web Developer and Software Engineering student at Riphah International University, Sahiwal. He builds real apps people actually use, with clean architecture, and is open to internships and freelance work.',
      'aboutPrivacy':
          'Privacy: your budgets, expenses and loans are stored only on this device. CashWise AI never uploads your financial data anywhere.',
      'whatsNew': "What's new in v7.1",
      'whatsNewText':
          '• The earlier wallet is back on the welcome page: its lid flips open and a gold card slides out\n• The home cards are clean again — every option lives inside its own category screen, each laid out differently\n• Calendars are fully open: every date is pickable, none is hidden or greyed out\n• Reminders only ever come when you set them — set one on any loan entry or payment, always in the future\n• The Reminders page shows only your reminders: Due now and Upcoming\n• About now says who built CashWise AI',
      'paymentTime': 'Payment time',
      'history': 'History',
      'editBudget': 'Edit budget',
      'addAnotherBudget': 'Add another budget',
      'yourBudgets': 'Your budgets',
      'active': 'Active',
      'people': 'people',
      'budgetNowActive': '{name} is now the active budget.',
      'enterPersonName': "Enter the person's name.",
      'reminderAdded': 'Reminder added.',
      'saveReminder': 'Save reminder',
      'reminderMustBeFuture':
          'The reminder must be in the future — not in the past or right now.',
      'setReminder': 'Set reminder',
      'upcomingReminders': 'Upcoming',
      'dueReminders': 'Due now',
      'budgetName': 'Budget name',
      'budgetNameHint': 'e.g. Home, Ramzan, Business',
      'renameBudget': 'Rename budget',
      'useThisBudget': 'Use this budget',
      'addReminder': 'Add reminder',
      'customReminders': 'Your reminders',
      'budgetReminder': 'Budget reminder',
      'loanReminder': 'Loan reminder',
      'remindWhenRemaining': 'Remind me when the remaining amount falls to',
      'dueMustBeFuture': 'The due date and time must be in the future.',
      'bin': 'Bin',
      'daysLeftInBin': '{n} days left in bin',
      'binAutoRemove':
          'Deleted items stay in the Bin for 30 days, then are removed automatically.',
      'paymentDetails': 'Payment details',
      'remainingAfterPayment': 'Remaining after this payment',
      'thisPayment': 'This payment',
      'budgetHistory': 'Budget history',
      'loanHistory': 'Loan history',
      'deletedItems': 'Deleted items',
      'restore': 'Restore',
      'noDeletedItems': 'Nothing deleted yet.',
      'today': 'Today',
      'ok': 'OK',
      'warning80': 'Warning: 80% of your budget has been used.',
      'warning100': 'Budget used up: 100% spent.',
      'edit': 'Edit',
      'dueInDays': 'Due in {n} days',
      'dueReminderOverdue': 'Overdue: {person} — {amount}',
      'dueReminderTomorrow': 'Due tomorrow: {person} — {amount}',
      'continueWithGoogle': 'Continue with Google',
      'googleSignInError':
          'Google sign-in did not complete. Try again.',
      'cashFlowPrediction': 'Cash-flow prediction',
      'projectedMonthEnd': 'Projected month-end spend',
      'dailyAverage': 'Daily average',
      'budgetRunsOut': 'Budget runs out',
      'onTrack': 'On track — your budget should last the month.',
      'willRunOut': 'At this pace, your budget will run out before the month ends.',
      'noExpensesPrediction': 'Add expenses to see a prediction.',
      'editExpense': 'Edit expense',
      'searchExpenses': 'Search expenses',
      'searchHint': 'Search by title…',
      'allCategories': 'All categories',
      'updateExpense': 'Update expense',
      'noMatchingExpenses': 'No expenses match your search.',
    },
    categoryNames: {
      'Food': 'Food',
      'Transport': 'Transport',
      'Bills': 'Bills',
      'Shopping': 'Shopping',
      'Health': 'Health',
      'Education': 'Education',
      'Other': 'Other',
    },
  ),
  AppLocale(
    code: 'ur',
    nativeName: 'اردو',
    currencySymbol: 'روپے ',
    defaultBudget: 50000,
    isRtl: true,
    strings: {
      'spentThisMonth': 'اس مہینے کا خرچ',
      'budget': 'بجٹ',
      'remaining': 'باقی',
      'overspendAlert': 'حد سے زیادہ خرچ کا انتباہ! آپ کا بجٹ ختم ہو گیا ہے۔',
      'warningAlert': 'خبردار: آپ کے بجٹ کا 80٪ استعمال ہو گیا ہے۔',
      'noExpenses': 'ابھی کوئی خرچ نہیں ہے۔',
      'tapToAdd': 'ہوم پیج سے اپنا پہلا خرچ شامل کریں۔',
      'addExpense': 'خرچ شامل کریں',
      'whatDidYouSpend': 'آپ نے کس چیز پر خرچ کیا؟',
      'amount': 'رقم',
      'category': 'زمرہ',
      'saveExpense': 'خرچ محفوظ کریں',
      'editMonthlyBudget': 'ماہانہ بجٹ تبدیل کریں',
      'monthlyBudget': 'ماہانہ بجٹ',
      'saveBudget': 'بجٹ محفوظ کریں',
      'budgetUpdated': 'ماہانہ بجٹ {amount} پر اپ ڈیٹ ہو گیا ہے۔',
      'enterTitleValidAmount': 'عنوان اور درست رقم درج کریں۔',
      'enterValidBudget': '0 سے زیادہ درست بجٹ درج کریں۔',
      'language': 'زبان',
      'spendingByCategory': 'زمرہ کے لحاظ سے خرچ',
      'topCategory': 'سب سے زیادہ خرچ',
      'home': 'ہوم',
      'darkMode': 'ڈارک موڈ',
      'about': 'تعارف',
      'aboutText': 'آپ کا پیسہ، خوبصورتی سے منظم — بجٹ، خرچے، قرض اور یاد دہانیاں، سب ایک جگہ، مکمل طور پر آف لائن۔',
      'sortBy': 'ترتیب',
      'newestFirst': 'نئے پہلے',
      'oldestFirst': 'پرانے پہلے',
      'highestAmount': 'سب سے بڑی رقم',
      'lowestAmount': 'سب سے چھوٹی رقم',
      'clearAllData': 'تمام ڈیٹا صاف کریں',
      'clearAllConfirm': 'اس سے آپ کے تمام خرچے حذف ہو جائیں گے۔ یہ واپس نہیں ہو سکتا۔',
      'cancel': 'منسوخ کریں',
      'delete': 'حذف کریں',
      'login': 'لاگ ان',
      'register': 'رجسٹر کریں',
      'emailAddress': 'ای میل',
      'password': 'پاس ورڈ',
      'fullName': 'پورا نام',
      'createAccount': 'اکاؤنٹ بنائیں',
      'alreadyHaveAccount': 'اکاؤنٹ پہلے سے ہے؟ لاگ ان کریں',
      'dontHaveAccount': 'اکاؤنٹ نہیں ہے؟ رجسٹر کریں',
      'invalidCredentials': 'ای میل یا پاس ورڈ غلط ہے۔',
      'fillAllFields': 'براہ کرم تمام خانے پُر کریں۔',
      'logout': 'لاگ آؤٹ',
      'passwordRequirements': 'پاس ورڈ کم از کم 8 حروف کا ہو، جس میں 1 بڑا حرف، 1 عدد اور 1 خاص علامت ہو۔',
      'invalidEmail': 'غلط ای میل۔',
      'unknownProvider': "فراہم کنندہ '{d}' تسلیم شدہ نہیں ہے۔",
      'addReceivable': 'وصولی شامل کریں',
      'addPayable': 'ادائیگی شامل کریں',
      'passwordTooShort': 'پاس ورڈ کم از کم 8 حروف کا ہونا چاہیے۔',
      'passwordNeedsUppercase': 'پاس ورڈ میں 1 بڑا حرف ہونا چاہیے۔',
      'passwordNeedsNumber': 'پاس ورڈ میں 1 عدد ہونا چاہیے۔',
      'passwordNeedsSpecial': 'پاس ورڈ میں 1 خاص علامت ہونی چاہیے۔',
      'passwordNeedsLowercase': 'پاس ورڈ میں 1 چھوٹا حرف ہونا چاہیے۔',
      'confirmPassword': 'پاس ورڈ کی تصدیق کریں',
      'confirmPasswordRequired': 'براہ کرم تصدیق کے لیے پاس ورڈ دوبارہ لکھیں۔',
      'passwordsDoNotMatch': 'پاس ورڈ میل نہیں کھاتے۔',
      'deleteExpenseConfirm': 'کیا آپ واقعی یہ خرچ حذف کرنا چاہتے ہیں؟',
      'statistics': 'اعداد و شمار',
      'welcomeTitle': 'CashWise AI میں خوش آمدید',
      'welcomeSubtitle':
          'آپ کا پیسہ، خوبصورتی سے منظم — ہر بجٹ اور ہر قرض، ہمیشہ آپ کے ہاتھ میں۔',
      'viewDetails': 'تفصیلات دیکھیں',
      'emailMissingProvider': '۔com سے پہلے فراہم کنندہ لکھیں (جیسے gmail)۔',
      'chooseBudget': 'اپنا ماہانہ بجٹ منتخب کریں',
      'customAmount': 'اپنی رقم',
      'setMonthlyBudget': 'ماہانہ بجٹ طے کریں',
      'expenses': 'اخراجات',
      'aiPredictor': 'اے آئی پیش گوئی',
      'summary': 'خلاصہ',
      'udhar': 'ادھار',
      'lent': 'دیا',
      'borrowed': 'لیا',
      'personName': 'شخص کا نام',
      'youLent': 'آپ نے دیا',
      'youBorrowed': 'آپ نے لیا',
      'addUdhar': 'ادھار شامل کریں',
      'settled': 'طے شدہ',
      'noUdharEntries': 'ابھی کوئی ادھار نہیں۔',
      'note': 'نوٹ',
      'moneyLent': 'وصولیاں',
      'moneyBorrowed': 'ادائیگیاں',
      'pending': 'زیر التوا',
      'markSettled': 'طے شدہ کریں',
      'markPending': 'زیر التوا کریں',
      'selectDate': 'تاریخ منتخب کریں',
      'date': 'تاریخ',
      'quickActions': 'فوری اختیارات',
      'light': 'روشن',
      'dark': 'تاریک',
      'details': 'تفصیلات',
      'budgets': 'بجٹ',
      'theme': 'تھیم',
      'setBudgetFirst': 'پہلے اپنا ماہانہ بجٹ سیٹ کریں',
      'budgetRequired':
          'اخراجات شامل کرنے سے پہلے بجٹ شامل کریں — بجٹ آپ کے '
          'اخراجات پر نظر رکھتا ہے۔',
      'categories': 'زمرہ جات',
      'netBalance': 'خالص بیلنس',
      'perPerson': 'فی شخص',
      'welcomeName': 'خوش آمدید، {name}',
      'dueDate': 'ادائیگی کی تاریخ',
      'dueTime': 'ادائیگی کا وقت',
      'noDueDate': 'کوئی تاریخ مقرر نہیں',
      'setDueDate': 'تاریخ مقرر کریں',
      'setDueTime': 'وقت مقرر کریں',
      'addPayment': 'ادائیگی',
      'paymentAmount': 'ادائیگی کی رقم',
      'paidSoFar': 'اب تک ادا شدہ',
      'remainingAmount': 'باقی رقم',
      'overdue': 'میعاد گزر گئی',
      'dueToday': 'آج ادائیگی ہے',
      'dueTomorrow': 'کل ادائیگی ہے',
      'reminders': 'یاد دہانیاں',
      'paymentHistory': 'ادائیگیوں کی تفصیل',
      'editDue': 'تاریخ و وقت بدلیں',
      'removeDueDate': 'تاریخ ہٹا دیں',
      'editName': 'نام بدلیں',
      'save': 'محفوظ کریں',
      'nextDue': 'اگلی ادائیگی',
      'totalAmount': 'کل رقم',
      'noPaymentsYet': 'ابھی کوئی ادائیگی نہیں',
      'oneDayLeft': 'ایک دن باقی ہے',
      'noReminders': 'کوئی یاد دہانی نہیں',
      'dueSoon': 'جلد واجب الادا',
      'viewAllReminders': 'تمام یاد دہانیاں دیکھیں',
      'nameInEnglish': 'انگریزی میں نام',
      'nameInUrdu': 'اردو میں نام',
      'features': 'خصوصیات',
      'aboutDescription':
          'کیش وائز اے آئی پاکستان میں روزمرہ کے پیسوں کے لیے بنایا گیا ذاتی مالی ساتھی ہے۔ ایک یا کئی ماہانہ بجٹ بنائیں، ہر خرچ کو زمرے کے حساب سے ٹریک کریں، ادھار کھاتے میں مقررہ تاریخ، وقت اور جزوی ادائیگیوں کے ساتھ پیسے دیں اور لیں، اور کسی بھی ادائیگی کے لیے اپنی یاد دہانی لگائیں — ایپ صرف تب یاد دلائے گی جب آپ نے کہا ہو۔ مقامی کیش فلو پیش گوئی بتاتی ہے کہ بجٹ کب ختم ہوگا — ختم ہونے سے پہلے۔ سب کچھ آف لائن کام کرتا ہے، انگریزی یا اردو میں، اور آپ کا ڈیٹا آپ کے آلے پر ہی رہتا ہے۔',
      'aboutFeatures':
          '• ماہانہ بجٹ — اپنے نام والے کئی بجٹ، ہر ایک کی اپنی اسکرین، خرچے اور الرٹس\n• خرچے — زمرے، تلاش، فلٹر اور پائی چارٹ جس سے پتا چلے پیسہ کہاں گیا\n• ادھار کھاتہ — وصولیاں اور ادائیگیاں، مقررہ تاریخ و وقت، جزوی ادائیگیاں، مکمل تاریخ\n• یاد دہانیاں — صرف آپ کی لگائی ہوئی یاد دہانیاں، کسی بھی ادائیگی یا بجٹ کے لیے، ہمیشہ مستقبل میں — اور بن جو حذف شدہ اشیاء 30 دن رکھتا ہے\n• اے آئی کیش فلو پیش گوئی — روزانہ اوسط، مہینے کے آخر کا تخمینہ اور بجٹ ختم ہونے کی تاریخ\n• انگریزی اور اردو — مکمل ترجمہ، ہر جگہ اردو رسم الخط، دائیں سے بائیں ترتیب\n• ہلکا اور گہرا تھیم، اور ہر بار ایپ کھلنے پر والٹ خوش آمدید\n• مکمل طور پر آف لائن — نہ اکاؤنٹ، نہ سرور، نہ انٹرنیٹ کی ضرورت',
      'aboutDeveloperTitle': 'ڈویلپر کے بارے میں',
      'aboutDeveloper':
          'CashWise AI ملک علی رضا نے بنائی ہے — ایک Flutter اور Web Developer اور Riphah International University, Sahiwal میں Software Engineering کے طالب علم۔ وہ صاف architecture کے ساتھ حقیقی ایپس بناتے ہیں جو لوگ واقعی استعمال کرتے ہیں، اور انٹرنشپ اور فری لانس کام کے لیے دستیاب ہیں۔',
      'aboutPrivacy':
          'رازداری: آپ کے بجٹ، خرچے اور قرض صرف اس آلے پر محفوظ ہوتے ہیں۔ کیش وائز اے آئی آپ کا مالی ڈیٹا کہیں بھی نہیں بھیجتا۔',
      'whatsNew': 'v7.1 میں نیا کیا ہے',
      'whatsNewText':
          '• خوش آمدید صفحے پر پہلے والا والٹ واپس: ڈھکن کھلتا ہے اور سونے کا کارڈ باہر آتا ہے\n• ہوم کارڈز پھر صاف — ہر اختیار اپنی کیٹیگری کی اسکرین کے اندر ہے، ہر ایک کی ترتیب الگ\n• کیلنڈر مکمل کھلے: ہر تاریخ منتخب ہو سکتی ہے، کوئی چھپی یا بند نہیں\n• یاد دہانی صرف تب آئے گی جب آپ خود لگائیں گے — کسی بھی ادھار یا ادائیگی پر، ہمیشہ مستقبل میں\n• یاد دہانیوں کا صفحہ صرف آپ کی یاد دہانیاں دکھاتا ہے: اب واجب اور آنے والی\n• About میں اب یہ بھی لکھا ہے کہ CashWise AI کس نے بنائی',
      'paymentTime': 'ادائیگی کا وقت',
      'history': 'تاریخ',
      'editBudget': 'بجٹ بدلیں',
      'addAnotherBudget': 'ایک اور بجٹ شامل کریں',
      'yourBudgets': 'آپ کے بجٹ',
      'active': 'فعال',
      'people': 'افراد',
      'budgetNowActive': '{name} اب فعال بجٹ ہے۔',
      'enterPersonName': 'شخص کا نام درج کریں۔',
      'reminderAdded': 'یاد دہانی شامل کر دی گئی۔',
      'saveReminder': 'یاد دہانی محفوظ کریں',
      'reminderMustBeFuture':
          'یاد دہانی مستقبل میں ہونی چاہیے — ماضی یا ابھی نہیں۔',
      'setReminder': 'یاد دہانی لگائیں',
      'upcomingReminders': 'آنے والی',
      'dueReminders': 'اب واجب',
      'budgetName': 'بجٹ کا نام',
      'budgetNameHint': 'مثلاً گھر، رمضان، کاروبار',
      'renameBudget': 'بجٹ کا نام بدلیں',
      'useThisBudget': 'یہ بجٹ استعمال کریں',
      'addReminder': 'یاد دہانی شامل کریں',
      'customReminders': 'آپ کی یاد دہانیاں',
      'budgetReminder': 'بجٹ یاد دہانی',
      'loanReminder': 'ادھار یاد دہانی',
      'remindWhenRemaining': 'جب باقی رقم اس حد تک آ جائے تو یاد دلائیں',
      'dueMustBeFuture': 'واجب الادا تاریخ اور وقت مستقبل میں ہونے چاہئیں۔',
      'bin': 'بن',
      'daysLeftInBin': 'بن میں {n} دن باقی',
      'binAutoRemove':
          'حذف شدہ اشیاء بن میں 30 دن رہتی ہیں، پھر خود بخود ہٹ جاتی ہیں۔',
      'paymentDetails': 'ادائیگی کی تفصیلات',
      'remainingAfterPayment': 'اس ادائیگی کے بعد باقی رقم',
      'thisPayment': 'یہ ادائیگی',
      'budgetHistory': 'بجٹ کی تاریخ',
      'loanHistory': 'ادھار کی تاریخ',
      'deletedItems': 'حذف شدہ اشیاء',
      'restore': 'بحال کریں',
      'noDeletedItems': 'ابھی تک کچھ حذف نہیں ہوا۔',
      'today': 'آج',
      'ok': 'ٹھیک ہے',
      'warning80': 'انتباہ: آپ کے بجٹ کا 80٪ استعمال ہو چکا ہے۔',
      'warning100': 'بجٹ ختم: 100٪ خرچ ہو چکا ہے۔',
      'edit': 'ترمیم کریں',
      'dueInDays': '{n} دن میں ادائیگی ہے',
      'dueReminderOverdue': 'میعاد گزر گئی: {person} — {amount}',
      'dueReminderTomorrow': 'کل ادائیگی: {person} — {amount}',
      'continueWithGoogle': 'گوگل کے ساتھ جاری رکھیں',
      'googleSignInError':
          'گوگل سائن ان مکمل نہیں ہوا۔ دوبارہ کوشش کریں۔',
      'cashFlowPrediction': 'نقد بہاؤ کی پیش گوئی',
      'projectedMonthEnd': 'مہینے کے آخر تک متوقع خرچ',
      'dailyAverage': 'یومیہ اوسط',
      'budgetRunsOut': 'بجٹ ختم ہو جائے گا',
      'onTrack': 'سب ٹھیک ہے — آپ کا بجٹ مہینہ بھر چلے گا۔',
      'willRunOut': 'اس رفتار سے آپ کا بجٹ مہینے کے اختتام سے پہلے ختم ہو جائے گا۔',
      'noExpensesPrediction': 'پیش گوئی دیکھنے کے لیے خرچ شامل کریں۔',
      'editExpense': 'خرچ تبدیل کریں',
      'searchExpenses': 'خرچ تلاش کریں',
      'searchHint': 'عنوان سے تلاش کریں…',
      'allCategories': 'تمام زمرے',
      'updateExpense': 'خرچ اپ ڈیٹ کریں',
      'noMatchingExpenses': 'تلاش سے کوئی خرچ نہیں ملا۔',
    },
    categoryNames: {
      'Food': 'کھانا',
      'Transport': 'نقل و حمل',
      'Bills': 'بل',
      'Shopping': 'خریداری',
      'Health': 'صحت',
      'Education': 'تعلیم',
      'Other': 'دیگر',
    },
  ),
];

/// Look up a locale by code; falls back to English for unknown codes.
AppLocale localeByCode(String code) {
  for (final locale in appLocales) {
    if (locale.code == code) return locale;
  }
  return appLocales.first;
}
