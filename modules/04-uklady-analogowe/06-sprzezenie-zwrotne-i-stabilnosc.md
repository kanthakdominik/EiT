# 04.06 — Sprzężenie zwrotne i stabilność

## Po co to jest

Ujemne sprzężenie zwrotne to najważniejszy pomysł w elektronice analogowej: zamienia niedokładny wzmacniacz o ogromnym wzmocnieniu na precyzyjny układ, którego właściwości ustalają dwa rezystory. Ceną jest ryzyko niestabilności — każdy projektant musi umieć ocenić zapas fazy.

## Teoria w pigułce

### Wzmocnienie ze sprzężeniem

$$A_f = \frac{A}{1 + A\beta}$$

$A$ — wzmocnienie w otwartej pętli, $\beta$ — współczynnik sprzężenia, $T = A\beta$ — **wzmocnienie pętli**. Gdy $T \gg 1$: $A_f \approx 1/\beta$ — wzmocnienie zależy tylko od sieci sprzężenia.

Co daje ujemne sprzężenie (wszystko w stosunku $1 + T$):

| Właściwość | Zmiana |
|---|---|
| Wrażliwość wzmocnienia na zmiany $A$ | maleje $(1 + T)$ razy |
| Pasmo | rośnie $(1 + T)$ razy (iloczyn wzmocnienia i pasma stały) |
| Zniekształcenia nieliniowe | maleją ok. $(1 + T)$ razy |
| Impedancje | zależnie od topologii — patrz niżej |

### Cztery topologie

| Próbkowanie wyjścia / porównanie na wejściu | Nazwa | Stabilizuje | $R_{we}$ | $R_{wy}$ | Przykład |
|---|---|---|---|---|---|
| Napięcie / szeregowo | szeregowo-równoległe | wzmocnienie napięciowe | ×(1 + T) | ÷(1 + T) | Wzmacniacz nieodwracający |
| Napięcie / równolegle | równoległo-równoległe | transimpedancję | ÷(1 + T) | ÷(1 + T) | Wzmacniacz odwracający, TIA |
| Prąd / szeregowo | szeregowo-szeregowe | transkonduktancję | ×(1 + T) | ×(1 + T) | WE z $R_E$, źródło prądowe |
| Prąd / równolegle | równoległo-szeregowe | wzmocnienie prądowe | ÷(1 + T) | ×(1 + T) | Wzmacniacz prądowy |

Zasada: porównanie szeregowe zwiększa $R_{we}$, równoległe — zmniejsza. Próbkowanie napięcia zmniejsza $R_{wy}$, próbkowanie prądu — zwiększa.

### Stabilność

Układ jest niestabilny, gdy przy pewnej częstotliwości $T(j\omega) = -1$ — ujemne sprzężenie zamienia się w dodatnie. Każdy biegun wnosi do 90° przesunięcia fazy, więc wzmacniacz z trzema biegunami (lub opóźnieniem) może się wzbudzić.

- **Zapas fazy (PM):** $180° + \arg T$ przy częstotliwości, w której $\lvert T\rvert = 1$. Dobrze: ≥ 45°, typowo 60°.
- **Zapas wzmocnienia (GM):** o ile dB $\lvert T\rvert$ jest poniżej 0 dB tam, gdzie faza $T$ osiąga −180°.

| Zapas fazy | Przeregulowanie odpowiedzi skokowej (ok.) | Pik charakterystyki |
|---|---|---|
| 76° | ~0% | brak |
| 60° | ~9% | brak |
| 45° | ~23% | ok. +2 dB |
| 30° | ~37% | ok. +6 dB |

**Najgorszy przypadek:** wtórnik napięciowy ($\beta = 1$) — największe wzmocnienie pętli, najmniejszy zapas fazy. Dlatego wzmacniacze operacyjne kompensuje się wewnętrznie tak, by były stabilne przy wzmocnieniu 1 (lub dokumentacja podaje minimalne stabilne wzmocnienie).

**Kompensacja:** dominujący biegun (kondensator Millera wewnątrz wzmacniacza), kompensacja zerem w sieci sprzężenia (kondensator równoległy do rezystora sprzężenia), izolacja obciążenia pojemnościowego rezystorem szeregowym.

## Przykład rozwiązany

**Odczulenie:** $A = 10^5$, $\beta = 0{,}01$ → $A_f = \dfrac{10^5}{1001} \approx 99{,}90$. Gdy $A$ spadnie o połowę: $A_f = \dfrac{5\cdot 10^4}{501} \approx 99{,}80$ — zmiana tylko o 0,1%.

