import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../servisler/skor_kayit_servisi.dart';
import '../widgetlar/arkaplan_component.dart';
import '../widgetlar/menu_butonu.dart';
import 'menu_ekrani.dart';
import 'oyun_ekrani.dart';

/// Oyun bittiğinde gösterilen sonuç ekranı
class SonucEkrani extends StatelessWidget {
  const SonucEkrani({
    super.key,
    required this.sonucMetni,
    required this.toplananCicek,
  });

  // "Kazandın", "Kaybettin" veya "Canavara Yakalandın" metni
  final String sonucMetni;

  // Oyuncunun topladığı çiçek sayısı
  final int toplananCicek;

  /// Sonuç metnine göre alt açıklama döndürür
  String _altMesaj() {
    switch (sonucMetni) {
      case 'Kazandın':
        return 'Eve ulaştın!';
      case 'Canavara Yakalandın':
        return 'Canavar seni yakaladı!';
      case 'Kaybettin':
      default:
        return 'Canın bitti...';
    }
  }

  /// Sonuç metnine göre renk döndürür
  Color _sonucRengi() {
    if (sonucMetni == 'Kazandın') {
      return Colors.green.shade700;
    }
    return Colors.red.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final enIyiSkor = SkorKayitServisi.instance.enIyiSkor;

    return Scaffold(
      body: ArkaplanWidget(
        karartma: 0.35,
        cocuk: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ekip fotoğrafı — varsa küçük görsel olarak göster
                  const EkipFotografiGorseli(genislik: 80, yukseklik: 80),
                  const SizedBox(height: 20),
                  // Büyük sonuç yazısı
                  Text(
                    sonucMetni,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: sonucMetni == 'Canavara Yakalandın' ? 36 : 44,
                      fontWeight: FontWeight.bold,
                      color: _sonucRengi(),
                      shadows: const [
                        Shadow(blurRadius: 8, color: Colors.black54),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Kazanma/kaybetme açıklaması
                  Text(
                    _altMesaj(),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Toplanan çiçek sayısı
                  Text(
                    'Toplanan çiçek: $toplananCicek',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  // En iyi skor kaydı varsa göster
                  if (enIyiSkor > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'En iyi skor: $enIyiSkor',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                  // Oyunu sıfırdan başlat
                  MenuButonu(
                    yazi: 'Tekrar Oyna',
                    onBas: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OyunEkrani(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Ana menüye dön
                  MenuButonu(
                    yazi: 'Menüye Dön',
                    anaButon: false,
                    onBas: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MenuEkrani(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
