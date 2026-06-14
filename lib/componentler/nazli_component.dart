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

  final double dunyaGenisligi;

  
  final double gorunenYukseklik;

  static const double hiz = 220;

  // Ağaç gücü — 10 sn aktif, Space/buton ile 0.5 sn aralıkla büyü
  bool buyuGucuAktif = false;
  double buyuGucuKalanSure = 0;
  double buyuAtmaCooldown = 0;
  bool _buyuGucuTekKullanimlik = true;

  // Sağ: 1, sol: -1 (varsayılan sağ)
  int _baktigiYon = 1;
  bool _spaceBasili = false;

  Vector2 get baktigiYonu => Vector2(_baktigiYon.toDouble(), 0);

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

    size = Vector2(150, 150);
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

  /// Ağaç dokunuşu — 10 saniyelik büyü gücü
  void buyuGucuKazan({double sure = 10}) {
    buyuGucuAktif = true;
    buyuGucuKalanSure = sure;
    _buyuGucuTekKullanimlik = sure <= 0;
  }

  /// Güç süresi ve atış cooldown güncellemesi
  void buyuGucunuGuncelle(double dt) {
    if (buyuGucuKalanSure > 0) {
      buyuGucuKalanSure -= dt;
      if (buyuGucuKalanSure <= 0) {
        buyuGucuKalanSure = 0;
        buyuGucuAktif = false;
      }
    }

    if (buyuAtmaCooldown > 0) {
      buyuAtmaCooldown -= dt;
      if (buyuAtmaCooldown < 0) {
        buyuAtmaCooldown = 0;
      }
    }
  }

  /// Space basılı ve güç aktifken büyü atılabilir (0.5 sn aralık)
  bool buyuAtmayiDene({bool zorla = false}) {
    if (!buyuGucuAktif || (!zorla && !_spaceBasili) || buyuAtmaCooldown > 0) {
      return false;
    }

    buyuAtmaCooldown = 0.5;
    if (_buyuGucuTekKullanimlik) {
      buyuGucuAktif = false;
      buyuGucuKalanSure = 0;
      _buyuGucuTekKullanimlik = true;
    }
    return true;
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
    if (normalizedYon.x < 0) {
      _baktigiYon = -1;
    } else if (normalizedYon.x > 0) {
      _baktigiYon = 1;
    }
    position += normalizedYon * hiz * dt;
    _sinirlariUygula();
  }

  /// Klavye, mobil ve sürükleme sonrası ortak hareket sınırı
  void _sinirlariUygula() {
    final yarimGenislik = size.x / 2;
    final yarimYukseklik = size.y / 2;

    // Oyun ekranındaki zemin çizgisiyle uyumlu (dunyaY - 140)
    final zeminY = gorunenYukseklik - 140;

    // Nazlı'nın gökyüzüne çıkmasını engelleyen sınır
    final minY = zeminY - 160;
    final maxY = gorunenYukseklik - yarimYukseklik - 20;

    position.x = position.x.clamp(
      yarimGenislik,
      dunyaGenisligi - yarimGenislik,
    );
    position.y = position.y.clamp(minY, maxY);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _hareketYonu = Vector2.zero();

    final yukari =
        keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW);
    final asagi =
        keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
        keysPressed.contains(LogicalKeyboardKey.keyS);
    final sol =
        keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA);
    final sag =
        keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
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

    _spaceBasili = keysPressed.contains(LogicalKeyboardKey.space);

    if (sol && !sag) {
      _baktigiYon = -1;
    } else if (sag && !sol) {
      _baktigiYon = 1;
    }

    return true;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
    _sinirlariUygula();
  }
}
