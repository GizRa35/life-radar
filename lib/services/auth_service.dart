import 'dart:convert';
import 'package:http/http.dart' as http;

/// Firebase Web API anahtarı.
/// Firebase Console → Project Settings → "Web API Key" buraya yapıştırılır.
/// (Bu anahtar herkese açık olabilir; güvenlik kurallarıyla korunur.)
const String firebaseApiKey = 'AIzaSyBik4JADItiNyrNeNhhcpBy-N3hjPeTEnM';

class AuthResult {
  final bool success;
  final String? idToken;
  final String? email;
  final String? localId;
  final String? displayName;
  final String? error;
  const AuthResult({
    required this.success,
    this.idToken,
    this.email,
    this.localId,
    this.displayName,
    this.error,
  });
}

/// Firebase hesap bilgisi (lookup sonucu).
class AccountInfo {
  final bool emailVerified;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final List<String> providers; // 'password', 'google.com'...
  const AccountInfo({
    required this.emailVerified,
    this.createdAt,
    this.lastLoginAt,
    this.providers = const [],
  });

  bool get isGoogle => providers.contains('google.com');
  bool get isPassword => providers.contains('password');
}

/// Firebase Authentication — REST API (eklenti gerektirmez, web'de CORS uyumlu).
class AuthService {
  static const String _base =
      'https://identitytoolkit.googleapis.com/v1/accounts';

  bool get configured =>
      firebaseApiKey.isNotEmpty && firebaseApiKey != 'FIREBASE_WEB_API_KEY';

