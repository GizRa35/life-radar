/// Mağaza içi puan/değerlendirme isteği.
///
/// NOT: `in_app_review` eklentisi (2.0.12) güncel Kotlin/AGP ile Android'de
/// derlenmiyor (toUri hatası), o yüzden geçici olarak devre dışı bırakıldı.
/// 1.1'de uyumlu bir sürümle yeniden eklenecek. Çağıran kod bozulmasın diye
/// fonksiyon korunur; şimdilik sessizce hiçbir şey yapmaz.
Future<void> requestStoreReview() async {
  // Geçici olarak devre dışı (eklenti uyumsuzluğu). 1.1'de geri gelecek.
  return;
}
