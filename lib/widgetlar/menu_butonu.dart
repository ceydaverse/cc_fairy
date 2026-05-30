import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Menü ve sonuç ekranlarında kullanılan sevimli ortak buton
class MenuButonu extends StatelessWidget {
  const MenuButonu({
    super.key,
    required this.yazi,
    required this.onBas,
    this.anaButon = true,
    this.genislik = 220,
  });

  // Buton üzerindeki yazı
  final String yazi;

  // Butona basılınca çalışacak fonksiyon
  final VoidCallback onBas;

  // true: dolu renkli buton, false: çerçeveli buton
  final bool anaButon;

  final double genislik;

  @override
  Widget build(BuildContext context) {
    final butonStili = anaButon
        ? ElevatedButton.styleFrom(
            backgroundColor: Colors.pink.shade300,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
            shadowColor: Colors.pink.shade200,
          )
        : OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: Colors.white, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );

    final buton = anaButon
        ? ElevatedButton(onPressed: onBas, style: butonStili, child: _yazi())
        : OutlinedButton(onPressed: onBas, style: butonStili, child: _yazi());

    return SizedBox(width: genislik, child: buton);
  }

  Widget _yazi() {
    return Text(
      yazi,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
