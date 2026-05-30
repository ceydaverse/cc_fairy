import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../modeller/cicek_turu.dart';

/// Toplanabilir çiçek bileşeni — türüne göre farklı görsel kullanır
class CicekComponent extends SpriteComponent
    with HasGameReference<FlameGame> {
  CicekComponent({
    required this.tur,
    required Vector2 konum,
    Vector2? boyut,
  }) : _boyut = boyut ?? CicekComponent.varsayilanBoyut {
    position = konum;
  }

  // Varsayılan çiçek boyutu — ekranda net görünür
  static final Vector2 varsayilanBoyut = Vector2(80, 80);

  // Çiçeğin rengi/türü (modeller klasöründen gelir)
  final CicekTuru tur;

  // İsteğe bağlı özel boyut
  final Vector2 _boyut;

  // Çiçek toplandı mı? Oyun ekranı bu bayrağı kontrol eder
  bool toplandi = false;

  /// Çarpışma kontrolü için çiçeğin ekrandaki dikdörtgen alanı (boyuta göre güncellenir)
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

    final cicekGorseli = await game.images.load(tur.assetDosyaAdi);
    sprite = Sprite(cicekGorseli);
    size = _boyut;
    anchor = Anchor.center;

    // Doğal çiçek renkleri — ekstra tint yok
    paint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..blendMode = BlendMode.srcOver;
  }
}
