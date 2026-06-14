import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'buyu_component.dart';
import 'nazli_component.dart';

/// Nazlı'yı takip eden ve büyü fırlatan cadı düşmanı
class CadiComponent extends SpriteComponent with HasGameReference<FlameGame> {
  CadiComponent({
    required Vector2 konum,
    required this.nazli,
    required this.onBuyuOlustur,
    this.dunyaGenisligi,
    this.gorunenYukseklik,
    this.zeminY,
    this.hiz = 80,
    this.minMesafe = 115,
    this.buyuBeklemeSuresi = 2.8,
  }) {
    position = konum;
  }

  final NazliComponent nazli;
  final void Function(BuyuComponent buyu) onBuyuOlustur;
  final double? dunyaGenisligi;
  final double? gorunenYukseklik;

  // Takip ve sınırlandırma için zemin çizgisi
  final double? zeminY;

  /// Nazlı'ya yaklaşma hızı
  final double hiz;

  /// Bu mesafeden yakına daha fazla gitmez
  final double minMesafe;

  /// Büyü atma aralığı (saniye)
  final double buyuBeklemeSuresi;

  /// false iken cadı büyü fırlatmaz (iksir etkisi vb.)
  bool buyuAtabilir = true;

  // İksir içilince büyü atma engeli — saniye cinsinden kalan süre
  double _buyuEngelKalan = 0;

  double _buyuSayaci = 1.2;

  /// Nazlı büyüsüyle sersemleme — hareket ve atış durur
  bool sersemledi = false;
  double _sersemSureKalan = 0;

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

    final cadiGorseli = await game.images.load('cadi.png');
    sprite = Sprite(cadiGorseli);
    const nazliYuksekligi = 150.0;
    final oran = cadiGorseli.width / cadiGorseli.height;
    size = Vector2(nazliYuksekligi * oran, nazliYuksekligi);
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _sersemletmeyiGuncelle(dt);
    _buyuEngeliniGuncelle(dt);
    if (sersemledi) {
      return;
    }
    _nazliyaDogruHareket(dt);
    _buyuSayaciniGuncelle(dt);
  }

  /// Nazlı büyüsü çarpınca cadı geçici sersemler
  void sersemlet(double sure) {
    sersemledi = true;
    _sersemSureKalan = sure;
  }

  void _sersemletmeyiGuncelle(double dt) {
    if (!sersemledi) {
      return;
    }

    _sersemSureKalan -= dt;
    if (_sersemSureKalan <= 0) {
      _sersemSureKalan = 0;
      sersemledi = false;
    }
  }

  /// İksir ve Nazlı büyüsü cadının büyü atmasını geçici durdurur
  void disableSpellCastingFor(Duration duration) {
    final saniye = duration.inMilliseconds / 1000;
    if (saniye <= 0) {
      return;
    }

    buyuAtabilir = false;
    if (saniye > _buyuEngelKalan) {
      _buyuEngelKalan = saniye;
    }
    _buyuSayaci = buyuBeklemeSuresi;
  }


  void buyuAtmayiDurdur(double saniye) {
    disableSpellCastingFor(Duration(milliseconds: (saniye * 1000).round()));
  }

  /// Büyü engel süresi bitince cadı tekrar büyü atabilir
  void _buyuEngeliniGuncelle(double dt) {
    if (_buyuEngelKalan <= 0) {
      return;
    }

    _buyuEngelKalan -= dt;
    if (_buyuEngelKalan <= 0) {
      _buyuEngelKalan = 0;
      buyuAtabilir = true;
    }
  }

  /// Nazlı'ya doğru yavaşça ilerle, çok yaklaşma
  void _nazliyaDogruHareket(double dt) {
    final fark = nazli.position - position;
    final mesafe = fark.length;
    if (mesafe <= minMesafe) {
      return;
    }

    position += fark.normalized() * hiz * dt;
    _sinirlaKonum();
  }

  void _sinirlaKonum() {
    final genislik = dunyaGenisligi ?? game.size.x;
    final yukseklik = gorunenYukseklik ?? game.size.y;
    final yarimGenislik = size.x / 2;
    final yarimYukseklik = size.y / 2;

    position.x = position.x.clamp(yarimGenislik, genislik - yarimGenislik);

    // Zemin varsa cadı gökyüzüne çıkmasın
    if (zeminY != null) {
      position.y = position.y.clamp(zeminY! - 90, zeminY! + 15);
    } else {
      position.y = position.y.clamp(yarimYukseklik, yukseklik - yarimYukseklik);
    }
  }

  /// Cooldown dolunca Nazlı'nın o anki konumuna büyü fırlat
  void _buyuSayaciniGuncelle(double dt) {
    if (!buyuAtabilir) {
      return;
    }

    _buyuSayaci -= dt;
    if (_buyuSayaci > 0) {
      return;
    }

    _buyuSayaci = buyuBeklemeSuresi;
    _buyuFirlatsin();
  }

  void _buyuFirlatsin() {
    if (!buyuAtabilir) {
      return;
    }

    final genislik = dunyaGenisligi ?? game.size.x;
    final yukseklik = gorunenYukseklik ?? game.size.y;

    final buyu = BuyuComponent(
      baslangic: position.clone(),
      hedef: nazli.position.clone(),
      dunyaGenisligi: genislik,
      dunyaYuksekligi: yukseklik,
    );
    onBuyuOlustur(buyu);
  }
}
