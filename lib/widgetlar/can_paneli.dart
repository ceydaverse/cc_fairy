import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../modeller/oyun_skoru.dart';

/// Sağ üstte kalan canları kalp ikonları ile gösteren panel
class CanPaneli extends StatelessWidget {
  const CanPaneli({
    super.key,
    required this.can,
  });

  // Mevcut kalan can (0 … OyunSkoru.baslangicCan)
  final int can;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.pink.shade100,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.shade100.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // "Can" etiketi
          Text(
            'Can',
            style: GoogleFonts.poppins(
              fontSize: 25,
              fontWeight: FontWeight.w600,
              color: Colors.pink.shade700,
            ),
          ),
          const SizedBox(width: 8),
          // baslangicCan kadar kalp — dolu/boş döngüyle (hardcoded değil)
          ...List.generate(OyunSkoru.baslangicCan, (index) {
            final dolu = index < can;
            return Padding(
              padding: const EdgeInsets.only(left: 2),
              child: _kalpGorseli(dolu: dolu),
            );
          }),
        ],
      ),
    );
  }

  /// Tek bir kalp ikonu — dolu veya gri boş kalp
  Widget _kalpGorseli({required bool dolu}) {
    if (dolu) {
      // Dolu kalp: renk filtresi yok, orijinal görsel
      return Image.asset(
        'assets/images/kalp.png',
        width: 24,
        height: 24,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.favorite,
            color: Colors.red.shade400,
            size: 24,
          );
        },
      );
    }

    // Boş kalp: sadece kenarlık ikon (tint ile bozulmaz)
    return Icon(
      Icons.favorite_border,
      color: Colors.grey.shade400,
      size: 24,
    );
  }
}
