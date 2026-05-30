import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';

import 'parcacik_component.dart';

/// Nazlı peri karakterini yöneten Flame bileşeni.
class NazliComponent extends SpriteComponent
    with DragCallbacks, KeyboardHandler, HasGameReference<FlameGame> {
  NazliComponent({
    required this.dunyaGenisligi,
    required this.gorunenYukseklik,
  });

  // Geniş oyun dünyası genişliği (x sınırı)
  final double dunyaGenisligi;

  // Görünen ekran yüksekliği (y sınırı)
  final double gorunenYukseklik;

  static const double hiz = 220;

  Vector2 _hareketYonu = Vector2.zero();
  double _pirlentiSayaci = 0;
  Vector2? _oncekiKonum;

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

    final nazliGorseli = await game.images.load('nazli.png');
    sprite = Sprite(nazliGorseli);

    size = Vector2(90, 90);
    anchor = Anchor.center;

    paint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..blendMode = BlendMode.srcOver
      ..filterQuality = FilterQuality.medium;

    // Haritanın solunda başla
    position = Vector2(100, gorunenYukseklik - 160);
    _oncekiKonum = position.clone();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_oncekiKonum != null) {
      final hareketMiktari = position.distanceTo(_oncekiKonum!);
      if (hareketMiktari > 1.5) {
        _pirlentiSayaci -= dt;
        if (_pirlentiSayaci <= 0) {
          _pirlentiSayaci = 0.05;
          final hedef = parent;
          if (hedef != null) {
            ParcacikComponent.pirlentiBirak(hedef, position.clone());
          }
        }
      }
    }
    _oncekiKonum = position.clone();
  }

  void hareketEt(double dt) {
    if (_hareketYonu == Vector2.zero()) {
      return;
    }
    _konumuGuncelle(_hareketYonu, dt);
  }

  void mobilHareketEt(Vector2 yon, double dt) {
    if (yon == Vector2.zero()) {
      return;
    }
    _konumuGuncelle(yon, dt);
  }

  void _konumuGuncelle(Vector2 yon, double dt) {
    final normalizedYon = yon.normalized();
    position += normalizedYon * hiz * dt;
    _sinirlaKonum();
  }

  /// x: dünya genişliği, y: ekran yüksekliği içinde kal
  void _sinirlaKonum() {
    final yarimGenislik = size.x / 2;
    final yarimYukseklik = size.y / 2;

    position.x =
        position.x.clamp(yarimGenislik, dunyaGenisligi - yarimGenislik);
    position.y = position.y.clamp(
      yarimYukseklik,
      gorunenYukseklik - yarimYukseklik,
    );
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _hareketYonu = Vector2.zero();

    final yukari = keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW);
    final asagi = keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
        keysPressed.contains(LogicalKeyboardKey.keyS);
    final sol = keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA);
    final sag = keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD);

    if (yukari) {
      _hareketYonu.y -= 1;
    }
    if (asagi) {
      _hareketYonu.y += 1;
    }
    if (sol) {
      _hareketYonu.x -= 1;
    }
    if (sag) {
      _hareketYonu.x += 1;
    }

    return true;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
    _sinirlaKonum();
  }
}
