import 'dart:html' as html;

/// Web: tarayıcı localStorage (oturum kalıcı). Senkron olduğu için init gereksiz.
Future<void> lsInit() async {}
String? lsGet(String key) => html.window.localStorage[key];
void lsSet(String key, String value) => html.window.localStorage[key] = value;
void lsRemove(String key) => html.window.localStorage.remove(key);
