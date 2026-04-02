import 'package:flutter/material.dart';

class AppTheme {
  // Colores UTP
  static const Color colorRojoUTP = Color(0xFFED1C24);
  static const Color colorRojoOscuro = Color(0xFFb3151b);
  static const Color colorBlancoFondo = Color(0xFFFFFFFF);
  static const Color colorGrisClaro = Color(0xFFF5F5F5);
  static const Color colorGris = Color(0xFF9E9E9E);
  static const Color colorGrisOscuro = Color(0xFF757575);
  static const Color colorNegro = Color(0xFF212121);

  // BorderRadius estándar
  static const double borderRadiusEstándar = 16.0;
  static const double borderRadiusBoton = 30.0;

  /// Tema Oscuro (Día)
  static ThemeData temaClaro() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: colorRojoUTP,
      scaffoldBackgroundColor: colorBlancoFondo,
      appBarTheme: const AppBarTheme(
        backgroundColor: colorRojoUTP,
        foregroundColor: colorBlancoFondo,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: colorBlancoFondo,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorRojoUTP,
          foregroundColor: colorBlancoFondo,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusBoton),
          ),
          elevation: 4,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorRojoUTP,
          side: const BorderSide(color: colorRojoUTP, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusBoton),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorGrisClaro,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: colorRojoUTP, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        hintStyle: const TextStyle(color: colorGris),
        labelStyle: const TextStyle(color: colorNegro),
      ),
      cardTheme: CardTheme(
        color: colorBlancoFondo,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusEstándar),
        ),
        shadowColor: Colors.black.withOpacity(0.08),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: colorNegro,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: colorNegro,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colorNegro,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: colorNegro,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: colorGrisOscuro,
        ),
      ),
      iconTheme: const IconThemeData(
        color: colorRojoUTP,
        size: 24,
      ),
    );
  }

  // Sombra personalizada UTP
  static BoxShadow sombraUTP() {
    return BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    );
  }
}
