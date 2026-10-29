# 21.03 — Autokorelacja i gęstość widmowa mocy

## Po co to jest

Karta katalogowa wzmacniacza podaje szum w nV/√Hz, generator — szum fazowy w dBc/Hz, przetwornik A/C — gęstość szumu w dBFS/Hz. Wszystkie te liczby to **gęstość widmowa mocy** (PSD): ile mocy szumu przypada na 1 Hz pasma przy danej częstotliwości. Z autokorelacji wynika, jak szybko szum się zmienia, z PSD — ile go przejdzie przez filtr. Łączy je twierdzenie Wienera–Chinczyna.

## Teoria w pigułce

### Twierdzenie Wienera–Chinczyna

Dla procesu WSS gęstość widmowa mocy jest transformatą Fouriera autokorelacji:

$$S_X(f) = \int_{-\infty}^{\infty}R_X(\tau)\,e^{-j2\pi f\tau}\,d\tau, \qquad R_X(\tau) = \int_{-\infty}^{\infty}S_X(f)\,e^{j2\pi f\tau}\,df$$

- Moc: $E[X^2] = R_X(0) = \displaystyle\int_{-\infty}^{\infty}S_X(f)\,df$ — pole pod PSD.
- $S_X(f) \geq 0$, dla procesu rzeczywistego parzysta.
- **Widmo jednostronne** (karty katalogowe, analizatory widma): $G_X(f) = 2S_X(f)$ dla $f > 0$; moc $= \int_0^\infty G_X\,df$. **Najczęstsze źródło błędu o czynnik 2** — sprawdzaj, którego widma używa wzór lub program (`scipy.signal.welch` zwraca domyślnie jednostronne).
- Jednostki: V²/Hz (pierwiastek: V/√Hz — „gęstość widmowa napięcia szumu”), W/Hz, dBm/Hz; dla szumu fazowego dBc/Hz.

### Szum biały i kolorowy

| Proces | $R_X(\tau)$ | $S_X(f)$ (dwustronne) |
|---|---|---|
| Biały | $\tfrac{N_0}{2}\,\delta(\tau)$ | $N_0/2$ — stałe |
| Biały filtrowany RC (proces Ornsteina–Uhlenbecka, szum „czerwony”) | $\sigma^2 e^{-\lvert\tau\rvert/\tau_c}$ | $\dfrac{2\sigma^2\tau_c}{1 + (2\pi f\tau_c)^2}$ |
| Sinusoida o losowej fazie | $\tfrac{A^2}{2}\cos 2\pi f_0\tau$ | $\tfrac{A^2}{4}[\delta(f - f_0) + \delta(f + f_0)]$ |
| Szum $1/f$ (różowy) | — (zależy od czasu obserwacji) | $\propto 1/\lvert f\rvert$ |
| Ciąg bitów NRZ ±A, okres $T_b$, losowe | $A^2(1 - \lvert\tau\rvert/T_b)$ dla $\lvert\tau\rvert < T_b$ | $A^2T_b\,\mathrm{sinc}^2(fT_b)$ |

- **Czas korelacji** $\tau_c$ i pasmo szumu są odwrotnie proporcjonalne: szybki szum — szerokie widmo.
- Szum „biały” w praktyce to szum o widmie płaskim w paśmie, które nas interesuje (szum termiczny jest płaski do ok. $kT/h \approx 6$ THz).
- Sygnał deterministyczny okresowy daje w PSD prążki (delty), szum — widmo ciągłe; analizator widma pokazuje oba naraz, ale skalują się różnie z szerokością pasma rozdzielczości (temat 05).

## Przykład rozwiązany

**Szum o autokorelacji wykładniczej:** $\sigma = 1$ mV (wartość skuteczna), $\tau_c = 1$ µs.

- PSD dwustronna przy niskich częstotliwościach: $S(0) = 2\sigma^2\tau_c = 2\cdot 10^{-6}\cdot 10^{-6} = 2\cdot 10^{-12}$ V²/Hz → $1\text{,}41$ µV/√Hz.
- Jednostronna (tak podałby to analizator lub karta katalogowa): $G(0) = 4\cdot 10^{-12}$ V²/Hz → **2 µV/√Hz**.
- Częstotliwość „narożna” (spadek PSD o połowę): $f_c = \dfrac{1}{2\pi\tau_c} = 159$ kHz.
- Kontrola mocy: $\displaystyle\int_0^\infty \frac{G(0)}{1 + (f/f_c)^2}\,df = G(0)\cdot\frac{\pi}{2}f_c = 4\cdot 10^{-12}\cdot 2\text{,}5\cdot 10^5 = 10^{-6}$ V² ✓ ($\sigma^2$).

## Typowe pułapki

