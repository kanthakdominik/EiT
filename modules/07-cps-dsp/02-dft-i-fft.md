# 07.02 — DFT i FFT

## Po co to jest

Dyskretne przekształcenie Fouriera (DFT) to jedyna wersja Fouriera, którą komputer może policzyć: skończona liczba próbek → skończona liczba prążków. Szybki algorytm FFT sprawia, że analiza widmowa, splot szybki, OFDM w Wi-Fi i LTE oraz korelacja w GPS są wykonalne w czasie rzeczywistym.

## Teoria w pigułce

$$X[k] = \sum_{n=0}^{N-1}x[n]e^{-j2\pi kn/N}, \qquad k = 0, 1, \dots, N - 1$$

$$x[n] = \frac{1}{N}\sum_{k=0}^{N-1}X[k]e^{j2\pi kn/N}$$

### Interpretacja prążków

| Wielkość | Wzór |
|---|---|
| Częstotliwość prążka $k$ | $f_k = k\dfrac{f_s}{N}$ |
| **Rozdzielczość częstotliwościowa** | $\Delta f = \dfrac{f_s}{N} = \dfrac{1}{T_{obs}}$ — zależy od **czasu obserwacji** |
| Prążki $k > N/2$ | Częstotliwości ujemne ($f_k - f_s$) |
| $X[0]$ | $N\cdot$ wartość średnia |
| Amplituda sinusoidy w prążku (bez okna) | $\lvert X[k]\rvert\cdot 2/N$ (jednostronnie) |

**DFT zakłada, że sygnał jest okresowy** z okresem $N$ próbek. Jeśli w oknie nie mieści się całkowita liczba okresów, na sztucznym „szwie” powstaje nieciągłość → **przeciek widma** ([07.03](03-okna-i-analiza-widmowa.md)).

**Dopełnianie zerami** (zero-padding) zagęszcza punkty widma (interpolacja), ale **nie poprawia rozdzielczości** — tę daje tylko dłuższy czas obserwacji.

### FFT

Algorytm radix-2 (Cooleya–Tukeya) dzieli DFT o długości $N = 2^m$ na dwie DFT o długości $N/2$ (próbki parzyste i nieparzyste) i składa je „motylkami”. Złożoność:

| | Mnożenia zespolone |
|---|---|
| DFT wprost | $N^2$ |
| FFT radix-2 | $\dfrac{N}{2}\log_2N$ |

Dla $N = 1024$: ok. 1 mln vs 5120 — ok. 200 razy szybciej.

### Splot szybki

Splot liniowy przez FFT: dopełnij oba sygnały zerami do długości $\geq N + M - 1$, pomnóż widma, odwrotna FFT. Dla długich filtrów (setki współczynników) jest szybszy niż splot bezpośredni. Bez dopełnienia zerami powstaje **splot kołowy** (zawinięcie).

## Przykład rozwiązany

Sygnał 50 Hz, $f_s = 1$ kHz.

1. $N = 1000$: $\Delta f = 1$ Hz, 50 Hz wypada dokładnie w prążku 50 — czyste widmo.
2. $N = 256$: $\Delta f \approx 3{,}91$ Hz, 50 Hz to „prążek 12,8” — energia rozlewa się na sąsiednie prążki, a odczytana amplituda w prążku 13 jest zaniżona (tzw. scalloping loss, do ok. 3,9 dB dla okna prostokątnego).
3. Rozróżnienie dwóch tonów 50 i 52 Hz wymaga $\Delta f < 2$ Hz → co najmniej ok. 0,5–1 s obserwacji (z oknem — więcej).

## Typowe pułapki

- **Rozdzielczość „poprawiana” dopełnianiem zerami.**
- **Brak normalizacji** — amplituda z FFT zależy od $N$ i od okna.
- **Odczyt prążków powyżej $N/2$ jako dodatnich częstotliwości.**
- **Splot kołowy zamiast liniowego** przy filtracji przez FFT.

## Ćwiczenie komputerowe

```python
import numpy as np
fs = 1000
for N in [1000, 256]:
    n = np.arange(N); x = np.sin(2*np.pi*50*n/fs)
    X = np.abs(np.fft.rfft(x))*2/N
    k = np.argmax(X)
    print(f"N={N}: Δf={fs/N:.2f} Hz, max w prążku {k} ({k*fs/N:.1f} Hz), amplituda {X[k]:.3f}")
```

Zaimplementuj własną FFT radix-2 rekurencyjnie (ok. 10 linii) i porównaj wynik z `np.fft.fft` oraz czas wykonania dla $N = 4096$ z DFT liczoną wprost.

## Zadania

1. $f_s = 1$ kHz, $N = 1000$ i $N = 256$. Rozdzielczość i prążek dla 50 Hz?
2. Ile mnożeń zespolonych wymaga DFT, a ile FFT dla $N = 1024$?
3. Jaki czas obserwacji jest potrzebny, aby rozróżnić tony 1000 Hz i 1001 Hz?
4. Sygnał $N = 8$ próbek: $x = [1, 1, 1, 1, 0, 0, 0, 0]$. Ile wynosi $X[0]$?
5. Filtr FIR ma 100 współczynników, sygnał 1000 próbek. Jaka minimalna długość FFT do splotu liniowego (potęga 2)?
6. $f_s = 48$ kHz, $N = 4096$. Jaka częstotliwość odpowiada prążkowi 3000?

<details>
<summary>Odpowiedzi</summary>

1. 1 Hz, prążek 50; ≈ 3,91 Hz, między 12 a 13
2. $1024^2 \approx 1{,}05\cdot 10^6$ i $512\cdot 10 = 5120$ (ok. 205 razy mniej)
3. Co najmniej ok. 1 s (w praktyce więcej, z oknem 2–4 s)
4. $X[0] = 4$ (suma próbek)
5. $1000 + 100 - 1 = 1099$ → 2048
6. Prążek 3000 > 2048 → częstotliwość ujemna: $3000\cdot 48000/4096 - 48000 \approx -12{,}84$ kHz
</details>

## Źródła

- [The Scientist and Engineer's Guide to DSP — rozdziały 8, 9 i 12](http://www.dspguide.com/) — DFT, zastosowania, FFT
- [MIT RES.6-008 Digital Signal Processing](https://ocw.mit.edu/courses/res-6-008-digital-signal-processing-spring-2011/) — wykłady o DFT i algorytmach FFT
- [Think DSP — rozdział o DFT](https://greenteapress.com/wp/think-dsp/)
