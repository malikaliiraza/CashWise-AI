// CashWise AI — login / register screen (v4.5).
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/google_auth_service.dart';
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
    super.dispose();
  }

  void _clearErrors() {
    _nameError = null;
    _emailError = null;
    _passwordError = null;
    _confirmError = null;
    _googleError = null;
  }

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
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 48,
                          color: CashWiseTheme.accentFor(context),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          store.displayBrand,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          strings.aboutText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: CashWiseTheme.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _isLogin ? strings.login : strings.createAccount,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (!_isLogin) ...[
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: strings.fullName,
                              errorText: _nameError,
                            ),
                            onChanged: (_) {
                              if (_nameError != null) {
                                setState(() => _nameError = null);
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: strings.emailAddress,
                            errorText: _emailError,
                          ),
                          onChanged: (_) {
                            if (_emailError != null) {
                              setState(() => _emailError = null);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: strings.password,
                            errorText: _passwordError,
                            errorMaxLines: 2,
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
                          const SizedBox(height: 12),
                          TextField(
                            controller: _confirmController,
                            obscureText: _obscureConfirm,
                            decoration: InputDecoration(
                              labelText: strings.confirmPassword,
                              errorText: _confirmError,
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
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _submit,
                          child: Text(
                            _isLogin ? strings.login : strings.createAccount,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                '—',
                                style: const TextStyle(
                                  color: CashWiseTheme.secondaryText,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _signInWithGoogle,
                          icon: const Icon(Icons.g_mobiledata, size: 28),
                          label: Text(strings.continueWithGoogle),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                        if (_googleError != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _googleError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: CashWiseTheme.danger,
                            ),
                          ),
                        ],
                        if (hasAccount) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                                _clearErrors();
                              });
                            },
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
