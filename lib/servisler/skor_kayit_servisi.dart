/// En iyi skor kaydı için basit servis — şimdilik bellekte tutulur
class SkorKayitServisi {
  SkorKayitServisi._();

  
  static final SkorKayitServisi instance = SkorKayitServisi._();

  int _enIyiSkor = 0;

  /// Kayıtlı en iyi skoru döndürür
  int get enIyiSkor => _enIyiSkor;

  /// Yeni skoru kaydeder; öncekinden yüksekse günceller
  void skorKaydet(int skor) {
    if (skor > _enIyiSkor) {
      _enIyiSkor = skor;
    }
  }

  /// Kaydı sıfırlar (test veya ileride kullanım için)
  void sifirla() {
    _enIyiSkor = 0;
  }
}
