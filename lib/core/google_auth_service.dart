// CashWise AI — Continue with Google (v5.3).
//
// Proper Google sign-in via the google_sign_in package: the user
// picks a Google account, and the app creates/logs in the local
// account from that Google profile (name + email) — no password
// is stored for Google accounts.
//
// ONE THING IS STILL MISSING: a Google Cloud OAuth client ID.
// Without it the Google button shows an error. To finish it:
//   1. Google Cloud Console (console.cloud.google.com) -> create
//      a project -> APIs & Services -> Credentials.
//   2. Create Credentials -> OAuth client ID -> Web application.
//   3. Authorised JavaScript origins: the domain the app runs on
//      (for local Chrome testing: http://localhost:PORT).
//   4. Paste the Client ID into kGoogleClientId below AND into
//      the google-signin-client_id meta tag in web/index.html.
// The rest of the system (button, profile -> local account,
// login) is already wired.

import 'package:google_sign_in/google_sign_in.dart';

/// Paste the OAuth 2.0 Client ID for a Web application here.
const String kGoogleClientId =
    'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kGoogleClientId,
    scopes: <String>['email', 'profile'],
  );

  /// Opens the Google account chooser. Returns the chosen
  /// profile's name + email, or null when the user cancels, the
  /// client ID is not configured, or sign-in fails.
  static Future<({String name, String email})?> signIn() async {
    if (kGoogleClientId.startsWith('YOUR_GOOGLE_CLIENT_ID')) {
      return null;
    }
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;
      return (
        name: account.displayName ?? account.email.split('@').first,
        email: account.email,
      );
    } catch (_) {
      return null;
    }
  }
}
