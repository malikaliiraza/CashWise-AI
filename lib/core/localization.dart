// CashWise AI v2 — international localization.
//
// Custom localization system with no extra packages. Every user-facing
// string is translated into each locale's own script only: no mixed
// language strings, no Roman Urdu, no Roman English.
//
// Expense categories are stored internally as English keys
// ('Food', 'Transport', ...) and only DISPLAYED in the current locale.

/// One supported language + country + currency profile.
class AppLocale {
  final String code;
  final String nativeName;
  final String country;
  final String currencyCode;
  final String currencySymbol;
  final double defaultBudget;
  final bool isRtl;
  final Map<String, String> strings;
  final Map<String, String> categories;

  const AppLocale({
    required this.code,
    required this.nativeName,
    required this.country,
    required this.currencyCode,
    required this.currencySymbol,
    required this.defaultBudget,
    required this.isRtl,
    required this.strings,
    required this.categories,
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

  /// e.g. "Monthly budget updated to $500." — {amount} is replaced with
  /// the already-formatted amount, so no language mixing is introduced.
  String budgetUpdated(String amount) =>
      _get('budgetUpdated').replaceAll('{amount}', amount);

  /// Translated display name for an internally-stored English category key.
  String categoryName(String key) => categories[key] ?? key;

  /// Label for an amount field, e.g. "Amount (USD)".
  String get amountLabel => '$amount ($currencyCode)';

  /// Label for a budget field, e.g. "Monthly budget (PKR)".
  String get monthlyBudgetLabel => '$monthlyBudget ($currencyCode)';
}

const List<AppLocale> appLocales = [
  AppLocale(
    code: 'en',
    nativeName: 'English',
    country: 'USA',
    currencyCode: 'USD',
    currencySymbol: r'$',
    defaultBudget: 500,
    isRtl: false,
    strings: {
      'spentThisMonth': 'Spent this month',
      'budget': 'Budget',
      'remaining': 'Remaining',
      'overspendAlert': 'Overspend alert! Your budget is finished.',
      'warningAlert': 'Warning: 80% of your budget has been used.',
      'noExpenses': 'No expenses yet.',
      'tapToAdd': 'Tap + to add your first one.',
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
    },
    categories: {
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
    country: 'Pakistan',
    currencyCode: 'PKR',
    currencySymbol: 'Rs.',
    defaultBudget: 50000,
    isRtl: true,
    strings: {
      'spentThisMonth': 'اس مہینے کا خرچ',
      'budget': 'بجٹ',
      'remaining': 'باقی',
      'overspendAlert': 'حد سے زیادہ خرچ کا انتباہ! آپ کا بجٹ ختم ہو گیا ہے۔',
      'warningAlert': 'خبردار: آپ کے بجٹ کا 80٪ استعمال ہو گیا ہے۔',
      'noExpenses': 'ابھی کوئی خرچ نہیں ہے۔',
      'tapToAdd': 'پہلا خرچ شامل کرنے کے لیے + دبائیں۔',
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
    },
    categories: {
      'Food': 'کھانا',
      'Transport': 'نقل و حمل',
      'Bills': 'بل',
      'Shopping': 'خریداری',
      'Health': 'صحت',
      'Education': 'تعلیم',
      'Other': 'دیگر',
    },
  ),
  AppLocale(
    code: 'ar',
    nativeName: 'العربية',
    country: 'Saudi Arabia',
    currencyCode: 'SAR',
    currencySymbol: 'ر.س',
    defaultBudget: 2000,
    isRtl: true,
    strings: {
      'spentThisMonth': 'المصروف هذا الشهر',
      'budget': 'الميزانية',
      'remaining': 'المتبقي',
      'overspendAlert': 'تنبيه تجاوز الإنفاق! انتهت ميزانيتك.',
      'warningAlert': 'تحذير: تم استخدام 80٪ من ميزانيتك.',
      'noExpenses': 'لا توجد مصروفات بعد.',
      'tapToAdd': 'اضغط على + لإضافة أول مصروف.',
      'addExpense': 'إضافة مصروف',
      'whatDidYouSpend': 'على ماذا أنفقت؟',
      'amount': 'المبلغ',
      'category': 'الفئة',
      'saveExpense': 'حفظ المصروف',
      'editMonthlyBudget': 'تعديل الميزانية الشهرية',
      'monthlyBudget': 'الميزانية الشهرية',
      'saveBudget': 'حفظ الميزانية',
      'budgetUpdated': 'تم تحديث الميزانية الشهرية إلى {amount}.',
      'enterTitleValidAmount': 'أدخل عنوانًا ومبلغًا صحيحًا.',
      'enterValidBudget': 'أدخل ميزانية صحيحة أكبر من 0.',
      'language': 'اللغة',
            'spendingByCategory': 'الإنفاق حسب الفئة',
    },
    categories: {
      'Food': 'طعام',
      'Transport': 'مواصلات',
      'Bills': 'فواتير',
      'Shopping': 'تسوق',
      'Health': 'صحة',
      'Education': 'تعليم',
      'Other': 'أخرى',
    },
  ),
  AppLocale(
    code: 'hi',
    nativeName: 'हिन्दी',
    country: 'India',
    currencyCode: 'INR',
    currencySymbol: '₹',
    defaultBudget: 40000,
    isRtl: false,
    strings: {
      'spentThisMonth': 'इस महीने का खर्च',
      'budget': 'बजट',
      'remaining': 'शेष',
      'overspendAlert': 'अधिक खर्च की चेतावनी! आपका बजट समाप्त हो गया है।',
      'warningAlert': 'चेतावनी: आपके बजट का 80% उपयोग हो चुका है।',
      'noExpenses': 'अभी कोई खर्च नहीं है।',
      'tapToAdd': 'अपना पहला खर्च जोड़ने के लिए + दबाएँ।',
      'addExpense': 'खर्च जोड़ें',
      'whatDidYouSpend': 'आपने किस पर खर्च किया?',
      'amount': 'राशि',
      'category': 'श्रेणी',
      'saveExpense': 'खर्च सहेजें',
      'editMonthlyBudget': 'मासिक बजट बदलें',
      'monthlyBudget': 'मासिक बजट',
      'saveBudget': 'बजट सहेजें',
      'budgetUpdated': 'मासिक बजट {amount} पर अपडेट हो गया है।',
      'enterTitleValidAmount': 'शीर्षक और सही राशि दर्ज करें।',
      'enterValidBudget': '0 से अधिक सही बजट दर्ज करें।',
      'language': 'भाषा',
            'spendingByCategory': 'श्रेणी के अनुसार खर्च',
    },
    categories: {
      'Food': 'भोजन',
      'Transport': 'परिवहन',
      'Bills': 'बिल',
      'Shopping': 'खरीदारी',
      'Health': 'स्वास्थ्य',
      'Education': 'शिक्षा',
      'Other': 'अन्य',
    },
  ),
  AppLocale(
    code: 'es',
    nativeName: 'Español',
    country: 'Spain',
    currencyCode: 'EUR',
    currencySymbol: '€',
    defaultBudget: 500,
    isRtl: false,
    strings: {
      'spentThisMonth': 'Gastado este mes',
      'budget': 'Presupuesto',
      'remaining': 'Restante',
      'overspendAlert': '¡Alerta de gasto excesivo! Tu presupuesto se ha agotado.',
      'warningAlert': 'Advertencia: se ha usado el 80% de tu presupuesto.',
      'noExpenses': 'Aún no hay gastos.',
      'tapToAdd': 'Toca + para añadir tu primer gasto.',
      'addExpense': 'Añadir gasto',
      'whatDidYouSpend': '¿En qué gastaste?',
      'amount': 'Cantidad',
      'category': 'Categoría',
      'saveExpense': 'Guardar gasto',
      'editMonthlyBudget': 'Editar presupuesto mensual',
      'monthlyBudget': 'Presupuesto mensual',
      'saveBudget': 'Guardar presupuesto',
      'budgetUpdated': 'Presupuesto mensual actualizado a {amount}.',
      'enterTitleValidAmount': 'Introduce un título y una cantidad válida.',
      'enterValidBudget': 'Introduce un presupuesto válido mayor que 0.',
      'language': 'Idioma',
            'spendingByCategory': 'Gasto por categoría',
    },
    categories: {
      'Food': 'Comida',
      'Transport': 'Transporte',
      'Bills': 'Facturas',
      'Shopping': 'Compras',
      'Health': 'Salud',
      'Education': 'Educación',
      'Other': 'Otros',
    },
  ),
  AppLocale(
    code: 'fr',
    nativeName: 'Français',
    country: 'France',
    currencyCode: 'EUR',
    currencySymbol: '€',
    defaultBudget: 500,
    isRtl: false,
    strings: {
      'spentThisMonth': 'Dépensé ce mois-ci',
      'budget': 'Budget',
      'remaining': 'Restant',
      'overspendAlert': 'Alerte de dépassement ! Votre budget est épuisé.',
      'warningAlert': 'Attention : 80 % de votre budget a été utilisé.',
      'noExpenses': 'Aucune dépense pour le moment.',
      'tapToAdd': 'Appuyez sur + pour ajouter votre première dépense.',
      'addExpense': 'Ajouter une dépense',
      'whatDidYouSpend': 'Sur quoi avez-vous dépensé ?',
      'amount': 'Montant',
      'category': 'Catégorie',
      'saveExpense': 'Enregistrer la dépense',
      'editMonthlyBudget': 'Modifier le budget mensuel',
      'monthlyBudget': 'Budget mensuel',
      'saveBudget': 'Enregistrer le budget',
      'budgetUpdated': 'Budget mensuel mis à jour à {amount}.',
      'enterTitleValidAmount': 'Saisissez un titre et un montant valide.',
      'enterValidBudget': 'Saisissez un budget valide supérieur à 0.',
      'language': 'Langue',
            'spendingByCategory': 'Dépenses par catégorie',
    },
    categories: {
      'Food': 'Nourriture',
      'Transport': 'Transport',
      'Bills': 'Factures',
      'Shopping': 'Achats',
      'Health': 'Santé',
      'Education': 'Éducation',
      'Other': 'Autre',
    },
  ),
  AppLocale(
    code: 'tr',
    nativeName: 'Türkçe',
    country: 'Türkiye',
    currencyCode: 'TRY',
    currencySymbol: '₺',
    defaultBudget: 20000,
    isRtl: false,
    strings: {
      'spentThisMonth': 'Bu ay harcanan',
      'budget': 'Bütçe',
      'remaining': 'Kalan',
      'overspendAlert': 'Aşırı harcama uyarısı! Bütçeniz bitti.',
      'warningAlert': "Uyarı: Bütçenizin %80'i kullanıldı.",
      'noExpenses': 'Henüz harcama yok.',
      'tapToAdd': 'İlk harcamanızı eklemek için + simgesine dokunun.',
      'addExpense': 'Harcama ekle',
      'whatDidYouSpend': 'Neye harcadınız?',
      'amount': 'Tutar',
      'category': 'Kategori',
      'saveExpense': 'Harcamayı kaydet',
      'editMonthlyBudget': 'Aylık bütçeyi düzenle',
      'monthlyBudget': 'Aylık bütçe',
      'saveBudget': 'Bütçeyi kaydet',
      'budgetUpdated': 'Aylık bütçe {amount} olarak güncellendi.',
      'enterTitleValidAmount': 'Bir başlık ve geçerli bir tutar girin.',
      'enterValidBudget': "0'dan büyük geçerli bir bütçe girin.",
      'language': 'Dil',
            'spendingByCategory': 'Kategoriye göre harcama',
    },
    categories: {
      'Food': 'Yemek',
      'Transport': 'Ulaşım',
      'Bills': 'Faturalar',
      'Shopping': 'Alışveriş',
      'Health': 'Sağlık',
      'Education': 'Eğitim',
      'Other': 'Diğer',
    },
  ),
  AppLocale(
    code: 'zh',
    nativeName: '中文',
    country: 'China',
    currencyCode: 'CNY',
    currencySymbol: '¥',
    defaultBudget: 3500,
    isRtl: false,
    strings: {
      'spentThisMonth': '本月支出',
      'budget': '预算',
      'remaining': '剩余',
      'overspendAlert': '超支提醒！您的预算已用完。',
      'warningAlert': '提醒：您的预算已使用80%。',
      'noExpenses': '暂无支出。',
      'tapToAdd': '点击 + 添加第一笔支出。',
      'addExpense': '添加支出',
      'whatDidYouSpend': '您花在了什么地方？',
      'amount': '金额',
      'category': '类别',
      'saveExpense': '保存支出',
      'editMonthlyBudget': '编辑月度预算',
      'monthlyBudget': '月度预算',
      'saveBudget': '保存预算',
      'budgetUpdated': '月度预算已更新为{amount}。',
      'enterTitleValidAmount': '请输入标题和有效金额。',
      'enterValidBudget': '请输入大于0的有效预算。',
      'language': '语言',
            'spendingByCategory': '按类别支出',
    },
    categories: {
      'Food': '餐饮',
      'Transport': '交通',
      'Bills': '账单',
      'Shopping': '购物',
      'Health': '健康',
      'Education': '教育',
      'Other': '其他',
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
