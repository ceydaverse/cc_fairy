import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

/// Ağaç — Nazlı dokununca geçici büyü gücü verir (cooldown ile)
class AgacComponent extends SpriteComponent with HasGameReference<FlameGame> {
  AgacComponent({
    required Vector2 konum,
    required this.assetAdi, //required = degeri zorunlu girilmesi lazım
  }) {
    position = konum;
  }

 
  final String assetAdi;

 
  static final Vector2 agacBoyutu = Vector2(150, 180);

  static const double cooldownSuresi = 10;

  double _cooldownKalan = 0;

  /// Cooldown bitmişse Nazlı'ya güç verilebilir
  bool get gucVerebilir => _cooldownKalan <= 0;

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

    final agacGorseli = await game.images.load(assetAdi);
    sprite = Sprite(agacGorseli);
    size = agacBoyutu;
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_cooldownKalan > 0) {
      _cooldownKalan -= dt;
      if (_cooldownKalan < 0) {
        _cooldownKalan = 0;
      }
    }
  }

  /// Nazlı güç aldı — 10 saniye cooldown başlar
  void gucVerildi() {
    _cooldownKalan = cooldownSuresi;
  }
}
