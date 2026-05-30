import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'yagmur_damlasi_component.dart';

/// Kara bulut — geniş harita üzerinde yavaşça hareket eder
class KaraBulutComponent extends SpriteComponent
    with HasGameReference<FlameGame> {
  KaraBulutComponent({
    required Vector2 konum,
    Vector2? boyut,
    this.hiz = 45,
    this.damlaAraligi = 0.45,
    required this.onDamlaOlustur,
    this.dunyaGenisligi,
  }) : _boyut = boyut ?? Vector2(140, 70) {
    position = konum;
  }

  final Vector2 _boyut;
  final double hiz;
  final double damlaAraligi;
  final void Function(YagmurDamlasiComponent damla) onDamlaOlustur;
  final double? dunyaGenisligi;

  double _yonCarpani = 1;
  double _damlaSayaci = 0;
  final Random _rastgele = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final bulutGorseli = await game.images.load('karabulut.png');
    sprite = Sprite(bulutGorseli);
    size = _boyut;
    anchor = Anchor.center;
    priority = 8;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _yatayHareketEt(dt);
    _damlaSayaciniGuncelle(dt);
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

  void _damlaSayaciniGuncelle(double dt) {
    _damlaSayaci += dt;
    if (_damlaSayaci < damlaAraligi) {
      return;
    }
    _damlaSayaci = 0;
    _yagmurDamlesiBirak();
  }

  void _yagmurDamlesiBirak() {
    final rastgeleOfset = (_rastgele.nextDouble() - 0.5) * size.x * 0.7;
    final damlaKonumu = Vector2(
      position.x + rastgeleOfset,
      position.y + size.y / 2 + 6,
    );
    onDamlaOlustur(YagmurDamlasiComponent(konum: damlaKonumu));
  }
}
