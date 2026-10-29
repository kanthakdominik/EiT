# 21 — Procesy losowe i szum

> **Status:** ✅ pełny

## Cel modułu

Opisywać sygnały losowe — szum, zakłócenia, dane, ruch w sieci — narzędziami, które pozwalają liczyć: funkcją autokorelacji, gęstością widmową mocy i ich przejściem przez układy liniowe. Na tej podstawie liczyć szum układów elektronicznych (rezystory, wzmacniacze, przetworniki, zegary) i systemów telekomunikacyjnych oraz poprawnie mierzyć widmo szumu. Moduł zbiera i porządkuje wątki rozrzucone po innych modułach: szum w torze w.cz. ([12.04](../12-technika-wcz-rf/04-szumy.md)), detekcję ([13.05](../13-telekomunikacja/05-detekcja-i-ber.md)), szum kwantyzacji ([07.01](../07-cps-dsp/01-przetwarzanie-ac.md)) i analizę widmową ([07.03](../07-cps-dsp/03-okna-i-analiza-widmowa.md)).

## Wymagania wstępne

- [00.06 Prawdopodobieństwo i statystyka](../00-matematyka/06-prawdopodobienstwo-i-statystyka.md) — zmienne losowe, rozkłady, wartość oczekiwana, wariancja.
- [06 Sygnały i systemy](../06-sygnaly-i-systemy/) — splot, transformata Fouriera, transmitancja; [06.08 Sygnały losowe i szum](../06-sygnaly-i-systemy/08-sygnaly-losowe.md) to krótkie wprowadzenie, które ten moduł rozwija.
- [07.02 DFT i FFT](../07-cps-dsp/02-dft-i-fft.md) i [07.03 Okna](../07-cps-dsp/03-okna-i-analiza-widmowa.md) — dla tematu 05.
- [19.02 Python naukowy](../19-programowanie/02-python-naukowy.md) — symulacje Monte Carlo.

## Tematy

| # | Temat | Czas (od zera / odświeżenie) |
|---|---|---|
| 01 | [Zmienne i wektory losowe w praktyce inżynierskiej](01-zmienne-i-wektory-losowe.md) | 6 h / 2 h |
| 02 | [Procesy losowe: stacjonarność i ergodyczność](02-procesy-losowe.md) | 6 h / 2 h |
| 03 | [Autokorelacja i gęstość widmowa mocy](03-autokorelacja-i-widmo-mocy.md) | 8 h / 3 h |
| 04 | [Procesy losowe w układach liniowych](04-procesy-w-ukladach-liniowych.md) | 6 h / 2 h |
| 05 | [Estymacja widma: periodogram i metoda Welcha](05-estymacja-widma.md) | 6 h / 2 h |
| 06 | [Szum w układach elektronicznych](06-szum-w-ukladach-elektronicznych.md) | 10 h / 3 h |
| 07 | [Szum w systemach cyfrowych i telekomunikacyjnych](07-szum-w-systemach-cyfrowych.md) | 6 h / 2 h |
| 08 | [Szum wąskopasmowy, obwiednia i procesy punktowe](08-szum-waskopasmowy-i-procesy-punktowe.md) | 6 h / 2 h |

## Test wejściowy (diagnoza)

Około 45 minut.

1. Zmienna losowa ma rozkład normalny. Jakie jest prawdopodobieństwo, że odchyli się od średniej o więcej niż $3\sigma$?
2. Dwie niezależne zmienne o wariancjach $\sigma_1^2$ i $\sigma_2^2$ dodano. Jaka jest wariancja sumy? A gdyby je odjęto?
3. Ile wynosi gęstość szumu termicznego rezystora 1 kΩ w temperaturze 300 K (w nV/√Hz)?
4. Szum biały o gęstości 10 nV/√Hz przechodzi przez idealny filtr o paśmie 10 kHz. Jaka jest wartość skuteczna szumu na wyjściu?
5. Czym różni się wartość średnia „po zespole” od średniej „po czasie”?
6. Jaki jest stosunek sygnału do szumu kwantyzacji idealnego 12-bitowego przetwornika A/C dla pełnej sinusoidy?
7. Licznik zlicza średnio 100 impulsów w czasie pomiaru (proces Poissona). Ile wynosi względna niepewność wyniku?

<details>
<summary>Odpowiedzi</summary>

1. Ok. 0,27%
2. $\sigma_1^2 + \sigma_2^2$ w obu przypadkach
3. $\sqrt{4kTR} \approx 4\text{,}07$ nV/√Hz
4. $10\ \text{nV}\cdot\sqrt{10^4} = 1$ µV
5. Średnia po zespole — po wielu realizacjach procesu w jednej chwili; po czasie — z jednej realizacji przez długi czas. Są równe dla procesu ergodycznego
6. $6\text{,}02\cdot 12 + 1\text{,}76 = 74$ dB
7. $\sqrt{100}/100 = 10\%$

