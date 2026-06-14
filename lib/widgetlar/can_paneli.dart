import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../modeller/oyun_skoru.dart';

/// Sağ üstte kalan canları kalp ikonları ile gösteren panel
class CanPaneli extends StatelessWidget {
  const CanPaneli({super.key, required this.can});

  // Mevcut kalan can (0 … OyunSkoru.baslangicCan)
  final int can;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.pink.shade100, width: 1.5),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // "Can" etiketi
          Text(
            'Can',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.pink.shade700,
            ),
          ),
          const SizedBox(width: 8),
          // baslangicCan kadar kalp — dolu/boş döngüyle (hardcoded değil)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 148),
            child: Wrap(
              spacing: 2,
              runSpacing: 1,
              children: List.generate(OyunSkoru.baslangicCan, (index) {
                final dolu = index < can;
                return _kalpGorseli(dolu: dolu);
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// Tek bir kalp ikonu — dolu veya gri boş kalp
  Widget _kalpGorseli({required bool dolu}) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Icon(
        dolu ? Icons.favorite : Icons.favorite_border,
        color: dolu ? Colors.pink.shade500 : Colors.grey.shade400,
        size: 24,
      ),
    );
  }
}
