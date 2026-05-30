import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Cadının Nazlı'ya doğru fırlattığı büyü — katmanlı mor enerji efekti
class BuyuComponent extends PositionComponent {
  BuyuComponent({
    required Vector2 baslangic,
    required Vector2 hedef,
    required this.dunyaGenisligi,
    required this.dunyaYuksekligi,
  })  : _yon = (hedef - baslangic).normalized(),
        super(
          position: baslangic,
          // Çarpışma alanı (eski yarıçap 14 ile uyumlu)
          size: Vector2(_carpismaBoyutu, _carpismaBoyutu),
          anchor: Anchor.center,
        );

  static const double _carpismaBoyutu = 28;

  // Büyünün gideceği yön
  final Vector2 _yon;

  // Harita genişliği ve yüksekliği
  final double dunyaGenisligi;
  final double dunyaYuksekligi;

  // Büyünün hızı
  final double hiz = 260;

  // Pulse / titreşim animasyonu
  double _animasyonZamani = 0;

  // Hareket izi (trail) noktaları
  final List<_BuyuIzNoktasi> _iz = [];
  double _izSayaci = 0;

  @override
  void update(double dt) {
    super.update(dt);

    _animasyonZamani += dt;

    // Büyü Nazlı'nın olduğu yöne doğru ilerler
    position += _yon * hiz * dt;

    _izGuncelle(dt);

    // Haritadan çok uzaklaşırsa silinsin
    if (position.x < -300 ||
        position.x > dunyaGenisligi + 300 ||
        position.y < -300 ||
        position.y > dunyaYuksekligi + 300) {
      removeFromParent();
    }
  }

  void _izGuncelle(double dt) {
    _izSayaci += dt;
    if (_izSayaci >= 0.045) {
      _izSayaci = 0;
      _iz.insert(0, _BuyuIzNoktasi(position.clone(), 0));
      if (_iz.length > 8) {
        _iz.removeLast();
      }
    }
    for (var i = _iz.length - 1; i >= 0; i--) {
      _iz[i].yas += dt;
      if (_iz[i].yas > 0.38) {
        _iz.removeAt(i);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final merkez = Offset(size.x / 2, size.y / 2);
    final pulse = 1.0 + 0.09 * math.sin(_animasyonZamani * 8.5);
    final titresim = Offset(
      math.sin(_animasyonZamani * 13) * 1.4,
      math.cos(_animasyonZamani * 10) * 1.4,
    );
    final cizimMerkezi = merkez + titresim;
    final faz = _animasyonZamani * 5.2;

    _izCiz(canvas, merkez);
    _buyuCiz(canvas, cizimMerkezi, pulse, faz);
  }

  /// Hareket yönünde solan mor sihir izi
  void _izCiz(Canvas canvas, Offset bilesenMerkezi) {
    for (final nokta in _iz) {
      final t = (nokta.yas / 0.38).clamp(0.0, 1.0);
      final opaklik = (1.0 - t) * 0.45;
      if (opaklik <= 0.02) {
        continue;
      }

      final yerel = Offset(
        nokta.konum.x - position.x + bilesenMerkezi.dx,
        nokta.konum.y - position.y + bilesenMerkezi.dy,
      );
      final izYaricap = 10.0 * (1.0 - t * 0.55);

      final izBoyama = Paint()
        ..color = const Color(0xFFAB47BC).withValues(alpha: opaklik)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawCircle(yerel, izYaricap, izBoyama);

      final izCekirdek = Paint()
        ..color = const Color(0xFFE1BEE7).withValues(alpha: opaklik * 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(yerel, izYaricap * 0.45, izCekirdek);
    }
  }

  void _buyuCiz(Canvas canvas, Offset merkez, double pulse, double faz) {
    final temelR = 15.0 * pulse;

    // Dış glow — koyu mor, yumuşak kenar
    final disGlow = Paint()
      ..color = const Color(0xFF4A148C).withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(merkez, temelR * 1.55, disGlow);

    // Orta enerji — düzensiz mor kütle (tek daire yerine birleşik lekeler)
    final ortaEnerji = Paint()
      ..color = const Color(0xFF7B1FA2).withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    _enerjiLekeleriCiz(canvas, merkez, temelR * 1.05, ortaEnerji, faz);

    final acikEnerji = Paint()
      ..color = const Color(0xFFBA68C8).withValues(alpha: 0.62)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    _enerjiLekeleriCiz(canvas, merkez, temelR * 0.78, acikEnerji, faz + 1.1);

    // İç parlak halka — lila ton
    final icHalka = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFF3E5F5).withValues(alpha: 0.95),
          const Color(0xFFCE93D8).withValues(alpha: 0.55),
          const Color(0xFF8E24AA).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: merkez, radius: temelR * 0.72));
    canvas.drawCircle(merkez, temelR * 0.72, icHalka);

    // Parlak çekirdek — beyaza yakın merkez
    final cekirdek = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFFFFF).withValues(alpha: 0.98),
          const Color(0xFFE1BEE7).withValues(alpha: 0.75),
          const Color(0xFFAB47BC).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.35, 1.0],
      ).createShader(Rect.fromCircle(center: merkez, radius: temelR * 0.38));
    canvas.drawCircle(merkez, temelR * 0.38, cekirdek);

    // Küçük kıvılcım noktaları — enerji hissi
    final kivilcim = Paint()
      ..color = const Color(0xFFF8BBD0).withValues(alpha: 0.85);
    for (var i = 0; i < 4; i++) {
      final aci = faz + i * 1.57;
      final uzaklik = temelR * (0.55 + 0.12 * math.sin(faz * 2 + i));
      final nokta = merkez +
          Offset(math.cos(aci) * uzaklik, math.sin(aci) * uzaklik * 0.9);
      canvas.drawCircle(nokta, 2.2, kivilcim);
    }
  }

  /// Tam yuvarlak yerine hafif kaymış lekeler — enerji topu hissi
  void _enerjiLekeleriCiz(
    Canvas canvas,
    Offset merkez,
    double yaricap,
    Paint boyama,
    double faz,
  ) {
    canvas.drawCircle(merkez, yaricap * 0.92, boyama);
    for (var i = 0; i < 3; i++) {
      final aci = faz + i * 2.15;
      final kayma = Offset(
        math.cos(aci) * yaricap * 0.22,
        math.sin(aci) * yaricap * 0.2,
      );
      canvas.drawCircle(merkez + kayma, yaricap * 0.72, boyama);
    }
  }

  /// Çarpışma kontrolü için sınır alanı (görselden bağımsız sabit kutu)
  Rect get sinirlar => toRect();
}

class _BuyuIzNoktasi {
  _BuyuIzNoktasi(this.konum, this.yas);

  final Vector2 konum;
  double yas;
}
