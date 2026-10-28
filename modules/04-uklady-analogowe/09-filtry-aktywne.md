# 04.09 — Filtry aktywne

## Po co to jest

Filtry usuwają z sygnału to, co niepotrzebne: zakłócenia sieciowe, szum poza pasmem, składowe powyżej połowy częstotliwości próbkowania (filtr antyaliasingowy). Filtry aktywne na wzmacniaczach operacyjnych pozwalają uzyskać charakterystyki 2. i wyższego rzędu bez cewek.

## Teoria w pigułce

### Specyfikacja filtra

Pasmo przepustowe (zafalowania), częstotliwość graniczna, pasmo zaporowe (wymagane tłumienie), pasmo przejściowe, charakterystyka fazowa / opóźnienie grupowe.

### Aproksymacje

| Aproksymacja | Pasmo przepustowe | Stromość | Odpowiedź skokowa | Zastosowanie |
|---|---|---|---|---|
| **Butterworth** | Maksymalnie płaskie | Średnia | Umiarkowane przeregulowanie | Ogólne, antyaliasing |
| **Czebyszew** | Zafalowania | Duża | Duże przeregulowanie | Gdy liczy się stromość |
| **Bessel** | Łagodny spadek | Mała | Prawie bez przeregulowania (liniowa faza) | Sygnały impulsowe, przebiegi czasowe |
| Eliptyczny (Cauera) | Zafalowania | Największa | Złe | Zera transmisji w paśmie zaporowym |

**Rząd filtra Butterwortha:** tłumienie przy $f$: $A(f) = 10\log\left[1 + (f/f_c)^{2n}\right]$; asymptotycznie $20n$ dB/dekadę.

Filtr wyższego rzędu buduje się kaskadą sekcji 2. rzędu (i ewentualnie jednej 1. rzędu) o odpowiednich $f_0$ i $Q$ z tablic. Dla Butterwortha 2. rzędu $Q = 1/\sqrt2 \approx 0{,}707$; 4. rzędu — sekcje o $Q = 0{,}541$ i $1{,}307$, obie o tej samej $f_0$.

### Struktura Sallen–Key (dolnoprzepustowa, wzmocnienie 1)

$R_1$ i $R_2$ szeregowo na wejściu, $C_1$ z węzła między nimi do **wyjścia**, $C_2$ z wejścia wzmacniacza do **masy**, wzmacniacz jako wtórnik.

$$f_0 = \frac{1}{2\pi\sqrt{R_1R_2C_1C_2}}, \qquad Q = \frac{\sqrt{R_1R_2C_1C_2}}{C_2(R_1 + R_2)}$$

Przy $R_1 = R_2 = R$: $Q = \tfrac12\sqrt{C_1/C_2}$, więc dla Butterwortha $C_1 = 2C_2$.

### Struktura MFB (wielokrotne sprzężenie zwrotne)

Odwracająca, mniej czuła na nieidealności wzmacniacza przy wysokich częstotliwościach, dobra do filtrów pasmowych o większym $Q$.

### Inne

Filtry z przełączanymi pojemnościami (scalone, przestrajane zegarem), filtr typu state-variable (jednocześnie LP, HP, BP), filtry wszechprzepustowe (korekcja fazy).

## Przykład rozwiązany

**Filtr antyaliasingowy Butterwortha 2. rzędu, $f_0 = 1$ kHz**, Sallen–Key, $R_1 = R_2 = 10$ kΩ.

1. $f_0 = \dfrac{1}{2\pi R\sqrt{C_1C_2}}$, $C_1 = 2C_2$ → $f_0 = \dfrac{1}{2\pi RC_2\sqrt2}$.
2. $C_2 = \dfrac{1}{2\pi\cdot 10^4\cdot 10^3\cdot\sqrt2} \approx 11{,}25$ nF, $C_1 \approx 22{,}5$ nF.
3. Wartości z szeregu: $C_2 = 11$ nF (lub 10 nF + 1 nF), $C_1 = 22$ nF → $f_0 \approx 1{,}02$ kHz, $Q \approx 0{,}707$.
4. Tłumienie przy 10 kHz: $10\log(1 + 10^4) \approx 40$ dB.

Kondensatory filtra — z dielektrykiem C0G lub foliowe ([02.07](../02-fizyka-i-materialy/07-materialy-elektroniczne.md)); X7R zmieni $f_0$ i $Q$ z napięciem.

