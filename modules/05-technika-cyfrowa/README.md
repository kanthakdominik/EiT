# 05 — Technika cyfrowa

> **Status:** ✅ pełny

## Cel modułu

Projektować układy kombinacyjne i sekwencyjne, rozumieć ich ograniczenia czasowe i elektryczne oraz to, jak bramki zbudowane są z tranzystorów. Po tym module potrafisz zaprojektować automat stanów od opisu słownego do działającego układu i policzyć, z jaką częstotliwością zegara może pracować.

## Wymagania wstępne

- [01 Teoria obwodów](../01-teoria-obwodow/) — podstawy, stany nieustalone RC (zbocza sygnałów).
- Dla tematu 07 — [03 Przyrządy półprzewodnikowe](../03-przyrzady-polprzewodnikowe/) (MOSFET jako klucz).

## Tematy

| # | Temat | Czas (od zera / odświeżenie) |
|---|---|---|
| 01 | [Systemy liczbowe, kody i arytmetyka binarna](01-liczby-i-kody.md) | 6 h / 1 h |
| 02 | [Algebra Boole'a i minimalizacja](02-algebra-boolea-i-minimalizacja.md) | 8 h / 2 h |
| 03 | [Układy kombinacyjne](03-uklady-kombinacyjne.md) | 8 h / 2 h |
| 04 | [Przerzutniki i rejestry](04-przerzutniki-i-rejestry.md) | 6 h / 2 h |
| 05 | [Liczniki i automaty stanów](05-liczniki-i-automaty.md) | 10 h / 3 h |
| 06 | [Parametry czasowe, metastabilność, synchronizacja](06-parametry-czasowe.md) | 8 h / 3 h |
| 07 | [Bramki CMOS, poziomy logiczne i interfejsy](07-technologia-cmos.md) | 8 h / 3 h |
| 08 | [Pamięci i układy programowalne](08-pamieci-i-pld.md) | 6 h / 2 h |

## Test wejściowy (diagnoza)

Około 60 minut, bez notatek.

1. Zapisz liczbę $-5$ w kodzie U2 na 8 bitach oraz $0\text{x}2F$ dziesiętnie i binarnie.
2. Zminimalizuj $f(A, B, C, D) = \sum m(0, 2, 5, 7, 8, 10, 13, 15)$.
3. Zaprojektuj multiplekser 4:1 na bramkach — ile wejść adresowych potrzeba?
4. Czym różni się zatrzask (latch) od przerzutnika wyzwalanego zboczem?
5. Ile przerzutników potrzeba do licznika modulo 10? Narysuj graf stanów.
6. $t_{clk\to q} = 0{,}5$ ns, maksymalne opóźnienie logiki 6 ns, $t_{setup} = 0{,}3$ ns. Jaka jest maksymalna częstotliwość zegara?
7. Dlaczego sygnału z przycisku nie podaje się bezpośrednio na wejście automatu taktowanego zegarem?

<details>
<summary>Odpowiedzi</summary>

1. $11111011_2$; $47_{10} = 101111_2$
2. $f = \overline{B}\,\overline{D} + BD$ (czyli $\overline{B \oplus D}$)
3. 2 wejścia adresowe; $Y = \overline{S_1}\,\overline{S_0}D_0 + \overline{S_1}S_0D_1 + S_1\overline{S_0}D_2 + S_1S_0D_3$
4. Zatrzask jest przezroczysty przez cały czas aktywnego poziomu sygnału zezwalającego; przerzutnik zapamiętuje stan wejścia tylko w chwili zbocza zegara
5. 4 przerzutniki ($2^3 < 10 \leq 2^4$); stany 0→1→…→9→0
6. $f_{max} = 1/6{,}8\ \text{ns} \approx 147$ MHz
7. Sygnał jest asynchroniczny względem zegara (ryzyko metastabilności) i drga przy przełączaniu (wiele zboczy). Potrzebny synchronizator i eliminacja drgań styków
</details>

## Projekt modułowy: sterownik sygnalizacji świetlnej

- [ ] Opisz słownie: dwie drogi, przycisk dla pieszych, czasy faz (np. 10 s zielone, 2 s żółte), stan awaryjny (migające żółte).
- [ ] Narysuj graf automatu Moore'a, zakoduj stany (binarnie i „one-hot”) i porównaj liczbę przerzutników.
- [ ] Zaprojektuj licznik czasu faz (preskaler zegara + licznik z ładowaniem).
- [ ] Dodaj synchronizator dwuprzerzutnikowy i układ eliminacji drgań dla przycisku.
- [ ] Zbuduj układ w [Logisim-evolution](https://github.com/logisim-evolution/logisim-evolution) lub [Digital](https://github.com/hneemann/Digital) i sprawdź na wykresach czasowych.
- [ ] Policz $f_{max}$ dla założonych opóźnień bramek (np. 1 ns na bramkę, 0,5 ns $t_{clk\to q}$, 0,3 ns setup).
- [ ] Rozszerzenie: przepisz automat w Verilogu lub VHDL (wstęp do modułu [17](../17-fpga-hdl/)).

## Sprawdzian końcowy modułu

- [ ] Przeliczam liczby między systemami i wykonuję arytmetykę w U2, rozpoznaję przepełnienie.
- [ ] Minimalizuję funkcję 4 zmiennych tablicą Karnaugha (z wartościami nieokreślonymi) i realizuję ją na bramkach NAND.
- [ ] Projektuję układy kombinacyjne z multiplekserów, dekoderów i sumatorów.
- [ ] Projektuję licznik synchroniczny modulo N i automat stanów od grafu do schematu.
- [ ] Liczę maksymalną częstotliwość zegara i sprawdzam warunek hold.
- [ ] Synchronizuję sygnały asynchroniczne i wiem, dlaczego pojedynczy przerzutnik nie wystarczy.
- [ ] Dobieram rezystor podciągający, sprawdzam zgodność poziomów logicznych 3,3 V / 5 V.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [All About Circuits — tom Digital](https://www.allaboutcircuits.com/textbook/) | Cały moduł: systemy liczbowe, bramki, algebra Boole'a, Karnaugh, przerzutniki, liczniki, pamięci |
| [MIT 6.004 Computation Structures (2017)](https://ocw.mit.edu/courses/6-004-computation-structures-spring-2017/) | Ujęcie akademickie: abstrakcja cyfrowa, CMOS, logika kombinacyjna i sekwencyjna, automaty, czasy |
| [MIT 6.111 Introductory Digital Systems Laboratory](https://ocw.mit.edu/courses/6-111-introductory-digital-systems-laboratory-spring-2006/) | Projektowanie systemów cyfrowych, automaty, synchronizacja, wstęp do FPGA |
| [nand2tetris](https://www.nand2tetris.org/) | Budowa komputera od bramki NAND — projekty z HDL i symulatorem |
| [Ben Eater — 8-bit breadboard computer](https://eater.net/8bit/) | Komputer z układów 74xx na płytkach stykowych, z filmami |
| [Falstad — demonstracje logiki kombinacyjnej i sekwencyjnej](https://falstad.com/circuit/e-index.html) | Animowane układy |
| Narzędzia: [Logisim-evolution](https://github.com/logisim-evolution/logisim-evolution), [Digital](https://github.com/hneemann/Digital) | Symulacja wszystkich ćwiczeń modułu |
