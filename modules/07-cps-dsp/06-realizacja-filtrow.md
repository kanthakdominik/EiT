# 07.06 — Realizacja filtrów i arytmetyka stałoprzecinkowa

## Po co to jest

Filtr zaprojektowany w Pythonie w liczbach zmiennoprzecinkowych trzeba uruchomić na mikrokontrolerze lub w FPGA, często bez jednostki zmiennoprzecinkowej. Wybór struktury, skalowanie i kontrola przepełnień decydują, czy filtr zadziała tak jak w symulacji.

## Teoria w pigułce

### Struktury realizacji

| Struktura | Cechy |
|---|---|
| Postać bezpośrednia I (DF-I) | Osobne linie opóźniające wejścia i wyjścia; odporna na przepełnienia w stanach pośrednich przy akumulatorze z zapasem |
| Postać bezpośrednia II (DF-II) | Wspólna linia opóźniająca — mniej pamięci; większe sygnały wewnętrzne |
| Transponowana DF-II | Dobre właściwości numeryczne w arytmetyce zmiennoprzecinkowej |
| **Kaskada sekcji 2. rzędu (biquad)** | Standard dla IIR: każda sekcja ma swoje bieguny i zera, mała wrażliwość na kwantyzację |
| Kratowa (lattice) | Dobra odporność numeryczna, filtry adaptacyjne, kodowanie mowy |

FIR: linia opóźniająca + mnożenie i akumulacja (MAC). **Bufor kołowy** zamiast przesuwania tablicy. Procesory DSP i rdzenie z rozszerzeniami DSP (np. instrukcje SIMD MAC) wykonują MAC w jednym cyklu.

### Format stałoprzecinkowy Qm.n

Q15: 16 bitów, zakres [−1, 1), krok $2^{-15}$. Iloczyn dwóch liczb Q15 to Q30 w 32 bitach — przed zapisem przesuwa się go o 15 bitów (z zaokrągleniem).

| Problem | Przyczyna | Rozwiązanie |
|---|---|---|
| **Przepełnienie** | Suma wychodzi poza zakres | Akumulator szerszy (32/40 bitów), skalowanie wejścia, **nasycanie** zamiast zawijania |
| Szum kwantyzacji iloczynów | Obcinanie po mnożeniu | Zaokrąglanie, szerszy akumulator |
| Kwantyzacja współczynników | Skończona liczba bitów | Biquady, sprawdzenie charakterystyki po zaokrągleniu |
| **Cykle graniczne** | Nieliniowość zaokrąglania w pętli IIR | Większa precyzja stanu, dither, odpowiednia struktura |
| Współczynniki > 1 | Sekcje IIR mają często $\lvert a_1\rvert$ do 2 | Format Q14 dla współczynników lub dzielenie przez 2 i podwójna akumulacja |

### Skalowanie

Aby uniknąć przepełnień, ogranicza się wzmocnienie każdej sekcji. Norma L1 odpowiedzi impulsowej (suma modułów) daje gwarancję braku przepełnienia, norma L∞ charakterystyki — ograniczenie dla sygnałów sinusoidalnych.

### Filtry bez mnożeń

**Średnia ruchoma** z rekurencją: $y[n] = y[n-1] + (x[n] - x[n - N])/N$. **CIC** (Cascaded Integrator–Comb) — kaskada integratorów i grzebieni bez mnożeń, używana w decymatorach przetworników sigma-delta. Wzmocnienie CIC $(RM)^N$ — wymaga zapasu bitów $N\log_2(RM)$.

## Przykład rozwiązany

Współczynnik 0,3 w Q15: $\text{round}(0\text{,}3\cdot 32768) = 9830$ (`0x2666`), błąd ok. $1\text{,}2\cdot 10^{-5}$.

Iloczyn próbki $x = 0\text{,}5$ (Q15: 16384) i współczynnika: $16384\cdot 9830 = 161\,054\,720$ (Q30). Przesunięcie o 15 bitów: $4915$ → $4915/32768 \approx 0\text{,}150$ ✓.

