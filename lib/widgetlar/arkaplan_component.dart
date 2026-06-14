import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// Flutter ekranları için tam ekran arka plan widget'ı 
class ArkaplanWidget extends StatelessWidget {
  const ArkaplanWidget({
    super.key,
    required this.cocuk,
    this.karartma = 0.0,
  });

  final Widget cocuk;
  final double karartma;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/arkaplan.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: karartma > 0
          ? Container(
              color: Colors.black.withValues(alpha: karartma),
              child: cocuk,
            )
          : cocuk,
    );
  }
}

/// Ekip fotoğrafını güvenli şekilde gösterir
class EkipFotografiGorseli extends StatelessWidget {
  const EkipFotografiGorseli({
    super.key,
    this.genislik = 90,
    this.yukseklik = 90,
    this.fit = BoxFit.cover,
  });

  final double genislik;
  final double yukseklik;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        'assets/images/ekip_fotografi.png',
        width: genislik,
        height: yukseklik,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      ),
    );
  }
}

/// Geniş oyun dünyası boyunca yatay tekrarlanan Flame arka planı
class FlameArkaplanComponent extends PositionComponent
    with HasGameReference<FlameGame> {
  FlameArkaplanComponent({
    required this.dunyaGenisligi,
    required this.dunyaYuksekligi,
  });

  final double dunyaGenisligi;
  final double dunyaYuksekligi;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    position = Vector2.zero();
    anchor = Anchor.topLeft;
    size = Vector2(dunyaGenisligi, dunyaYuksekligi);
    priority = -10;

    final arkaplanGorseli = await game.images.load('arkaplan.png');
    final sprite = Sprite(arkaplanGorseli);
    final karoGenisligi = sprite.srcSize.x;
    final karoYuksekligi = dunyaYuksekligi;

    // Yatayda tekrarlayarak siyah boşluk bırakma
    final karoSayisi = (dunyaGenisligi / karoGenisligi).ceil() + 1;
    for (var i = 0; i < karoSayisi; i++) {
      add(
        SpriteComponent(
          sprite: sprite,
          position: Vector2(i * karoGenisligi, 0),
          size: Vector2(karoGenisligi, karoYuksekligi),
          anchor: Anchor.topLeft,
        )..priority = 0,
      );
    }
  }
}
