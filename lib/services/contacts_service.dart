import 'package:flutter_contacts/flutter_contacts.dart';

/// Telefon rehberinden kişi seçtirir (sistem seçicisi).
/// Dönüş: (name, phone) — iptal/telefonsuz kişi seçilirse null.
Future<({String name, String phone})?> pickPhoneContact() async {
  try {
    // İzni ÖNCE iste — böylece seçiciden dönen kişinin tam kaydını (telefon
    // dahil) okuyabiliriz. Bazı Android sürümlerinde seçici yalnızca id+ad
    // döndürür; telefon ancak izinle getContact ile alınır.
    await FlutterContacts.requestPermission(readonly: true);

    final picked = await FlutterContacts.openExternalPick();
    if (picked == null) return null;

    var contact = picked;
    if (contact.phones.isEmpty) {
      final full =
          await FlutterContacts.getContact(picked.id, withProperties: true);
      if (full != null) contact = full;
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
