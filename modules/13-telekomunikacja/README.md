# 13 — Telekomunikacja i teoria informacji

> **Status:** 🟡 szkielet — zakres, cele i główne źródła. Pełne notatki i zadania w kolejnym etapie.

## Cel modułu

Opisać tor telekomunikacyjny od źródła informacji do odbiorcy: kodowanie, modulacja, kanał z szumem, detekcja i ocena jakości transmisji.

## Wymagania wstępne

- [06 Sygnały i systemy](../06-sygnaly-i-systemy/), [07 CPS](../07-cps-dsp/), podstawy rachunku prawdopodobieństwa ([00 Matematyka](../00-matematyka/)).

## Tematy

### Teoria informacji
- [ ] Ilość informacji, entropia źródła
- [ ] Kodowanie źródłowe: kody Huffmana, kompresja
- [ ] Pojemność kanału, twierdzenie Shannona–Hartleya

### Modulacje analogowe
- [ ] AM, DSB-SC, SSB — widmo, moc, demodulacja
- [ ] FM i PM — dewiacja, reguła Carsona, demodulacja

### Transmisja cyfrowa
- [ ] Kodowanie liniowe, interferencja międzysymbolowa, kryterium Nyquista, filtr podniesionego kosinusa
- [ ] Modulacje cyfrowe: ASK, FSK, PSK, QAM — konstelacje, efektywność widmowa
- [ ] Detekcja w szumie: filtr dopasowany, stopa błędów (BER) w funkcji Eb/N0
- [ ] Synchronizacja nośnej i zegara

### Kodowanie kanałowe
- [ ] Kody blokowe (Hamminga), CRC, kody splotowe, dekoder Viterbiego
- [ ] Przeplot, wprowadzenie do turbo i LDPC

### Techniki wielodostępu i systemy
- [ ] OFDM, rozpraszanie widma (DSSS, FHSS)
- [ ] FDMA, TDMA, CDMA, OFDMA
- [ ] Kanał radiowy: zaniki, wielodrogowość, dywersyfikacja
- [ ] Przegląd systemów: radiofonia, telefonia komórkowa, Wi-Fi, łącza satelitarne

## Główne źródła

- [Fundamentals of Electrical Engineering I — D. Johnson](https://open.umn.edu/opentextbooks/textbooks/fundamentals-of-electrical-engineering-1) — komunikacja, teoria informacji, kody korekcyjne
- [Modular Electronics Learning (ModEL) Project](https://ibiblio.org/kuphaldt/socratic/model/) — moduły o modulacji AM i FM
- [MIT RES.6-007 Signals and Systems](https://ocw.mit.edu/courses/res-6-007-signals-and-systems-spring-2011/) — wykłady o modulacji

## Ćwiczenie modułowe

Symulacja łącza cyfrowego w Pythonie: generator bitów → QPSK/16-QAM → kanał AWGN → detektor. Wykreśl krzywe BER(Eb/N0) i porównaj z teorią. Rozszerzenie: dodaj kod Hamminga i zmierz zysk kodowania.

## Sprawdzian umiejętności

- Liczę pasmo sygnału FM regułą Carsona.
- Wyznaczam pojemność kanału z pasma i SNR.
- Wybieram modulację do zadanego pasma, przepływności i BER.
