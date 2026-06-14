import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// Parçacık türü: Nazlı için pırıltı, canavar için sis
enum ParcacikTuru {
  pirlenti,
  sis,
}

/// Kodla çizilen kısa ömürlü parçacık — büyür ve fade-out ile kaybolur
class ParcacikComponent extends PositionComponent
    with HasGameReference<FlameGame> {
  ParcacikComponent({
    required this.tur,
    required Vector2 konum,
  }) {
    position = konum;
    anchor = Anchor.center;
    // Karakterlerin arkasında kalsın
    priority = 0;

    final rastgele = Random();
    _drift = Vector2(
      (rastgele.nextDouble() - 0.5) * 18,
      (rastgele.nextDouble() - 0.5) * 18,
    );
    _baslangicBoyut = tur == ParcacikTuru.pirlenti
        ? 4 + rastgele.nextDouble() * 4
        : 14 + rastgele.nextDouble() * 10;
  }

  final ParcacikTuru tur;

  // Parçacığın ekranda kalma süresi (saniye)
  static const double omur = 0.55;

  double _yasam = 0;
  late final Vector2 _drift;
  late final double _baslangicBoyut;

 
  static void pirlentiBirak(Component eklemeHedefi, Vector2 konum) {
    final rastgele = Random();
    final ofset = Vector2(
      (rastgele.nextDouble() - 0.5) * 24,
      (rastgele.nextDouble() - 0.5) * 24,
    );
    eklemeHedefi.add(ParcacikComponent(
      tur: ParcacikTuru.pirlenti,
      konum: konum + ofset,
    ));
  }

  /// Canavar arkasında mor sis bırakır (dünya içine eklenir)
  static void sisBirak(Component eklemeHedefi, Vector2 konum) {
    final rastgele = Random();
    final ofset = Vector2(
      (rastgele.nextDouble() - 0.5) * 20,
      (rastgele.nextDouble() - 0.5) * 20,
    );
    eklemeHedefi.add(ParcacikComponent(
      tur: ParcacikTuru.sis,
      konum: konum + ofset,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);

    _yasam += dt;
    // Hafif sürüklenme
    position += _drift * dt;

    if (_yasam >= omur) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final ilerleme = (_yasam / omur).clamp(0.0, 1.0);
    // Fade-out: başta görünür, sonda kaybolur
    final opaklik = (1.0 - ilerleme);
    if (opaklik <= 0) {
      return;
    }

    // Hafif büyüme
    final boyut = _baslangicBoyut * (1.0 + ilerleme * 0.6);
    size = Vector2(boyut, boyut);

    if (tur == ParcacikTuru.pirlenti) {
      _pirlentiCiz(canvas, boyut, opaklik);
    } else {
      _sisCiz(canvas, boyut, opaklik);
    }
  }

  /// Altın-beyaz küçük pırıltı (daire + parlak çekirdek)
  void _pirlentiCiz(Canvas canvas, double boyut, double opaklik) {
    final merkez = Offset(size.x / 2, size.y / 2);

    final disBoyut = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.55 * opaklik)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawCircle(merkez, boyut / 2, disBoyut);

    final icBoyut = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.9 * opaklik);

    canvas.drawCircle(merkez, boyut / 4, icBoyut);
  }

  /// Mor yarı saydam sis (üst üste yumuşak daireler)
  void _sisCiz(Canvas canvas, double boyut, double opaklik) {
    final merkez = Offset(size.x / 2, size.y / 2);

    final disSis = Paint()
      ..color = const Color(0xFF7E57C2).withValues(alpha: 0.22 * opaklik)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawCircle(merkez, boyut * 0.55, disSis);

    final icSis = Paint()
      ..color = const Color(0xFFCE93D8).withValues(alpha: 0.35 * opaklik)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawCircle(merkez, boyut * 0.35, icSis);
  }
}
