# 01.07 — Rezonans i charakterystyki częstotliwościowe

## Po co to jest

Transmitancja i wykres Bodego to najważniejsze narzędzia projektowania filtrów, wzmacniaczy i układów regulacji. Obwody rezonansowe wybierają kanały w odbiornikach radiowych, tworzą generatory i filtry w.cz.

## Teoria w pigułce

### Transmitancja

$$\underline{H}(j\omega) = \frac{\underline{U}_{wy}}{\underline{U}_{we}}$$

Charakterystyka amplitudowa $\lvert H(j\omega)\rvert$ (zwykle w dB) i fazowa $\arg H(j\omega)$.

### Filtry 1. rzędu

| Filtr | Transmitancja | Częstotliwość graniczna |
|---|---|---|
| Dolnoprzepustowy RC | $\dfrac{1}{1 + j\omega RC}$ | $f_c = \dfrac{1}{2\pi RC}$ |
| Górnoprzepustowy RC | $\dfrac{j\omega RC}{1 + j\omega RC}$ | $f_c = \dfrac{1}{2\pi RC}$ |
| Dolnoprzepustowy RL | $\dfrac{1}{1 + j\omega L/R}$ | $f_c = \dfrac{R}{2\pi L}$ |

Przy $f_c$: $\lvert H\rvert = 1/\sqrt{2}$ (−3 dB), faza ±45°. Za $f_c$ nachylenie 20 dB/dekadę.

### Wykres Bodego — reguły asymptotyczne

- Biegun rzeczywisty w $\omega_p$: od $\omega_p$ nachylenie −20 dB/dek; faza od 0 do −90° (−45° w $\omega_p$, zmiana w przedziale $0{,}1\omega_p$–$10\omega_p$).
- Zero rzeczywiste: to samo ze znakiem „+”.
- Para biegunów zespolonych (2. rząd): −40 dB/dek, faza do −180°; przy małym $\zeta$ — rezonansowy pik.
- Stałe wzmocnienie $K$: przesunięcie o $20\log K$.

Rzeczywista krzywa różni się od asymptoty o 3 dB w punkcie załamania (dla bieguna 1. rzędu).

### Rezonans szeregowy RLC

$$f_0 = \frac{1}{2\pi\sqrt{LC}}, \qquad Q = \frac{1}{R}\sqrt{\frac{L}{C}} = \frac{\omega_0 L}{R}, \qquad B = \frac{f_0}{Q}$$

W rezonansie: impedancja minimalna i czysto rezystancyjna ($Z = R$), prąd maksymalny, a napięcia na L i C są $Q$ razy większe od napięcia zasilania (**rezonans napięć**).

### Rezonans równoległy RLC

$$f_0 = \frac{1}{2\pi\sqrt{LC}}, \qquad Q = R\sqrt{\frac{C}{L}} = \frac{R}{\omega_0 L}$$

W rezonansie: impedancja maksymalna ($Z = R$), prądy w L i C są $Q$ razy większe od prądu źródła (**rezonans prądów**).

Związek z obwodami 2. rzędu: $Q = \dfrac{1}{2\zeta}$.

## Przykład rozwiązany

**Filtr RC:** $R = 1{,}6$ kΩ, $C = 100$ nF.

1. $f_c = \dfrac{1}{2\pi\cdot 1600\cdot 10^{-7}} \approx 995$ Hz.
2. Przy 1 kHz: $\lvert H\rvert = \dfrac{1}{\sqrt{1 + (1000/995)^2}} \approx 0{,}705$ → −3,03 dB, faza $-\arctan(1{,}005) \approx -45{,}2^\circ$.
3. Przy 10 kHz: $\lvert H\rvert \approx 0{,}099$ → −20,1 dB, faza ≈ −84,3°. Asymptota przewiduje −20 dB i −90°.

**Rezonans szeregowy:** $R = 100\ \Omega$, $L = 10$ mH, $C = 100$ nF, zasilanie 1 V.

1. $f_0 = \dfrac{1}{2\pi\sqrt{10^{-9}}} \approx 5033$ Hz.
2. $Q = \dfrac{1}{100}\sqrt{\dfrac{10^{-2}}{10^{-7}}} \approx 3{,}16$, $B \approx 1592$ Hz.
3. Prąd w rezonansie $1\ \text{V}/100\ \Omega = 10$ mA; napięcie na kondensatorze $10\ \text{mA}\cdot X_C = Q\cdot 1\ \text{V} \approx 3{,}16$ V.

