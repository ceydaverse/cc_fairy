import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

/// Diken engeli — Nazlı değerse can azaltılır (kontrol oyun ekranında yapılır)
class DikenComponent extends SpriteComponent
    with HasGameReference<FlameGame> {
  DikenComponent({
    required Vector2 konum,
    Vector2? boyut,
  }) : _boyut = boyut ?? Vector2(60, 60) {
    position = konum;
  }

  // İsteğe bağlı özel boyut
  final Vector2 _boyut;

  /// Çarpışma kontrolü için dikenin ekrandaki dikdörtgen alanı
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

    final dikenGorseli = await game.images.load('diken.png');
    sprite = Sprite(dikenGorseli);
    size = _boyut;
    anchor = Anchor.center;
  }
}
