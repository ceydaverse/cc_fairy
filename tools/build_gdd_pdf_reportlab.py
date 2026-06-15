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
PDF_PATH = DOCS / "Nazlinin_Cicek_Bahcesi_GDD.pdf"


FONT_REGULAR = r"C:\Windows\Fonts\arial.ttf"
FONT_BOLD = r"C:\Windows\Fonts\arialbd.ttf"
pdfmetrics.registerFont(TTFont("ArialTR", FONT_REGULAR))
pdfmetrics.registerFont(TTFont("ArialTR-Bold", FONT_BOLD))


PINK = colors.HexColor("#C2185B")
BLUE = colors.HexColor("#1F4E79")
DARK = colors.HexColor("#202124")
MUTED = colors.HexColor("#5F6368")
LIGHT_PINK = colors.HexColor("#FFF4FA")
LIGHT_BLUE = colors.HexColor("#E8EEF5")
GRID = colors.HexColor("#DADCE0")


styles = getSampleStyleSheet()
styles.add(
    ParagraphStyle(
        name="TRBody",
        fontName="ArialTR",
        fontSize=10.5,
        leading=14,
        textColor=DARK,
        alignment=TA_LEFT,
        spaceAfter=7,
    )
)
styles.add(
    ParagraphStyle(
        name="TRSmall",
        fontName="ArialTR",
        fontSize=9,
        leading=12,
        textColor=MUTED,
        spaceAfter=4,
    )
)
styles.add(
    ParagraphStyle(
        name="TRTitle",
        fontName="ArialTR-Bold",
        fontSize=26,
        leading=32,
        textColor=PINK,
        alignment=TA_CENTER,
        spaceAfter=8,
    )
)
styles.add(
    ParagraphStyle(
        name="TRSubtitle",
        fontName="ArialTR-Bold",
        fontSize=15,
        leading=20,
        textColor=DARK,
        alignment=TA_CENTER,
        spaceAfter=20,
    )
)
styles.add(
    ParagraphStyle(
        name="TRH1",
        fontName="ArialTR-Bold",
        fontSize=15,
        leading=19,
        textColor=BLUE,
        spaceBefore=12,
        spaceAfter=7,
    )
)
styles.add(
    ParagraphStyle(
        name="TRH2",
        fontName="ArialTR-Bold",
        fontSize=12.5,
        leading=16,
        textColor=BLUE,
        spaceBefore=8,
        spaceAfter=5,
    )
)
styles.add(
    ParagraphStyle(
        name="TRTable",
        fontName="ArialTR",
        fontSize=9.2,
        leading=11.5,
        textColor=DARK,
    )
)
styles.add(
    ParagraphStyle(
        name="TRTableBold",
        fontName="ArialTR-Bold",
        fontSize=9.2,
        leading=11.5,
        textColor=DARK,
    )
)


def p(text: str, style: str = "TRBody") -> Paragraph:
    return Paragraph(text, styles[style])


def bullet(text: str) -> Paragraph:
    return Paragraph(f"• {text}", styles["TRBody"])


def numbered(index: int, text: str) -> Paragraph:
    return Paragraph(f"{index}. {text}", styles["TRBody"])


def img(name: str, width_cm: float) -> Image:
    path = ASSETS / name
    image = Image(str(path))
    ratio = image.imageHeight / image.imageWidth
    image.drawWidth = width_cm * cm
    image.drawHeight = width_cm * cm * ratio
    return image


def table(data, widths, header=True):
    tbl = Table(data, colWidths=[w * cm for w in widths], hAlign="LEFT", repeatRows=1 if header else 0)
    style = [
        ("GRID", (0, 0), (-1, -1), 0.5, GRID),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("LEFTPADDING", (0, 0), (-1, -1), 6),
        ("RIGHTPADDING", (0, 0), (-1, -1), 6),
        ("TOPPADDING", (0, 0), (-1, -1), 5),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
    ]
    if header:
        style += [
            ("BACKGROUND", (0, 0), (-1, 0), LIGHT_BLUE),
            ("FONTNAME", (0, 0), (-1, 0), "ArialTR-Bold"),
        ]
    tbl.setStyle(TableStyle(style))
    return tbl


def asset_rows(items):
    rows = [[p("Görsel", "TRTableBold"), p("Varlık", "TRTableBold"), p("Oyundaki görevi", "TRTableBold")]]
    for image_name, name, role in items:
        rows.append([
            img(image_name, 1.65 if image_name != "arkaplan.png" else 2.25),
            p(name, "TRTableBold"),
            p(role, "TRTable"),
        ])
    return rows


