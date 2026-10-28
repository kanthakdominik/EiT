# 06.08 — Sygnały losowe i szum

## Po co to jest

Szum ogranicza czułość każdego odbiornika, rozdzielczość każdego pomiaru i zasięg każdego łącza. Opis sygnałów losowych przez funkcję autokorelacji i gęstość widmową mocy pozwala policzyć szum na wyjściu filtra, porównać źródła szumu i zrozumieć, dlaczego zawężenie pasma poprawia stosunek sygnału do szumu.

## Teoria w pigułce

### Opis procesu losowego

| Wielkość | Definicja | Znaczenie |
|---|---|---|
| Wartość średnia | $\mu = E[x(t)]$ | Składowa stała |
| Funkcja autokorelacji | $R_x(\tau) = E[x(t)x(t + \tau)]$ | Jak szybko sygnał „zapomina” swoją wartość; $R_x(0)$ = moc |
| **Gęstość widmowa mocy (PSD)** | $S_x(f) = \mathcal{F}\{R_x(\tau)\}$ (twierdzenie Wienera–Chinczyna) | Rozkład mocy na częstotliwości [V²/Hz] |
| Moc w paśmie | $P = \int S_x(f)df$ | |

Proces **stacjonarny** — właściwości statystyczne nie zmieniają się w czasie. **Ergodyczny** — średnie po czasie równe średnim po zbiorze (można je mierzyć na jednym przebiegu).

### Szum biały i kolorowy

- **Biały:** stała PSD $N_0/2$ (dwustronna) — autokorelacja to delta, próbki nieskorelowane.
- **Różowy (1/f):** PSD maleje jak $1/f$ — dominuje przy niskich częstotliwościach w przyrządach półprzewodnikowych.
- Szum filtrowany jest „kolorowy”.

### Przejście przez układ LTI

$$S_y(f) = \lvert H(f)\rvert^2S_x(f)$$

**Równoważne pasmo szumowe** $B_n$ — szerokość prostokątnego filtra, który przepuści tę samą moc szumu białego: $P = S_x\cdot B_n$ (dla jednostronnej PSD). Dla filtra RC 1. rzędu $B_n = \dfrac{\pi}{2}f_c \approx 1{,}57f_c$.

### Fizyczne źródła szumu

| Szum | Gęstość | Uwagi |
|---|---|---|
| Termiczny (Johnsona–Nyquista) | $e_n = \sqrt{4kTR}$ [V/√Hz] | 1 kΩ, 300 K: ok. 4 nV/√Hz |
| Śrutowy | $i_n = \sqrt{2qI}$ [A/√Hz] | Prąd przez złącze (diody, fotodiody, tranzystory) |
| 1/f (migotania) | $\propto 1/f$ | Niskie częstotliwości |
| $kT/C$ | $U_n = \sqrt{kT/C}$ (całkowity) | Próbkowanie na kondensatorze — ograniczenie przetworników |

## Przykład rozwiązany

1. **Szum rezystora 1 kΩ w paśmie audio (20 kHz), 300 K:** $\sqrt{4\cdot 1{,}38\cdot 10^{-23}\cdot 300\cdot 10^3\cdot 2\cdot 10^4} \approx 0{,}58\ \mu$V RMS.
2. **Szum $kT/C$ kondensatora próbkującego 1 pF:** $\sqrt{1{,}38\cdot 10^{-23}\cdot 300/10^{-12}} \approx 64\ \mu$V RMS — dla przetwornika o zakresie 1 V i rozdzielczości 16 bitów (LSB ≈ 15 µV) to ponad 4 LSB. Dlatego precyzyjne przetworniki mają duże kondensatory próbkujące.
3. **Szum biały za filtrem RC:** jednostronna PSD $(10\ \text{nV}/\sqrt{\text{Hz}})^2$, $f_c = 10$ kHz → $B_n \approx 15{,}7$ kHz → $U_n = 10\ \text{nV}\cdot\sqrt{15\,700} \approx 1{,}25\ \mu$V RMS.