  /// Şifre değiştir — başarılıysa yeni idToken döner (AuthResult).
  Future<AuthResult> changePassword(String idToken, String newPassword) async {
    if (!configured) {
      return const AuthResult(success: false, error: 'Firebase ayarlı değil.');
    }
    final uri = Uri.parse('$_base:update?key=$firebaseApiKey');
    try {
      final res = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'idToken': idToken,
                'password': newPassword,
                'returnSecureToken': true,
              }))
          .timeout(const Duration(seconds: 30));
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) {
        return AuthResult(
          success: true,
          idToken: data['idToken']?.toString(),
          email: data['email']?.toString(),
        );
      }
      return AuthResult(
          success: false, error: _msg(data['error']?['message']?.toString()));
    } catch (_) {
      return const AuthResult(success: false, error: 'Bağlantı hatası.');
    }
  }

  /// Şifre sıfırlama e-postası gönder — başarılıysa null, hata varsa mesaj.
  Future<String?> sendPasswordReset(String email) async {
    if (!configured) return 'Firebase ayarlı değil.';
    final uri = Uri.parse('$_base:sendOobCode?key=$firebaseApiKey');
    try {
      final res = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(
                  {'requestType': 'PASSWORD_RESET', 'email': email.trim()}))
          .timeout(const Duration(seconds: 30));
      if (res.statusCode == 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return _msg(data['error']?['message']?.toString());
    } catch (_) {
      return 'Bağlantı hatası.';
    }
  }

  /// E-posta doğrulama bağlantısı gönder — başarılıysa null, hata varsa mesaj.
  Future<String?> sendVerifyEmail(String idToken) async {
    if (!configured) return 'Firebase ayarlı değil.';
    final uri = Uri.parse('$_base:sendOobCode?key=$firebaseApiKey');
    try {
      final res = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(
                  {'requestType': 'VERIFY_EMAIL', 'idToken': idToken}))
          .timeout(const Duration(seconds: 30));
      if (res.statusCode == 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return _msg(data['error']?['message']?.toString());
    } catch (_) {
      return 'Bağlantı hatası.';
    }
  }

  /// Hesap bilgisini getir (doğrulama durumu, tarihler, sağlayıcılar).
  Future<AccountInfo?> getAccountInfo(String idToken) async {
    if (!configured) return null;
    final uri = Uri.parse('$_base:lookup?key=$firebaseApiKey');
    try {
      final res = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'idToken': idToken}))
          .timeout(const Duration(seconds: 30));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final users = data['users'] as List?;
      if (users == null || users.isEmpty) return null;
      final u = users.first as Map<String, dynamic>;
      DateTime? parseMs(dynamic v) {
        final n = int.tryParse(v?.toString() ?? '');
        return n == null ? null : DateTime.fromMillisecondsSinceEpoch(n);
      }

      final provs = (u['providerUserInfo'] as List?)
              ?.map((p) => (p as Map)['providerId']?.toString() ?? '')
              .where((s) => s.isNotEmpty)
              .toList() ??
          <String>[];
      return AccountInfo(
        emailVerified: u['emailVerified'] == true,
        createdAt: parseMs(u['createdAt']),
        lastLoginAt: parseMs(u['lastLoginAt']),
        providers: provs,
      );
    } catch (_) {
      return null;
    }
  }

  /// Hesabı kalıcı sil — başarılıysa null, hata varsa mesaj.
  Future<String?> deleteAccount(String idToken) async {
    if (!configured) return 'Firebase ayarlı değil.';
    final uri = Uri.parse('$_base:delete?key=$firebaseApiKey');
    try {
      final res = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'idToken': idToken}))
          .timeout(const Duration(seconds: 30));
      if (res.statusCode == 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return _msg(data['error']?['message']?.toString());
    } catch (_) {
      return 'Bağlantı hatası.';
    }
  }

  Future<AuthResult> register(String email, String password) =>
      _call('signUp', email, password);

  Future<AuthResult> login(String email, String password) =>
      _call('signInWithPassword', email, password);

  /// Google access_token ile Firebase'e giriş (signInWithIdp).
  Future<AuthResult> signInWithGoogle(String accessToken) async {
    if (!configured) {
      return const AuthResult(
          success: false, error: 'Firebase API anahtarı ayarlanmamış.');
    }
    final uri = Uri.parse('$_base:signInWithIdp?key=$firebaseApiKey');
    try {
      final res = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'postBody': 'access_token=$accessToken&providerId=google.com',
              'requestUri': 'http://localhost:5151',
              'returnIdpCredential': true,
              'returnSecureToken': true,
            }),
          )
          .timeout(const Duration(seconds: 30));
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) {
        return AuthResult(
          success: true,
          idToken: data['idToken']?.toString(),
          email: data['email']?.toString(),
          localId: data['localId']?.toString(),
          displayName: data['displayName']?.toString(),
        );
      }
      return AuthResult(
          success: false, error: _msg(data['error']?['message']?.toString()));
    } catch (_) {
      return const AuthResult(success: false, error: 'Bağlantı hatası.');
    }
  }

  Future<AuthResult> _call(String action, String email, String password) async {
    if (!configured) {
      return const AuthResult(
        success: false,
        error: 'Firebase API anahtarı ayarlanmamış. Lütfen anahtarı ekleyin.',
      );
    }
    final uri = Uri.parse('$_base:$action?key=$firebaseApiKey');
    try {
      final res = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email.trim(),
              'password': password,
              'returnSecureToken': true,
            }),
          )
          .timeout(const Duration(seconds: 30));
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) {
        return AuthResult(
          success: true,
          idToken: data['idToken']?.toString(),
          email: data['email']?.toString(),
          localId: data['localId']?.toString(),
        );
      }
      return AuthResult(
        success: false,
        error: _msg(data['error']?['message']?.toString()),
      );
    } catch (_) {
      return const AuthResult(
        success: false,
        error: 'Bağlantı hatası. İnternetinizi kontrol edin.',
      );
    }
  }

  String _msg(String? code) {
    if (code == null) return 'Bilinmeyen hata.';
    if (code.startsWith('WEAK_PASSWORD')) return 'Şifre en az 6 karakter olmalı.';
    switch (code) {
      case 'EMAIL_EXISTS':
        return 'Bu e-posta zaten kayıtlı.';
      case 'INVALID_LOGIN_CREDENTIALS':
      case 'INVALID_PASSWORD':
        return 'E-posta veya şifre hatalı.';
      case 'EMAIL_NOT_FOUND':
        return 'Bu e-posta kayıtlı değil.';
      case 'INVALID_EMAIL':
        return 'Geçersiz e-posta adresi.';
      case 'MISSING_PASSWORD':
        return 'Şifre girin.';
      case 'OPERATION_NOT_ALLOWED':
        return 'E-posta/şifre girişi Firebase\'de etkin değil.';
      case 'CREDENTIAL_TOO_OLD_LOGIN_AGAIN':
      case 'TOKEN_EXPIRED':
      case 'INVALID_ID_TOKEN':
        return 'Güvenlik için tekrar giriş yapmanız gerekiyor.';
      case 'USER_NOT_FOUND':
        return 'Hesap bulunamadı.';
      case 'USER_DISABLED':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'TOO_MANY_ATTEMPTS_TRY_LATER':
        return 'Çok fazla deneme. Lütfen daha sonra tekrar deneyin.';
      default:
        return code;
    }
  }
}
