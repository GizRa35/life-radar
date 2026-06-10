import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/i18n.dart';
import '../core/theme.dart';
import '../models/subscription.dart';
import '../services/auth_service.dart';
import '../state/app_state.dart';

/// Hesap Yönetimi — hesap bilgileri, şifre, e-posta doğrulama, hesap silme.
class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  AccountInfo? _info;
  bool _loadingInfo = true;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    final info = await context.read<AppState>().fetchAccountInfo();
    if (!mounted) return;
    setState(() {
      _info = info;
      _loadingInfo = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (!state.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: Text(t('Hesap Yönetimi'))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_circle_outlined,
                    size: 64, color: LifeRadarColors.textSecondary),
                const SizedBox(height: 16),
                Text(
                  t('Hesap yönetimi için e-posta ile giriş yapmalısın. Misafir kullanıcıların verileri yalnızca bu cihazda tutulur.'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: LifeRadarColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(t('Hesap Yönetimi'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1) Hesap bilgileri
          _InfoCard(
            state: state,
            info: _info,
            loading: _loadingInfo,
            onRefresh: () {
              setState(() => _loadingInfo = true);
              _loadInfo();
            },
          ),
          const SizedBox(height: 8),

          // 2) E-posta doğrulama
          _SectionLabel(t('E-posta Doğrulama'), Icons.mark_email_read_outlined),
          _VerifyCard(info: _info),
          const SizedBox(height: 8),

          // 3) Şifre yönetimi (yalnızca e-posta/şifre hesapları)
          _SectionLabel(t('Şifre'), Icons.password_outlined),
          if (_info?.isGoogle == true && _info?.isPassword != true)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: LifeRadarColors.turquoise),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        t('Google ile giriş yaptığın için şifre yönetimi Google hesabından yapılır.'),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            const _PasswordCard(),
          const SizedBox(height: 8),

          // 4) Tehlikeli bölge
          _SectionLabel(t('Tehlikeli Bölge'), Icons.dangerous_outlined),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: LifeRadarColors.navy),
              title: Text(t('Çıkış yap'),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                state.logout();
                Navigator.of(context).pop();
              },
            ),
          ),
          Card(
            color: LifeRadarColors.riskHigh.withOpacity(0.06),
            child: ListTile(
              leading: const Icon(Icons.delete_forever,
                  color: LifeRadarColors.riskHigh),
              title: Text(t('Hesabı kalıcı olarak sil'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: LifeRadarColors.riskHigh)),
              subtitle: Text(
                  t('Hesabın ve tüm yerel verilerin silinir. Geri alınamaz.')),
              onTap: () => _confirmDelete(context),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t('Hesabı sil')),
        content: Text(t(
            'Hesabın Firebase\'den kalıcı olarak silinecek ve bu cihazdaki tüm verilerin temizlenecek. Bu işlem geri alınamaz. Devam edilsin mi?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t('Vazgeç')),
          ),
          TextButton(
            style:
                TextButton.styleFrom(foregroundColor: LifeRadarColors.riskHigh),
            onPressed: () => Navigator.pop(context, true),
            child: Text(t('Hesabı Sil')),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final err = await context.read<AppState>().deleteAccount();
    if (!context.mounted) return;
    if (err == null) {
      Navigator.of(context).popUntil((r) => r.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('Hesap silindi.'))),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(t('Silinemedi')),
          content: Text(err.contains('tekrar giriş')
              ? '$err\n\nÇıkış yapıp yeniden giriş yaptıktan sonra tekrar dene.'
              : err),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(t('Tamam'))),
          ],
        ),
      );
    }
  }
}

class _InfoCard extends StatelessWidget {
  final AppState state;
  final AccountInfo? info;
  final bool loading;
  final VoidCallback onRefresh;
  const _InfoCard({
    required this.state,
    required this.info,
    required this.loading,
    required this.onRefresh,
  });

