import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
        appBar: AppBar(title: const Text('Hesap Yönetimi')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.account_circle_outlined,
                    size: 64, color: LifeRadarColors.textSecondary),
                SizedBox(height: 16),
                Text(
                  'Hesap yönetimi için e-posta ile giriş yapmalısın. '
                  'Misafir kullanıcıların verileri yalnızca bu cihazda tutulur.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: LifeRadarColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Hesap Yönetimi')),
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
          const _SectionLabel('E-posta Doğrulama', Icons.mark_email_read_outlined),
          _VerifyCard(info: _info),
          const SizedBox(height: 8),

          // 3) Şifre yönetimi (yalnızca e-posta/şifre hesapları)
          const _SectionLabel('Şifre', Icons.password_outlined),
          if (_info?.isGoogle == true && _info?.isPassword != true)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: LifeRadarColors.turquoise),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Google ile giriş yaptığın için şifre yönetimi Google '
                        'hesabından yapılır.',
                        style: TextStyle(fontSize: 13),
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
          const _SectionLabel('Tehlikeli Bölge', Icons.dangerous_outlined),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: LifeRadarColors.navy),
              title: const Text('Çıkış yap',
                  style: TextStyle(fontWeight: FontWeight.w600)),
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
              title: const Text('Hesabı kalıcı olarak sil',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: LifeRadarColors.riskHigh)),
              subtitle: const Text(
                  'Hesabın ve tüm yerel verilerin silinir. Geri alınamaz.'),
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
        title: const Text('Hesabı sil'),
        content: const Text(
            'Hesabın Firebase\'den kalıcı olarak silinecek ve bu cihazdaki tüm '
            'verilerin temizlenecek. Bu işlem geri alınamaz. Devam edilsin mi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            style:
                TextButton.styleFrom(foregroundColor: LifeRadarColors.riskHigh),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hesabı Sil'),
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
        const SnackBar(content: Text('Hesap silindi.')),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Silinemedi'),
          content: Text(err.contains('tekrar giriş')
              ? '$err\n\nÇıkış yapıp yeniden giriş yaptıktan sonra tekrar dene.'
              : err),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tamam')),
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

  String _tierLabel(SubscriptionTier t) {
    switch (t) {
      case SubscriptionTier.vip:
        return 'VIP';
      case SubscriptionTier.premium:
        return 'Premium';
      case SubscriptionTier.free:
        return 'Ücretsiz';
    }
  }

  String _fmt(DateTime? d) =>
      d == null ? '—' : DateFormat('d MMM yyyy', 'tr').format(d);

  @override
  Widget build(BuildContext context) {
    final method = info?.isGoogle == true
        ? 'Google'
        : (info?.isPassword == true ? 'E-posta / Şifre' : '—');
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
                  tooltip: 'Yenile',
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const Divider(height: 24),
            if (loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 10),
                    Text('Hesap bilgileri yükleniyor...',
                        style: TextStyle(color: LifeRadarColors.textSecondary)),
                  ],
                ),
              )
            else ...[
              _row(Icons.workspace_premium_outlined, 'Abonelik',
                  _tierLabel(state.tier)),
              _row(Icons.login, 'Giriş yöntemi', method),
              _row(
                  info?.emailVerified == true
                      ? Icons.verified
                      : Icons.error_outline,
                  'E-posta doğrulama',
                  info?.emailVerified == true ? 'Doğrulandı' : 'Doğrulanmadı'),
              _row(Icons.calendar_today_outlined, 'Hesap oluşturma',
                  _fmt(info?.createdAt)),
              _row(Icons.access_time, 'Son giriş', _fmt(info?.lastLoginAt)),
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
        child: const ListTile(
          leading: Icon(Icons.verified, color: LifeRadarColors.riskLow),
          title: Text('E-posta adresin doğrulanmış',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'E-posta adresin henüz doğrulanmadı. Doğrulama bağlantısını '
                'gönderip e-postandaki linke tıklayabilirsin.',
                style: TextStyle(fontSize: 13)),
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
                                  ? 'Doğrulama e-postası gönderildi. Gelen kutunu kontrol et.'
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
                label: const Text('Doğrulama e-postası gönder'),
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
      _snack('Şifre en az 6 karakter olmalı.');
      return;
    }
    if (p1 != p2) {
      _snack('Şifreler eşleşmiyor.');
      return;
    }
    setState(() => _saving = true);
    final err = await context.read<AppState>().changePassword(p1);
    if (!mounted) return;
    setState(() => _saving = false);
    if (err == null) {
      _pw1.clear();
      _pw2.clear();
      _snack('Şifren güncellendi.');
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
            const Text('Yeni şifre belirle',
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: LifeRadarColors.navy)),
            const SizedBox(height: 12),
            TextField(
              controller: _pw1,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Yeni şifre',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
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
              decoration: const InputDecoration(
                labelText: 'Yeni şifre (tekrar)',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
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
              label: const Text('Şifreyi değiştir'),
            ),
            const Divider(height: 28),
            const Text('Şifreni mi unuttun?',
                style: TextStyle(color: LifeRadarColors.textSecondary)),
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
                          ? 'Şifre sıfırlama e-postası gönderildi.'
                          : err);
                    },
              icon: const Icon(Icons.mail_outline, size: 18),
              label: const Text('Şifre sıfırlama e-postası gönder'),
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
