# 06.07 — Układy dyskretne i transformata Z

## Po co to jest

Transformata Z jest dla układów dyskretnych tym, czym Laplace dla ciągłych. Każdy filtr cyfrowy, regulator programowy i algorytm DSP opisuje się równaniem różnicowym i transmitancją $H(z)$. Z położenia biegunów w płaszczyźnie $z$ odczytuje się stabilność i kształt charakterystyki.

## Teoria w pigułce

### Równanie różnicowe

$$y[n] = \sum_{k=0}^{M}b_kx[n - k] - \sum_{k=1}^{N}a_ky[n - k]$$

- $a_k = 0$ → **FIR** (skończona odpowiedź impulsowa, zawsze stabilny),
- $a_k \neq 0$ → **IIR** (rekursywny, nieskończona odpowiedź impulsowa).

### Transformata Z

$$X(z) = \sum_{n=-\infty}^{\infty}x[n]z^{-n}$$

| $x[n]$ | $X(z)$ | Obszar zbieżności |
|---|---|---|
| $\delta[n]$ | 1 | cała płaszczyzna |
| $\delta[n - k]$ | $z^{-k}$ | $z \neq 0$ |
| $u[n]$ | $\dfrac{1}{1 - z^{-1}}$ | $\lvert z\rvert > 1$ |
| $a^nu[n]$ | $\dfrac{1}{1 - az^{-1}}$ | $\lvert z\rvert > \lvert a\rvert$ |

**Najważniejsza własność:** opóźnienie o jedną próbkę = mnożenie przez $z^{-1}$. Stąd:

$$H(z) = \frac{\sum b_kz^{-k}}{1 + \sum a_kz^{-k}}$$

### Bieguny w płaszczyźnie $z$

| Położenie | Znaczenie |
|---|---|
| Wewnątrz okręgu jednostkowego | Stabilny (dla układu przyczynowego) |
| Na okręgu | Granica — oscylator |
| Na zewnątrz | Niestabilny |
| Blisko okręgu przy kącie $\omega_0$ | Rezonans przy $\omega_0$ |
| Zero na okręgu przy kącie $\omega_0$ | Całkowite tłumienie częstotliwości $\omega_0$ |

### Charakterystyka częstotliwościowa (DTFT)

$H(e^{j\omega})$ — wartość $H(z)$ na okręgu jednostkowym. Pulsacja unormowana $\omega = 2\pi f/f_s$, zakres $[-\pi, \pi]$; $\omega = \pi$ odpowiada $f_s/2$. Charakterystyka jest okresowa co $2\pi$.

$\omega = 0$ (DC) odpowiada $z = 1$, $\omega = \pi$ (Nyquist) — $z = -1$.

### Związek z czasem ciągłym

$z = e^{sT_s}$: lewa półpłaszczyzna $s$ → wnętrze okręgu. Metody dyskretyzacji filtrów analogowych (biliniowa, niezmienność odpowiedzi impulsowej) — [07.05](../07-cps-dsp/05-filtry-iir.md).

## Przykład rozwiązany

$y[n] = 0{,}5y[n - 1] + x[n]$.

1. $Y(z) = 0{,}5z^{-1}Y(z) + X(z)$ → $H(z) = \dfrac{1}{1 - 0{,}5z^{-1}}$.
2. Biegun $z = 0{,}5$ — wewnątrz okręgu, układ stabilny.
3. Odpowiedź impulsowa: $h[n] = 0{,}5^nu[n] = 1;\ 0{,}5;\ 0{,}25;\ \dots$
4. Wzmocnienie DC: $H(1) = 2$; przy Nyquiście: $H(-1) = 1/1{,}5 \approx 0{,}67$ — filtr dolnoprzepustowy (uśrednianie wykładnicze).

