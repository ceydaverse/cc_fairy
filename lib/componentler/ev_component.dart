import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

/// Ev hedefi — Nazlı buraya ulaşınca oyun kazanılır
class EvComponent extends SpriteComponent with HasGameReference<FlameGame> {
  EvComponent({
    required Vector2 konum,
    Vector2? boyut,
  }) : _boyut = boyut ?? Vector2(150, 150) {
    position = konum;
  }

  // İsteğe bağlı özel boyut
  final Vector2 _boyut;

  /// Çarpışma kontrolü için evin ekrandaki dikdörtgen alanı
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

    // Ev görselini yükle (Flame: sadece dosya adı)
    final evGorseli = await game.images.load('ev.png');
    sprite = Sprite(evGorseli);
    size = _boyut;
    anchor = Anchor.center;
  }
}
