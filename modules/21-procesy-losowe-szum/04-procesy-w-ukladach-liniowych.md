# 21.04 — Procesy losowe w układach liniowych

## Po co to jest

Szum wejściowy przechodzi przez wzmacniacz, filtr antyaliasingowy, tor odbiornika. Projektant musi policzyć, ile szumu zostanie na wyjściu, jak zmienia się jego widmo i ile da się zyskać filtrem. Odpowiedź daje jeden wzór — $S_Y = \lvert H\rvert^2 S_X$ — i jedno praktyczne pojęcie: **pasmo szumowe równoważne** (ENBW), które zamienia całkę w mnożenie.

## Teoria w pigułce

### Przejście procesu WSS przez układ LTI

Dla układu o odpowiedzi impulsowej $h(t)$ i transmitancji $H(f)$, z wejściem WSS $X(t)$:

- Średnia: $\mu_Y = H(0)\,\mu_X$.
- Autokorelacja: $R_Y(\tau) = h(\tau) * h(-\tau) * R_X(\tau)$.
- **Gęstość widmowa:** $S_Y(f) = \lvert H(f)\rvert^2\,S_X(f)$ — faza nie ma znaczenia dla mocy.
- Moc na wyjściu: $\sigma_Y^2 = \displaystyle\int \lvert H(f)\rvert^2 S_X(f)\,df$.
- Wejście gaussowskie → wyjście gaussowskie (filtr liniowy zachowuje rozkład normalny); filtr wąskopasmowy „gaussuje” także szum niegaussowski.
- Korelacja wzajemna wejście–wyjście: $S_{XY}(f) = H(f)S_X(f)$ — podstawa pomiaru transmitancji szumem (analizatory FFT, identyfikacja obiektu).

### Pasmo szumowe równoważne (ENBW)

Szerokość idealnego filtru prostokątnego o tym samym wzmocnieniu szczytowym, który przepuszcza tyle samo mocy szumu białego:

$$B_n = \frac{1}{\lvert H_{max}\rvert^2}\int_0^\infty \lvert H(f)\rvert^2\,df$$

| Filtr | $B_n / f_{-3\,\text{dB}}$ |
|---|---|
| RC (1. rzędu) | $\pi/2 \approx 1\text{,}571$ |
| Butterworth 2. rzędu | 1,111 |
| Butterworth 3. rzędu | 1,047 |
| Butterworth 4. rzędu | 1,026 |
| Idealny prostokątny | 1 |

Dla szumu białego o jednostronnej gęstości $e_n$ [V/√Hz]: $v_{n,RMS} = e_n\sqrt{B_n}$.

### Szum $kT/C$

Rezystor $R$ z kondensatorem $C$: $e_n^2 = 4kTR$, $B_n = \dfrac{\pi}{2}\cdot\dfrac{1}{2\pi RC} = \dfrac{1}{4RC}$, więc

$$v_n^2 = 4kTR\cdot\frac{1}{4RC} = \frac{kT}{C}$$

**Nie zależy od $R$**: większy rezystor szumi bardziej, ale zawęża pasmo dokładnie w tej samej proporcji. Wartości przy 300 K: 1 pF — 64 µV, 10 pF — 20 µV, 1 nF — 2,0 µV. To fundamentalne ograniczenie układów z próbkowaniem (S/H, przetworniki z przełączanymi pojemnościami, piksele matryc): aby zmniejszyć szum, trzeba zwiększyć pojemność próbkującą.

## Przykład rozwiązany

**Filtr RC na wyjściu źródła o rezystancji 10 kΩ, C = 1 nF, T = 300 K.**

- Gęstość szumu termicznego: $e_n = \sqrt{4kTR} = \sqrt{4\cdot 1\text{,}381\cdot 10^{-23}\cdot 300\cdot 10^4} = 12\text{,}87$ nV/√Hz.
- $f_{-3\,\text{dB}} = 1/(2\pi RC) = 15\text{,}9$ kHz; $B_n = \tfrac{\pi}{2}f_{-3\,\text{dB}} = 25$ kHz.
- $v_n = 12\text{,}87\ \text{nV}\cdot\sqrt{25\,000} = 2\text{,}04$ µV $= \sqrt{kT/C}$ ✓.

Gdyby po filtrze RC wstawić ostry filtr 4. rzędu o $f_{-3\,\text{dB}} = 1$ kHz ($B_n \approx 1\text{,}03$ kHz), szum spadnie do $12\text{,}87\cdot\sqrt{1026} \approx 0\text{,}41$ µV — o tyle, o ile pasmo sygnału pozwala.

## Typowe pułapki

