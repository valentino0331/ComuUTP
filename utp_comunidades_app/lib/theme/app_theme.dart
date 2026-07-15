import 'package:flutter/material.dart';

class AppTheme {
  // ===== COLORES PRINCIPALES (Sin Rojo) =====
  // Principal: Deep Indigo (profesional, académico, gaming)
  static const Color colorPrimary = Color(0xFF1F3A93);        // Indigo profundo
  static const Color colorPrimaryDark = Color(0xFF0D1F61);    // Indigo oscuro
  static const Color colorPrimaryLight = Color(0xFF3F51B5);   // Indigo claro
  
  // Secundario: Cyan Vibrante (energético, gaming)
  static const Color colorSecondary = Color(0xFF00BCD4);      // Cyan principal
  static const Color colorSecondaryDark = Color(0xFF0097A7);  // Cyan oscuro
  
  // Accent: Amber Premium (destacar, premium)
  static const Color colorAccent = Color(0xFFFF9800);         // Amber
  static const Color colorAccentLight = Color(0xFFFFB74D);    // Amber claro
  
  // Estados
  static const Color colorSuccess = Color(0xFF4CAF50);        // Verde
  static const Color colorError = Color(0xFFE53935);          // Rojo (solo errores)
  static const Color colorWarning = Color(0xFFFFA000);        // Naranja
  
  // Fondos
  static const Color colorBg = Color(0xFFF5F7FA);             // Gris muy claro
  static const Color colorSurface = Color(0xFFFFFFFF);        // Blanco puro
  static const Color colorGradientStart = Color(0xFF1F3A93);  // Para gradientes

  // Texto
  static const Color colorTextPrimary = Color(0xFF1A1A1A);    // Títulos oscuros
  static const Color colorTextSecondary = Color(0xFF666666);  // Subtítulos
  static const Color colorTextLink = Color(0xFF00BCD4);       // Links en cyan
  static const Color colorTextWhite = Color(0xFFFFFFFF);      // Sobre fondos oscuros
  static const Color colorTextHint = Color(0xFF999999);       // Placeholder

  // Bordes e inputs
  static const Color colorBorder = Color(0xFFE0E0E0);
  static const Color colorInputBg = Color(0xFFFFFFFF);
  static const Color colorInputBorder = Color(0xFFCCCCCC);
  static const Color colorInputBorderFocus = Color(0xFF00BCD4);

  // Íconos de comunidades (colores variados, sin rojo)
  static const Color colorIconSistemas = Color(0xFF1F3A93);   // Indigo
  static const Color colorIconFutbol = Color(0xFF00BCD4);     // Cyan
  static const Color colorIconHacks = Color(0xFF4CAF50);      // Verde
  static const Color colorIconArequipa = Color(0xFFFF9800);   // Amber

  // Sombras Premium (Glassmorphism / Soft UI)
  static const BoxShadow shadowCard = BoxShadow(
    color: Color.fromRGBO(31, 58, 147, 0.08),
    blurRadius: 16,
    spreadRadius: 2,
    offset: Offset(0, 4),
  );
  static const BoxShadow shadowBottomNav = BoxShadow(
    color: Color.fromRGBO(31, 58, 147, 0.12),
    blurRadius: 20,
    offset: Offset(0, -4),
  );
  
  // Gradientes
  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [colorPrimary, colorPrimaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient gradientPrimaryToCyan = LinearGradient(
    colors: [colorPrimary, colorSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient gradientCyanVibrant = LinearGradient(
    colors: [colorSecondary, Color(0xFF00ACC1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient gradientAccent = LinearGradient(
    colors: [colorAccent, colorAccentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Tipografía - Montserrat (Premium UI)
  static const String fontFamily = 'Montserrat';
  static const double fontSizeXs = 11.0;
  static const double fontSizeSm = 13.0;
  static const double fontSizeBase = 15.0;
  static const double fontSizeMd = 17.0;
  static const double fontSizeLg = 20.0;
  static const double fontSizeXl = 26.0;

  // Espaciado
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;

  // Bordes redondeados
  static const double radiusSm = 6.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 20.0;
  static const double radiusPill = 50.0;

  // Bordes redondeados standard
  static const double borderRadiusStandard = 12.0;
  static const double borderRadiusButton = 50.0;

  /// Tema Claro (Día) - Indigo + Cyan
  static ThemeData temaClaro() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: colorPrimary,
      scaffoldBackgroundColor: colorBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: colorPrimary,
        foregroundColor: colorTextWhite,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colorTextWhite,
          fontSize: fontSizeMd,
          fontWeight: FontWeight.w700,
          fontFamily: fontFamily,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorSecondary,
          foregroundColor: colorTextWhite,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: fontSizeBase,
            fontWeight: FontWeight.w700,
            fontFamily: fontFamily,
            letterSpacing: 1.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorPrimary,
          side: const BorderSide(color: colorSecondary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: fontSizeBase,
            fontWeight: FontWeight.w600,
            fontFamily: fontFamily,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorInputBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: spacingMd, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: colorInputBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: colorInputBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: colorSecondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: colorError, width: 2),
        ),
        hintStyle: const TextStyle(color: colorTextHint, fontFamily: fontFamily),
        labelStyle: const TextStyle(color: colorPrimary, fontFamily: fontFamily),
        prefixIconColor: colorPrimary,
        suffixIconColor: colorSecondary,
      ),
      cardTheme: CardThemeData(
        color: colorSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        shadowColor: colorPrimary.withOpacity(0.08),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: fontSizeXl,
          fontWeight: FontWeight.w700,
          color: colorTextPrimary,
          fontFamily: fontFamily,
        ),
        displayMedium: TextStyle(
          fontSize: fontSizeLg,
          fontWeight: FontWeight.w700,
          color: colorTextPrimary,
          fontFamily: fontFamily,
        ),
        headlineSmall: TextStyle(
          fontSize: fontSizeMd,
          fontWeight: FontWeight.w600,
          color: colorTextPrimary,
          fontFamily: fontFamily,
        ),
        bodyLarge: TextStyle(
          fontSize: fontSizeBase,
          color: colorTextPrimary,
          fontFamily: fontFamily,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          fontSize: fontSizeBase,
          color: colorTextSecondary,
          fontFamily: fontFamily,
        ),
        bodySmall: TextStyle(
          fontSize: fontSizeSm,
          color: colorTextSecondary,
          fontFamily: fontFamily,
        ),
      ),
      iconTheme: const IconThemeData(
        color: colorPrimary,
        size: 24,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: colorWhite,
        selectedItemColor: colorSecondary,
        unselectedItemColor: colorTextSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        backgroundColor: colorSurface,
        elevation: 8,
      ),
      colorScheme: const ColorScheme.light(
        primary: colorPrimary,
        secondary: colorSecondary,
        tertiary: colorAccent,
        surface: colorSurface,
        error: colorError,
        onPrimary: colorTextWhite,
        onSecondary: colorTextWhite,
        onSurface: colorTextPrimary,
      ),
    );
  }

  // ===== CONSTANTES ADICIONALES =====
  static const Color colorWhite = Color(0xFFFFFFFF);

  // Sombra personalizada UTP (Soft UI)
  static BoxShadow sombraUTP() {
    return const BoxShadow(
      color: Color.fromRGBO(31, 58, 147, 0.08),
      blurRadius: 16,
      spreadRadius: 2,
      offset: Offset(0, 4),
    );
  }
}