## Typowe pułapki

- **Kondensatory $C_1$ i $C_2$ zamienione miejscami** w Sallen–Key — inne $Q$.
- **Kaskada dwóch jednakowych sekcji Butterwortha 2. rzędu** nie daje Butterwortha 4. rzędu (spadek −6 dB przy $f_0$ zamiast −3 dB).
- **Wzmacniacz o zbyt małym GBW** — dla sekcji o dużym $Q$ potrzeba GBW rzędu $100\cdot Q\cdot f_0$ lub więcej.
- **Sallen–Key LP przy wysokich częstotliwościach** — rzeczywista $R_{wy}$ wzmacniacza powoduje, że tłumienie przestaje rosnąć.

## Symulacja

```spice
* 04.09 Sallen-Key Butterworth 1 kHz
VIN in 0 AC 1
R1 in a 10k
R2 a b 10k
C1 a out 22n
C2 b 0 11n
E1 out 0 b out 1e5
.ac dec 100 10 100k
.end
```

Sprawdź −3 dB przy ok. 1 kHz i −40 dB przy 10 kHz. Zamień kondensatory na 10 nF i 10 nF — co dzieje się z $Q$ i kształtem charakterystyki? Narzędzie do szybkiego projektowania: [Analog Filter Wizard](https://www.analog.com/en/resources/design-tools-and-calculators/ltspice-simulator.html) (eksportuje projekt do LTspice).

```python
from scipy import signal
import numpy as np
b, a = signal.butter(4, 2*np.pi*1e3, analog=True)   # Butterworth 4. rzędu, 1 kHz
print(np.roots(a)/(2*np.pi))                          # bieguny → f0 i Q sekcji
```

## Zadania

1. Zaprojektuj Sallen–Key Butterworth $f_0 = 1$ kHz z $R_1 = R_2 = 10$ kΩ.
2. Jakiego rzędu Butterworth jest potrzebny, aby przy $10f_c$ tłumienie wynosiło co najmniej 40 dB? A 60 dB przy $5f_c$?
3. Sallen–Key z $R_1 = R_2 = 10$ kΩ, $C_1 = C_2 = 10$ nF. Wyznacz $f_0$ i $Q$.
4. Filtr antyaliasingowy dla przetwornika próbkującego 1 kHz, sygnał użyteczny do 100 Hz, wymagane tłumienie 40 dB przy 500 Hz. Jaki rząd Butterwortha i jaka częstotliwość graniczna?
5. Dlaczego do filtrowania sygnału EKG albo przebiegów prostokątnych częściej wybiera się filtr Bessela niż Czebyszewa?

<details>
<summary>Odpowiedzi</summary>

1. $C_2 \approx 11{,}3$ nF, $C_1 \approx 22{,}5$ nF
2. $n = 2$ (dokładnie 40,0 dB); dla 60 dB przy $5f_c$: $10\log(1 + 5^{2n}) \geq 60$ → $5^{2n} \geq 10^6$ → $n \geq 4{,}3$ → $n = 5$
3. $f_0 \approx 1{,}59$ kHz, $Q = 0{,}5$
4. Przy $f_c = 100$ Hz potrzeba tłumienia 40 dB przy $5f_c$: $5^{2n} \geq 10^4$ → $n \geq 2{,}9$ → 3. rząd (ok. 41,9 dB) lub 4. rząd z zapasem. Z $f_c$ nieco powyżej 100 Hz (np. 120 Hz) — 4. rząd
5. Bessel ma prawie liniową fazę (stałe opóźnienie grupowe), więc nie zniekształca kształtu przebiegu i nie wprowadza przeregulowań, które w EKG wyglądałyby jak sztuczne załamki
</details>

## Źródła

- [Operational Amplifiers & Linear ICs — J. M. Fiore, rozdział *Active Filters*](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html)
- [The Scientist and Engineer's Guide to DSP — rozdział 3 o ADC/DAC i filtrach antyaliasingowych](http://www.dspguide.com/)
- [Analog Devices — Electronics I and II](https://wiki.analog.com/university/courses/electronics/text/electronics-toc)
- [LTspice — narzędzia projektowe (Analog Filter Wizard)](https://www.analog.com/en/resources/design-tools-and-calculators/ltspice-simulator.html)