  String _tierLabel(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.vip:
        return 'VIP';
      case SubscriptionTier.premium:
        return 'Premium';
      case SubscriptionTier.free:
        return t('Ücretsiz');
    }
  }

  String _fmt(DateTime? d) =>
      d == null ? '—' : DateFormat('d MMM yyyy', i18nLang).format(d);

  @override
  Widget build(BuildContext context) {
    final method = info?.isGoogle == true
        ? 'Google'
        : (info?.isPassword == true ? t('E-posta / Şifre') : '—');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: LifeRadarColors.turquoise,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.displayName,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: LifeRadarColors.navy)),
                      Text(state.authEmail ?? '—',
                          style: const TextStyle(
                              color: LifeRadarColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: t('Yenile'),
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const Divider(height: 24),
            if (loading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    const SizedBox(width: 10),
                    Text(t('Hesap bilgileri yükleniyor...'),
                        style: const TextStyle(
                            color: LifeRadarColors.textSecondary)),
                  ],
                ),
              )
            else ...[
              _row(Icons.workspace_premium_outlined, t('Abonelik'),
                  _tierLabel(state.tier)),
              _row(Icons.login, t('Giriş yöntemi'), method),
              _row(
                  info?.emailVerified == true
                      ? Icons.verified
                      : Icons.error_outline,
                  t('E-posta doğrulama'),
                  info?.emailVerified == true
                      ? t('Doğrulandı')
                      : t('Doğrulanmadı')),
              _row(Icons.calendar_today_outlined, t('Hesap oluşturma'),
                  _fmt(info?.createdAt)),
              _row(Icons.access_time, t('Son giriş'), _fmt(info?.lastLoginAt)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: LifeRadarColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
              child: Text(label,
                  style: const TextStyle(color: LifeRadarColors.navy))),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: LifeRadarColors.navy)),
        ],
      ),
    );
  }
}

class _VerifyCard extends StatefulWidget {
  final AccountInfo? info;
  const _VerifyCard({required this.info});

  @override
  State<_VerifyCard> createState() => _VerifyCardState();
}

class _VerifyCardState extends State<_VerifyCard> {
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    final verified = widget.info?.emailVerified == true;
    if (verified) {
      return Card(
        color: LifeRadarColors.riskLow.withOpacity(0.10),
        child: ListTile(
          leading: const Icon(Icons.verified, color: LifeRadarColors.riskLow),
          title: Text(t('E-posta adresin doğrulanmış'),
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                t('E-posta adresin henüz doğrulanmadı. Doğrulama bağlantısını gönderip e-postandaki linke tıklayabilirsin.'),
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sending
                    ? null
                    : () async {
                        setState(() => _sending = true);
                        final err =
                            await context.read<AppState>().sendVerifyEmail();
                        if (!mounted) return;
                        setState(() => _sending = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(err == null
                                  ? t('Doğrulama e-postası gönderildi. Gelen kutunu kontrol et.')
                                  : err)),
                        );
                      },
                icon: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_outlined, size: 18),
                label: Text(t('Doğrulama e-postası gönder')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordCard extends StatefulWidget {
  const _PasswordCard();

  @override
  State<_PasswordCard> createState() => _PasswordCardState();
}

class _PasswordCardState extends State<_PasswordCard> {
  final _pw1 = TextEditingController();
  final _pw2 = TextEditingController();
  bool _obscure = true;
  bool _saving = false;
  bool _sendingReset = false;

  @override
  void dispose() {
    _pw1.dispose();
    _pw2.dispose();
    super.dispose();
  }

  Future<void> _change() async {
    final p1 = _pw1.text;
    final p2 = _pw2.text;
    if (p1.length < 6) {
      _snack(t('Şifre en az 6 karakter olmalı.'));
      return;
    }
    if (p1 != p2) {
      _snack(t('Şifreler eşleşmiyor.'));
      return;
    }
    setState(() => _saving = true);
    final err = await context.read<AppState>().changePassword(p1);
    if (!mounted) return;
    setState(() => _saving = false);
    if (err == null) {
      _pw1.clear();
      _pw2.clear();
      _snack(t('Şifren güncellendi.'));
    } else {
      _snack(err);
    }
  }

  void _snack(String m) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t('Yeni şifre belirle'),
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: LifeRadarColors.navy)),
            const SizedBox(height: 12),
            TextField(
              controller: _pw1,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: t('Yeni şifre'),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pw2,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: t('Yeni şifre (tekrar)'),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _saving ? null : _change,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check),
              label: Text(t('Şifreyi değiştir')),
            ),
            const Divider(height: 28),
            Text(t('Şifreni mi unuttun?'),
                style: const TextStyle(color: LifeRadarColors.textSecondary)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _sendingReset
                  ? null
                  : () async {
                      setState(() => _sendingReset = true);
                      final err =
                          await context.read<AppState>().sendPasswordReset();
                      if (!mounted) return;
                      setState(() => _sendingReset = false);
                      _snack(err == null
                          ? t('Şifre sıfırlama e-postası gönderildi.')
                          : err);
                    },
              icon: const Icon(Icons.mail_outline, size: 18),
              label: Text(t('Şifre sıfırlama e-postası gönder')),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final IconData icon;
  const _SectionLabel(this.text, this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: LifeRadarColors.navy),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: LifeRadarColors.navy)),
        ],
      ),
    );
  }
}
