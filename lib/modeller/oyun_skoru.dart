import 'package:flutter/foundation.dart';

/// Oyun sırasında skor ve can bilgisini tutan basit model
class OyunSkoru extends ChangeNotifier {
  // Başlangıç can değeri
  static const int baslangicCan = 3;

  int _can = baslangicCan;
  int _toplananCicek = 0;

  /// Kalan can sayısı
  int get can => _can;

  /// Toplanan çiçek sayısı
  int get toplananCicek => _toplananCicek;

  /// Oyuncu canı bitti mi?
  bool get canBitti => _can <= 0;

  /// Nazlı bir çiçek topladığında skoru artır
  void cicekTopla() {
    _toplananCicek++;
    notifyListeners();
  }

  /// Diken temasında can azalt; can kaldıysa true döner
  bool canAzalt() {
    if (_can <= 0) {
      return false;
    }

    _can--;
    notifyListeners();
    return true;
  }

  /// Yeni oyun başlarken skor ve canı sıfırla
  void sifirla() {
    _can = baslangicCan;
    _toplananCicek = 0;
    notifyListeners();
  }
}