- **Mieszanie widma jedno- i dwustronnego** — błąd o czynnik 2 w mocy (3 dB).
- **Mylenie V/√Hz z V²/Hz** — gęstości mocy się dodają, gęstości napięcia — geometrycznie.
- **Gęstość szumu bez pasma** — „szum 10 nV/√Hz” nie mówi nic o wartości skutecznej, dopóki nie znasz pasma.
- **Prążek i szum w tych samych jednostkach** — prążek ma moc (V²), szum gęstość (V²/Hz); na wykresie PSD wysokość prążka zależy od rozdzielczości analizy.
- **Szum $1/f$ całkowany od 0 Hz** — całka jest rozbieżna; dolną granicą jest odwrotność czasu obserwacji.

## Ćwiczenie komputerowe

Generacja szumu o autokorelacji wykładniczej (biały przez filtr RC) i sprawdzenie twierdzenia Wienera–Chinczyna numerycznie:

```python
import numpy as np
from scipy import signal

rng = np.random.default_rng(0)
fs, N = 10e6, 2_000_000                       # 10 MS/s, 0,2 s
tau_c, sigma = 1e-6, 1e-3
a = np.exp(-1/(fs*tau_c))                     # dyskretny odpowiednik filtru RC (proces AR(1))
w = rng.normal(0, sigma*np.sqrt(1 - a**2), N)
x = signal.lfilter([1], [1, -a], w)
print(f"wartość skuteczna: {x.std()*1e3:.3f} mV (oczekiwane 1 mV)")

# autokorelacja dla kilku opóźnień
for lag_us in (0, 0.5, 1, 2):
    L = int(lag_us*1e-6*fs)
    r = np.mean(x[:N - L]*x[L:])
    print(f"R({lag_us} µs) = {r*1e6:.3f} µV²·10^6  (teoria {sigma**2*np.exp(-lag_us*1e-6/tau_c)*1e6:.3f})")

# gęstość widmowa jednostronna metodą Welcha
f, G = signal.welch(x, fs, nperseg=8192)
G_th = 4*sigma**2*tau_c/(1 + (2*np.pi*f*tau_c)**2)
for fq in (20e3, 159e3, 1e6):
    i = np.argmin(np.abs(f - fq)); sl = slice(i - 5, i + 6)          # średnia z 11 binów wokół fq
    print(f"G({fq/1e3:.0f} kHz): pomiar {np.sqrt(G[sl].mean())*1e6:.3f} µV/√Hz, teoria {np.sqrt(G_th[sl].mean())*1e6:.3f} µV/√Hz")
print(f"moc z całki PSD: {np.trapezoid(G, f)*1e6:.3f} µV²·10^6")
```

Model dyskretny AR(1) różni się od ciągłego przy częstotliwościach bliskich $f_s/2$ — dlatego punkty kontrolne są wybrane znacznie poniżej 5 MHz.

## Zadania

1. Jednostronna gęstość widmowa napięcia szumu wynosi 4 nV/√Hz. Ile wynosi gęstość mocy w V²/Hz i jaka jest wartość skuteczna w paśmie 0–100 kHz (szum biały)?
2. Dwa niezależne źródła szumu: 3 nV/√Hz i 4 nV/√Hz. Jaka jest gęstość sumy?
3. Autokorelacja procesu: $R(\tau) = 4e^{-1000\lvert\tau\rvert}$ V². Podaj moc, wartość skuteczną i jednostronną PSD przy 0 Hz.
4. Losowy ciąg bitów NRZ ±1 V z szybkością 1 Mb/s. Przy jakiej częstotliwości widmo ma pierwsze zero? Gdzie skupia się większość mocy?
5. Dlaczego całkowanie szumu $1/f$ wymaga dolnej granicy częstotliwości i od czego ona zależy w praktyce?

<details>
<summary>Odpowiedzi</summary>

1. $(4\cdot 10^{-9})^2 = 1\text{,}6\cdot 10^{-17}$ V²/Hz; $4\ \text{nV}\cdot\sqrt{10^5} \approx 1\text{,}26$ µV
2. $\sqrt{3^2 + 4^2} = 5$ nV/√Hz
3. Moc $R(0) = 4$ V², wartość skuteczna 2 V; $\tau_c = 1$ ms, $S(0) = 2\cdot 4\cdot 10^{-3} = 8\cdot 10^{-3}$ V²/Hz (dwustronna), jednostronna $G(0) = 0\text{,}016$ V²/Hz
4. Pierwsze zero przy $1/T_b = 1$ MHz; ok. 90% mocy w głównym listku do 1 MHz
5. $\int df/f = \ln(f_H/f_L)$ rozbiega się dla $f_L \to 0$; w praktyce $f_L \approx 1/T_{obs}$ (czas pomiaru) lub dolna granica pasma układu (sprzężenie AC, autozerowanie, okres kalibracji)
</details>

## Źródła

- [MIT 6.011 Signals, Systems and Inference](https://ocw.mit.edu/courses/6-011-signals-systems-and-inference-spring-2018/) — autokorelacja, gęstość widmowa mocy
- [MIT 6.450 Principles of Digital Communication I](https://ocw.mit.edu/courses/6-450-principles-of-digital-communications-i-fall-2006/) — procesy gaussowskie, szum biały
- [SciPy — signal.welch](https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.welch.html)
