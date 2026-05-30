import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

/// Kelebek — Nazlı yakalayınca kaybolur ve iksirin yerini gösterir
class KelebekComponent extends SpriteComponent
    with HasGameReference<FlameGame> {
  KelebekComponent({
    required Vector2 konum,
    required this.iksirKonumu,
    Vector2? boyut,
  }) : _boyut = boyut ?? Vector2(48, 48) {
    position = konum;
  }

  final Vector2 _boyut;

  // İksirin konumu — kelebek bunun çevresinde uçar (ipucu)
  final Vector2 iksirKonumu;

  double _ucusAcisi = 0;

  // Yakalandı mı?
  bool yakalandi = false;

  /// Çarpışma kontrolü için kelebeğin alanı
  Rect get sinirlar {
    return Rect.fromCenter(
      center: Offset(position.x, position.y),
      width: size.x,
      height: size.y,
    );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final kelebekGorseli = await game.images.load('kelebek.png');
    sprite = Sprite(kelebekGorseli);
    size = _boyut;
    anchor = Anchor.center;
    priority = 2;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (yakalandi) {
      return;
    }

    // İksir konumu çevresinde yavaşça süzül
    _ucusAcisi += dt * 2.2;
    final hedefMerkez = iksirKonumu;
    position = hedefMerkez +
        Vector2(
          cos(_ucusAcisi) * 55,
          sin(_ucusAcisi * 1.3) * 35,
        );
  }

  /// Kelebek yakalandı — ekrandan kaldır
  void yakala() {
    if (yakalandi) {
      return;
    }

    yakalandi = true;
    removeFromParent();
  }
}
