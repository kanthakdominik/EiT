# 08 — Miernictwo elektroniczne

> **Status:** ✅ pełny

## Cel modułu

Mierzyć świadomie: znać przyrządy i ich ograniczenia, przewidywać wpływ przyrządu na mierzony układ, szacować niepewność wyniku i automatyzować pomiary. Po tym module potrafisz powiedzieć nie tylko „ile wyszło”, ale też „z jaką dokładnością i dlaczego tyle”.

## Wymagania wstępne

- [01 Teoria obwodów](../01-teoria-obwodow/) — Thévenin, AC, charakterystyki częstotliwościowe.
- [04 Układy analogowe](../04-uklady-analogowe/) — wzmacniacze, filtry (tor kondycjonowania).
- [06 Sygnały i systemy](../06-sygnaly-i-systemy/) i [00.06 Statystyka](../00-matematyka/06-prawdopodobienstwo-i-statystyka.md) — widmo, szum, rozkłady.

## Tematy

| # | Temat | Czas (od zera / odświeżenie) |
|---|---|---|
| 01 | [Metrologia i niepewność pomiaru](01-metrologia-i-niepewnosc.md) | 8 h / 2 h |
| 02 | [Multimetr i pomiary podstawowe](02-multimetr-i-pomiary-podstawowe.md) | 6 h / 2 h |
| 03 | [Oscyloskop i sondy](03-oscyloskop.md) | 8 h / 3 h |
| 04 | [Generatory, częstościomierze, analizatory widma](04-generatory-i-analizatory.md) | 6 h / 2 h |
| 05 | [Pomiary impedancji i charakterystyk częstotliwościowych](05-impedancja-i-charakterystyki.md) | 6 h / 2 h |
| 06 | [Czujniki i tor pomiarowy](06-czujniki-i-tor-pomiarowy.md) | 8 h / 3 h |
| 07 | [Zakłócenia, masa i ekranowanie w pomiarach](07-zaklocenia-i-ekranowanie.md) | 6 h / 2 h |
| 08 | [Automatyzacja pomiarów](08-automatyzacja-pomiarow.md) | 6 h / 2 h |

## Test wejściowy (diagnoza)

Około 60 minut, bez notatek.

1. Woltomierz o dokładności ±(0,5% w.m. + 2 cyfry) na zakresie 20,00 V pokazuje 12,34 V. Ile wynosi niepewność standardowa typu B?
2. Dzielnik 1 MΩ / 1 MΩ zasilany 10 V mierzysz multimetrem o rezystancji wejściowej 10 MΩ. Co pokaże?
3. Oscyloskop ma pasmo 100 MHz. Jaki ma własny czas narastania? Jaki czas narastania zmierzysz dla sygnału o rzeczywistym czasie 5 ns?
4. Generator ustawiony na 1 Vpp (tryb obciążenia 50 Ω) podłączono do wejścia oscyloskopu 1 MΩ. Ile pokaże oscyloskop?
5. Przesunięcie czasowe dwóch sinusoid 1 kHz wynosi 125 µs. Jakie to przesunięcie fazy?
6. Termistor NTC 10 kΩ (25 °C), B = 3950 K. Jaką ma rezystancję w 50 °C?
7. Dlaczego do pomiaru rezystancji 10 mΩ używa się metody czteroprzewodowej?

<details>
<summary>Odpowiedzi</summary>

