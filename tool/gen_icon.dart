import 'dart:io';
import 'package:image/image.dart' as img;

/// Life Radar uygulama ikonu üretir (1024x1024 PNG).
/// Lacivert zemin + turkuaz radar halkaları + nişangah + merkez + blipler.
/// Çalıştır:  dart run tool/gen_icon.dart
void main() {
  const size = 1024;
  final image = img.Image(width: size, height: size, numChannels: 3);

  final navy = img.ColorRgb8(10, 35, 66); // #0A2342
  final turq = img.ColorRgb8(0, 184, 217); // #00B8D9
  final turqDim = img.ColorRgb8(26, 86, 110);

  // Zemin
  img.fill(image, color: navy);

  final cx = size ~/ 2;
  final cy = size ~/ 2;

  // Nişangah (sönük) — halkaların altında
  img.drawLine(image,
      x1: cx - 400, y1: cy, x2: cx + 400, y2: cy, color: turqDim, thickness: 5);
  img.drawLine(image,
      x1: cx, y1: cy - 400, x2: cx, y2: cy + 400, color: turqDim, thickness: 5);

  // Radar halkaları (kalınlık için iç içe daireler)
  for (final r in [380, 280, 180]) {
    for (var t = 0; t < 11; t++) {
      img.drawCircle(image, x: cx, y: cy, radius: r - t, color: turq);
    }
  }

  // Radar süpürme kolu (merkezden dışa, parlak çizgi)
  img.drawLine(image,
      x1: cx, y1: cy, x2: cx + 270, y2: cy - 270, color: turq, thickness: 10);

  // Blipler (radar üzerindeki noktalar)
  img.fillCircle(image, x: cx + 190, y: cy - 130, radius: 24, color: turq);
  img.fillCircle(image, x: cx - 160, y: cy + 220, radius: 20, color: turq);
  img.fillCircle(image, x: cx + 60, y: cy + 300, radius: 16, color: turq);

  // Merkez nokta
  img.fillCircle(image, x: cx, y: cy, radius: 34, color: turq);
  img.fillCircle(image, x: cx, y: cy, radius: 16, color: navy);

  final out = File('assets/icon/icon.png');
  out.parent.createSync(recursive: true);
  out.writeAsBytesSync(img.encodePng(image));
  stdout.writeln('Ikon yazildi: ${out.path} (${size}x$size)');
}
