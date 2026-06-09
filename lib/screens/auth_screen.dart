import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../state/app_state.dart';

/// Giriş / Kayıt ekranı (Firebase Auth REST).
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final Widget icon;
  final VoidCallback onTap;
  const _SocialButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: foreground)),
          ],
        ),
      ),
    );
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  String _gender = '';
  String _language = 'tr'; // haber dili tercihi
  // Kısa tanışma anketi (isteğe bağlı) — AI analizini kişiselleştirir.
  String _ageRange = '';
  String _household = '';
  String _health = '';
  String _finance = '';
  bool _isRegister = false;
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  /// "ahMET yılmaz" → "Ahmet Yılmaz" (Türkçe uyumlu baş harf büyütme).
  String _titleCase(String s) {
    return s
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) {
          final first = w.substring(0, 1);
          final up = first == 'i' ? 'İ' : first.toUpperCase();
          return up + w.substring(1).toLowerCase();
        })
        .join(' ');
  }

  /// iOS'ta gerçek Apple ile giriş; web'de henüz desteklenmiyor.
  bool get _appleAvailable =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> _googleSignIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final err = await context.read<AppState>().loginWithGoogle();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = err;
    });
  }

  Future<void> _appleSignIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final err = await context.read<AppState>().loginWithApple();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = err;
    });
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final state = context.read<AppState>();
    final err = _isRegister
        ? await state.register(_email.text, _password.text)
        : await state.login(_email.text, _password.text);
    if (!mounted) return;
    // Kayıt başarılıysa ad/cinsiyet bilgisini kaydet (avatar + isim için).
    if (_isRegister && err == null) {
      final name = _titleCase('${_firstName.text} ${_lastName.text}');
      state.updateUserContext(
        state.userContext.copyWith(
          name: name,
          gender: _gender,
          language: _language,
          age: _ageRange,
          familyInfo: _household,
          healthNotes: _health,
          financialSensitivity: _finance,
        ),
      );
    }
    setState(() {
      _loading = false;
      _error = err;
    });
    // Başarılıysa gateOpen true olur, üst widget MainScaffold'a geçer.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LifeRadarColors.navy,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.radar,
                      color: LifeRadarColors.turquoise, size: 56),
                  const SizedBox(height: 12),
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppConstants.slogan,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 28),

                  // Sosyal giriş: Google her platformda; Apple yalnızca iOS'ta.
                  // Google ile devam et
                  _SocialButton(
                    label: 'Google ile devam et',
                    background: Colors.white,
                    foreground: const Color(0xFF3C4043),
                    icon: const Text('G',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: Color(0xFF4285F4),
                        )),
                    onTap: _loading ? () {} : _googleSignIn,
                  ),
                  // Apple ile devam et (iOS)
                  if (_appleAvailable) ...[
                    const SizedBox(height: 10),
                    _SocialButton(
                      label: 'Apple ile devam et',
                      background: Colors.black,
                      foreground: Colors.white,
                      icon: const Icon(Icons.apple,
                          color: Colors.white, size: 22),
                      onTap: _loading ? () {} : _appleSignIn,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: Divider(color: Colors.white.withOpacity(0.3))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text('veya e-posta ile',
                            style:
                                TextStyle(color: Colors.white.withOpacity(0.7))),
                      ),
                      Expanded(
                          child: Divider(color: Colors.white.withOpacity(0.3))),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isRegister ? 'Kayıt Ol' : 'Giriş Yap',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: LifeRadarColors.navy,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_isRegister) ...[
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _firstName,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                    labelText: 'Ad',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _lastName,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                    labelText: 'Soyad',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _gender.isEmpty ? null : _gender,
                            decoration: const InputDecoration(
                              labelText: 'Cinsiyet',
                              prefixIcon: Icon(Icons.wc_outlined),
                              border: OutlineInputBorder(),
                            ),
                            items: const ['Kadın', 'Erkek']
                                .map((g) =>
                                    DropdownMenuItem(value: g, child: Text(g)))
                                .toList(),
                            onChanged: (v) => setState(() => _gender = v ?? ''),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _language,
                            decoration: const InputDecoration(
                              labelText: 'Haber Dili',
                              prefixIcon: Icon(Icons.translate_outlined),
                              border: OutlineInputBorder(),
                              helperText:
                                  'Yabancı kaynaklı haberler bu dile çevrilir',
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'tr', child: Text('Türkçe')),
                              DropdownMenuItem(
                                  value: 'en', child: Text('English')),
                            ],
                            onChanged: (v) =>
                                setState(() => _language = v ?? 'tr'),
                          ),
                          const SizedBox(height: 16),
                          // ---- Kısa tanışma anketi (isteğe bağlı) ----
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Seni daha iyi tanıyalım (isteğe bağlı)',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: LifeRadarColors.navy,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Bu bilgiler analizleri sana göre kişiselleştirir; '
                              'istemezsen boş bırakabilirsin.',
                              style: TextStyle(
                                color: LifeRadarColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _ageRange.isEmpty ? null : _ageRange,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Yaş aralığı',
                              prefixIcon: Icon(Icons.cake_outlined),
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              '18-24',
                              '25-34',
                              '35-44',
                              '45-54',
                              '55-64',
                              '65+',
                            ]
                                .map((g) => DropdownMenuItem(
                                    value: g, child: Text(g)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _ageRange = v ?? ''),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _household.isEmpty ? null : _household,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Yaşam durumu',
                              prefixIcon: Icon(Icons.home_outlined),
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              'Yalnız yaşıyorum',
                              'Eşimle',
                              'Çocuklu aile',
                              'Ebeveynlerimle',
                              'Ev arkadaşıyla',
                            ]
                                .map((g) => DropdownMenuItem(
                                    value: g, child: Text(g)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _household = v ?? ''),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _health.isEmpty ? null : _health,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Sağlık durumu',
                              prefixIcon:
                                  Icon(Icons.health_and_safety_outlined),
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              'Belirgin bir sağlık sorunum yok',
                              'Kronik hastalığım var',
                              'Bağışıklığım düşük',
                              'Hamile / yeni doğum',
                              '65 yaş üstü bakım',
                            ]
                                .map((g) => DropdownMenuItem(
                                    value: g, child: Text(g)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _health = v ?? ''),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _finance.isEmpty ? null : _finance,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Finansal hassasiyet',
                              prefixIcon: Icon(Icons.savings_outlined),
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              'Döviz/altın takip ederim',
                              'Kira öderim',
                              'Kredi/borç ödemem var',
                              'Sabit gelirli/emekli',
                              'Yatırımcıyım',
                            ]
                                .map((g) => DropdownMenuItem(
                                    value: g, child: Text(g)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _finance = v ?? ''),
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'E-posta',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _password,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            labelText: 'Şifre',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: LifeRadarColors.riskHigh.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: LifeRadarColors.riskHigh, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(_error!,
                                      style: const TextStyle(
                                          color: LifeRadarColors.riskHigh,
                                          fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : Text(_isRegister ? 'Kayıt Ol' : 'Giriş Yap'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () => setState(() {
                                    _isRegister = !_isRegister;
                                    _error = null;
                                  }),
                          child: Text(_isRegister
                              ? 'Zaten hesabın var mı? Giriş yap'
                              : 'Hesabın yok mu? Kayıt ol'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.read<AppState>().continueAsGuest(),
                    child: Text(
                      'Misafir olarak devam et',
                      style: TextStyle(color: Colors.white.withOpacity(0.85)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
