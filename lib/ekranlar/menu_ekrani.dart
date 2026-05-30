import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgetlar/arkaplan_component.dart';
import '../widgetlar/menu_butonu.dart';
import 'oyun_ekrani.dart';

/// Oyunun başlangıç menü ekranı
class MenuEkrani extends StatelessWidget {
  const MenuEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ArkaplanWidget(
        karartma: 0.25,
        cocuk: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ekip fotoğrafı menüde daha görünür olacak şekilde büyütüldü
                  const EkipFotografiGorseli(
                    genislik: 500,
                    yukseklik: 500,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  // Oyun adı
                  Text(
                    "Nazlı'nın Çiçek Bahçesi",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: const [
                        Shadow(blurRadius: 8, color: Colors.black54),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Kısa açıklama
                  Text(
                    'Çiçekleri topla, dikenlerden kaç!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Oyun ekranına geçiş butonu
                  MenuButonu(
                    yazi: 'Oyuna Başla',
                    onBas: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>  OyunEkrani(),
                        ),
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
