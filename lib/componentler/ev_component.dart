import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

/// Ev hedefi — Nazlı buraya ulaşınca oyun kazanılır
class EvComponent extends SpriteComponent with HasGameReference<FlameGame> {
  EvComponent({
    required Vector2 konum,
  }) {
    position = konum;
  }

  // Ev boyutu — büyütmek için sadece burayı değiştir
  static final Vector2 evBoyutu = Vector2(180, 180);

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
    size = evBoyutu;
    anchor = Anchor.center;
  }
}
