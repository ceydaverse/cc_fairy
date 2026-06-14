/// Çiçek türlerini temsil eden enum — pembe, mavi ve mor çiçekler
enum CicekTuru {
  pembe,
  mavi,
  mor,
}


extension CicekTuruUzantisi on CicekTuru {

  String get assetDosyaAdi {
    switch (this) {
      case CicekTuru.pembe:
        return 'pembe_cicek.png';
      case CicekTuru.mavi:
        return 'mavi_cicek.png';
      case CicekTuru.mor:
        return 'mor_cicek.png';
    }
  }

  /// Flutter Image.asset / AssetImage için tam yol
  String get flutterAssetYolu => 'assets/images/$assetDosyaAdi';
}