**Zapas fazy:** wzmacniacz ma $A_0 = 10^5$ i bieguny przy 10 Hz i 1 MHz.

1. Dla $\beta = 1$ (wtórnik): $\lvert T\rvert = 1$ przy ok. 786 kHz, faza $T$ ≈ −128°, **PM ≈ 52°** — stabilny, z wyraźnym przeregulowaniem.
2. Dla $\beta = 0{,}1$ (wzmocnienie 10): $\lvert T\rvert = 1$ przy ok. 100 kHz, **PM ≈ 84°** — bardzo stabilny.

## Typowe pułapki

- **Ocena stabilności z charakterystyki wzmacniacza ze sprzężeniem** zamiast z charakterystyki pętli $T$.
- **Obciążenie pojemnościowe wyjścia** (kabel, duży kondensator) dodaje biegun w pętli i może wzbudzić stabilny wcześniej wzmacniacz.
- **Kondensator wejściowy (np. pojemność fotodiody)** w układzie TIA tworzy biegun w $\beta$ — konieczny kondensator kompensujący w sprzężeniu.
- **„Stabilny w symulacji”** — model może nie zawierać pasożytniczych biegunów; zawsze sprawdź odpowiedź skokową na stole.

## Symulacja

Pomiar zapasu fazy w LTspice metodą przerwania pętli dla sygnału AC (źródło napięciowe w pętli, z zachowaniem punktu pracy):

```spice
* 04.06 wtornik napieciowy - wzmocnienie petli
VIN in 0 0
VT fb out AC 1
E1 out 0 Laplace={1e5/((1+s/(2*pi*10))*(1+s/(2*pi*1e6)))} in fb
.ac dec 100 1 10Meg
.end
```

(Źródło sterowane modeluje wzmacniacz o dwóch biegunach.) Narysuj `-V(out)/V(fb)` — to $T(j\omega)$. Odczytaj częstotliwość przejścia przez 0 dB i fazę. Porównaj z wynikiem z przykładu. Następnie zbuduj wtórnik z modelem rzeczywistego wzmacniacza, obciąż go kondensatorem 1 nF i obejrzyj odpowiedź skokową.

## Zadania

1. $A = 10^5$, $\beta = 0{,}01$. Wyznacz $A_f$ i jego zmianę przy dwukrotnym spadku $A$.
2. Wzmacniacz o $A = 2000$ i paśmie 1 kHz (jeden biegun). Jakie pasmo będzie miał ze sprzężeniem dającym wzmocnienie 20?
3. Wzmacniacz nieodwracający: wejście wzmacniacza ma 1 MΩ, wzmocnienie pętli 1000. Jaka jest rezystancja wejściowa układu ze sprzężeniem?
4. Dla wzmacniacza z przykładu (bieguny 10 Hz i 1 MHz) wyznacz zapas fazy przy wzmocnieniu 10 i przy wzmocnieniu 1. Który przypadek jest groźniejszy i dlaczego?
5. Stopień ma zniekształcenia 5% bez sprzężenia. Jakie będą zniekształcenia przy wzmocnieniu pętli 99 (przy tej samej amplitudzie wyjściowej)?

<details>
<summary>Odpowiedzi</summary>

1. ≈ 99,9; spada do ≈ 99,8 (0,1%)
2. $1 + T = 2000/20 = 100$ → pasmo 100 kHz
3. ≈ 1 GΩ (w praktyce ograniczona przez rezystancje polaryzacji i pojemności)
4. ≈ 84° (wzmocnienie 10) i ≈ 52° (wzmocnienie 1); wtórnik jest groźniejszy, bo ma największe wzmocnienie pętli, więc przejście przez 0 dB wypada wyżej, bliżej drugiego bieguna
5. ok. 5%/100 = 0,05%
</details>

## Źródła

- [Operational Amplifiers & Linear ICs — J. M. Fiore, rozdział 3 *Negative Feedback*](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html)
- [MIT 6.002 Circuits and Electronics](https://ocw.mit.edu/courses/6-002-circuits-and-electronics-spring-2007/) — wykłady o wzmacniaczu operacyjnym i sprzężeniu dodatnim
- [MIT 6.003 Signals and Systems](https://ocw.mit.edu/courses/6-003-signals-and-systems-fall-2011/) — sprzężenie zwrotne, bieguny i stabilność od strony teorii systemów
- [LTspice](https://www.analog.com/en/resources/design-tools-and-calculators/ltspice-simulator.html) — materiały producenta o symulacji pętli regulacji
