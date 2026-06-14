import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'parcacik_component.dart';

enum CanavarHareketYonu { yatay, dikey }

/// Ekranda otomatik hareket eden canavar engeli
class CanavarComponent extends SpriteComponent
    with HasGameReference<FlameGame> {
  CanavarComponent({
    required Vector2 konum,
    Vector2? boyut,
    this.hareketYonu = CanavarHareketYonu.yatay,
    this.hiz = 130,
    this.dunyaGenisligi,
    this.gorunenYukseklik,
    this.zeminY,
  }) : _boyut = boyut ?? Vector2(150, 150) {
    position = konum;
  }

  final Vector2 _boyut;
  final CanavarHareketYonu hareketYonu;
  final double hiz;

  // Geniş harita sınırları (verilmezse ekran boyutu kullanılır)
  final double? dunyaGenisligi;
  final double? gorunenYukseklik;

  // Dikey hareket zemine yakın kalsın (gökyüzüne çıkmasın)
  final double? zeminY;

  double _yonCarpani = 1;
  double _sisSayaci = 0;

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

    final canavarGorseli = await game.images.load('canavar.png');
    sprite = Sprite(canavarGorseli);
    size = _boyut;
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (hareketYonu == CanavarHareketYonu.yatay) {
      _yatayHareketEt(dt);
    } else {
      _dikeyHareketEt(dt);
    }

    _sisSayaci -= dt;
    if (_sisSayaci <= 0) {
      _sisSayaci = 0.09;
      final hedef = parent;
      if (hedef != null) {
        ParcacikComponent.sisBirak(hedef, position.clone());
      }
    }
  }

  void _yatayHareketEt(double dt) {
    final genislik = dunyaGenisligi ?? game.size.x;
    final yarimGenislik = size.x / 2;

    position.x += hiz * _yonCarpani * dt;

    if (position.x <= yarimGenislik) {
      position.x = yarimGenislik;
      _yonCarpani = 1;
    } else if (position.x >= genislik - yarimGenislik) {
      position.x = genislik - yarimGenislik;
      _yonCarpani = -1;
    }
  }

  void _dikeyHareketEt(double dt) {
    final yarimYukseklik = size.y / 2;

    
    final minY = zeminY != null ? zeminY! - 35 : yarimYukseklik;
    final maxY = zeminY != null
        ? zeminY! + 8
        : (gorunenYukseklik ?? game.size.y) - yarimYukseklik;

    position.y += hiz * _yonCarpani * dt;

    if (position.y <= minY) {
      position.y = minY;
      _yonCarpani = 1;
    } else if (position.y >= maxY) {
      position.y = maxY;
      _yonCarpani = -1;
    }
  }
}
