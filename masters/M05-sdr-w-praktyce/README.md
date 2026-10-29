# M05 — Radio programowalne (SDR) w praktyce

> **Status:** ✅ pełny · ścieżka magisterska (II stopień)

## Cel modułu

Przejść od teorii modulacji i detekcji do odbiorników, które działają z prawdziwym sprzętem: rozumieć architekturę SDR i jej ograniczenia (zakres dynamiki, składowa stała, niezrównoważenie I/Q, błąd oscylatora), sprawnie przetwarzać próbki I/Q (przesunięcie, decymacja, korekcja), budować grafy w GNU Radio i własne bloki, demodulować sygnały analogowe, synchronizować odbiornik cyfrowy w częstotliwości, czasie i fazie, zbudować od zera odbiornik pakietowy QPSK i OFDM oraz dekodować prawdziwe sygnały (ADS-B) — przestrzegając przepisów o odbiorze i nadawaniu. Moduł łączy [13 Telekomunikację](../../modules/13-telekomunikacja/), [07 CPS](../../modules/07-cps-dsp/) i [12 Technikę w.cz.](../../modules/12-technika-wcz-rf/) z [M01](../M01-estymacja-detekcja-filtracja/) i [M02](../M02-mimo-i-kodowanie/).

## Wymagania wstępne

- [13 Telekomunikacja](../../modules/13-telekomunikacja/) — modulacje analogowe i cyfrowe, filtry RRC, BER, OFDM.
- [07 Cyfrowe przetwarzanie sygnałów](../../modules/07-cps-dsp/) — filtry FIR, FFT, zmiana częstotliwości próbkowania.
- [12 Technika w.cz.](../../modules/12-technika-wcz-rf/) — szumy, mieszacze, liniowość.
- [M01.01 Teoria detekcji](../M01-estymacja-detekcja-filtracja/01-teoria-detekcji.md) — wykrywanie preambuły; [10.05 Regulatory PID](../../modules/10-automatyka/05-regulatory-pid.md) — filtry pętli.

## Sprzęt

Wystarczy jedno z urządzeń (szczegóły w temacie [01](01-architektura-odbiornika-sdr.md)): **RTL-SDR** (tylko odbiór, najtańszy — tematy 01–05, 08), **ADALM-Pluto** (nadawanie i odbiór, pętla kablowa — tematy 06–07), opcjonalnie HackRF lub USRP. Do pętli kablowej: kabel SMA i tłumik 30–40 dB. Wszystkie ćwiczenia komputerowe działają bez sprzętu (sygnały symulowane).

## Tematy

| # | Temat | Czas |
|---|---|---|
| 01 | [Architektura odbiornika i nadajnika SDR](01-architektura-odbiornika-sdr.md) | 8 h |
| 02 | [Sygnały I/Q i przetwarzanie wstępne](02-sygnaly-iq-i-przetwarzanie-wstepne.md) | 8 h |
| 03 | [GNU Radio: grafy przepływu i własne bloki](03-gnu-radio.md) | 10 h |
| 04 | [Demodulacja analogowa: FM, AM, SSB](04-demodulacja-analogowa.md) | 8 h |
| 05 | [Synchronizacja: częstotliwość, czas symbolu, faza](05-synchronizacja.md) | 10 h |
| 06 | [Cyfrowy odbiornik pakietowy QPSK od zera](06-odbiornik-cyfrowy-od-zera.md) | 12 h |
| 07 | [OFDM w SDR: synchronizacja i estymacja kanału](07-ofdm-w-sdr.md) | 10 h |
| 08 | [Praktyka: dekodowanie ADS-B, sygnały do odbioru i przepisy](08-praktyka-ads-b-i-przepisy.md) | 8 h |

## Test wejściowy (diagnoza)

Około 60 minut.

1. Czym różni się widmo sygnału zespolonego I/Q od widma sygnału rzeczywistego?
2. Co trzeba zrobić przed zmniejszeniem częstotliwości próbkowania 10 razy?
3. Zapisz sygnał FM przez całkę z sygnału modulującego. Jak odtworzyć sygnał modulujący z fazy?
4. Po co stosuje się filtr RRC po obu stronach łącza?
5. Jak wygląda konstelacja QPSK odebrana z przesunięciem częstotliwości nośnej?
6. Ile wynosi BER QPSK przy $E_b/N_0 = 8$ dB (wzór)?

<details>
<summary>Odpowiedzi</summary>