- **Przyjęcie $B_n = f_{-3\,\text{dB}}$ dla filtru 1. rzędu** — zaniżenie mocy szumu o 57% (2 dB).
- **Dodawanie wzmocnień szumu w dB do gęstości w nV/√Hz bez przeliczenia** — moc skaluje się z $\lvert H\rvert^2$, napięcie z $\lvert H\rvert$.
- **Pominięcie szumu z pasma poza sygnałem** — wzmacniacz o paśmie 10 MHz w torze sygnału 1 kHz dokłada szum z całych 10 MHz, jeśli nie ma za nim filtru (a przetwornik A/C go „złoży” przez aliasing).
- **Liczenie szumu filtru aktywnego tylko z rezystorów** — wzmacniacz operacyjny w filtrze ma własny szum, często dominujący.
- **Zapomnienie o $kT/C$** przy wyborze małej pojemności próbkującej.

## Ćwiczenie komputerowe

Numeryczne ENBW filtrów i szum $kT/C$ z symulacji:

```python
import numpy as np
from scipy import signal

# ENBW filtrów Butterwortha (wzmocnienie 1, f_c = 1 rad/s)
w = np.logspace(-4, 4, 400_001)
for order in (1, 2, 3, 4):
    b, a = signal.butter(order, 1, analog=True)
    _, h = signal.freqs(b, a, worN=w)
    print(f"Butterworth {order}. rzędu: ENBW / f_c = {np.trapezoid(np.abs(h)**2, w):.3f}")

# szum kT/C: symulacja szumu termicznego rezystora przez filtr RC dla dwóch wartości R
k, T, C = 1.380649e-23, 300, 1e-9
rng = np.random.default_rng(0)
for R in (1e3, 100e3):
    tau = R*C; fs = 200/tau; N = 400_000            # próbkowanie 200 razy na stałą czasową
    en2 = 4*k*T*R                                    # jednostronna gęstość [V²/Hz]
    w_n = rng.normal(0, np.sqrt(en2*fs/2), N)        # szum biały o tej gęstości w paśmie fs/2
    a = np.exp(-1/(fs*tau))
    v = signal.lfilter([1 - a], [1, -a], w_n)
    print(f"R = {R/1e3:5.0f} kΩ: v_n = {v[1000:].std()*1e6:.2f} µV, sqrt(kT/C) = {np.sqrt(k*T/C)*1e6:.2f} µV")
```

Dla obu rezystancji wynik jest ten sam — zgodnie z $kT/C$.

## Zadania

1. Wzmacniacz o gęstości szumu wejściowego 5 nV/√Hz, wzmocnieniu 40 dB i paśmie ograniczonym filtrem 1. rzędu o $f_{-3\,\text{dB}} = 100$ kHz. Ile wynosi szum na wyjściu (RMS)?
2. Ten sam wzmacniacz z filtrem Butterwortha 4. rzędu o tej samej $f_{-3\,\text{dB}}$. O ile mniejszy jest szum?
3. Jaka pojemność próbkująca jest potrzebna, aby szum $kT/C$ w temperaturze 300 K był mniejszy niż połowa LSB przetwornika 16-bitowego o zakresie 2 V?
4. Szum biały przechodzi przez filtr pasmowy o paśmie 1 kHz wokół 10 MHz. Jak wygląda autokorelacja szumu wyjściowego?
5. Dlaczego do pomiaru transmitancji układu można użyć szumu białego zamiast przemiatania sinusem?

<details>
<summary>Odpowiedzi</summary>

1. $B_n = 157$ kHz; wejście $5\ \text{nV}\cdot\sqrt{1\text{,}57\cdot 10^5} = 1\text{,}98$ µV; wyjście ×100 → ok. 198 µV
2. $B_n = 102\text{,}6$ kHz; stosunek $\sqrt{157/102\text{,}6} = 1\text{,}24$ — szum mniejszy o ok. 19% (1,8 dB)
3. LSB = $2/65\,536 = 30\text{,}5$ µV, połowa — 15,3 µV; $C > kT/v^2 = 4\text{,}14\cdot 10^{-21}/(15\text{,}3\cdot 10^{-6})^2 \approx 18$ pF
4. Cosinusoida 10 MHz z obwiednią $\mathrm{sinc}$ o czasie korelacji rzędu 1 ms ($R(\tau) \propto \mathrm{sinc}(B\tau)\cos 2\pi f_0\tau$) — szum wąskopasmowy wygląda jak sinusoida o wolno zmiennej amplitudzie i fazie (temat 08)
5. $S_Y = \lvert H\rvert^2 S_X$ i $S_{XY} = HS_X$: szum zawiera wszystkie częstotliwości naraz, więc jeden pomiar (z uśrednianiem) daje $\lvert H\rvert$, a widmo wzajemne — także fazę
</details>

## Źródła

- [MIT 6.011 Signals, Systems and Inference](https://ocw.mit.edu/courses/6-011-signals-systems-and-inference-spring-2018/) — procesy losowe w układach LTI
- [Analog Devices — MT-048 Op Amp Noise Relationships](https://www.analog.com/media/en/training-seminars/tutorials/MT-048.pdf) — pasmo szumowe, sumowanie szumów
- [06.08 Sygnały losowe i szum](../06-sygnaly-i-systemy/08-sygnaly-losowe.md)