**FIR z 64 współczynnikami w Q15** przy sumie modułów współczynników równej 1,8: akumulator 32-bitowy (Q30) pomieści sumę bez przepełnienia (zapas ok. 1 bitu wystarcza), ale wynik po przesunięciu może przekroczyć zakres Q15 → nasycanie przy zapisie.

## Typowe pułapki

- **Mnożenie `int16 * int16` w C bez rzutowania na `int32`** — przepełnienie przed przesunięciem.
- **Przesunięcie w prawo zamiast zaokrąglenia** — systematyczne obcinanie (przesunięcie składowej stałej).
- **Zawijanie przy przepełnieniu** — wynik zmienia znak i daje głośny „trzask”; nasycanie jest znacznie łagodniejsze.
- **Współczynniki IIR wysokiego rzędu w postaci bezpośredniej** po kwantyzacji.

## Ćwiczenie komputerowe

```python
import numpy as np
from scipy import signal
h = signal.firwin(31, 0.2)
hq = np.round(h*32768).astype(np.int32)
x = np.round(0.9*np.sin(2*np.pi*0.05*np.arange(500))*32767).astype(np.int32)
acc = np.convolve(x, hq)                              # „akumulator” Q30
y = np.clip((acc + (1 << 14)) >> 15, -32768, 32767)   # zaokrąglenie i nasycanie
ref = np.convolve(x/32768, h)*32768
print("max błąd [LSB]:", np.max(np.abs(y - ref)))
```

Napisz ten sam filtr w C (bufor kołowy, `int32_t` akumulator, nasycanie) i porównaj wyniki bit w bit z Pythonem.

## Zadania

1. Zapisz 0,3 i −0,75 w Q15. Jaki jest błąd kwantyzacji 0,3?
2. Pomnóż w Q15: 0,5 × 0,3. Pokaż kolejne kroki.
3. Ile bitów akumulatora potrzeba dla FIR o 256 współczynnikach Q15 i danych Q15, aby w najgorszym przypadku nie było przepełnienia?
4. Dlaczego sekcja IIR 2. rzędu ma często współczynnik $a_1$ bliski −2? Jak go zapisać w 16 bitach?
5. Decymator CIC: $R = 16$, $M = 1$, $N = 3$. Ile bitów przyrasta?

<details>
<summary>Odpowiedzi</summary>

1. 9830 (`0x2666`), −24576 (`0xA000`); błąd ok. $-1\text{,}2\cdot 10^{-5}$
2. $16384\cdot 9830 = 161\,054\,720$ (Q30) → $\gg 15$ → 4915 → ≈ 0,150
3. Iloczyn Q30 wymaga 31 bitów + 1 bit znaku; suma 256 iloczynów dodaje do $\log_2 256 = 8$ bitów → ok. 40 bitów (stąd 40-bitowe akumulatory w procesorach DSP)
4. Bieguny blisko $z = 1$ (niska częstotliwość graniczna względem $f_s$) dają $a_1 \approx -2r\cos\theta \approx -2$; zapis w Q14 (zakres [−2, 2)) lub jako połowa współczynnika i podwójne dodanie
5. $N\log_2(RM) = 3\cdot 4 = 12$ bitów
</details>

## Źródła

- [The Scientist and Engineer's Guide to DSP — rozdziały 4, 28 i 29](http://www.dspguide.com/) — oprogramowanie DSP, procesory sygnałowe, precyzja obliczeń
- [MIT RES.6-008 Digital Signal Processing](https://ocw.mit.edu/courses/res-6-008-digital-signal-processing-spring-2011/) — struktury filtrów cyfrowych, efekty skończonej precyzji
- [SciPy — `sosfilt`, `tf2sos`](https://docs.scipy.org/doc/scipy/reference/signal.html)
