import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'parcacik_component.dart';

/// İksir — oyun başında gizli; kelebek yakalanınca fade-in ile görünür
class IksirComponent extends SpriteComponent with HasGameReference<FlameGame> {
  IksirComponent({required Vector2 konum, Vector2? boyut})
    : _boyut = boyut ?? Vector2(80, 80) {
    position = konum;
  }

  final Vector2 _boyut;

  // Başlangıçta gizli
  bool _gorunur = false;

  // Fade-in animasyonu
  double _hedefOpaklik = 0;
  double _toplanabilirGecikme = 0;

  /// İksir şu an ekranda görünüyor mu?
  bool get gorunur => _gorunur;

  /// Nazlı iksiri içti mi?
  bool get icildiMi => _icildi;

  // Nazlı tarafından bir kez içildi
  bool _icildi = false;

  /// Çarpışma — yalnızca görünür ve içilmemiş iksir için
  Rect get sinirlar {
    if (!_gorunur || _icildi || _toplanabilirGecikme > 0 || opacity < 0.55) {
      return Rect.zero;
    }

    return Rect.fromCenter(
      center: Offset(position.x, position.y),
      width: size.x,
      height: size.y,
    );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final iksirGorseli = await game.images.load('iksir.png');
    sprite = Sprite(iksirGorseli);
    size = _boyut;
    anchor = Anchor.center;
    priority = 6;

    // Başlangıçta tamamen gizli
    opacity = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_gorunur) {
      return;
    }

    if (_toplanabilirGecikme > 0) {
      _toplanabilirGecikme = (_toplanabilirGecikme - dt).clamp(0.0, 1.0);
    }

    // Fade-in: opaklığı yavaşça 1'e çıkar
    if (opacity < _hedefOpaklik) {
      opacity = (opacity + dt * 2.5).clamp(0.0, 1.0);
    }
  }

  @override
  void render(Canvas canvas) {
    // Gizliyken çizme
    if (!_gorunur || opacity <= 0) {
      return;
    }

    super.render(canvas);
  }

  /// Nazlı iksire değince içilir ve gizlenir
  void ic() {
    if (_icildi) {
      return;
    }

    _icildi = true;
    _gorunur = false;
    _hedefOpaklik = 0;
    _toplanabilirGecikme = 0;
    opacity = 0;
  }

  /// Kelebek yakalanınca iksiri görünür yap
  void goster() {
    if (_gorunur || _icildi) {
      return;
    }

    _gorunur = true;
    _hedefOpaklik = 1.0;
    _toplanabilirGecikme = 0.6;
    opacity = 0.15;

    // İksir konumunda kısa pırıltı efekti (basit işaret)
    final hedef = parent;
    if (hedef != null) {
      for (var i = 0; i < 5; i++) {
        ParcacikComponent.pirlentiBirak(hedef, position.clone());
      }
    }
  }
}