## Typowe pułapki

- **$f$ i $\omega$ pomylone** we wzorach — różnica $2\pi$.
- **Asymptota traktowana jak wartość dokładna** w pobliżu punktu załamania.
- **Napięcie na kondensatorze w rezonansie większe od zasilania** — to nie błąd, to istota rezonansu napięć (i powód przebicia kondensatorów o zbyt niskim napięciu znamionowym).
- **Dobroć obwodu szeregowego i równoległego** liczona tym samym wzorem.

## Symulacja

```spice
* 01.07 filtr RC i rezonans szeregowy
V1 in 0 AC 1
R1 in lp 1.6k
C1 lp 0 100n
R2 in a 100
L2 a b 10m
C2 b 0 100n
.ac dec 100 10 1Meg
.end
```

Wyświetl `V(lp)` i `V(b)`. Kursorem odczytaj $f_c$ (−3 dB), $f_0$ i pasmo 3 dB rezonansu. Kliknij oś pionową, aby przełączyć między dB i wartością liniową.

```python
import numpy as np, matplotlib.pyplot as plt
from scipy import signal
R, C = 1.6e3, 100e-9
w, mag, phase = signal.bode(signal.lti([1], [R*C, 1]), w=np.logspace(2, 6, 500))
plt.semilogx(w/(2*np.pi), mag); plt.grid(which="both"); plt.xlabel("f [Hz]"); plt.ylabel("dB"); plt.show()
```

## Zadania

1. Wyznacz $f_c$ filtra RC z $R = 10$ kΩ i $C = 10$ nF.
2. Filtr górnoprzepustowy RC. Wyznacz $\lvert H\rvert$ (dB) i fazę przy $f = f_c/10$.
3. Szeregowy RLC: $R = 100\ \Omega$, $L = 10$ mH, $C = 100$ nF, zasilanie 1 V. Wyznacz $f_0$, $Q$, $B$ i napięcie na kondensatorze w rezonansie.
4. Równoległy RLC: $R = 10$ kΩ, $L = 1$ mH, $C = 10$ nF. Wyznacz $f_0$, $Q$, $B$.
5. Narysuj asymptotyczny wykres Bodego dla $H(j\omega) = \dfrac{100}{(1 + j\omega/10^3)(1 + j\omega/10^5)}$. Ile wynosi wzmocnienie przy $\omega = 10^4$ rad/s według asymptoty, a ile dokładnie?
6. Dobierz $C$ filtra dolnoprzepustowego RC z $R = 10$ kΩ, aby $f_c = 1$ kHz.

<details>
<summary>Odpowiedzi</summary>

1. ≈ 1592 Hz
2. ≈ −20,0 dB, faza ≈ +84,3°
3. $f_0 \approx 5033$ Hz, $Q \approx 3{,}16$, $B \approx 1592$ Hz, $U_C \approx 3{,}16$ V
4. $f_0 \approx 50{,}3$ kHz, $Q = 10^4\sqrt{10^{-8}/10^{-3}} \approx 31{,}6$, $B \approx 1{,}59$ kHz
5. 40 dB do $10^3$ rad/s, potem −20 dB/dek do $10^5$ (gdzie asymptota osiąga 0 dB), dalej −40 dB/dek. Przy $10^4$: asymptotycznie 20 dB, dokładnie ≈ 19,9 dB
6. $C = \dfrac{1}{2\pi\cdot 10^4\cdot 10^3} \approx 15{,}9$ nF (najbliższa wartość z szeregu: 15 nF lub 16 nF)
</details>

## Źródła

- [AC Electrical Circuit Analysis — J. M. Fiore](https://eng.libretexts.org/Bookshelves/Electrical_Engineering/Electronics/AC_Electrical_Circuit_Analysis%3A_A_Practical_Approach_%28Fiore%29) — rezonans i filtry pasywne
- [Operational Amplifiers & Linear ICs — J. M. Fiore, rozdział 1](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html) — decybele i wykresy Bodego
- [All About Circuits — tom AC](https://www.allaboutcircuits.com/textbook/) — rozdziały o rezonansie i filtrach
- [MIT 6.002 Circuits and Electronics](https://ocw.mit.edu/courses/6-002-circuits-and-electronics-spring-2007/) — wykład o filtrach
- [Falstad — przykłady filtrów pasywnych](https://falstad.com/circuit/e-index.html)
