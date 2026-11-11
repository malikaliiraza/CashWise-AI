// CashWise AI — Roman → Urdu transliteration (v5.6).
//
// A GENERAL system, not a name list: any English/Roman name is
// converted to Urdu script. A small dictionary of common words
// and names wins first (exact, correct spellings — e.g. Malik
// is ملک, not مالک), and anything not in the dictionary goes
// through the rule-based fallback, so ANY name converts:
// digraphs first (kh → خ, sh → ش, ch → چ, gh → غ, ...), then
// consonants one by one, and short vowels between consonants
// are dropped the way Urdu spelling drops them (Malik → ملک),
// while long vowels and word-final vowels are kept
// (Bilal → بلال, Raza → رضا, Ali → علی).
// Brand words are in the dictionary too: CashWise AI →
// کیش وائز اے آئی.

/// Common words/names with their exact Urdu spellings.
const Map<String, String> _dictionary = {
  // Brand.
  'cash': 'کیش',
  'wise': 'وائز',
  'ai': 'اے آئی',
  // Common first names.
  'malik': 'ملک',
  'ali': 'علی',
  'raza': 'رضا',
  'ahmed': 'احمد',
  'ahmad': 'احمد',
  'muhammad': 'محمد',
  'mohammad': 'محمد',
  'hassan': 'حسن',
  'hussain': 'حسین',
  'fatima': 'فاطمہ',
  'ayesha': 'عائشہ',
  'khan': 'خان',
  'usman': 'عثمان',
  'bilal': 'بلال',
  'umar': 'عمر',
  'omar': 'عمر',
  'zain': 'زین',
  'hamza': 'حمزہ',
  'sara': 'سارہ',
  'maryam': 'مریم',
  'noor': 'نور',
  'muheeb': 'محیب',
  'moheeb': 'محیب',
  'talha': 'طلحہ',
  'arham': 'ارحم',
  'ibrahim': 'ابراہیم',
  'yusuf': 'یوسف',
  'mustafa': 'مصطفی',
  'zainab': 'زینب',
  'khadija': 'خدیجہ',
  'amna': 'آمنہ',
  'hafsa': 'حفصہ',
  'ayan': 'آیان',
  'anas': 'انس',
  'saad': 'سعد',
  'ahad': 'احد',
  'rayan': 'ریان',
  'danish': 'دانش',
  'imran': 'عمران',
  'salman': 'سلمان',
  'farhan': 'فرحان',
  'shahid': 'شاہد',
  'nasir': 'ناصر',
  'tariq': 'طارق',
  'asif': 'آصف',
  'javed': 'جاوید',
  'rashid': 'راشد',
  'naeem': 'نعیم',
  'shazia': 'شازیہ',
  'rubina': 'روبینہ',
  'samina': 'ثمینہ',
  'noman': 'نعمان',
  'faraz': 'فراز',
  'sana': 'ثنا',
  'mahmood': 'محمود',
  'mehmood': 'محمود',
  'abdullah': 'عبداللہ',
  'abdul': 'عبد',
  'rehman': 'رحمان',
  'rahman': 'رحمان',
  'karim': 'کریم',
  'raheem': 'رحیم',
  'akhtar': 'اختر',
  'iqbal': 'اقبال',
  'kamran': 'کامران',
  'shoaib': 'شعیب',
  'waqas': 'وقاص',
  'arslan': 'ارسلان',
  'hina': 'حنا',
  'mahnoor': 'ماہ نور',
  'aiza': 'عائزہ',
  'eman': 'ایمان',
  'iman': 'ایمان',
  'zoya': 'زویا',
  'laiba': 'لائبہ',
  'sajal': 'سجل',
  'anum': 'انعم',
  'bushra': 'بشریٰ',
  'sadia': 'سعدیہ',
  'nida': 'ندا',
  'rabia': 'رابعہ',
  'hira': 'حرا',
  'aqsa': 'اقصیٰ',
  'umer': 'عمر',
  'kashif': 'کاشف',
  'aamir': 'عامر',
  'amir': 'عامر',
  'sajid': 'ساجد',
  'naveed': 'نوید',
  'daniyal': 'دانیال',
  'haseeb': 'حسیب',
  'adeel': 'عدیل',
  'faisal': 'فیصل',
  'jawad': 'جواد',
  'shahzad': 'شہزاد',
  'irfan': 'عرفان',
  'zeeshan': 'ذیشان',
  'rizwan': 'رضوان',
  'adnan': 'عدنان',
  'yasir': 'یاسر',
  'sohail': 'سہیل',
  'pervaiz': 'پرویز',
  'akram': 'اکرم',
  'ashfaq': 'اشفاق',
  'nadeem': 'ندیم',
  'shabbir': 'شبیر',
  'abbas': 'عباس',
  'kulsoom': 'کلثوم',
  'tahira': 'طاہرہ',
  'nasreen': 'نسرین',
  'farzana': 'فرزانہ',
  'rukhsana': 'رخسانہ',
  'shagufta': 'شگفتہ',
  'mehwish': 'مہوش',
};

