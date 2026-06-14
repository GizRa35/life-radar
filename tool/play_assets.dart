// Google Play görselleri üretir:
//  - play-assets/icon-512.png       (512x512 uygulama ikonu)
//  - play-assets/feature-graphic.png (1024x500 feature graphic)
//
// Kullanım: dart run tool/play_assets.dart
import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final src = img.decodeImage(File('assets/icon/icon.png').readAsBytesSync());
  if (src == null) {
    stderr.writeln('assets/icon/icon.png okunamadı');
    exit(1);
  }
  Directory('play-assets').createSync(recursive: true);

  // 1) 512x512 ikon
  final icon512 = img.copyResize(src, width: 512, height: 512);
  File('play-assets/icon-512.png').writeAsBytesSync(img.encodePng(icon512));

  // 2) Feature graphic 1024x500 — lacivert yatay gradyan + ikon + başlık
  const w = 1024, h = 500;
  final fg = img.Image(width: w, height: h, numChannels: 3);
  final c1 = [10, 35, 66]; // #0A2342
  final c2 = [18, 58, 99]; // #123A63
  for (var x = 0; x < w; x++) {
    final t = x / (w - 1);
    final r = (c1[0] + (c2[0] - c1[0]) * t).round();
    final g = (c1[1] + (c2[1] - c1[1]) * t).round();
    final b = (c1[2] + (c2[2] - c1[2]) * t).round();
    for (var y = 0; y < h; y++) {
      fg.setPixelRgb(x, y, r, g, b);
    }
  }

  // İkonu sola yerleştir (yuvarlatmadan, 300px)
  final iconFg = img.copyResize(src, width: 300, height: 300);
  img.compositeImage(fg, iconFg, dstX: 80, dstY: (h - 300) ~/ 2);

  // Metin (ASCII — bitmap fontta Türkçe karakter sorunu olmasın)
  final white = img.ColorRgb8(255, 255, 255);
  final turquoise = img.ColorRgb8(0, 184, 217);
  img.drawString(fg, 'LIFE RADAR',
      font: img.arial48, x: 440, y: 190, color: white);
  img.drawString(fg, 'News & personal risk radar',
      font: img.arial24, x: 440, y: 260, color: turquoise);

  File('play-assets/feature-graphic.png').writeAsBytesSync(img.encodePng(fg));

  stdout.writeln('Bitti:');
  stdout.writeln('  play-assets/icon-512.png        (512x512)');
  stdout.writeln('  play-assets/feature-graphic.png (1024x500)');
}
