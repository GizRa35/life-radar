import 'package:flutter/material.dart';

/// Life Radar tasarım dili.
///
/// Genel stil: modern, premium, güven veren, resmi kurum hissi,
/// Apple kalitesinde minimal arayüz, sade ikonlar, yüksek okunabilirlik.
class LifeRadarColors {
  LifeRadarColors._();

  // Ana renk — Koyu Lacivert (menü, başlıklar, navigasyon)
  static const Color navy = Color(0xFF0A2342);

  // İkincil renk — Turkuaz (butonlar, vurgular, AI cevapları, grafikler)
  static const Color turquoise = Color(0xFF00B8D9);

  // Zeminler
  static const Color background = Color(0xFFFFFFFF); // Beyaz
  static const Color cardBackground = Color(0xFFF5F7FA); // Açık gri

  // Risk seviyeleri
  static const Color riskLow = Color(0xFF34C759); // Yeşil
  static const Color riskMedium = Color(0xFFFFB800); // Sarı
  static const Color riskHigh = Color(0xFFFF453A); // Kırmızı

  // Metin
  static const Color textPrimary = Color(0xFF0A2342);
  static const Color textSecondary = Color(0xFF5B6B7E);
}

/// Aciliyet/risk seviyeleri ve karşılık gelen renkler.
enum RiskLevel { low, medium, high, critical }

extension RiskLevelColor on RiskLevel {
  Color get color {
    switch (this) {
      case RiskLevel.low:
        return LifeRadarColors.riskLow;
      case RiskLevel.medium:
        return LifeRadarColors.riskMedium;
      case RiskLevel.high:
      case RiskLevel.critical:
        return LifeRadarColors.riskHigh;
    }
  }

  String get label {
    switch (this) {
      case RiskLevel.low:
        return 'Düşük Risk';
      case RiskLevel.medium:
        return 'Orta Risk';
      case RiskLevel.high:
        return 'Yüksek Risk';
      case RiskLevel.critical:
        return 'Kritik Risk';
    }
  }
}

class LifeRadarTheme {
  LifeRadarTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: LifeRadarColors.background,
      colorScheme: const ColorScheme.light(
        primary: LifeRadarColors.navy,
        secondary: LifeRadarColors.turquoise,
        surface: LifeRadarColors.background,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: LifeRadarColors.textPrimary,
      ),
      fontFamily: 'SF Pro Text',
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: LifeRadarColors.background,
        foregroundColor: LifeRadarColors.navy,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: LifeRadarColors.navy,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardTheme(
        color: LifeRadarColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LifeRadarColors.turquoise,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: LifeRadarColors.navy,
        selectedItemColor: LifeRadarColors.turquoise,
        unselectedItemColor: Color(0xFF8DA0B8),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: LifeRadarColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: LifeRadarColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        // Metin kutusu (TextField) yazısı bunu kullanır → koyu renk garanti.
        bodyLarge: TextStyle(color: LifeRadarColors.textPrimary),
        bodyMedium: TextStyle(color: LifeRadarColors.textSecondary),
      ),
      // Metin girişi: yazı koyu, etiket/ipucu gri, imleç turkuaz.
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(color: LifeRadarColors.textSecondary),
        hintStyle: TextStyle(color: LifeRadarColors.textSecondary),
        floatingLabelStyle: TextStyle(color: LifeRadarColors.turquoise),
        prefixIconColor: LifeRadarColors.textSecondary,
        suffixIconColor: LifeRadarColors.textSecondary,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: LifeRadarColors.turquoise,
        selectionColor: Color(0x3300B8D9),
        selectionHandleColor: LifeRadarColors.turquoise,
      ),
    );
  }
}