1. $a = 0\text{,}005\cdot 12\text{,}34 + 0\text{,}02 \approx 0\text{,}082$ V, rozkład prostokątny: $u_B = a/\sqrt3 \approx 0\text{,}047$ V
2. $R_{th} = 500$ kΩ, $U = 5\cdot\dfrac{10}{10\text{,}5} \approx 4\text{,}76$ V (błąd −4,8%)
3. $t_r \approx 0\text{,}35/100\ \text{MHz} = 3\text{,}5$ ns; zmierzysz $\sqrt{5^2 + 3\text{,}5^2} \approx 6\text{,}1$ ns
4. 2 Vpp — generator zakłada dzielnik z obciążeniem 50 Ω
5. $360°\cdot 125\ \mu\text{s}\cdot 1\ \text{kHz} = 45°$
6. $R = 10\ \text{k}\cdot e^{3950(1/323\text{,}15 - 1/298\text{,}15)} \approx 3\text{,}59$ kΩ
7. Rezystancja przewodów pomiarowych i styków (rzędu dziesiątek mΩ) byłaby porównywalna z mierzoną; w metodzie czteroprzewodowej przez przewody napięciowe nie płynie prąd, więc spadek na nich nie wchodzi do wyniku

**Ocena:** zadanie 1 — temat 01; 2, 7 — temat 02; 3 — temat 03; 4 — temat 04; 5 — temat 05; 6 — temat 06.
</details>

## Projekt modułowy: zautomatyzowany pomiar charakterystyki filtra

- [ ] Wybierz filtr z modułu [04](../04-uklady-analogowe/09-filtry-aktywne.md) (np. Sallen–Key 1 kHz) i zbuduj go na płytce stykowej.
- [ ] Zmierz charakterystykę amplitudową i fazową **ręcznie** w 10 punktach (generator + oscyloskop dwukanałowy).
- [ ] Zautomatyzuj pomiar (PyVISA + SCPI, a bez przyrządów laboratoryjnych — karta dźwiękowa lub przetwornik mikrokontrolera z modułu [09](../09-mikrokontrolery-embedded/)) dla 50 punktów logarytmicznie rozłożonych.
- [ ] Zmierz odpowiedź skokową i wyznacz charakterystykę przez FFT — porównaj obie metody.
- [ ] Policz budżet niepewności dla wzmocnienia w paśmie przepustowym (przyrządy, tolerancje, rozrzut powtórzeń).
- [ ] Nałóż na jeden wykres: wynik analityczny, symulację LTspice i pomiar z niepewnościami. Wyjaśnij rozbieżności.

## Sprawdzian końcowy modułu

- [ ] Wyznaczam niepewność typu A i B, łączę je i podaję wynik z niepewnością rozszerzoną.
- [ ] Przewiduję wpływ rezystancji wejściowej woltomierza i spadku napięcia na amperomierzu.
- [ ] Dobieram pasmo oscyloskopu, częstotliwość próbkowania i sondę do mierzonego sygnału.
- [ ] Mierzę charakterystykę częstotliwościową i impedancję, rozumiem ograniczenia metod.
- [ ] Projektuję tor pomiarowy z czujnikiem i szacuję jego błędy.
- [ ] Rozpoznaję i eliminuję pętle masy i zakłócenia wspólne.
- [ ] Steruję przyrządem z Pythona i zapisuję wyniki z metadanymi.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [JCGM 100:2008 — GUM, Guide to the Expression of Uncertainty in Measurement](https://www.bipm.org/en/doi/10.59161/jcgm100-2008e) | Temat 01 — dokument źródłowy dla szacowania niepewności (bezpłatny PDF) |
| [Tektronix — XYZs of Oscilloscopes (primer)](https://www.electronicdesign.com/resources/white-papers/whitepaper/21807643/xyzs-of-oscilloscopes-primer) | Temat 03 — działanie i parametry oscyloskopów |
| [Modular Electronics Learning (ModEL) Project](https://ibiblio.org/kuphaldt/socratic/model/) | Pomiary, przyrządy, pomiary RF, ćwiczenia |
| [All About Circuits — tomy DC i Experiments](https://www.allaboutcircuits.com/textbook/) | Obwody pomiarowe, ćwiczenia z przyrządami |
| [Analog Devices — Engineering University Program](https://wiki.analog.com/university) | Ćwiczenia laboratoryjne z pomiarami |
| [PyVISA](https://pyvisa.readthedocs.io/) | Temat 08 — sterowanie przyrządami z Pythona |
