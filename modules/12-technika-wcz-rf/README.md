# 12 — Technika wielkich częstotliwości (RF)

> **Status:** ✅ pełny

## Cel modułu

Analizować i projektować bloki toru radiowego — dopasowania, wzmacniacze, mieszacze, oscylatory, filtry — posługując się parametrami S, współczynnikiem szumów i miarami nieliniowości. Rozumieć architektury nadajników i odbiorników, w tym radia programowalnego (SDR), i czytać karty katalogowe układów w.cz.

## Wymagania wstępne

- [11 Pole EM, linie, anteny](../11-pole-em-linie-anteny/) — zwłaszcza linie i wykres Smitha ([11.03](../11-pole-em-linie-anteny/03-linie-transmisyjne.md), [11.04](../11-pole-em-linie-anteny/04-wykres-smitha-i-dopasowanie.md)).
- [04 Układy analogowe](../04-uklady-analogowe/) — wzmacniacze tranzystorowe, sprzężenie zwrotne.
- [00.07 Decybele](../00-matematyka/07-decybele.md), [06.08 Sygnały losowe](../06-sygnaly-i-systemy/08-sygnaly-losowe.md).

## Tematy

| # | Temat | Czas (od zera / odświeżenie) |
|---|---|---|
| 01 | [Elementy bierne na wielkich częstotliwościach](01-elementy-bierne-wcz.md) | 5 h / 2 h |
| 02 | [Parametry S i analizator obwodów](02-parametry-s.md) | 8 h / 3 h |
| 03 | [Dopasowanie impedancji obwodami LC](03-dopasowanie-lc.md) | 6 h / 2 h |
| 04 | [Szumy w torze w.cz.](04-szumy.md) | 6 h / 2 h |
| 05 | [Nieliniowość i zakres dynamiki](05-nieliniowosc.md) | 6 h / 2 h |
| 06 | [Wzmacniacze w.cz.: LNA i wzmacniacze mocy](06-wzmacniacze-wcz.md) | 8 h / 3 h |
| 07 | [Mieszacze, oscylatory i syntezery](07-mieszacze-i-oscylatory.md) | 8 h / 3 h |
| 08 | [Filtry w.cz. i architektury odbiorników](08-filtry-i-architektury.md) | 8 h / 3 h |

## Test wejściowy (diagnoza)

Około 60 minut, bez notatek.

1. Kondensator 100 nF ma indukcyjność pasożytniczą 1 nH. Do jakiej częstotliwości zachowuje się jak kondensator?
2. Wzmacniacz ma S21 = 15 dB i S11 = −12 dB. Co to oznacza? Jaki jest WFS na wejściu?
3. Dopasuj rezystancję 200 Ω do 50 Ω przy 100 MHz obwodem L (podaj wartości elementów).
4. LNA (G = 15 dB, NF = 1 dB), mieszacz (G = −7 dB, NF = 7 dB), wzmacniacz p.cz. (G = 20 dB, NF = 4 dB). Ile wynosi NF całości?
5. Wzmacniacz ma OIP3 = +30 dBm i wzmocnienie 20 dB. Dwa tony po −20 dBm na wejściu — jaki poziom produktów IM3 na wyjściu?
6. Odbiornik FM: RF = 100 MHz, p.cz. = 10,7 MHz, generator lokalny powyżej sygnału. Jaka jest częstotliwość lustrzana?
7. Syntezer PLL: $f_{ref}$ = 1 MHz, wyjście 2,44 GHz. O ile dB szum fazowy wyjścia w paśmie pętli jest większy od szumu referencji?

<details>
<summary>Odpowiedzi</summary>

1. Częstotliwość rezonansu własnego $1/(2\pi\sqrt{LC}) \approx 15\text{,}9$ MHz — powyżej zachowuje się jak indukcyjność
2. Wzmocnienie mocy (przy dopasowanych zakończeniach 50 Ω) 15 dB; odbija się 6,3% mocy wejściowej; $|\Gamma| = 0\text{,}25$, WFS ≈ 1,67
3. $Q = \sqrt{200/50 - 1} = 1\text{,}73$; równoległy C przy 200 Ω: $X = 115\text{,}5\ \Omega$ → 13,8 pF; szeregowa L: $X = 86\text{,}6\ \Omega$ → 138 nH
4. ≈ 2,1 dB
5. $P_{out} = 0$ dBm, $IM3 = 3\cdot 0 - 2\cdot 30 = -60$ dBm
6. $100 + 2\cdot 10\text{,}7 = 121\text{,}4$ MHz
7. $20\log N = 20\log 2440 \approx 67\text{,}7$ dB

