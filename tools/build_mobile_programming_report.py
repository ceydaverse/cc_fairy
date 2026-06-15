from __future__ import annotations

from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    Image,
    KeepTogether,
    PageBreak,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets" / "images"
DOCS = ROOT / "docs"
DOCS.mkdir(exist_ok=True)
PDF_PATH = DOCS / "Mobil_Programlama_Proje_Raporu.pdf"

pdfmetrics.registerFont(TTFont("ArialTR", r"C:\Windows\Fonts\arial.ttf"))
pdfmetrics.registerFont(TTFont("ArialTR-Bold", r"C:\Windows\Fonts\arialbd.ttf"))

PINK = colors.HexColor("#C2185B")
BLUE = colors.HexColor("#1F4E79")
DARK = colors.HexColor("#202124")
MUTED = colors.HexColor("#5F6368")
LIGHT_BLUE = colors.HexColor("#E8EEF5")
LIGHT_PINK = colors.HexColor("#FFF4FA")
GRID = colors.HexColor("#DADCE0")

styles = getSampleStyleSheet()
styles.add(ParagraphStyle("BodyTR", fontName="ArialTR", fontSize=10.5, leading=14, textColor=DARK, spaceAfter=7))
styles.add(ParagraphStyle("SmallTR", fontName="ArialTR", fontSize=9, leading=11.5, textColor=MUTED, spaceAfter=4))
styles.add(ParagraphStyle("TitleTR", fontName="ArialTR-Bold", fontSize=26, leading=32, textColor=PINK, alignment=TA_CENTER, spaceAfter=8))
styles.add(ParagraphStyle("SubtitleTR", fontName="ArialTR-Bold", fontSize=14, leading=18, textColor=DARK, alignment=TA_CENTER, spaceAfter=14))
styles.add(ParagraphStyle("H1TR", fontName="ArialTR-Bold", fontSize=15, leading=19, textColor=BLUE, spaceBefore=12, spaceAfter=7))
styles.add(ParagraphStyle("H2TR", fontName="ArialTR-Bold", fontSize=12.5, leading=16, textColor=BLUE, spaceBefore=8, spaceAfter=5))
styles.add(ParagraphStyle("TableTR", fontName="ArialTR", fontSize=9.2, leading=11.5, textColor=DARK))
styles.add(ParagraphStyle("TableBoldTR", fontName="ArialTR-Bold", fontSize=9.2, leading=11.5, textColor=DARK))


def p(text: str, style: str = "BodyTR") -> Paragraph:
    return Paragraph(text, styles[style])


def bullet(text: str) -> Paragraph:
    return Paragraph(f"• {text}", styles["BodyTR"])


def img(name: str, width_cm: float) -> Image:
    image = Image(str(ASSETS / name))
    ratio = image.imageHeight / image.imageWidth
    image.drawWidth = width_cm * cm
    image.drawHeight = width_cm * cm * ratio
    return image


def table(data, widths, header=True):
    tbl = Table(data, colWidths=[w * cm for w in widths], hAlign="LEFT", repeatRows=1 if header else 0)
    commands = [
        ("GRID", (0, 0), (-1, -1), 0.5, GRID),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("LEFTPADDING", (0, 0), (-1, -1), 6),
        ("RIGHTPADDING", (0, 0), (-1, -1), 6),
        ("TOPPADDING", (0, 0), (-1, -1), 5),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
    ]
    if header:
        commands += [("BACKGROUND", (0, 0), (-1, 0), LIGHT_BLUE)]
    tbl.setStyle(TableStyle(commands))
    return tbl


