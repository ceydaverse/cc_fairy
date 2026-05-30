import 'dart:math';



import 'package:flame/components.dart';

import 'package:flame/events.dart';

import 'package:flame/game.dart';

import 'package:flutter/material.dart';



import '../componentler/buyu_component.dart';

import '../componentler/cadi_component.dart';

import '../componentler/canavar_component.dart';

import '../componentler/cicek_component.dart';

import '../componentler/diken_component.dart';

import '../componentler/ev_component.dart';

import '../componentler/iksir_component.dart';

import '../componentler/kelebek_component.dart';

import '../componentler/karabulut_component.dart';

import '../componentler/nazli_component.dart';

import '../componentler/yagmur_damlasi_component.dart';

import '../modeller/cicek_turu.dart';

import '../modeller/oyun_skoru.dart';

import '../servisler/skor_kayit_servisi.dart';

import '../widgetlar/arkaplan_component.dart';

import '../widgetlar/can_paneli.dart';

import '../widgetlar/skor_paneli.dart';

import 'sonuc_ekrani.dart';



/// Oyun nesnelerinin çizim sırası — arka planın üstünde görünürler

const int _oyunNesnesiOnceligi = 1;



/// Oyunun ana ekranı — Flame GameWidget ile oyunu gösterir

class OyunEkrani extends StatefulWidget {

  const OyunEkrani({super.key});



  @override

  State<OyunEkrani> createState() => _OyunEkraniState();

}



class _OyunEkraniState extends State<OyunEkrani> {

  // Skor ve can bilgisini tutan model

  late final OyunSkoru _oyunSkoru;

  late final PeriOyunu _oyun;



  @override

  void initState() {

    super.initState();

    _oyunSkoru = OyunSkoru();



    _oyun = PeriOyunu(

      oyunSkoru: _oyunSkoru,

      onOyunBitti: _oyunBitti,

    );

  }



  /// Oyun kazanıldığında veya kaybedildiğinde sonuç ekranına geç

  void _oyunBitti(String sonucMetni) {

    if (!mounted) {

      return;

    }



    // En iyi skoru kaydet (toplanan çiçek sayısına göre)

    SkorKayitServisi.instance.skorKaydet(_oyunSkoru.toplananCicek);



    Navigator.pushReplacement(

      context,

      MaterialPageRoute(

        builder: (context) => SonucEkrani(

          sonucMetni: sonucMetni,

          toplananCicek: _oyunSkoru.toplananCicek,

        ),

      ),

    );

  }



  @override

  void dispose() {

    _oyunSkoru.dispose();

    super.dispose();

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      // Flame arka planı göstereceği için scaffold rengi şeffaf

      backgroundColor: Colors.transparent,

      body: Stack(

        fit: StackFit.expand,

        children: [

          // Tam ekran Flame oyun alanı

          GameWidget(

            game: _oyun,

            autofocus: true,

          ),

          // Üst HUD: sol skor, sağ can paneli

          SafeArea(

            child: ListenableBuilder(

              listenable: _oyunSkoru,

              builder: (context, _) {

                return Stack(

                  children: [

                    // Sol üst — çiçek sayacı

                    Positioned(

                      top: 8,

                      left: 16,

                      child: SkorPaneli(

                        toplananCicek: _oyunSkoru.toplananCicek,

                      ),

                    ),

                    // Sağ üst — can kutusu (3 kalp)

                    Positioned(

                      top: 8,

                      right: 16,

                      child: CanPaneli(can: _oyunSkoru.can),

                    ),

                  ],

                );

              },

            ),

          ),

          // Mobil için basit yön kontrolü

          Positioned(

            left: 0,

            right: 0,

            bottom: 24,

            child: _MobilYonKontrolu(

              onYon: (dx, dy) => _oyun.mobilHareket(dx, dy),

            ),

          ),

        ],

      ),

    );

  }

}



/// Mobil cihazlar için ekran altı yön okları

class _MobilYonKontrolu extends StatelessWidget {

  const _MobilYonKontrolu({required this.onYon});



  // dx ve dy: -1, 0 veya 1

  final void Function(double dx, double dy) onYon;



  @override