**Ocena:** 1–2 — temat 01; 5 — 02; 3 — 06; 4 — 03–04; 6 — 07; 7 — 08.
</details>

## Projekt modułowy: budżet szumów wzmacniacza pomiarowego

- [ ] **Model (tematy 03–04, 06):** wybierz wzmacniacz operacyjny i obwód (np. wzmacniacz napięcia z czujnika o rezystancji 10 kΩ, wzmocnienie 100, pasmo 0,1 Hz–1 kHz). Policz szum na wyjściu: $e_n$ z szumem $1/f$, $i_n$, szum termiczny rezystorów; podaj udziały procentowe.
- [ ] **Symulacja:** analiza `.noise` w LTspice/ngspice; porównanie z obliczeniem.
- [ ] **Pomiar (temat 05):** wyjście wzmacniacza (wejście zwarte przez rezystancję źródła) do karty dźwiękowej lub oscyloskopu z długim zapisem; gęstość widmowa metodą Welcha, odczyt częstotliwości narożnej $1/f$ i poziomu szumu białego.
- [ ] **Raport:** wykres gęstości widmowej z modelem, symulacją i pomiarem; wnioski — który składnik dominuje i jak go zmniejszyć.

## Sprawdzian końcowy modułu

- [ ] Łączę wariancje niezależnych i skorelowanych składników, liczę rozrzut układu metodą RSS i Monte Carlo.
- [ ] Rozróżniam stacjonarność w szerokim sensie i ergodyczność; wiem, kiedy średnia czasowa zastępuje średnią po zespole.
- [ ] Wyznaczam gęstość widmową mocy z autokorelacji (twierdzenie Wienera–Chinczyna), rozróżniam widmo jedno- i dwustronne.
- [ ] Liczę szum na wyjściu układu liniowego, używam pasma szumowego równoważnego (ENBW).
- [ ] Szacuję widmo szumu metodą Welcha, znam kompromis rozdzielczość–wariancja i poprawnie skaluję jednostki.
- [ ] Liczę szum termiczny, śrutowy, $1/f$, $kT/C$ oraz szum wzmacniacza z $e_n$ i $i_n$; wyznaczam współczynnik szumów.
- [ ] Liczę szum kwantyzacji, wpływ jittera zegara i jitter z szumu fazowego.
- [ ] Opisuję szum wąskopasmowy przez składowe I/Q, rozkład Rayleigha obwiedni i statystykę Poissona zliczeń.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [MIT 6.041 Probabilistic Systems Analysis and Applied Probability (2010)](https://ocw.mit.edu/courses/6-041-probabilistic-systems-analysis-and-applied-probability-fall-2010/) | Prawdopodobieństwo i procesy losowe (wykłady wideo) — tematy 01–02, 08 |
| [MIT 6.011 Signals, Systems and Inference (2018)](https://ocw.mit.edu/courses/6-011-signals-systems-and-inference-spring-2018/) | Procesy losowe w układach LTI, widmo mocy, estymacja — tematy 02–05 |
| [MIT 6.450 Principles of Digital Communication I (2006)](https://ocw.mit.edu/courses/6-450-principles-of-digital-communications-i-fall-2006/) | Szum gaussowski, szum pasmowy — tematy 07–08 |
| [Analog Devices — MT-048 Op Amp Noise Relationships](https://www.analog.com/media/en/training-seminars/tutorials/MT-048.pdf) | Szum $1/f$ i szum biały wzmacniaczy — temat 06 |
| [Texas Instruments — Precision Labs: Op Amps (noise)](https://www.ti.com/video/series/precision-labs/ti-precision-labs-op-amps.html) | Wykłady wideo o szumie wzmacniaczy — temat 06 |
| [SciPy — signal.welch](https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.welch.html) | Estymacja widma — temat 05 |
| [Analog Devices — MT-001 Taking the Mystery out of the Infamous Formula „SNR = 6.02N + 1.76 dB”](https://www.analog.com/media/en/training-seminars/tutorials/MT-001.pdf) | Szum kwantyzacji — temat 07 |
| A. Papoulis, S. U. Pillai — *Probability, Random Variables and Stochastic Processes* (płatna) | Klasyczny podręcznik procesów losowych |
| C. D. Motchenbacher, J. A. Connelly — *Low-Noise Electronic System Design* (płatna) | Projektowanie układów niskoszumnych |
