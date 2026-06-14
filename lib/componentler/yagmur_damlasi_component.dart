import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// Kodla çizilen yağmur damlası — yukarıdan aşağı düşer, Nazlı'ya değerse can azaltır
class YagmurDamlasiComponent extends PositionComponent
    with HasGameReference<FlameGame> {
  YagmurDamlasiComponent({required Vector2 konum}) {
    position = konum;
    // Çarpışması hissedilir, görünür mavi damla boyutu
    size = Vector2(11, 11);
    anchor = Anchor.center;
    // Yağmur arka plandan biraz önde, buluttan sonra görünsün
    priority = 5;
  }

  // Düşme hızı (piksel/saniye)
  static const double dusmeHizi = 300;

  /// Çarpışma kontrolü için damlanın ekrandaki dikdörtgen alanı
  Rect get sinirlar {
    return Rect.fromCenter(
      center: Offset(position.x, position.y),
      width: size.x,
      height: size.y,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Damla aşağı doğru düşer
    position.y += dusmeHizi * dt;

    // Ekranın altına çıkınca oyundan kaldır
    if (position.y - size.y / 2 > game.size.y) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    // Asset kullanmadan küçük mavi oval damla çiz
    final damlaBoyasi = Paint()..color = const Color(0xFF42A5F5);

    final damlaAlani = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(size.x / 2),
    );

    canvas.drawRRect(damlaAlani, damlaBoyasi);
  }
}
