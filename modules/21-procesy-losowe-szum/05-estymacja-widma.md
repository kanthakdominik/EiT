# 21.05 — Estymacja widma: periodogram i metoda Welcha

## Po co to jest

Gęstość widmowa mocy jest pojęciem teoretycznym — z pomiaru dostajesz skończony fragment jednej realizacji. Pomiar szumu wzmacniacza, sprawdzenie częstotliwości narożnej $1/f$, szukanie zakłóceń od przetwornicy w widmie ADC, analiza drgań — wszystko to **estymacja** PSD. Naiwne $\lvert\text{FFT}\rvert^2$ daje wynik, który wygląda jak szum na szumie: jego rozrzut wynosi 100% wartości niezależnie od długości zapisu. Metoda Welcha to standardowe rozwiązanie, a jej parametry trzeba umieć dobrać i odczytać.

## Teoria w pigułce

### Periodogram

Z $N$ próbek z częstotliwością $f_s$ i oknem $w[n]$:

$$\hat G(f_k) = \frac{2}{f_s\sum w[n]^2}\left|\sum_n w[n]x[n]e^{-j2\pi kn/N}\right|^2 \quad\text{(jednostronny, V}^2/\text{Hz)}$$

- Rozdzielczość: $\Delta f = f_s/N$ (odstęp prążków); efektywna szerokość pasma bina: $\text{ENBW}_{okna}\cdot f_s/N$ (okno Hann: 1,5 bina).
- **Wariancja:** dla szumu gaussowskiego każdy punkt periodogramu ma rozkład $\chi^2$ z 2 stopniami swobody — odchylenie standardowe = wartości oczekiwanej, **niezależnie od $N$**. Dłuższy zapis daje gęstsze punkty, ale nie mniej zaszumione.

### Metoda Welcha

1. Podziel zapis na $K$ segmentów długości $L$ (zwykle z nakładaniem 50%).
2. Pomnóż każdy przez okno (Hann), policz periodogram.
3. Uśrednij periodogramy.

- Rozdzielczość: $f_s/L$ (gorsza niż dla całego zapisu).
- Względne odchylenie standardowe ≈ $1/\sqrt{K_{eff}}$; przy oknie Hann i nakładaniu 50% $K_{eff} \approx 0\text{,}95K$ (segmenty nie są całkiem niezależne).
- **Kompromis:** krótsze segmenty → więcej uśrednień (mniejszy rozrzut), gorsza rozdzielczość. Dobór: rozdzielczość tylko taka, jaka jest potrzebna.
- W `scipy.signal.welch`: `nperseg` = $L$, `noverlap` (domyślnie $L/2$), `window` (domyślnie Hann), `scaling='density'` (V²/Hz) lub `'spectrum'` (V², do odczytu amplitudy prążków).

### Gęstość czy widmo mocy?

| Co odczytujesz | Skalowanie | Zależy od rozdzielczości? |
|---|---|---|
| Szum (ciągłe widmo) | **Gęstość** V²/Hz, V/√Hz | Nie |
| Sinusoida (prążek) | **Widmo mocy** V² (lub V RMS) | Nie |
| Prążek na wykresie gęstości | — | Tak: wysokość rośnie z $L$ |
| Szum na wykresie widma mocy | — | Tak: poziom rośnie z $\Delta f$ |

Dlatego analizator widma podaje RBW: poziom szumu na ekranie zmienia się o 10 dB przy zmianie RBW 10 razy, a prążek — nie.

### Zysk przetwarzania (processing gain)

Sinusoida o amplitudzie $A$ w szumie białym: moc prążka $A^2/2$ jest skupiona w jednym binie, a moc szumu w binie maleje z $1/N$. Stosunek prążek/szum w binie rośnie o $10\log_{10}(N/2)$ dB ponad SNR w całym paśmie — długą FFT „widać” sygnał głęboko pod poziomem szumu ([07.03](../07-cps-dsp/03-okna-i-analiza-widmowa.md)).

## Przykład rozwiązany

**Pomiar szumu białego:** $f_s = 10$ kHz, zapis 10 s ($N = 100\,000$), szum o $\sigma = 1$ V. Teoretyczna gęstość jednostronna: $G = 2\sigma^2/f_s = 2\cdot 10^{-4}$ V²/Hz.

| Metoda | Rozdzielczość | Liczba uśrednień | Rozrzut względny punktów |
|---|---|---|---|
| Periodogram całego zapisu | 0,1 Hz | 1 | ok. 100% |
| Welch, $L = 10\,000$ | 1 Hz | 19 | ok. 24% |
| Welch, $L = 1000$ | 10 Hz | 199 | ok. 8% |
| Welch, $L = 100$ | 100 Hz | 1999 | ok. 2,3% |

Do pomiaru poziomu szumu białego wystarczy rozdzielczość 10 Hz i rozrzut ok. 8%; do odczytu narożnika $1/f$ przy kilku Hz potrzebny jest dłuższy segment (np. $L = 10\,000$) i dłuższy zapis.

## Typowe pułapki