  Widget build(BuildContext context) {

    Widget yonButonu(IconData ikon, double dx, double dy) {

      return Material(

        color: Colors.white.withValues(alpha: 0.75),

        shape: const CircleBorder(),

        child: InkWell(

          customBorder: const CircleBorder(),

          onTapDown: (_) => onYon(dx, dy),

          onTapUp: (_) => onYon(0, 0),

          onTapCancel: () => onYon(0, 0),

          child: SizedBox(

            width: 52,

            height: 52,

            child: Icon(ikon, color: Colors.pink.shade700),

          ),

        ),

      );

    }



    return Row(

      mainAxisAlignment: MainAxisAlignment.center,

      children: [

        yonButonu(Icons.arrow_back, -1, 0),

        const SizedBox(width: 8),

        Column(

          children: [

            yonButonu(Icons.arrow_upward, 0, -1),

            const SizedBox(height: 8),

            yonButonu(Icons.arrow_downward, 0, 1),

          ],

        ),

        const SizedBox(width: 8),

        yonButonu(Icons.arrow_forward, 1, 0),

      ],

    );

  }

}



/// Flame oyun sınıfı — geniş dünya + kamera takibi

class PeriOyunu extends FlameGame with HasKeyboardHandlerComponents {

  PeriOyunu({

    required this.oyunSkoru,

    required this.onOyunBitti,

  });



  final OyunSkoru oyunSkoru;

  final void Function(String sonucMetni) onOyunBitti;



  bool _oyunBitti = false;

  bool _oyunKuruldu = false;

  bool _oyunKuruluyor = false;

  bool _temelHazir = false;



  static const double _hasarBeklemeSuresi = 1.0;

  double _sonHasarZamani = -999;

  double _oyunSuresi = 0;



  Vector2 _mobilHareketYonu = Vector2.zero();



  // Geniş oyun dünyası boyutları (FlameGame'in yerleşik world/camera'sı kullanılır)

  double _dunyaGenisligi = 0;

  double _gorunenYukseklik = 0;



  // Nazlı ve objelerin yürüdüğü zemin çizgisi (anchor.center için merkez y)

  double _zeminY = 0;

  final Random _rastgele = Random();



  late NazliComponent _nazli;

  late EvComponent _ev;

  late IksirComponent _iksir;

  late KelebekComponent _kelebek;

  late KaraBulutComponent _karaBulut;

  late CadiComponent _cadi;



  bool _kelebekYakalandi = false;



  final List<CicekComponent> _cicekler = [];

  final List<DikenComponent> _dikenler = [];

  final List<CanavarComponent> _canavarlar = [];

  final List<YagmurDamlasiComponent> _yagmurDamlalari = [];

  final List<BuyuComponent> _buyuler = [];



  @override

  Color backgroundColor() => Colors.transparent;



  void mobilHareket(double dx, double dy) {

    _mobilHareketYonu = Vector2(dx, dy);

  }



  void _yagmurDamlesiEkle(YagmurDamlasiComponent damla) {

    _yagmurDamlalari.add(damla);

    world.add(damla);

  }



  /// Cadının fırlattığı büyüyü dünyaya ekler

  void _buyuEkle(BuyuComponent buyu) {

    _buyuler.add(buyu);

    world.add(buyu);

  }



  @override

  Future<void> onLoad() async {

    await super.onLoad();



    // Varsayılan viewfinder merkez (0,0)'da olduğu için arka plan sağ-alta kayar

    camera.viewfinder.anchor = Anchor.topLeft;

    camera.viewfinder.position = Vector2.zero();



    await images.loadAll([

      'arkaplan.png',

      'nazli.png',

      'pembe_cicek.png',

      'mavi_cicek.png',

      'mor_cicek.png',

      'diken.png',

      'ev.png',

      'canavar.png',

      'cadi.png',

      'karabulut.png',

      'kelebek.png',

      'iksir.png',

    ]);

    _temelHazir = true;



    // size onLoad'da henüz 0 olabilir; ilk geçerli boyutu bekle

    var deneme = 0;

    while ((size.x <= 0 || size.y <= 0) && deneme < 300) {

      await Future<void>.delayed(const Duration(milliseconds: 16));

      deneme++;

    }



    if (size.x <= 0 || size.y <= 0) {

      print('onLoad: geçerli boyut alınamadı, onGameResize bekleniyor');

      return;

    }



    _oyunKuruluyor = true;

    try {

      await _oyunuKur();

      _oyunKuruldu = true;

      print('onLoad: oyun kuruldu, _oyunKuruldu=true');

    } catch (e, st) {

      print('onLoad: oyun kurulum hatası: $e');

      print(st);

    } finally {

      _oyunKuruluyor = false;

    }

  }



