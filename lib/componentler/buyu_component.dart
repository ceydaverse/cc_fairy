import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Cadının Nazlı'ya doğru fırlattığı büyü
class BuyuComponent extends CircleComponent {
  BuyuComponent({
    required Vector2 baslangic,
    required Vector2 hedef,
    required this.dunyaGenisligi,
    required this.dunyaYuksekligi,
  })  : _yon = (hedef - baslangic).normalized(),
        super(
          position: baslangic,
          radius: 14,
          anchor: Anchor.center,
          paint: Paint()..color = Colors.purpleAccent,
        );

  // Büyünün gideceği yön
  final Vector2 _yon;

  // Harita genişliği ve yüksekliği
  final double dunyaGenisligi;
  final double dunyaYuksekligi;

  // Büyünün hızı
  final double hiz = 260;

  @override
  void update(double dt) {
    super.update(dt);

    // Büyü Nazlı'nın olduğu yöne doğru ilerler
    position += _yon * hiz * dt;

    // Haritadan çok uzaklaşırsa silinsin
    if (position.x < -300 ||
        position.x > dunyaGenisligi + 300 ||
        position.y < -300 ||
        position.y > dunyaYuksekligi + 300) {
      removeFromParent();
    }
  }

  /// Çarpışma kontrolü için sınır alanı
  Rect get sinirlar => toRect();
}