1. Widmo sygnału rzeczywistego jest symetryczne (częstotliwości ujemne są lustrem dodatnich); w sygnale zespolonym częstotliwości ujemne i dodatnie niosą różną informację, pasmo obejmuje od $-f_s/2$ do $f_s/2$
2. Filtr dolnoprzepustowy (antyaliasingowy) tłumiący wszystko powyżej nowej częstotliwości Nyquista
3. $s(t) = \exp\left(j2\pi\Delta f\int m\,d\tau\right)$; $m(t) \propto \tfrac{d}{dt}\arg s(t)$ — w dyskretnej postaci $\arg(s[n]s^*[n-1])$
4. Iloczyn RRC·RRC daje impuls podniesionego kosinusa bez ISI w chwilach próbkowania, a filtr w odbiorniku jest jednocześnie filtrem dopasowanym (maksymalny SNR)
5. Punkty obracają się po okręgu (cztery „pierścienie” lub okrąg) z prędkością kątową równą przesunięciu
6. $\tfrac12\mathrm{erfc}\left(\sqrt{E_b/N_0}\right) = \tfrac12\mathrm{erfc}(\sqrt{6\text{,}31}) \approx 1\text{,}9\cdot 10^{-4}$

**Ocena:** 1–2 — tematy 01–02; 3 — 04; 4–6 — moduł 13 i tematy 05–06.
</details>

## Projekt modułowy: własny modem pakietowy na ADALM-Pluto

- [ ] **Symulacja (tematy 05–06):** modem QPSK z ramką (preambuła, nagłówek, dane, CRC-16), korelacja segmentowa, CFO, śledzenie fazy; krzywe BER i prawdopodobieństwa wykrycia ramki.
- [ ] **GNU Radio (temat 03):** ten sam nadajnik jako graf GRC lub blok Python; podgląd konstelacji i widma na żywo.
- [ ] **Sprzęt:** pętla kablowa Pluto TX → tłumik → RX; pomiar BER w funkcji mocy nadajnika (tłumienia); porównanie CFO zmierzonego z dokładnością wzorca.
- [ ] **Rozszerzenie (temat 07):** wariant OFDM 64 podnośnych z estymacją kanału; porównanie z QPSK jednonośnym przy tym samym paśmie.
- [ ] **Odbiór prawdziwych sygnałów (temat 08):** dekoder ADS-B lub FM z RDS z RTL-SDR — porównanie z gotowym dekoderem.

## Sprawdzian końcowy modułu

- [ ] Opisuję architektury SDR, oceniam zakres dynamiki przetwornika i błąd oscylatora, dobieram sprzęt i szybkość próbkowania.
- [ ] Przesuwam kanał NCO, decymuję z filtrem, koryguję DC i niezrównoważenie I/Q.
- [ ] Buduję graf w GNU Radio Companion i własny blok Python ze stanem.
- [ ] Demoduluję FM (z de-emfazą), AM i SSB; rozumiem zysk FM i efekt progowy.
- [ ] Estymuję CFO, implementuję detektor Gardnera i pętlę Costasa, rozumiem kompromis pasma pętli.
- [ ] Buduję odbiornik pakietowy QPSK od zera z jakością bliską teorii.
- [ ] Synchronizuję OFDM metodą Schmidla–Coxa, estymuję kanał i korekcję CPE.
- [ ] Dekoduję ramki ADS-B z CRC i znam zasady prawne odbioru i nadawania.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [PySDR: A Guide to SDR and DSP using Python (M. Lichtman)](https://pysdr.org) | Główny, darmowy podręcznik modułu: I/Q, filtry, synchronizacja, PlutoSDR, RTL-SDR, USRP, GNU Radio |
| [T. Collins, R. Getz, D. Pu, A. Wyglinski — Software-Defined Radio for Engineers](https://www.analog.com/sdrforengineers) | Darmowa książka od Analog Devices: tor radiowy, niedoskonałości, synchronizacja, projekty z ADALM-Pluto |
| [GNU Radio — Guided Tutorial GRC](https://wiki.gnuradio.org/index.php?title=GRC), [Your First Flowgraph](https://wiki.gnuradio.org/index.php/Your_First_Flowgraph), [GNU Radio in Python](https://wiki.gnuradio.org/index.php/Guided_Tutorial_GNU_Radio_in_Python) | Oficjalne samouczki GNU Radio |
| [Analog Devices — ADALM-Pluto (wiki)](https://wiki.analog.com/plutosdr) | Dokumentacja sprzętu, sterowniki, pyadi-iio |
| [RTL-SDR Quick Start Guide](https://www.rtl-sdr.com/rtl-sdr-quick-start-guide/) | Pierwsze kroki z RTL-SDR |
| [J. Sun — The 1090 Megahertz Riddle (TU Delft OPEN)](https://books.open.tudelft.nl/home/catalog/book/11) | Darmowa książka o dekodowaniu Mode S i ADS-B |
| [MIT 6.450 Principles of Digital Communication I (2006)](https://ocw.mit.edu/courses/6-450-principles-of-digital-communications-i-fall-2006/) | Teoria: modulacja, detekcja, kanał |
| M. Rice — *Digital Communications: A Discrete-Time Approach* (płatna) | Synchronizacja i odbiorniki w dziedzinie dyskretnej |
