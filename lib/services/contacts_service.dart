import 'package:flutter_contacts/flutter_contacts.dart';

/// Telefon rehberinden kişi seçtirir (sistem seçicisi).
/// Dönüş: (name, phone) — iptal/telefonsuz kişi seçilirse null.
Future<({String name, String phone})?> pickPhoneContact() async {
  try {
    final picked = await FlutterContacts.openExternalPick();
    if (picked == null) return null;

    var contact = picked;
    // Bazı platformlarda picker yalnızca id+ad döndürür; telefonu almak için
    // (izin varsa) tam kaydı çek.
    if (contact.phones.isEmpty) {
      if (await FlutterContacts.requestPermission(readonly: true)) {
        final full =
            await FlutterContacts.getContact(picked.id, withProperties: true);
        if (full != null) contact = full;
      }
    }

    final phone =
        contact.phones.isNotEmpty ? contact.phones.first.number.trim() : '';
    final name = contact.displayName.trim();
    if (phone.isEmpty) return null;
    return (name: name, phone: phone);
  } catch (_) {
    return null;
  }
}
