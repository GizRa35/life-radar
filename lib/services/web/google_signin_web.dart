import 'dart:html' as html;
import 'dart:js_util' as jsutil;

/// index.html'deki lifeRadarGoogleSignIn() fonksiyonunu çağırır;
/// Google popup'ından access_token döner (iptal/başarısızlıkta null).
Future<String?> googleAccessToken() async {
  try {
    final promise = jsutil.callMethod(html.window, 'lifeRadarGoogleSignIn', []);
    final token = await jsutil.promiseToFuture<dynamic>(promise);
    return token?.toString();
  } catch (_) {
    return null;
  }
}
