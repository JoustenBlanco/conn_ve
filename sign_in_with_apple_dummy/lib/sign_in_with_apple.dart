// sign_in_with_apple_dummy/lib/sign_in_with_apple.dart

class SignInWithApple {
  static Future<AuthorizationCredentialAppleID> getAppleIDCredential({
    required List<dynamic> scopes,
    String? nonce,
    String? state,
  }) async {
    throw UnsupportedError('SignInWithApple no está disponible en esta plataforma.');
  }
}

class AppleIDAuthorizationScopes {
  static const email = 'email';
  static const fullName = 'fullName';
}

class AuthorizationCredentialAppleID {
  final String identityToken;
  final String authorizationCode;
  final String? givenName;
  final String? familyName;

  AuthorizationCredentialAppleID({
    required this.identityToken,
    required this.authorizationCode,
    this.givenName,
    this.familyName,
  });
}