## Typowe pułapki

- **PSD jedno- i dwustronna pomylone** — różnią się dwukrotnie.
- **Pasmo −3 dB zamiast pasma szumowego** — dla filtra 1. rzędu zaniża szum o ok. 20%.
- **Szumy dodawane arytmetycznie** — niezależne źródła sumuje się w kwadratach.
- **Wartość szczytowa szumu z RMS** — dla szumu gaussowskiego wartość międzyszczytowa to w praktyce ok. 6–6,6 × RMS.

## Ćwiczenie komputerowe

```python
import numpy as np, matplotlib.pyplot as plt
from scipy import signal
fs = 100e3; N = 2**18
x = np.random.default_rng(0).normal(0, 1, N)                 # szum biały
b, a = signal.butter(1, 10e3, fs=fs)                          # filtr 1. rzędu, 10 kHz
y = signal.lfilter(b, a, x)
f, Px = signal.welch(x, fs, nperseg=4096); f, Py = signal.welch(y, fs, nperseg=4096)
plt.semilogy(f, Px, f, Py); plt.xlabel("f [Hz]"); plt.grid(); plt.show()
print("stosunek mocy:", y.var()/x.var())
```

Porównaj wynik z $B_n/(f_s/2) \approx 0{,}31$. Symulacja da ok. 0,24 — filtr cyfrowy z transformacji biliniowej ma zero przy $f_s/2$, więc jego pasmo szumowe jest węższe niż analogowego prototypu. Przy $f_c \ll f_s$ różnica znika. W LTspice analiza `.noise` liczy gęstość szumu na wyjściu z uwzględnieniem wszystkich rezystorów i przyrządów.

## Zadania

1. Wyznacz szum termiczny rezystora 1 kΩ w paśmie 20 kHz w 300 K.
2. Ile wynosi szum $kT/C$ dla kondensatora 1 pF i 100 pF?
3. Szum biały o jednostronnej PSD 10 nV/√Hz przechodzi przez filtr RC o $f_c = 10$ kHz. Jaki jest szum RMS na wyjściu?
4. Fotodioda przewodzi prąd 1 µA. Jaki jest szum śrutowy w paśmie 1 MHz?
5. Sygnał ma moc 1 µW, szum ma płaską PSD $10^{-12}$ W/Hz. Jaki jest SNR w paśmie 100 kHz, a jaki w paśmie 1 kHz?
6. Jak wygląda funkcja autokorelacji szumu białego i sinusoidy?

<details>
<summary>Odpowiedzi</summary>

1. ≈ 0,58 µV RMS
2. ≈ 64 µV i ≈ 6,4 µV
3. ≈ 1,25 µV RMS
4. $\sqrt{2\cdot 1{,}6\cdot 10^{-19}\cdot 10^{-6}\cdot 10^6} \approx 0{,}57$ nA RMS
5. Szum: 0,1 µW → SNR = 10 (10 dB); w 1 kHz: 1 nW → SNR = 1000 (30 dB) — zawężenie pasma poprawia SNR
6. Szum biały: delta w $\tau = 0$ (brak korelacji między różnymi chwilami); sinusoida: kosinus o tym samym okresie, $R(\tau) = \tfrac{A^2}{2}\cos\omega\tau$ (nie zanika)
</details>

## Źródła

- [MIT 6.003 Signals and Systems](https://ocw.mit.edu/courses/6-003-signals-and-systems-fall-2011/)
- [The Scientist and Engineer's Guide to DSP — rozdział 2 *Statistics, Probability and Noise*](http://www.dspguide.com/)
- [Think DSP — rozdział o szumie](https://greenteapress.com/wp/think-dsp/) — szum biały, różowy, autokorelacja w Pythonie
- [Fundamentals of Electrical Engineering I — D. Johnson](https://open.umn.edu/opentextbooks/textbooks/fundamentals-of-electrical-engineering-1) — szum w systemach komunikacyjnych