**Średnia ruchoma z 3 próbek:** $y[n] = \tfrac13(x[n] + x[n-1] + x[n-2])$, $H(e^{j\omega}) = \tfrac13(1 + 2\cos\omega)e^{-j\omega}$ — zero przy $\omega = 2\pi/3$, czyli $f = f_s/3$.

## Typowe pułapki

- **Mylenie $z^{-1}$ (opóźnienie) i $z$ (przyspieszenie)** przy przepisywaniu równań.
- **Charakterystyka rysowana do $f_s$ zamiast do $f_s/2$** — powyżej $f_s/2$ to lustrzane odbicie.
- **Biegun na samym okręgu „bo stabilny matematycznie w symulacji”** — w arytmetyce o skończonej precyzji może wyjść poza okrąg ([07.06](../07-cps-dsp/06-realizacja-filtrow.md)).

## Ćwiczenie komputerowe

```python
import numpy as np, matplotlib.pyplot as plt
from scipy import signal
b, a = [1], [1, -0.5]
w, H = signal.freqz(b, a, worN=512)
print("bieguny:", np.roots(a), " H(DC) =", abs(H[0]))
imp = signal.lfilter(b, a, np.r_[1, np.zeros(9)])
print("h[n]:", imp)
plt.plot(w/np.pi, 20*np.log10(abs(H))); plt.xlabel("ω/π"); plt.ylabel("dB"); plt.grid(); plt.show()
```

## Zadania

1. $y[n] = 0{,}5y[n - 1] + x[n]$: $H(z)$, biegun, $h[n]$, wzmocnienie DC.
2. Wyznacz transformatę Z sygnału $x[n] = 0{,}8^nu[n]$ i jej obszar zbieżności.
3. Średnia ruchoma 3-punktowa: przy jakiej częstotliwości (dla $f_s = 300$ Hz) całkowicie tłumi sygnał?
4. Układ ma bieguny $0{,}9e^{\pm j\pi/4}$. Czy jest stabilny? Przy jakiej częstotliwości ma rezonans dla $f_s = 8$ kHz?
5. Zaprojektuj (podaj zera) prosty filtr FIR 2. rzędu usuwający 50 Hz przy $f_s = 1$ kHz.
6. $y[n] = y[n - 1] + x[n]$. Jaki to układ? Czy jest stabilny w sensie BIBO?

<details>
<summary>Odpowiedzi</summary>

1. $\dfrac{1}{1 - 0{,}5z^{-1}}$, $z = 0{,}5$, $0{,}5^nu[n]$, 2
2. $\dfrac{1}{1 - 0{,}8z^{-1}}$, $\lvert z\rvert > 0{,}8$
3. $f = f_s/3 = 100$ Hz
4. Tak ($\lvert p\rvert = 0{,}9 < 1$); $\omega = \pi/4$ → $f = f_s/8 = 1$ kHz
5. Zera $z = e^{\pm j2\pi\cdot 50/1000} = e^{\pm j0{,}1\pi}$: $H(z) = 1 - 2\cos(0{,}1\pi)z^{-1} + z^{-2} \approx 1 - 1{,}902z^{-1} + z^{-2}$ (z normalizacją wzmocnienia DC)
6. Akumulator (całkowanie dyskretne); biegun $z = 1$ na okręgu — niestabilny w sensie BIBO (skok na wejściu daje rosnącą rampę)
</details>

## Źródła

- [MIT 6.003 Signals and Systems](https://ocw.mit.edu/courses/6-003-signals-and-systems-fall-2011/) — układy dyskretne, równania różnicowe, transformata Z (kurs zaczyna od czasu dyskretnego)
- [MIT RES.6-007 Signals and Systems](https://ocw.mit.edu/courses/res-6-007-signals-and-systems-spring-2011/) — wykłady 22–23: transformata Z
- [MIT RES.6-008 Digital Signal Processing](https://ocw.mit.edu/courses/res-6-008-digital-signal-processing-spring-2011/) — transformata Z w kontekście filtrów cyfrowych
