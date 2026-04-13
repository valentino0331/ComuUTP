import 'package:flutter/material.dart';

class AppTheme {
  // Colores principales - UTP oficial
  static const Color colorPrimary = Color(0xFFC8102E);        // Rojo UTP principal
  static const Color colorPrimaryDark = Color(0xFFA00D24);    // Rojo oscuro (hover)
  static const Color colorPrimaryLight = Color(0xFFE8142F);   // Rojo vibrante
  static const Color colorAccent = Color(0xFFC8102E);         // Links rojos

  // Fondos
  static const Color colorBg = Color(0xFFF5F5F5);             // Gris claro
  static const Color colorSurface = Color(0xFFFFFFFF);        // Cards y modales
  static const Color colorSplashBg = Color(0xFFC8102E);       // Fondo rojo splash

  // Texto
  static const Color colorTextPrimary = Color(0xFF1A1A1A);    // Títulos
  static const Color colorTextSecondary = Color(0xFF666666);  // Subtítulos
  static const Color colorTextLink = Color(0xFFC8102E);       // Links en rojo
  static const Color colorTextWhite = Color(0xFFFFFFFF);      // Sobre fondo rojo
  static const Color colorTextHint = Color(0xFF999999);       // Placeholder inputs

  // Bordes e inputs
  static const Color colorBorder = Color(0xFFE0E0E0);
  static const Color colorInputBg = Color(0xFFFFFFFF);
  static const Color colorInputBorder = Color(0xFFCCCCCC);
  static const Color colorInputBorderFocus = Color(0xFFC8102E);

  // Íconos de comunidades
  static const Color colorIconSistemas = Color(0xFFC8102E);   // Rojo
  static const Color colorIconFutbol = Color(0xFF1A3A6B);     // Azul marino
  static const Color colorIconHacks = Color(0xFF2E9E6B);      // Verde
  static const Color colorIconArequipa = Color(0xFFE53935);   // Rojo claro

  // Sombras
  static const BoxShadow shadowCard = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.08),
    blurRadius: 8,
    offset: Offset(0, 2),
  );
  static const BoxShadow shadowBottomNav = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.1),
    blurRadius: 4,
    offset: Offset(0, -1),
  );

  // Tipografía - Roboto
  static const String fontFamily = 'Roboto';
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

  // Bordes redondeados standard (keep for compatibility)
  static const double borderRadiusStandard = 12.0;
  static const double borderRadiusButton = 50.0;

  /// Tema Claro (Día) - UTP Design System
  static ThemeData temaClaro() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: colorPrimary,
      scaffoldBackgroundColor: colorBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: colorSurface,
        foregroundColor: colorTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colorTextPrimary,
          fontSize: fontSizeMd,
          fontWeight: FontWeight.w500,
          fontFamily: fontFamily,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorPrimary,
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
          side: const BorderSide(color: colorPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPill),
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
          borderSide: const BorderSide(color: colorInputBorderFocus, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: Colors.red),
        ),
        hintStyle: const TextStyle(color: colorTextHint, fontFamily: fontFamily),
        labelStyle: const TextStyle(color: colorTextPrimary, fontFamily: fontFamily),
      ),
      cardTheme: CardThemeData(
        color: colorSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        shadowColor: Colors.black.withOpacity(0.08),
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
        color: colorTextPrimary,
        size: 24,
      ),
    );
  }

  // Sombra personalizada UTP
  static BoxShadow sombraUTP() {
    return const BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.08),
      blurRadius: 8,
      offset: Offset(0, 2),
    );
  }
}