def add_cover(story):
    story.append(Spacer(1, 2.0 * cm))
    story.append(p("KAYSERİ ÜNİVERSİTESİ", "TRSubtitle"))
    story.append(p("Bilgisayar Mühendisliği Bölümü", "TRSubtitle"))
    story.append(Spacer(1, 0.4 * cm))
    story.append(img("nazli.png", 3.5))
    story[-1].hAlign = "CENTER"
    story.append(Spacer(1, 0.6 * cm))
    story.append(p("Nazlı'nın Çiçek Bahçesi", "TRTitle"))
    story.append(p("Oyun Tasarım Dokümanı (GDD)", "TRSubtitle"))
    cover_table = table(
        [
            [p("Hazırlayan", "TRTableBold"), p("Bilgisayar Mühendisliği 4. Sınıf Öğrencisi", "TRTable")],
            [p("Okul Numarası", "TRTableBold"), p("23103021703", "TRTable")],
            [p("Ders / Çalışma", "TRTableBold"), p("Oyun Tasarımı ve Geliştirme Projesi", "TRTable")],
            [p("Teknoloji", "TRTableBold"), p("Flutter + Flame", "TRTable")],
        ],
        [4.1, 9.7],
        header=False,
    )
    cover_table.setStyle(TableStyle([("BACKGROUND", (0, 0), (0, -1), LIGHT_PINK)]))
    story.append(cover_table)
    story.append(Spacer(1, 1.2 * cm))
    story.append(p("Kayseri, 2026", "TRSubtitle"))
    story.append(PageBreak())