  /// onLoad'da size henüz gelmediyse burada kurulumu tamamla

  @override

  void onGameResize(Vector2 size) {

    super.onGameResize(size);



    if (!_temelHazir ||

        _oyunKuruldu ||

        _oyunKuruluyor ||

        size.x <= 0 ||

        size.y <= 0) {

      return;

    }



    _oyunKuruluyor = true;

    _oyunuKur().then((_) {

      _oyunKuruldu = true;

      print('onGameResize: oyun kuruldu, _oyunKuruldu=true');

    }).catchError((Object e, StackTrace st) {

      print('onGameResize: oyun kurulum hatası: $e');

      print(st);

    }).whenComplete(() {

      _oyunKuruluyor = false;

    });

  }



  /// Tüm oyun nesnelerini geniş dünyaya ekler

  Future<void> _oyunuKur() async {

    if (_oyunKuruldu || world.children.isNotEmpty) {

      return;

    }



    print('oyun kuruluyor');



    _gorunenYukseklik = size.y;

    // Görünen ekranın 3 katı genişlikte dünya

    _dunyaGenisligi = size.x * 3;



    final dunyaY = _gorunenYukseklik;

    // Görünür zemin seviyesi — çiçek/canavar/cadı buraya yakın spawn olur

    _zeminY = dunyaY - 140;



    // 1) Arka plan — position (0,0), tüm oyun alanını kaplar

    await world.add(

      FlameArkaplanComponent(

        dunyaGenisligi: _dunyaGenisligi,

        dunyaYuksekligi: dunyaY,

      ),

    );



    // 2) Nazlı — diğer nesnelerden önce oluştur (update/cadı/canavar bunu kullanır)

    _nazli = NazliComponent(

      dunyaGenisligi: _dunyaGenisligi,

      gorunenYukseklik: dunyaY,

    );

    _nazli.priority = _oyunNesnesiOnceligi;

    await world.add(_nazli);



    // 3) Ev — haritanın en sonunda (ilk ekranda görünmez)

    _ev = EvComponent(

      konum: Vector2(_dunyaGenisligi - 180, dunyaY - 180),

      boyut: Vector2(96, 96),

    );

    _ev.priority = _oyunNesnesiOnceligi;

    await world.add(_ev);



    // 4) İksir (gizli) ve kelebek — haritanın orta bölgesinde

    final iksirKonumu = Vector2(_dunyaGenisligi * 0.52, dunyaY - 200);

    _iksir = IksirComponent(konum: iksirKonumu);

    _iksir.priority = _oyunNesnesiOnceligi;

    await world.add(_iksir);



    _kelebek = KelebekComponent(

      konum: Vector2(_dunyaGenisligi * 0.48, dunyaY - 220),

      iksirKonumu: iksirKonumu,

    );

    await world.add(_kelebek);



    // 5) Çiçekler, dikenler, canavarlar — haritaya yayılmış

    await _cicekleriOlustur();

    await _dikenleriOlustur();

    await _canavarlariOlustur();

    await _cadiOlustur();



    // 6) Kara bulut — tüm harita üzerinde gezinir

    _karaBulut = KaraBulutComponent(

      konum: Vector2(_dunyaGenisligi * 0.4, 70),

      boyut: Vector2(150, 75),

      onDamlaOlustur: _yagmurDamlesiEkle,

      dunyaGenisligi: _dunyaGenisligi,

    );

    _karaBulut.priority = 3;

    await world.add(_karaBulut);



    // Kamera başlangıçta solda

    camera.viewfinder.position = Vector2.zero();



    print('dunya children: ${world.children.length}');

    print('nazli position: ${_nazli.position}');

  }



  /// Nazlı sağa yürüdükçe kamera onu takip eder (yatay kaydırma)

  void _kamerayiTakipEt() {

    final hedefX = _nazli.position.x - size.x * 0.5;

    final maxX = (_dunyaGenisligi - size.x).clamp(0.0, double.infinity);

    camera.viewfinder.position = Vector2(

      hedefX.clamp(0.0, maxX),

      0,

    );

  }



