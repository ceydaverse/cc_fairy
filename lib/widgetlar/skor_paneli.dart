import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ekranın üst kısmında toplanan çiçek sayısını gösteren panel
class SkorPaneli extends StatelessWidget {
  const SkorPaneli({
    super.key,
    required this.toplananCicek,
  });

  // Şu ana kadar toplanan çiçek sayısı
  final int toplananCicek;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.shade100.withValues(alpha: 0.6),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        'Çiçek: $toplananCicek',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.pink.shade700,
        ),
      ),
    );
  }
}