**Ocena:** 1 — temat 01; 2 — 02; 3 — 03; 4 — 04; 5 — 05; 6 — 07–08; 7 — 07.
</details>

## Projekt modułowy: tor odbiorczy

- [ ] **Projekt na papierze:** tor odbiornika na wybrane pasmo (np. 433 lub 868 MHz): filtr wejściowy, LNA, mieszacz, filtr p.cz. lub odbiór z bezpośrednią przemianą. Policz NF, wzmocnienie, IIP3 kaskady, czułość i zakres dynamiki (arkusz lub skrypt w Pythonie).
- [ ] **Dopasowanie:** zaprojektuj dopasowanie LC wejścia LNA (na podstawie parametrów S z karty katalogowej) i sprawdź symulacją w LTspice lub z biblioteką scikit-rf.
- [ ] **Filtr:** zaprojektuj filtr LC (np. Butterwortha lub Czebyszewa 5. rzędu), zbuduj go z elementów SMD i zmierz tanim analizatorem (np. NanoVNA); porównaj z symulacją i wyjaśnij różnice (elementy pasożytnicze, dobroć).
- [ ] **SDR:** odbiornikiem SDR (np. RTL-SDR) obejrzyj widmo pasma ISM, zmierz poziomy sygnałów i szum, zdemoduluj transmisję FM lub prosty sygnał cyfrowy w Pythonie ([PySDR](https://pysdr.org)).

## Sprawdzian końcowy modułu

- [ ] Uwzględniam elementy pasożytnicze i dobroć przy doborze elementów biernych.
- [ ] Interpretuję S11, S21, S12, S22 z pomiaru VNA i przeliczam je na impedancję, WFS, wzmocnienie.
- [ ] Projektuję dopasowanie L, π i T i szacuję jego pasmo.
- [ ] Liczę współczynnik szumów kaskady i czułość odbiornika.
- [ ] Liczę P1dB, IP3, produkty intermodulacji i zakres dynamiki wolny od zniekształceń.
- [ ] Sprawdzam stabilność wzmacniacza (K, Δ) i dobieram klasę wzmacniacza mocy.
- [ ] Wyznaczam częstotliwość lustrzaną i produkty mieszania, rozumiem szum fazowy i syntezę PLL.
- [ ] Dobieram architekturę odbiornika i filtry do zastosowania.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [Fundamentals of Microwave and RF Design — M. Steer (open textbook)](https://open.umn.edu/opentextbooks/textbooks/fundamentals-of-microwave-and-rf-design) | Główny podręcznik: parametry S, linie, dopasowanie, wzmacniacze, szumy |
| [Microwave and RF Design: Radio Systems — M. Steer](https://open.umn.edu/opentextbooks/textbooks/microwave-and-rf-design-radio-systems) | Architektury nadajników i odbiorników, budżety, nieliniowość |
| [Keysight AN 154 — S-Parameter Design](https://www.keysight.com/be/en/assets/7018-06743/application-notes/5952-1087.pdf) | Klasyczna nota o parametrach S i projektowaniu wzmacniaczy |
| [Analog Devices MT-080 — Mixers and Modulators](https://www.analog.com/media/en/training-seminars/tutorials/MT-080.pdf) | Mieszacze i modulatory |
| [PySDR — M. Lichtman](https://pysdr.org) | Radio programowalne i DSP w Pythonie, od podstaw |
| [scikit-rf](https://scikit-rf.readthedocs.io) | Biblioteka Pythona: parametry S, pliki Touchstone, wykres Smitha, kalibracja |
| [Lessons in Electric Circuits / All About Circuits Textbook](https://www.allaboutcircuits.com/textbook/) | Przystępne wprowadzenie do elementów i obwodów w.cz. |
| [Electromagnetics, Vol. 2 — Ellingson](https://doi.org/10.21061/electromagnetics-vol-2) | Podstawy pola dla w.cz. |
