# 07.04 — Filtry FIR

## Po co to jest

Filtry FIR (o skończonej odpowiedzi impulsowej) są zawsze stabilne i mogą mieć dokładnie liniową fazę — nie zniekształcają kształtu sygnału, tylko go opóźniają. To standard w audio, telekomunikacji (kształtowanie impulsów), przetwarzaniu obrazu i przy decymacji.

## Teoria w pigułce

$$y[n] = \sum_{k=0}^{N-1}h[k]\,x[n - k]$$

Współczynniki $h[k]$ są jednocześnie odpowiedzią impulsową. Koszt: $N$ mnożeń i dodawań na próbkę.

### Liniowa faza

Gdy współczynniki są symetryczne ($h[k] = h[N - 1 - k]$) lub antysymetryczne, faza jest liniowa, a **opóźnienie grupowe stałe**:

$$\tau = \frac{N - 1}{2}\ \text{próbek}$$

### Metody projektowania

| Metoda | Zasada | Cechy |
|---|---|---|
| **Okna** | Idealna odpowiedź impulsowa (sinc) ucięta i pomnożona przez okno | Prosta; tłumienie zależy od okna (Hamming ok. 53 dB, Blackman ok. 74 dB, Kaiser regulowane) |
| Próbkowanie częstotliwościowe | Zadana charakterystyka w punktach DFT | Proste filtry o dowolnym kształcie |
| **Parks–McClellan (equiripple)** | Optymalizacja minimaksowa | Najkrótszy filtr dla zadanych wymagań |
| Najmniejszych kwadratów | Minimalizacja energii błędu | Mniejszy błąd średni, większy szczytowy |

### Szacowanie długości filtra

Reguła (fred harris): $N \approx \dfrac{A_{dB}}{22}\cdot\dfrac{f_s}{\Delta f}$

$A_{dB}$ — wymagane tłumienie, $\Delta f$ — szerokość pasma przejściowego. **Długość zależy od stromości, nie od częstotliwości granicznej.**

### Filtry specjalne

Filtr Hilberta (przesunięcie o 90°), różniczkator, filtr półpasmowy (co drugi współczynnik zerowy — połowa mnożeń), filtr podniesionego kosinusa (moduł [13](../13-telekomunikacja/)), średnia ruchoma (najprostszy FIR).

## Przykład rozwiązany

Filtr dolnoprzepustowy: $f_s = 8$ kHz, pasmo przepustowe do 1 kHz, zaporowe od 1,4 kHz, tłumienie 60 dB.

1. $\Delta f = 400$ Hz, $N \approx \dfrac{60}{22}\cdot\dfrac{8000}{400} \approx 55$ współczynników.
2. Okno Hamming nie zapewni 60 dB (daje ok. 53 dB). Okno Kaisera ($\beta \approx 5\text{,}65$, dobrane funkcją `kaiserord`) spełnia wymagania dopiero przy $N = 77$ — metoda okien marnuje współczynniki.
3. Parks–McClellan z wagą 10 w paśmie zaporowym spełnia wymagania przy $N = 55$ (zafalowania w paśmie przepustowym ok. 0,07 dB) — zgodnie z oszacowaniem. Bez wagi potrzeba $N = 69$.
4. Dla $N = 55$: opóźnienie 27 próbek ≈ 3,4 ms; koszt 55 mnożeń na próbkę = 440 tys. mnożeń/s (z wykorzystaniem symetrii — ok. połowa).

Reguła szacunkowa to punkt startowy — długość zawsze potwierdza się, sprawdzając charakterystykę gotowego filtra.

## Typowe pułapki

- **Długość filtra liczona z częstotliwości granicznej** zamiast z pasma przejściowego.
- **Okno prostokątne** (ucięty sinc) — tylko ok. 21 dB tłumienia i zafalowania Gibbsa.
- **Opóźnienie pominięte** w układach czasu rzeczywistego (regulacja, dźwięk na żywo).
- **Parzysta liczba współczynników przy filtrze górnoprzepustowym** — symetryczny FIR o parzystej długości ma zawsze zero przy $f_s/2$.

## Ćwiczenie komputerowe

```python
import numpy as np, matplotlib.pyplot as plt
from scipy import signal
fs = 8000
N, beta = signal.kaiserord(60, 400/(fs/2))                       # oszacowanie dla okna Kaisera
h_win = signal.firwin(77, 1200, window=("kaiser", beta), fs=fs)
h_pm  = signal.remez(55, [0, 1000, 1400, fs/2], [1, 0], weight=[1, 10], fs=fs)
for h, lab in [(h_win, "Kaiser N=77"), (h_pm, "Parks-McClellan N=55")]:
    w, H = signal.freqz(h, worN=8192, fs=fs)
    dB = 20*np.log10(abs(H) + 1e-15)
    print(lab, "— maks. w paśmie zaporowym:", round(dB[w >= 1400].max(), 1), "dB")
    plt.plot(w, dB, label=lab)
plt.axvline(1000, ls=":"); plt.axvline(1400, ls=":"); plt.ylim(-100, 5)
plt.legend(); plt.xlabel("f [Hz]"); plt.ylabel("dB"); plt.grid(); plt.show()
```

Sprawdź, czy oba filtry spełniają wymagania. Zmniejszaj $N$, aż przestaną.

## Zadania

1. Oszacuj długość filtra: $f_s = 8$ kHz, pasmo przejściowe 400 Hz, tłumienie 60 dB.
2. Filtr FIR o 65 współczynnikach, $f_s = 8$ kHz. Opóźnienie w próbkach i ms?
3. Jak zmieni się wymagana długość, jeśli pasmo przejściowe zawęzisz dwukrotnie? A jeśli dwukrotnie zwiększysz $f_s$ przy tych samych wymaganiach w Hz?
4. Średnia ruchoma z 20 próbek przy $f_s = 1$ kHz. Gdzie ma zera charakterystyki? Do czego się nada?
5. Dlaczego filtr FIR o symetrycznych współczynnikach ma liniową fazę?

<details>
<summary>Odpowiedzi</summary>

1. ≈ 55
2. 32 próbki, 4 ms
3. Dwukrotnie dłuższy; też dwukrotnie dłuższy (długość zależy od $f_s/\Delta f$)
4. Przy wielokrotnościach $f_s/20 = 50$ Hz — do tłumienia zakłóceń sieciowych 50 Hz i ich harmonicznych
5. Pary symetrycznych współczynników sumują się do wyrażeń postaci $e^{-j\omega\tau}\cdot(\text{funkcja rzeczywista})$ — faza jest liniowa z nachyleniem $-\tau$, czyli stałe opóźnienie
</details>

## Źródła

- [The Scientist and Engineer's Guide to DSP — rozdziały 14–17](http://www.dspguide.com/) — filtry cyfrowe, średnia ruchoma, filtry z oknem sinc, filtry o dowolnej charakterystyce
- [MIT RES.6-008 Digital Signal Processing](https://ocw.mit.edu/courses/res-6-008-digital-signal-processing-spring-2011/) — projektowanie filtrów FIR
- [SciPy — `firwin`, `remez`, `freqz`](https://docs.scipy.org/doc/scipy/reference/signal.html)