- **Periodogram bez uśredniania** — „pomiar” poziomu szumu z dokładnością ±100%.
- **Odczyt amplitudy prążka z wykresu gęstości** (lub szumu z wykresu widma mocy) — wynik zależy od długości segmentu.
- **Brak okna** — przeciek widma z silnego prążka (np. 50 Hz) zasłania słaby szum w okolicy.
- **Składowa stała i trend** — dominują najniższe biny; użyj `detrend='constant'` lub `'linear'`.
- **Aliasing szumu** — szum powyżej $f_s/2$ bez filtru antyaliasingowego „złoży się” do pasma pomiaru i zawyży wynik.
- **Mylenie jednostek dBFS, dBV, dBm/Hz** w raporcie — zawsze podawaj, co i w jakim paśmie.

## Ćwiczenie komputerowe

```python
import numpy as np
from scipy import signal

rng = np.random.default_rng(0)
fs, N, sigma = 10_000, 100_000, 1.0
x = rng.normal(0, sigma, N)
G_true = 2*sigma**2/fs
print(f"teoria: G = {G_true:.2e} V²/Hz")

f, P = signal.periodogram(x, fs, window="hann")
band = (f > 100) & (f < 4000)
print(f"periodogram: Δf = {f[1]:.2f} Hz, średnia {P[band].mean():.2e}, rozrzut względny {P[band].std()/P[band].mean()*100:.0f}%")
for L in (10_000, 1000, 100):
    f, P = signal.welch(x, fs, nperseg=L)
    band = (f > 100) & (f < 4000)
    K = (N - L)//(L//2) + 1
    print(f"Welch L = {L:6d}: Δf = {f[1]:6.1f} Hz, K = {K:5d}, średnia {P[band].mean():.2e}, "
          f"rozrzut {P[band].std()/P[band].mean()*100:4.1f}% (≈ 1/sqrt(0,95K) = {100/np.sqrt(0.95*K):.1f}%)")

# prążek w szumie: gęstość vs widmo mocy
t = np.arange(N)/fs
y = x + 0.2*np.sin(2*np.pi*1234*t)                   # sinusoida 200 mV — moc 17 dB poniżej mocy szumu
for L in (2000, 20_000):
    f, Pd = signal.welch(y, fs, nperseg=L, scaling="density")
    f, Ps = signal.welch(y, fs, nperseg=L, scaling="spectrum")
    i = np.argmin(np.abs(f - 1234))
    print(f"L = {L:6d}: prążek na wykresie gęstości {Pd[i]:.2e} V²/Hz, w widmie mocy {np.sqrt(Ps[i]*2)*1e3:.1f} mV amplitudy")
```

Amplituda odczytana z widma mocy jest prawie stała (ok. 200 mV) niezależnie od $L$, a wysokość prążka na wykresie gęstości rośnie ok. dziesięciokrotnie ze wzrostem $L$. Przy krótkim segmencie do binu z prążkiem wpada też więcej szumu — gdyby sinusoida była słabsza (np. 50 mV), odczyt amplitudy przy $L = 1000$ byłby wyraźnie zawyżony.

## Zadania

1. Zapis 1 s z $f_s = 48$ kHz. Jaki segment Welcha da rozdzielczość ok. 10 Hz i ile uśrednień (nakładanie 50%)? Jaki będzie rozrzut względny?
2. Analizator widma przy RBW = 1 kHz pokazuje poziom szumu −100 dBm. Jaki będzie poziom przy RBW = 10 Hz? A jaka gęstość w dBm/Hz (przybliżenie RBW ≈ ENBW)?
3. Dlaczego wydłużenie zapisu przy stałym periodogramie (bez segmentacji) nie zmniejsza rozrzutu punktów?
4. Sinusoida ma moc o 20 dB mniejszą niż szum w paśmie 0–$f_s/2$. Jaka długość FFT pozwoli zobaczyć prążek 10 dB ponad poziomem szumu w binie (okno prostokątne)?
5. Jak sprawdzić, czy wykres PSD pochodzi z widma jedno- czy dwustronnego?

<details>
<summary>Odpowiedzi</summary>

1. $L = 4800$ (10 Hz); $K = (48\,000 - 4800)/2400 + 1 = 19$; rozrzut ok. $1/\sqrt{18} \approx 24\%$ (krótszy segment, np. $L = 2400$, da 39 uśrednień i 16%)
2. −120 dBm (spadek o $10\log_{10}100 = 20$ dB); gęstość $-100 - 30 = -130$ dBm/Hz
3. Każdy punkt periodogramu to kwadrat modułu jednej zmiennej zespolonej gaussowskiej — rozkład $\chi^2_2$ o rozrzucie 100%; dłuższy zapis zwiększa tylko liczbę punktów (gęstość siatki), a nie liczbę uśrednionych wartości w każdym punkcie
4. Potrzebny zysk $20 + 10 = 30$ dB $= 10\log_{10}(N/2)$ → $N \approx 2000$ (w praktyce 2048, a z oknem Hann nieco więcej)
5. Scałkuj PSD po dodatnich częstotliwościach i porównaj z wariancją sygnału w dziedzinie czasu: dla jednostronnej się zgadzają, dla dwustronnej wychodzi połowa
</details>

## Źródła

- [SciPy — signal.welch](https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.welch.html) — parametry i skalowanie
- [MIT 6.011 Signals, Systems and Inference](https://ocw.mit.edu/courses/6-011-signals-systems-and-inference-spring-2018/) — estymacja widma
- [Analog Devices — MT-001](https://www.analog.com/media/en/training-seminars/tutorials/MT-001.pdf) — zysk przetwarzania FFT
- [07.03 Okna i analiza widmowa](../07-cps-dsp/03-okna-i-analiza-widmowa.md)