def add_cover(story):
    story.append(Spacer(1, 1.6 * cm))
    story.append(p("KAYSERİ ÜNİVERSİTESİ", "SubtitleTR"))
    story.append(p("Bilgisayar Mühendisliği Bölümü", "SubtitleTR"))
    story.append(p("Mobil Programlama Dersi", "SubtitleTR"))
    story.append(Spacer(1, 0.4 * cm))
    nazli = img("nazli.png", 3.4)
    nazli.hAlign = "CENTER"
    story.append(nazli)
    story.append(Spacer(1, 0.5 * cm))
    story.append(p("Nazlı'nın Çiçek Bahçesi", "TitleTR"))
    story.append(p("Mobil Oyun Proje Raporu", "SubtitleTR"))

    team = table(
        [
            [p("Proje Ekibi", "TableBoldTR"), p("Okul Numarası", "TableBoldTR")],
            [p("Hürü Ceren Genç", "TableTR"), p("23103021703", "TableTR")],
            [p("Ceyda Özcan", "TableTR"), p("221030210034", "TableTR")],
        ],
        [8.0, 5.0],
    )
    team.setStyle(TableStyle([("BACKGROUND", (0, 1), (-1, -1), LIGHT_PINK)]))
    story.append(team)
    story.append(Spacer(1, 1.0 * cm))
    story.append(p("Kayseri, 2026", "SubtitleTR"))
    story.append(PageBreak())


def add_asset_strip(story):
    rows = [
        [img("nazli.png", 1.35), img("cadi.png", 1.35), img("canavar.png", 1.35), img("iksir.png", 1.35), img("agac_1.png", 1.35)],
        [p("Nazlı", "TableTR"), p("Cadı", "TableTR"), p("Canavar", "TableTR"), p("İksir", "TableTR"), p("Sihirli Ağaç", "TableTR")],
    ]
    tbl = table(rows, [3.0, 3.0, 3.0, 3.0, 3.0], header=False)
    tbl.setStyle(TableStyle([("ALIGN", (0, 0), (-1, -1), "CENTER")]))
    story.append(tbl)


