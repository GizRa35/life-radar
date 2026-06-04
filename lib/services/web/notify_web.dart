import 'dart:html' as html;

Future<bool> requestNotifyPermission() async {
  try {
    if (!html.Notification.supported) return false;
    final perm = await html.Notification.requestPermission();
    return perm == 'granted';
  } catch (_) {
    return false;
  }
}

void showNotify(String title, String body) {
  try {
    if (html.Notification.supported &&
        html.Notification.permission == 'granted') {
      html.Notification(title, body: body);
    }
  } catch (_) {}
}

/// İzin durumu: 'granted' | 'denied' | 'default' | 'unsupported'.
String notifyPermission() {
  try {
    if (!html.Notification.supported) return 'unsupported';
    return html.Notification.permission ?? 'default';
  } catch (_) {
    return 'unsupported';
  }
}