  Future<void> _cicekleriOlustur() async {

    final cicekBoyutu = Vector2(55, 55);

    final w = _dunyaGenisligi;



    // Rastgele sadece yatay konum dağıtılıyor; y zemine yakın

    final cicekTanimlari = <(CicekTuru, double)>[

      (CicekTuru.pembe, w * 0.10),

      (CicekTuru.mavi, w * 0.22),

      (CicekTuru.mor, w * 0.35),

      (CicekTuru.pembe, w * 0.50),

      (CicekTuru.mavi, w * 0.68),

      (CicekTuru.mor, w * 0.85),

    ];



    for (final (tur, x) in cicekTanimlari) {

      // Objeler gökyüzünde çıkmasın diye zemine yakın yerleştirildi

      final y = _zeminY - 10 + _rastgele.nextDouble() * 20;

      final cicek = CicekComponent(

        tur: tur,

        konum: Vector2(x, y),

        boyut: cicekBoyutu,

      );

      cicek.priority = _oyunNesnesiOnceligi;

      _cicekler.add(cicek);

      await world.add(cicek);

    }

  }



  Future<void> _dikenleriOlustur() async {

    final w = _dunyaGenisligi;

    final h = _gorunenYukseklik;



    final dikenKonumlari = <Vector2>[

      Vector2(w * 0.18, h * 0.52),

      Vector2(w * 0.32, h * 0.40),

      Vector2(w * 0.48, h * 0.68),

      Vector2(w * 0.62, h * 0.48),

      Vector2(w * 0.78, h * 0.58),

    ];



    for (final konum in dikenKonumlari) {

      final diken = DikenComponent(konum: konum);

      diken.priority = _oyunNesnesiOnceligi;

      _dikenler.add(diken);

      await world.add(diken);

    }

  }



  Future<void> _canavarlariOlustur() async {

    final w = _dunyaGenisligi;

    final h = _gorunenYukseklik;



    // Objeler gökyüzünde çıkmasın diye zemine yakın yerleştirildi

    final yatayY = _zeminY - 20 + _rastgele.nextDouble() * 20;

    final dikeyY = _zeminY - 20 + _rastgele.nextDouble() * 20;



    final yatayCanavar = CanavarComponent(

      konum: Vector2(w * 0.30, yatayY),

      hareketYonu: CanavarHareketYonu.yatay,

      hiz: 140,

      dunyaGenisligi: w,

      gorunenYukseklik: h,

      zeminY: _zeminY,

    );

    yatayCanavar.priority = _oyunNesnesiOnceligi;

    _canavarlar.add(yatayCanavar);

    await world.add(yatayCanavar);



    final dikeyCanavar = CanavarComponent(

      konum: Vector2(w * 0.72, dikeyY),

      hareketYonu: CanavarHareketYonu.dikey,

      hiz: 110,

      dunyaGenisligi: w,

      gorunenYukseklik: h,

      zeminY: _zeminY,

    );

    dikeyCanavar.priority = _oyunNesnesiOnceligi;

    _canavarlar.add(dikeyCanavar);

    await world.add(dikeyCanavar);

  }



  /// Haritanın orta bölgesine cadı yerleştir — Nazlı'yı takip eder

  Future<void> _cadiOlustur() async {

    final w = _dunyaGenisligi;

    final h = _gorunenYukseklik;



    // Objeler gökyüzünde çıkmasın diye zemine yakın yerleştirildi

    _cadi = CadiComponent(

      konum: Vector2(w * 0.6, _zeminY - 60),

      nazli: _nazli,

      onBuyuOlustur: _buyuEkle,

      dunyaGenisligi: w,

      gorunenYukseklik: h,

      zeminY: _zeminY,

    );

    _cadi.priority = _oyunNesnesiOnceligi;

    await world.add(_cadi);

  }



  @override

  void update(double dt) {

    super.update(dt);



    // Oyun henüz kurulmadıysa veya bittiyse kontrolleri çalıştırma

    if (!_oyunKuruldu || _oyunBitti) {

      return;

    }



    _oyunSuresi += dt;



    // Klavye ile hareket (WASD / yön tuşları)

    _nazli.hareketEt(dt);



    // Mobil yön butonları ile hareket

    _nazli.mobilHareketEt(_mobilHareketYonu, dt);



    // Kamera Nazlı'yı yatayda takip eder

    _kamerayiTakipEt();



    _yagmurDamlalari.removeWhere((damla) => !damla.isMounted);

    _buyuler.removeWhere((buyu) => !buyu.isMounted);



    _kelebekCarpismasiniKontrolEt();

    _cicekCarpismalariniKontrolEt();

    _dikenCarpismalariniKontrolEt();

    _yagmurCarpismalariniKontrolEt();

    _buyuCarpismalariniKontrolEt();

    _cadiTemasKontrolEt();

    _canavarCarpismasiniKontrolEt();

    _evCarpismasiniKontrolEt();

    _kaybetmeKontrolEt();

  }