def add_body(story):
    story.append(p("1. Projenin Amacı", "H1TR"))
    story.append(p(
        "Bu proje, Mobil Programlama dersi kapsamında Flutter ve Flame kullanılarak geliştirilen 2B bir mobil oyundur. "
        "Oyunda oyuncu, Nazlı adlı karakteri kontrol ederek çiçek toplar, engellerden kaçar, cadının büyülerinden korunur "
        "ve haritanın sonundaki eve ulaşmaya çalışır."
    ))
    story.append(p(
        "Projenin temel amacı; mobil cihazlarda çalışan, dokunmatik kontrolleri destekleyen, görsel olarak anlaşılır ve "
        "oynanabilir bir oyun uygulaması geliştirmektir."
    ))

    story.append(p("2. Kullanılan Teknolojiler", "H1TR"))
    story.append(table([
        [p("Teknoloji", "TableBoldTR"), p("Projede Kullanım Amacı", "TableBoldTR")],
        [p("Flutter", "TableTR"), p("Mobil uygulama arayüzü ve proje çatısı için kullanılmıştır.", "TableTR")],
        [p("Dart", "TableTR"), p("Oyun mantığı, bileşenler ve durum yönetimi Dart diliyle yazılmıştır.", "TableTR")],
        [p("Flame", "TableTR"), p("Oyun motoru, sprite yönetimi, game loop ve bileşen yapısı için kullanılmıştır.", "TableTR")],
        [p("Asset sistemi", "TableTR"), p("Karakter, arka plan, çiçek, iksir ve diğer görseller assets/images klasöründen yüklenmiştir.", "TableTR")],
        [p("path_provider", "TableTR"), p("Platforma özgü dosya yolları ve skor kaydı gibi servislerde kullanılmak üzere projeye eklenmiştir.", "TableTR")],
    ], [4.0, 12.0]))

    story.append(p("3. Oyun Özeti", "H1TR"))
    story.append(p(
        "Nazlı'nın Çiçek Bahçesi, masalsı bir bahçe atmosferinde geçen yandan görünümlü bir oyundur. "
        "Oyuncu Nazlı'yı yönlendirerek çiçekleri toplar ve skor kazanır. Cadı, canavar, diken ve yağmur gibi tehlikeler "
        "oyuncunun canını azaltır. Kelebek ve sihirli ağaç gibi yardımcı öğeler ise oyuncuya geçici avantaj sağlar."
    ))
    add_asset_strip(story)

    story.append(p("4. Mobil Programlama Açısından Özellikler", "H1TR"))
    for item in [
        "Oyun, Flutter projesi olarak Android cihazda çalışacak şekilde yapılandırılmıştır.",
        "Ekran altındaki yön butonları mobil cihazlarda dokunmatik kontrol sağlar.",
        "Sihir butonu, mobil oyuncuların klavyeye ihtiyaç duymadan özel yetenek kullanabilmesini sağlar.",
        "HUD alanında skor ve can bilgileri sürekli güncellenir.",
        "Oyun dünyası geniş tutulmuş, kamera Nazlı'yı takip edecek şekilde ayarlanmıştır.",
        "Görseller asset sistemi üzerinden yüklenerek mobil uygulama paketine dahil edilmiştir.",
    ]:
        story.append(bullet(item))

    story.append(p("5. Temel Oyun Mekanikleri", "H1TR"))
    story.append(table([
        [p("Mekanik", "TableBoldTR"), p("Açıklama", "TableBoldTR")],
        [p("Hareket", "TableTR"), p("Nazlı; klavye, sürükleme ve mobil yön butonları ile hareket edebilir.", "TableTR")],
        [p("Çiçek toplama", "TableTR"), p("Nazlı çiçeğe temas ettiğinde skor artar ve çiçek sahneden kaldırılır.", "TableTR")],
        [p("Can sistemi", "TableTR"), p("Başlangıçta 10 can vardır. Tehlikeler canı 1 azaltır.", "TableTR")],
        [p("Cadı büyüsü", "TableTR"), p("Mor büyü Nazlı'ya çarptığında can azalır.", "TableTR")],
        [p("İksir", "TableTR"), p("Kelebek yakalanınca görünür olur; alındığında cadıyı 5 saniye susturur.", "TableTR")],
        [p("Sihirli ağaç", "TableTR"), p("Nazlı'ya 10 saniyelik sihir gücü verir.", "TableTR")],
        [p("Game over", "TableTR"), p("Can 0 olduğunda Nazlı şatoya doğru çekilir ve sonuç ekranı açılır.", "TableTR")],
    ], [4.0, 12.0]))

    story.append(p("6. Kod Yapısı ve Bileşenler", "H1TR"))
    story.append(table([
        [p("Dosya / Bileşen", "TableBoldTR"), p("Görevi", "TableBoldTR")],
        [p("OyunEkrani / PeriOyunu", "TableTR"), p("Oyun döngüsü, kamera, çarpışma kontrolleri ve oyun bitiş akışını yönetir.", "TableTR")],
        [p("NazliComponent", "TableTR"), p("Oyuncu karakterinin hareketini ve sihir gücünü yönetir.", "TableTR")],
        [p("CadiComponent", "TableTR"), p("Cadının hareketini, büyü üretimini ve geçici susturma durumunu yönetir.", "TableTR")],
        [p("BuyuComponent", "TableTR"), p("Cadının mor büyüsünü temsil eder.", "TableTR")],
        [p("NazliBuyuComponent", "TableTR"), p("Nazlı'nın ağaçtan güç aldıktan sonra attığı sihri temsil eder.", "TableTR")],
        [p("IksirComponent", "TableTR"), p("İksirin görünürlük, fade-in ve kullanım durumunu yönetir.", "TableTR")],
        [p("OyunSkoru", "TableTR"), p("Toplanan çiçek sayısı ve kalan can bilgisini tutar.", "TableTR")],
        [p("CanPaneli / SkorPaneli", "TableTR"), p("Oyuncuya can ve skor bilgisini gösteren arayüz bileşenleridir.", "TableTR")],
    ], [4.8, 11.2]))

    story.append(p("7. Arayüz ve Kullanıcı Deneyimi", "H1TR"))
    story.append(p(
        "Oyunun arayüzünde sol üstte toplanan çiçek sayısı, sağ üstte ise can paneli yer alır. Can paneli 10 kalp üzerinden "
        "oyuncunun kalan canını gösterir. Ekran altındaki mobil kontrol butonları, oyunun telefon ekranında rahat oynanmasını sağlar."
    ))
    story.append(p(
        "Görsel tasarımda piksel sanat tarzı tercih edilmiştir. Arka plan, karakterler ve nesneler masalsı bir atmosfer oluşturacak "
        "şekilde seçilmiştir."
    ))

    story.append(p("8. Test ve Doğrulama", "H1TR"))
    for item in [
        "Çiçek toplandığında skorun arttığı kontrol edilmiştir.",
        "Cadı büyüsü, yağmur, diken ve canavar temaslarının can sistemine etkisi test edilmiştir.",
        "Kelebek yakalandığında iksirin görünür hâle geldiği ve iksir alındığında cadının sustuğu doğrulanmıştır.",
        "Sihirli ağacın Nazlı'ya 10 saniye sihir gücü verdiği kontrol edilmiştir.",
        "Can 0 olduğunda game over akışının çalıştığı gözlemlenmiştir.",
        "Mobil kontrol butonları ve sihir butonu test edilmiştir.",
    ]:
        story.append(bullet(item))

    story.append(p("9. Karşılaşılan Sorunlar ve Çözümler", "H1TR"))
    story.append(table([
        [p("Sorun", "TableBoldTR"), p("Çözüm", "TableBoldTR")],
        [p("Cadı büyüsü ve yağmur hasarı algılanmıyordu.", "TableTR"), p("Aktif Flame world çocukları üzerinden çarpışma taraması yapılarak sorun giderildi.", "TableTR")],
        [p("İksir görünmeden kaybolabiliyordu.", "TableTR"), p("İksire fade-in ve kısa toplanabilir gecikme eklendi.", "TableTR")],
        [p("Can paneli fazla büyük görünüyordu.", "TableTR"), p("Kalpler kompakt ve eşit boyutta gösterilecek şekilde düzenlendi.", "TableTR")],
        [p("Ağaç sihri tek kullanımlık kalıyordu.", "TableTR"), p("Nazlı'nın 10 saniye boyunca sihir atabilmesi sağlandı.", "TableTR")],
    ], [6.0, 10.0]))

    story.append(p("10. Sonuç", "H1TR"))
    story.append(p(
        "Bu proje kapsamında Flutter ve Flame kullanılarak mobil cihazlarda çalışabilen, etkileşimli ve görsel öğeleri zengin "
        "bir 2B oyun geliştirilmiştir. Proje; oyun döngüsü, dokunmatik kontroller, çarpışma mantığı, can sistemi, skor takibi, "
        "asset yönetimi ve durum güncelleme gibi mobil programlama açısından önemli konuları uygulamalı olarak içermektedir."
    ))
    story.append(p(
        "Geliştirilen oyun, ilerleyen aşamalarda ses efektleri, bölüm sistemi, animasyonlu sprite yapısı ve farklı güçlendirmeler "
        "eklenerek daha kapsamlı bir mobil oyun hâline getirilebilir."
    ))


def footer(canvas, doc):
    canvas.saveState()
    canvas.setFont("ArialTR", 8)
    canvas.setFillColor(MUTED)
    canvas.drawString(2 * cm, 1.1 * cm, "Mobil Programlama Dersi | Nazlı'nın Çiçek Bahçesi")
    canvas.drawRightString(A4[0] - 2 * cm, 1.1 * cm, f"Sayfa {doc.page}")
    canvas.restoreState()


def main():
    story = []
    add_cover(story)
    add_body(story)
    doc = SimpleDocTemplate(
        str(PDF_PATH),
        pagesize=A4,
        leftMargin=2 * cm,
        rightMargin=2 * cm,
        topMargin=1.8 * cm,
        bottomMargin=1.8 * cm,
        title="Mobil Programlama Dersi Proje Raporu",
        author="Hürü Ceren Genç, Ceyda Özcan",
    )
    doc.build(story, onFirstPage=footer, onLaterPages=footer)
    print(PDF_PATH)


if __name__ == "__main__":
    main()
