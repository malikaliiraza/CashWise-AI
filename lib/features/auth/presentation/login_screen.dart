// Hisaab Kitaab — login / register screen (v7.2).
//
// Local account only: the account lives on this device in
// SharedPreferences (see ExpenseStore.register/login). There is no
// server, so this is a gate so the app does not open straight into
// the expenses — not a secure server account.
//
// Rules (user's words, v4.5):
// - First time (no account on this device): only Create account is
//   possible — the "Already have an account? Log in" switch is
//   hidden until an account exists.
// - Errors appear UNDER the field they belong to, and only after the
//   user submits (or finishes the field) — never while typing.
// - One error at a time, in order: length, uppercase, lowercase,
//   number, special character. Confirm password: empty -> its own
//   error only; mismatch -> "Passwords do not match." only.
// - Every field error shows in full (errorMaxLines: 3) so long
//   errors wrap instead of truncating with "...".
// - A local captcha guards both forms (v7.2): a wrong captcha blocks
//   submit and a fresh code is generated.
// - Compact, one screen, no scroll on a normal phone (v7.2).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/captcha.dart';
import '../../../core/google_auth_service.dart';
import '../../../core/google_g_icon.dart';
import '../../../core/theme.dart';
import '../../expenses/data/expense_store.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _captchaController = TextEditingController();
  final _captchaKey = GlobalKey<CaptchaFieldState>();
  late bool _isLogin;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  String? _googleError;

  @override
  void initState() {
    super.initState();
    // Account already on this device -> start on Log in.
    // First time -> only Create account is possible.
    _isLogin = context.read<ExpenseStore>().userEmail.isNotEmpty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  void _clearErrors() {
    _nameError = null;
    _emailError = null;
    _passwordError = null;
    _confirmError = null;
    _googleError = null;
  }

  /// Compact field decoration: dense, and every error shows in full.
  InputDecoration _fieldDecoration(String label, String? error) =>
      InputDecoration(
        labelText: label,
        errorText: error,
        errorMaxLines: 3,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
      );

  /// Continue with Google: pick a Google account, and the local
  /// account is created from that profile (name + email).
  Future<void> _signInWithGoogle() async {
    final store = context.read<ExpenseStore>();
    final strings = store.strings;
    final profile = await GoogleAuthService.signIn();
    if (!mounted) return;
    if (profile == null) {
      setState(() => _googleError = strings.googleSignInError);
      return;
    }
    await store.loginWithGoogle(
      name: profile.name,
      email: profile.email,
    );
  }

  Future<void> _submit() async {
    final store = context.read<ExpenseStore>();
    final strings = store.strings;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();
    final confirm = _confirmController.text;

    setState(_clearErrors);

    if (!_isLogin && name.isEmpty) {
      setState(() => _nameError = strings.fillAllFields);
      return;
    }
    if (email.isEmpty) {
      setState(() => _emailError = strings.fillAllFields);
      return;
    }
    // e.g. melicalyraza5@.com — the provider (gmail) is missing,
    // so say that, not "check the spelling".
    if (email.contains('@.')) {
      setState(() => _emailError = strings.emailMissingProvider);
      return;
    }
    if (!ExpenseStore.isValidEmail(email)) {
      setState(() => _emailError = strings.invalidEmail);
      return;
    }
    // A shape-valid address with an unknown provider gets its
    // own error (v6.0): "The provider 'l.com' is not a
    // recognised provider." — never just "invalid email".
    final domain = ExpenseStore.emailDomain(email);
    if (domain != null && !ExpenseStore.isKnownProvider(domain)) {
      setState(() => _emailError = strings.unknownProvider(domain));
      return;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = strings.fillAllFields);
      return;
    }
    // One rule at a time, in order.
    if (!_isLogin) {
      if (password.length < 8) {
        setState(() => _passwordError = strings.passwordTooShort);
        return;
      }
      if (!password.contains(RegExp(r'[A-Z]'))) {
        setState(() => _passwordError = strings.passwordNeedsUppercase);
        return;
      }
      if (!password.contains(RegExp(r'[a-z]'))) {
        setState(() => _passwordError = strings.passwordNeedsLowercase);
        return;
      }
      if (!password.contains(RegExp(r'[0-9]'))) {
        setState(() => _passwordError = strings.passwordNeedsNumber);
        return;
      }
      if (!password.contains(RegExp(r'[^A-Za-z0-9]'))) {
        setState(() => _passwordError = strings.passwordNeedsSpecial);
        return;
      }
      if (confirm.isEmpty) {
        setState(() => _confirmError = strings.confirmPasswordRequired);
        return;
      }
      if (confirm != password) {
        setState(() => _confirmError = strings.passwordsDoNotMatch);
        return;
      }
    }
    // Captcha last: a wrong code blocks submit, and the captcha
    // regenerates a fresh code on failure (inside validate).
    if (!(_captchaKey.currentState?.validate() ?? false)) {
      return;
    }
    final ok = _isLogin
        ? await store.login(email: email, password: password)
        : await store.register(
            name: name,
            email: email,
            password: password,
          );
    if (!ok && mounted) {
      setState(() => _passwordError = strings.invalidCredentials);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseStore>();
    final strings = store.strings;
    final locale = store.locale;
    // First time: no account exists, so Sign in is not offered at all.
    final hasAccount = store.userEmail.isNotEmpty;

    return Directionality(
      textDirection: locale.isRtl ? TextDirection.rtl : TextDirection.ltr,
      // No scroll view: the compact layout fits one screen, and the
      // keyboard overlays instead of resizing the form.
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.asset(
                          'assets/logo.png',
                          height: 40,
                          errorBuilder: (ctx, err, stack) => Icon(
                            Icons.account_balance_wallet,
                            size: 40,
                            color: CashWiseTheme.accentFor(context),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          store.displayBrand,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          strings.punchLine,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.0,
                            color: CashWiseTheme.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isLogin ? strings.login : strings.createAccount,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (!_isLogin) ...[
                          TextField(
                            controller: _nameController,
                            decoration: _fieldDecoration(
                              strings.fullName,
                              _nameError,
                            ),
                            onChanged: (_) {
                              if (_nameError != null) {
                                setState(() => _nameError = null);
                              }
                            },
                          ),
                          const SizedBox(height: 6),
                        ],
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _fieldDecoration(
                            strings.emailAddress,
                            _emailError,
                          ),
                          onChanged: (_) {
                            if (_emailError != null) {
                              setState(() => _emailError = null);
                            }
                          },
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: _fieldDecoration(
                            strings.password,
                            _passwordError,
                          ).copyWith(
                            suffixIcon: IconButton(
                              // Slashed eye = hidden, plain eye =
                              // showing, so the state is visible.
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          onChanged: (_) {
                            if (_passwordError != null) {
                              setState(() => _passwordError = null);
                            }
                          },
                        ),
                        if (!_isLogin) ...[
                          const SizedBox(height: 6),
                          TextField(
                            controller: _confirmController,
                            obscureText: _obscureConfirm,
                            decoration: _fieldDecoration(
                              strings.confirmPassword,
                              _confirmError,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                              ),
                            ),
                            onChanged: (_) {
                              if (_confirmError != null) {
                                setState(() => _confirmError = null);
                              }
                            },
                          ),
                        ],
                        const SizedBox(height: 6),
                        CaptchaField(
                          key: _captchaKey,
                          controller: _captchaController,
                          captchaLabel: strings.captcha,
                          enterLabel: strings.enterCaptcha,
                          wrongMessage: strings.captchaWrong,
                          refreshTooltip: strings.refreshCaptcha,
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                            ),
                          ),
                          child: Text(
                            _isLogin ? strings.login : strings.createAccount,
                          ),
                        ),
                        const SizedBox(height: 6),
                        OutlinedButton.icon(
                          onPressed: _signInWithGoogle,
                          icon: const GoogleGIcon(size: 24),
                          label: Text(strings.continueWithGoogle),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                        if (_googleError != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            _googleError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: CashWiseTheme.danger,
                            ),
                          ),
                        ],
                        if (hasAccount) ...[
                          const SizedBox(height: 4),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                                _clearErrors();
                                _captchaKey.currentState?.reset();
                              });
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2,
                              ),
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              _isLogin
                                  ? strings.dontHaveAccount
                                  : strings.alreadyHaveAccount,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
