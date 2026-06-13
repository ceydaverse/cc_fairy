import 'package:flame/components.dart';
import 'package:flame/game.dart';

/// Cadı şatosu — başlangıç dekoru (çarpışma/hasar yok)
class CadiSatosuComponent extends SpriteComponent
    with HasGameReference<FlameGame> {
  CadiSatosuComponent({
    required Vector2 konum,
  }) {
    position = konum;
  }

  // Şato boyutu — büyütmek için sadece burayı değiştir
  static final Vector2 satoBoyutu = Vector2(230, 230);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final satoGorseli = await game.images.load('cadi_satosu.png');
    sprite = Sprite(satoGorseli);
    size = satoBoyutu;
    anchor = Anchor.center;
  }
}
