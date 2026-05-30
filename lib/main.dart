import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ekranlar/menu_ekrani.dart';

void main() {
  runApp(const NazliCicekBahcesiApp());
}

/// Uygulamanın kök widget'ı — MaterialApp buradan başlar
class NazliCicekBahcesiApp extends StatelessWidget {
  const NazliCicekBahcesiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Nazlı'nın Çiçek Bahçesi",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Sevimli pastel renk paleti
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF8BBD0),
          primary: const Color(0xFFF48FB1),
          secondary: const Color(0xFFCE93D8),
          surface: const Color(0xFFFFF8E1),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF8E1),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF48FB1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
      // İlk açılan ekran: menü
      home: const MenuEkrani(),
    );
  }
}
