import 'dart:html' as html;

/// Raporu temiz bir HTML sayfası olarak yeni sekmede açar ve yazdırma
/// (PDF olarak kaydet) penceresini tetikler.
void openHtmlReport(String title, String body) {
  final escaped = body
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
  final page = '''
<!DOCTYPE html><html lang="tr"><head><meta charset="utf-8">
<title>$title</title>
<style>
  body { font-family: -apple-system, Segoe UI, Roboto, sans-serif; max-width: 760px;
         margin: 40px auto; padding: 0 24px; color: #0A2342; line-height: 1.6; }
  h1 { color: #0A2342; border-bottom: 3px solid #00B8D9; padding-bottom: 8px; }
  .meta { color: #5B6B7E; font-size: 13px; margin-bottom: 24px; }
  pre { white-space: pre-wrap; font-family: inherit; font-size: 15px; }
  .brand { color: #00B8D9; font-weight: 800; }
</style></head><body>
<h1>$title</h1>
<div class="meta"><span class="brand">Life Radar</span> · ${DateTime.now().toString().split('.').first}</div>
<pre>$escaped</pre>
<script>setTimeout(function(){ window.print(); }, 400);</script>
</body></html>''';
  final blob = html.Blob([page], 'text/html');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.window.open(url, '_blank');
}

/// Metni dosya olarak indirir (ör. gizlilik verisi JSON'u).
void downloadFile(String filename, String content, String mime) {
  final blob = html.Blob([content], mime);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}
