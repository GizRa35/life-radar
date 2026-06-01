import 'package:flutter/material.dart';

/// Acil Durum Rehberi (Sayfa 8) kategori kartları.
class EmergencyGuide {
  final String title;
  final IconData icon;

  /// Hazırlık Listesi
  final List<String> preparation;

  /// İlk 24 Saat
  final List<String> first24Hours;

  /// Gerekli Malzemeler
  final List<String> supplies;

  /// İlk Yardım Bilgileri
  final List<String> firstAid;

  const EmergencyGuide({
    required this.title,
    required this.icon,
    required this.preparation,
    required this.first24Hours,
    required this.supplies,
    required this.firstAid,
  });
}