def add_body(story):
    story.append(p("1. Oyun Özeti", "TRH1"))
    story.append(p(
        "Nazlı'nın Çiçek Bahçesi, Flutter ve Flame kullanılarak geliştirilen 2B yandan görünümlü bir macera oyunudur. "
        "Oyuncu, Nazlı adlı peri/prenses karakterini kontrol ederek çiçek toplar, tehlikelerden kaçar ve bölüm sonundaki eve ulaşmaya çalışır."
    ))
    story.append(p(
        "Oyun; renkli piksel sanat görselleri, basit mobil kontroller, can sistemi ve geçici güçlendirmeler üzerine kuruludur. "
        "Cadı mor büyülerle oyuncuyu zorlar; kelebek, iksir ve sihirli ağaç gibi yardımcı öğeler ise oyuncuya kısa süreli avantaj sağlar."
    ))

    story.append(p("2. Tasarım Hedefleri", "TRH1"))
    for item in [
        "Oyuncunun ilk dakikada anlayabileceği basit bir kontrol yapısı sunmak.",
        "Çiçek toplama, kaçınma ve güçlendirme döngüsünü net biçimde hissettirmek.",
        "Çocuk dostu, masalsı ve renkli bir atmosfer oluşturmak.",
        "Mobil ekranda rahat okunabilen bir arayüz ve HUD tasarlamak.",
        "Tehlike ve ödül öğelerini dengeli biçimde konumlandırmak.",
    ]:
        story.append(bullet(item))

    story.append(p("3. Temel Oyun Döngüsü", "TRH1"))
    steps = [
        "Oyuncu, Nazlı'yı haritada hareket ettirir.",
        "Çiçekleri toplayarak skor kazanır.",
        "Diken, yağmur, canavar ve cadının mor büyüsünden kaçınır.",
        "Kelebeğe dokunursa iksir görünür hâle gelir.",
        "İksiri alırsa cadı 5 saniye boyunca büyü atamaz.",
        "Sihirli ağaca dokunursa Nazlı 10 saniye boyunca sihir atabilir.",
        "Nazlı'nın sihri cadıya çarparsa cadı 5 saniye boyunca büyü atamaz.",
        "Canlar bitmeden eve ulaşılırsa oyun kazanılır.",
    ]
    for idx, step in enumerate(steps, start=1):
        story.append(numbered(idx, step))

    story.append(p("4. Karakterler ve Mekanikler", "TRH1"))
    story.append(p("4.1 Nazlı", "TRH2"))
    story.append(p("Nazlı, oyuncunun kontrol ettiği ana karakterdir. Klavye, mobil yön butonları ve sürükleme hareketiyle hareket edebilir. Normal durumda sihir atamaz; sihirli ağaçtan güç aldığında 10 saniye boyunca sihir kullanabilir."))
    story.append(p("4.2 Cadı", "TRH2"))
    story.append(p("Cadı, Nazlı'yı takip eden ve belirli aralıklarla mor büyü fırlatan düşman karakterdir. İksir veya Nazlı'nın sihri cadıyı 5 saniye boyunca büyü atamaz hâle getirir."))
    story.append(p("4.3 Canavar / Hayalet", "TRH2"))
    story.append(p("Canavar, haritada hareket eden tehlikeli bir varlıktır. Nazlı canavara temas ettiğinde oyun doğrudan bitmez; yalnızca 1 can azalır. Hasar bekleme süresi, aynı temasın bütün canları hızlıca tüketmesini engeller."))

    story.append(p("5. Can ve Hasar Sistemi", "TRH1"))
    story.append(table([
        [p("Öğe", "TRTableBold"), p("Etkisi", "TRTableBold"), p("Not", "TRTableBold")],
        [p("Başlangıç canı", "TRTable"), p("10 can", "TRTable"), p("HUD üzerinde kalp simgeleriyle gösterilir.", "TRTable")],
        [p("Cadı büyüsü", "TRTable"), p("1 can azaltır", "TRTable"), p("Büyü Nazlı'ya çarptığında çalışır.", "TRTable")],
        [p("Yağmur damlası", "TRTable"), p("1 can azaltır", "TRTable"), p("Her damla peş peşe can götürmez; bekleme süresi vardır.", "TRTable")],
        [p("Canavar", "TRTable"), p("1 can azaltır", "TRTable"), p("Doğrudan game over yapmaz.", "TRTable")],
        [p("Diken", "TRTable"), p("1 can azaltır", "TRTable"), p("Sürekli temas için bekleme süresi kullanılır.", "TRTable")],
    ], [3.2, 3.2, 9.0]))
    story.append(p("Can 0 olduğunda oyun kaybedilir. Kaybetme durumunda Nazlı bir anda ışınlanmaz; cadı şatosuna doğru hareket efektiyle çekilir ve ardından sonuç ekranı açılır."))

    story.append(p("6. Yardımcı Öğeler", "TRH1"))
    story.append(p("6.1 Kelebek ve İksir", "TRH2"))
    story.append(p("Kelebek yakalandığında iksir görünür hâle gelir. İksir, oyuncunun erişebileceği ve kameranın içinde kalan bir konuma taşınır. Fade-in animasyonu sırasında hemen toplanamaz; böylece oyuncu iksirin ortaya çıktığını görebilir. Nazlı iksire temas ettiğinde cadı 5 saniye boyunca büyü atamaz."))
    story.append(p("6.2 Sihirli Ağaç", "TRH2"))
    story.append(p("Sihirli ağaç, Nazlı'ya 10 saniyelik sihir gücü verir. Bu süre boyunca Nazlı, Space tuşu veya mobil sihir butonu ile sihir atabilir. Sihir cadıya çarptığında cadının büyü atması 5 saniye durdurulur."))

    story.append(p("7. Kazanma ve Kaybetme Koşulları", "TRH1"))
    story.append(p("Oyuncu, Nazlı'yı haritanın sonundaki eve ulaştırdığında oyunu kazanır. Nazlı'nın canı 0 olduğunda ise oyun kaybedilir. Sonuç ekranında toplanan çiçek sayısı gösterilir."))

    story.append(p("8. Arayüz ve Kontroller", "TRH1"))
    for item in [
        "Sol üstte toplanan çiçek sayısı gösterilir.",
        "Sağ üstte 10 kalpten oluşan can paneli bulunur.",
        "Mobil oyuncular için ekran altında yön butonları yer alır.",
        "Ağaçtan sihir gücü alındığında mobil sihir butonu kullanılabilir.",
    ]:
        story.append(bullet(item))

    story.append(PageBreak())
    story.append(p("9. Görsel Varlıklar", "TRH1"))
    asset_sections = [
        ("9.1 Ana Karakterler ve Düşmanlar", [
            ("nazli.png", "Nazlı", "Oyuncunun kontrol ettiği ana karakter."),
            ("cadi.png", "Cadı", "Nazlı'yı takip eden ve mor büyü atan düşman."),
            ("canavar.png", "Canavar / Hayalet", "Temas ettiğinde 1 can azaltan hareketli düşman."),
            ("cadi_satosu.png", "Cadı Şatosu", "Başlangıç dekoru ve kaybetme animasyonunun hedef noktası."),
        ]),
        ("9.2 Toplanabilir ve Yardımcı Öğeler", [
            ("pembe_cicek.png", "Pembe Çiçek", "Skor kazandıran toplanabilir çiçek."),
            ("mavi_cicek.png", "Mavi Çiçek", "Skor kazandıran toplanabilir çiçek."),
            ("mor_cicek.png", "Mor Çiçek", "Skor kazandıran toplanabilir çiçek."),
            ("kelebek.png", "Kelebek", "Yakalandığında iksiri ortaya çıkarır."),
            ("iksir.png", "İksir", "Cadının büyü atmasını 5 saniye durdurur."),
            ("kalp.png", "Kalp", "Can panelindeki dolu can göstergesidir."),
        ]),
        ("9.3 Çevre ve Engel Görselleri", [
            ("arkaplan.png", "Arka Plan", "Oyunun masalsı bahçe atmosferini oluşturur."),
            ("agac_1.png", "Sihirli Ağaç 1", "Nazlı'ya geçici sihir gücü verir."),
            ("agac_2.png", "Sihirli Ağaç 2", "Nazlı'ya geçici sihir gücü verir."),
            ("diken.png", "Diken", "Temas edildiğinde can azaltan sabit engeldir."),
            ("karabulut.png", "Kara Bulut", "Yağmur damlaları oluşturan hareketli tehlikedir."),
            ("ev.png", "Ev", "Nazlı ulaştığında kazanma koşulunu tamamlayan hedeftir."),
        ]),
    ]
    for title, items in asset_sections:
        story.append(KeepTogether([p(title, "TRH2"), table(asset_rows(items), [2.7, 3.6, 9.9])]))

    story.append(p("10. Teknik Tasarım", "TRH1"))
    story.append(table([
        [p("Başlık", "TRTableBold"), p("Açıklama", "TRTableBold")],
        [p("Oyun motoru", "TRTable"), p("Flutter + Flame", "TRTable")],
        [p("Ana ekran", "TRTable"), p("OyunEkrani ve PeriOyunu sınıfları", "TRTable")],
        [p("Karakter bileşeni", "TRTable"), p("NazliComponent", "TRTable")],
        [p("Düşman bileşenleri", "TRTable"), p("CadiComponent, CanavarComponent", "TRTable")],
        [p("Mermi ve etki bileşenleri", "TRTable"), p("BuyuComponent, NazliBuyuComponent", "TRTable")],
        [p("Skor ve can modeli", "TRTable"), p("OyunSkoru", "TRTable")],
        [p("Çarpışma yaklaşımı", "TRTable"), p("Flame componentleri üzerinden Rect tabanlı kontrol", "TRTable")],
    ], [4.0, 12.2]))

    story.append(p("11. Denge Değerleri", "TRH1"))
    story.append(table([
        [p("Değer", "TRTableBold"), p("Mevcut ayar", "TRTableBold")],
        [p("Başlangıç canı", "TRTable"), p("10", "TRTable")],
        [p("Ağaç sihri süresi", "TRTable"), p("10 saniye", "TRTable")],
        [p("Cadı susturma süresi", "TRTable"), p("5 saniye", "TRTable")],
        [p("Hasar bekleme süresi", "TRTable"), p("Yaklaşık 1 saniye", "TRTable")],
        [p("Nazlı sihir atış aralığı", "TRTable"), p("0,5 saniye", "TRTable")],
        [p("İksir toplanabilir gecikmesi", "TRTable"), p("Kısa fade-in süresi", "TRTable")],
    ], [6.0, 10.2]))

    story.append(p("12. Gelecek Geliştirme Önerileri", "TRH1"))
    for item in [
        "Bölüm sistemi ve zorluk artışı eklenebilir.",
        "Ses efektleri ve arka plan müziği geliştirilebilir.",
        "Sprite sheet tabanlı yürüme ve hasar animasyonları eklenebilir.",
        "Farklı iksir türleri ve güçlendirmeler tasarlanabilir.",
        "Ana menüye ayarlar ve yardım ekranı eklenebilir.",
    ]:
        story.append(bullet(item))

    story.append(p("13. Başarı Kriterleri", "TRH1"))
    for item in [
        "Oyuncu, Nazlı'yı rahatça kontrol edebilmelidir.",
        "Çiçek toplama ve skor sistemi doğru çalışmalıdır.",
        "Can sistemi, hasar ve game over akışı tutarlı olmalıdır.",
        "İksir ve ağaç sihri cadının büyü atmasını geçici olarak durdurmalıdır.",
        "HUD ve mobil kontroller küçük ekranlarda okunabilir olmalıdır.",
    ]:
        story.append(bullet(item))


def footer(canvas, doc):
    canvas.saveState()
    canvas.setFont("ArialTR", 8)
    canvas.setFillColor(MUTED)
    canvas.drawString(2 * cm, 1.1 * cm, "Kayseri Üniversitesi | Bilgisayar Mühendisliği | 23103021703")
    canvas.drawRightString(A4[0] - 2 * cm, 1.1 * cm, f"Sayfa {doc.page}")
    canvas.restoreState()


def main():
    story = []
    add_cover(story)
    add_body(story)
    doc = SimpleDocTemplate(
        str(PDF_PATH),
        pagesize=A4,
        rightMargin=2 * cm,
        leftMargin=2 * cm,
        topMargin=1.8 * cm,
        bottomMargin=1.8 * cm,
        title="Nazlı'nın Çiçek Bahçesi - Oyun Tasarım Dokümanı",
        author="23103021703",
    )
    doc.build(story, onFirstPage=footer, onLaterPages=footer)
    print(PDF_PATH)


if __name__ == "__main__":
    main()