/// Two-letter sequences, checked before single letters.
const Map<String, String> _digraphs = {
  'kh': 'خ',
  'gh': 'غ',
  'ch': 'چ',
  'sh': 'ش',
  'th': 'تھ',
  'ph': 'پھ',
  'bh': 'بھ',
  'dh': 'دھ',
  'zh': 'ژ',
  'ng': 'نگ',
  'aa': 'آ',
  'ee': 'ی',
  'oo': 'و',
  'ai': 'ای',
  'au': 'او',
  'ay': 'ے',
  'ei': 'ای',
  'ou': 'و',
};

/// Single consonants.
const Map<String, String> _consonants = {
  'b': 'ب',
  'c': 'ک',
  'd': 'د',
  'f': 'ف',
  'g': 'گ',
  'h': 'ہ',
  'j': 'ج',
  'k': 'ک',
  'l': 'ل',
  'm': 'م',
  'n': 'ن',
  'p': 'پ',
  'q': 'ق',
  'r': 'ر',
  's': 'س',
  't': 'ت',
  'v': 'و',
  'w': 'و',
  'x': 'کس',
  'y': 'ی',
  'z': 'ز',
};

bool _isVowel(String c) =>
    c == 'a' || c == 'e' || c == 'i' || c == 'o' || c == 'u';

/// Transliterate ONE word with the fallback rules (the
/// dictionary is checked first by [transliterate]).
String _transliterateWord(String word) {
  final w = word.toLowerCase();
  final out = StringBuffer();
  var i = 0;
  String? previousLetter;
  while (i < w.length) {
    // Collapse doubled consonants (ss → س, ll → ل).
    if (i > 0 &&
        w[i] == w[i - 1] &&
        !_isVowel(w[i]) &&
        _consonants.containsKey(w[i])) {
      i++;
      continue;
    }
    // Digraphs first.
    if (i + 1 < w.length) {
      final two = w.substring(i, i + 2);
      final mapped = _digraphs[two];
      if (mapped != null) {
        out.write(mapped);
        previousLetter = two;
        i += 2;
        continue;
      }
    }
    final c = w[i];
    final isFirst = i == 0;
    final isLast = i == w.length - 1;
    if (_isVowel(c)) {
      if (isFirst) {
        // Word-initial vowel: a/e/i → ا, o/u → و.
        out.write((c == 'o' || c == 'u') ? 'و' : 'ا');
      } else if (isLast) {
        // Word-final vowel: a → ا, e → ے, i → ی, o/u → و.
        out.write(
          c == 'a'
              ? 'ا'
              : c == 'e'
                  ? 'ے'
                  : c == 'i'
                      ? 'ی'
                      : 'و',
        );
      } else {
        // Medial vowel: kept as ا only when it is an "a"
        // before a single final consonant (Bilal → بلال);
        // every other short vowel between consonants is
        // dropped the way Urdu drops it (Malik → ملک).
        final next = w[i + 1];
        final isFinalSyllable =
            i + 2 == w.length && !_isVowel(next);
        if (c == 'a' && isFinalSyllable) {
          out.write('ا');
        }
      }
      previousLetter = c;
      i++;
      continue;
    }
    final mapped = _consonants[c];
    if (mapped != null) {
      out.write(mapped);
      previousLetter = c;
    }
    // Anything else (digits, punctuation) passes through.
    else {
      out.write(c);
    }
    i++;
  }
  return out.toString();
}

/// Transliterate a full name ("Malik Ali Raza" → "ملک علی رضا",
/// "CashWise AI" → "کیش وائز اے آئی"). Words are split on
/// spaces and on camelCase boundaries; every word goes through
/// the dictionary first, then the fallback rules.
String transliterate(String name) {
  // Split camelCase ("CashWise" → "Cash Wise") before splitting
  // on spaces, so brand names transliterate word by word.
  final spaced = name.replaceAllMapped(
    RegExp(r'([a-z])([A-Z])'),
    (m) => '${m[1]} ${m[2]}',
  );
  final words = spaced.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  return words
      .map((w) => _dictionary[w.toLowerCase()] ?? _transliterateWord(w))
      .join(' ');
}
