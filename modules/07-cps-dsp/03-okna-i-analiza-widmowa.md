# 07.03 — Okna czasowe i analiza widmowa

## Po co to jest

Prawdziwe pomiary widma (analizatory, oscyloskopy z FFT, pomiar THD, wykrywanie wibracji) nigdy nie mają całkowitej liczby okresów w oknie. Dobór okna decyduje, czy słaby sygnał obok silnego będzie widoczny, a dobór metody estymacji — czy widmo szumu będzie czytelne.

## Teoria w pigułce

### Przeciek widma

Ucięcie sygnału do $N$ próbek to mnożenie przez prostokąt → w widmie splot z funkcją sinc. Listki boczne sinc „rozlewają” energię silnego tonu na całe widmo i mogą zasłonić słabe składowe.

**Okno czasowe** łagodnie wygasza sygnał na brzegach — obniża listki boczne kosztem szerszego listka głównego.

### Porównanie okien

| Okno | Najwyższy listek boczny | Szerokość listka głównego (między zerami) | ENBW [prążki] | Zastosowanie |
|---|---|---|---|---|
| Prostokątne | −13 dB | 2 | 1,00 | Sygnały koherentne, impulsy |
| **Hann** | −31 dB | 4 | 1,50 | Ogólne, domyślne |
| Hamming | −43 dB | 4 | 1,36 | Rozróżnianie bliskich tonów |
| Blackman | −58 dB | 6 | 1,73 | Duża dynamika |
| Blackman–Harris (4-term.) | ok. −92 dB | 8 | ok. 2,0 | Bardzo duża dynamika |
| Flat-top | ok. −90 dB | ok. 10 | ok. 3,8 | **Dokładna amplituda** (kalibracja) |
| Kaiser($\beta$) | regulowany | regulowana | — | Kompromis wybierany parametrem |

**ENBW** (równoważne pasmo szumowe) — o ile okno poszerza pasmo, w którym zbiera się szum w jednym prążku. Potrzebne do poprawnego pomiaru gęstości szumu.

**Korekcja amplitudy:** okno zmniejsza średnie wzmocnienie (Hann — o połowę, czyli $-6$ dB), trzeba to skompensować.

### Estymacja widma sygnałów losowych

Pojedyncza FFT szumu ma duży rozrzut (odchylenie rzędu 100% wartości w każdym prążku). **Metoda Welcha:** podziel sygnał na nakładające się segmenty (typowo 50%), nałóż okno, policz FFT każdego, uśrednij kwadraty modułów. Uśrednienie $K$ segmentów zmniejsza rozrzut ok. $\sqrt{K}$ razy.

**Spektrogram (STFT)** — widmo liczone w kolejnych oknach czasowych; kompromis rozdzielczości czasowej i częstotliwościowej.

### Jednostki

dBFS (względem pełnego zakresu), dBV, dBm; widmo mocy [V²] vs gęstość widmowa mocy [V²/Hz] — gęstość dzieli się przez $\text{ENBW}\cdot\Delta f$.

## Przykład rozwiązany

Pomiar THD: ton 1 kHz o amplitudzie 1 V i 3. harmoniczna 1 mV (−60 dBc), $f_s = 48$ kHz, $N = 4096$, ton nie mieści się w całkowitej liczbie okresów.

1. Okno prostokątne: listki boczne tonu zanikają wolno (ok. −13 dB i dalej −6 dB/oktawę); w okolicy 3 kHz poziom przecieku może być rzędu −40 dB — harmoniczna −60 dB jest niewidoczna.
2. Okno Hann: przeciek przy 3 kHz poniżej −100 dB — harmoniczna wyraźnie widoczna.
3. Do dokładnego odczytu amplitudy (np. kalibracja) — okno flat-top.

## Typowe pułapki

- **Okno prostokątne „bo daje najlepszą rozdzielczość”** przy pomiarze sygnału o dużej dynamice.
- **Brak korekcji wzmocnienia okna** — zaniżone amplitudy.
- **Gęstość szumu bez uwzględnienia ENBW** — błąd 1,8 dB dla okna Hann.
- **Pojedyncza FFT szumu** interpretowana jako dokładne widmo.

## Ćwiczenie komputerowe

```python
import numpy as np, matplotlib.pyplot as plt
from scipy import signal
fs, N = 48000, 4096; n = np.arange(N)
x = np.sin(2*np.pi*1000.3*n/fs) + 1e-3*np.sin(2*np.pi*3000.9*n/fs)
for name in ["boxcar", "hann", "blackmanharris", "flattop"]:
    w = signal.get_window(name, N)
    X = np.abs(np.fft.rfft(x*w))*2/np.sum(w)
    plt.plot(np.fft.rfftfreq(N, 1/fs), 20*np.log10(X + 1e-12), label=name)
plt.xlim(0, 6000); plt.ylim(-160, 5); plt.legend(); plt.xlabel("f [Hz]"); plt.ylabel("dB"); plt.show()
```

Następnie oszacuj widmo szumu `signal.welch` dla różnych `nperseg` i porównaj rozrzut z pojedynczą FFT.

## Zadania

1. Ton silny 0 dB i słaby −50 dB, odległe o 20 prążków. Które okna pozwolą zobaczyć słaby ton?
2. Dwa tony o równej amplitudzie są oddalone o 3 prążki. Czy okno Blackmana je rozdzieli? A Hann?
3. Zmierzono w prążku z oknem Hann amplitudę 0,5 V (bez korekcji). Jaka jest rzeczywista amplituda tonu (ton dokładnie w prążku)?
4. Szum o płaskiej gęstości: moc w jednym prążku z oknem Hann wynosi $10^{-9}$ V², $\Delta f = 10$ Hz. Ile wynosi gęstość widmowa?
5. Ile segmentów trzeba uśrednić w metodzie Welcha, aby zmniejszyć rozrzut estymaty 10 razy?

<details>
<summary>Odpowiedzi</summary>

1. Hann (listki daleko od tonu ≪ −50 dB), Blackman, Blackman–Harris; prostokątne — nie
2. Blackman (listek główny ±3 prążki) — na granicy, raczej nie; Hann (±2 prążki) — tak, z wyraźnym przegięciem
3. 1 V — wzmocnienie koherentne okna Hann wynosi 0,5
4. $10^{-9}/(1\text{,}5\cdot 10) \approx 6\text{,}7\cdot 10^{-11}$ V²/Hz (≈ 8,2 µV/√Hz)
5. Ok. 100
</details>

## Źródła

- [The Scientist and Engineer's Guide to DSP — rozdział 9 *Applications of the DFT*](http://www.dspguide.com/) — okna, rozdzielczość, analiza widmowa
- [Think DSP — rozdziały o widmach i spektrogramach](https://greenteapress.com/wp/think-dsp/)
- [SciPy — `scipy.signal.get_window`, `welch`, `spectrogram`](https://docs.scipy.org/doc/scipy/reference/signal.html)