  /// Nazlı kelebeği yakalarsa iksir görünür olur

  void _kelebekCarpismasiniKontrolEt() {

    if (_kelebekYakalandi || !_kelebek.isMounted) {

      return;

    }



    if (_nazli.sinirlar.overlaps(_kelebek.sinirlar)) {

      _kelebekYakalandi = true;

      _kelebek.yakala();

      _iksir.goster();

    }

  }



  /// Nazlı çiçeğe değerse skor artır ve çiçeği kaldır

  void _cicekCarpismalariniKontrolEt() {

    for (final cicek in _cicekler) {

      if (cicek.toplandi) {

        continue;

      }



      if (_nazli.sinirlar.overlaps(cicek.sinirlar)) {

        cicek.toplandi = true;

        cicek.removeFromParent();

        oyunSkoru.cicekTopla();

      }

    }

  }



  /// Nazlı dikene değerse can azalt (cooldown ile)

  void _dikenCarpismalariniKontrolEt() {

    if (oyunSkoru.canBitti) {

      return;

    }



    final simdi = _oyunSuresi;

    var dikenTemas = false;



    for (final diken in _dikenler) {

      if (_nazli.sinirlar.overlaps(diken.sinirlar)) {

        dikenTemas = true;

        break;

      }

    }



    if (!dikenTemas) {

      return;

    }



    if (simdi - _sonHasarZamani < _hasarBeklemeSuresi) {

      return;

    }



    _sonHasarZamani = simdi;

    oyunSkoru.canAzalt();

  }



  /// Nazlı yağmur damlasına değerse can azalt ve damlayı kaldır

  void _yagmurCarpismalariniKontrolEt() {

    if (oyunSkoru.canBitti) {

      return;

    }



    for (final damla in _yagmurDamlalari.toList()) {

      if (!_nazli.sinirlar.overlaps(damla.sinirlar)) {

        continue;

      }



      damla.removeFromParent();

      _yagmurDamlalari.remove(damla);

      oyunSkoru.canAzalt();

      break;

    }

  }



  /// Büyü Nazlı'ya çarparsa can azalt (cooldown ile), büyüyü sil

  void _buyuCarpismalariniKontrolEt() {

    if (oyunSkoru.canBitti) {

      return;

    }



    for (final buyu in _buyuler.toList()) {

      if (!_nazli.sinirlar.overlaps(buyu.sinirlar)) {

        continue;

      }



      buyu.removeFromParent();

      _buyuler.remove(buyu);



      if (_oyunSuresi - _sonHasarZamani < _hasarBeklemeSuresi) {

        return;

      }



      _sonHasarZamani = _oyunSuresi;

      oyunSkoru.canAzalt();

      return;

    }

  }



  /// Cadıya temas edilirse de 1 can azalt (aynı hasar cooldown)

  void _cadiTemasKontrolEt() {

    if (oyunSkoru.canBitti || !_cadi.isMounted) {

      return;

    }



    if (!_nazli.sinirlar.overlaps(_cadi.sinirlar)) {

      return;

    }



    if (_oyunSuresi - _sonHasarZamani < _hasarBeklemeSuresi) {

      return;

    }



    _sonHasarZamani = _oyunSuresi;

    oyunSkoru.canAzalt();

  }



  /// Nazlı canavara değerse anında kaybet

  void _canavarCarpismasiniKontrolEt() {

    for (final canavar in _canavarlar) {

      if (_nazli.sinirlar.overlaps(canavar.sinirlar)) {

        _oyunuBitir('Canavara Yakalandın');

        return;

      }

    }

  }



  /// Nazlı eve ulaşırsa oyun kazanılır

  void _evCarpismasiniKontrolEt() {

    if (_nazli.sinirlar.overlaps(_ev.sinirlar)) {

      _oyunuBitir('Kazandın');

    }

  }



  /// Can bitti mi kontrol et

  void _kaybetmeKontrolEt() {

    if (oyunSkoru.canBitti) {

      _oyunuBitir('Kaybettin');

    }

  }



  /// Oyunu durdur ve sonuç ekranına yönlendir

  void _oyunuBitir(String sonucMetni) {

    if (_oyunBitti) {

      return;

    }



    _oyunBitti = true;

    pauseEngine();

    onOyunBitti(sonucMetni);

  }

}

