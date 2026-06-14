import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';


class NazliBuyuComponent extends PositionComponent {
  NazliBuyuComponent({
    required Vector2 baslangic,
    required Vector2 yon,
    required this.dunyaGenisligi,
    required this.dunyaYuksekligi,
  }) : _yon = yon.normalized(),
       super(
         position: baslangic,
         size: Vector2(_carpismaBoyutu, _carpismaBoyutu),
         anchor: Anchor.center,
       );

  static const double _carpismaBoyutu = 42;

  final Vector2 _yon;
  final double dunyaGenisligi;
  final double dunyaYuksekligi;

  final double hiz = 300;
  double _animasyonZamani = 0;

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

    _animasyonZamani += dt;
    position += _yon * hiz * dt;

    if (position.x < -300 ||
        position.x > dunyaGenisligi + 300 ||
        position.y < -300 ||
        position.y > dunyaYuksekligi + 300) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final merkez = Offset(size.x / 2, size.y / 2);
    final pulse = 1.0 + 0.08 * math.sin(_animasyonZamani * 9);
    final titresim = Offset(
      math.sin(_animasyonZamani * 12) * 1.2,
      math.cos(_animasyonZamani * 9) * 1.0,
    );
    final cizimMerkezi = merkez + titresim;
    final faz = _animasyonZamani * 5;
    final temelR = 13.0 * pulse;

    // Dış glow — açık pembe / lila
    final disGlow = Paint()
      ..color = const Color(0xFFF8BBD0).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);
    canvas.drawCircle(cizimMerkezi, temelR * 1.5, disGlow);

    // Orta enerji — yumuşak lila lekeler
    final ortaEnerji = Paint()
      ..color = const Color(0xFFE1BEE7).withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    _enerjiLekeleriCiz(canvas, cizimMerkezi, temelR, ortaEnerji, faz);

    // İç parlak çekirdek — beyaza yakın
    final cekirdek = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFFFFFFFF).withValues(alpha: 0.98),
              const Color(0xFFF3E5F5).withValues(alpha: 0.7),
              const Color(0xFFFCE4EC).withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.4, 1.0],
          ).createShader(
            Rect.fromCircle(center: cizimMerkezi, radius: temelR * 0.55),
          );
    canvas.drawCircle(cizimMerkezi, temelR * 0.55, cekirdek);
  }

  void _enerjiLekeleriCiz(
    Canvas canvas,
    Offset merkez,
    double yaricap,
    Paint boyama,
    double faz,
  ) {
    canvas.drawCircle(merkez, yaricap * 0.9, boyama);
    for (var i = 0; i < 3; i++) {
      final aci = faz + i * 2.1;
      final kayma = Offset(
        math.cos(aci) * yaricap * 0.2,
        math.sin(aci) * yaricap * 0.18,
      );
      canvas.drawCircle(merkez + kayma, yaricap * 0.65, boyama);
    }
  }
}
