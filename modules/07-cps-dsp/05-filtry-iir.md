# 07.05 — Filtry IIR

## Po co to jest

Filtry IIR (rekursywne) uzyskują tę samą stromość co FIR przy kilka–kilkadziesiąt razy mniejszej liczbie obliczeń. Są cyfrowymi odpowiednikami filtrów analogowych (Butterworth, Czebyszew, eliptyczny) i podstawą prostych filtrów w mikrokontrolerach. Ceną jest nieliniowa faza i ryzyko niestabilności.

## Teoria w pigułce

$$y[n] = \sum_{k=0}^{M}b_kx[n - k] - \sum_{k=1}^{N}a_ky[n - k], \qquad H(z) = \frac{\sum b_kz^{-k}}{1 + \sum a_kz^{-k}}$$

### Projektowanie z prototypu analogowego

| Metoda | Zasada | Cechy |
|---|---|---|
| **Transformacja biliniowa** | $s = \dfrac{2}{T_s}\cdot\dfrac{1 - z^{-1}}{1 + z^{-1}}$ | Brak aliasingu, cała oś $j\omega$ na okrąg jednostkowy; **zniekształcenie osi częstotliwości** — wymaga predistorsji |
| Niezmienność odpowiedzi impulsowej | Próbkowanie $h(t)$ | Zachowuje kształt $h$; aliasing — tylko dla filtrów dolno- i pasmowoprzepustowych |
| Dopasowanie biegunów i zer | $z = e^{sT_s}$ dla każdego bieguna i zera | Proste, przybliżone |

**Predistorsja (prewarping):** częstotliwość cyfrowa $f_d$ odpowiada analogowej

$$f_a = \frac{f_s}{\pi}\tan\frac{\pi f_d}{f_s}$$

Prototyp analogowy projektuje się dla $f_a$, a po transformacji granica wypada dokładnie w $f_d$.

### Najprostszy IIR — filtr wykładniczy (EMA)

$$y[n] = y[n - 1] + \alpha(x[n] - y[n - 1]), \qquad \alpha = 1 - e^{-2\pi f_c/f_s} \approx \frac{2\pi f_c}{f_s}$$

Jedno mnożenie na próbkę, odpowiednik filtra RC. Standard do wygładzania odczytów czujników.

### Porównanie z FIR

| | FIR | IIR |
|---|---|---|
| Stabilność | Zawsze | Bieguny muszą być wewnątrz okręgu |
| Faza | Może być liniowa | Nieliniowa (wyjątek: przetwarzanie „w przód i wstecz” offline, `filtfilt`) |
| Koszt dla stromej charakterystyki | Duży | Mały |
| Wrażliwość na kwantyzację współczynników | Mała | Duża — stosuje się kaskadę sekcji 2. rzędu (biquad) |
| Cykle graniczne | Brak | Możliwe przy arytmetyce stałoprzecinkowej |

## Przykład rozwiązany

Filtr Butterwortha 2. rzędu, $f_s = 8$ kHz, $f_c = 1$ kHz, metoda biliniowa.

1. Predistorsja: $f_a = \dfrac{8000}{\pi}\tan\dfrac{\pi}{8} \approx 1055$ Hz.
2. Prototyp analogowy Butterwortha 2. rzędu z granicą 1055 Hz → transformacja biliniowa → $H(z)$ z granicą dokładnie 1 kHz.
3. W SciPy: `signal.butter(2, 1000, fs=8000)` robi predistorsję automatycznie.
4. Koszt: 5 mnożeń na próbkę. Filtr FIR o podobnej stromości potrzebowałby kilkudziesięciu.

**EMA:** $f_s = 1$ kHz, potrzebna granica ok. 1,6 Hz → $\alpha \approx 0\text{,}01$.

## Typowe pułapki

- **Projekt bez predistorsji** — granica przesunięta, tym bardziej, im bliżej $f_s/2$.
- **Filtr wysokiego rzędu w jednej sekcji (postać bezpośrednia)** — przy zaokrągleniu współczynników bieguny wychodzą poza okrąg. Zawsze kaskada sekcji 2. rzędu (`output="sos"` w SciPy).
- **IIR do sygnałów, w których liczy się kształt** (impulsy, EKG) — zniekształcenia fazowe.
- **$\alpha$ filtra EMA dobrane „na oko”** bez związku z częstotliwością próbkowania.

## Ćwiczenie komputerowe

```python
import numpy as np, matplotlib.pyplot as plt
from scipy import signal
fs = 8000
sos_b = signal.butter(4, 1000, fs=fs, output="sos")
sos_e = signal.ellip(4, 0.5, 60, 1000, fs=fs, output="sos")
for sos, lab in [(sos_b, "Butterworth 4"), (sos_e, "eliptyczny 4")]:
    w, H = signal.sosfreqz(sos, worN=4096, fs=fs)
    plt.plot(w, 20*np.log10(abs(H) + 1e-12), label=lab)
plt.ylim(-100, 5); plt.legend(); plt.grid(); plt.xlabel("f [Hz]"); plt.show()
w, gd = signal.group_delay(signal.sos2tf(sos_e), fs=fs)
print("max opóźnienie grupowe:", gd.max(), "próbek")
```

Porównaj z filtrem FIR z [07.04](04-filtry-fir.md): liczba mnożeń na próbkę, opóźnienie, kształt odpowiedzi skokowej.

## Zadania

1. $f_s = 8$ kHz, $f_c = 1$ kHz. Jaką granicę musi mieć prototyp analogowy przy metodzie biliniowej?
2. Filtr EMA, $f_s = 1$ kHz, $\alpha = 0\text{,}01$. Ile wynosi przybliżona częstotliwość graniczna?
3. Dobierz $\alpha$ filtra EMA, aby stała czasowa wynosiła 0,1 s przy $f_s = 100$ Hz.
4. Filtr IIR ma bieguny $0\text{,}95e^{\pm j0\text{,}2\pi}$ i $1\text{,}02$. Czy jest stabilny?
5. Dlaczego filtr eliptyczny 4. rzędu może zastąpić FIR o długości kilkudziesięciu współczynników i czym za to płacimy?

<details>
<summary>Odpowiedzi</summary>

1. ≈ 1055 Hz
2. ≈ 1,6 Hz
3. $\tau = 0\text{,}1$ s = 10 próbek → $\alpha = 1 - e^{-1/10} \approx 0\text{,}095$
4. Nie — biegun 1,02 leży poza okręgiem jednostkowym
5. Bieguny blisko okręgu jednostkowego dają bardzo strome przejście małym kosztem; płaci się nieliniową fazą (duże zmiany opóźnienia grupowego przy granicy), zafalowaniami w pasmach i większą wrażliwością na kwantyzację
</details>

## Źródła

- [The Scientist and Engineer's Guide to DSP — rozdziały 19–21](http://www.dspguide.com/) — filtry rekursywne, Czebyszew, porównanie filtrów
- [MIT RES.6-008 Digital Signal Processing](https://ocw.mit.edu/courses/res-6-008-digital-signal-processing-spring-2011/) — projektowanie filtrów IIR, transformacja biliniowa
- [SciPy — `butter`, `cheby1`, `ellip`, `sosfilt`](https://docs.scipy.org/doc/scipy/reference/signal.html)
