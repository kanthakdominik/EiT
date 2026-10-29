# M01.05 — Filtr Wienera

## Po co to jest

Filtr Wienera to optymalny (w sensie MSE) filtr liniowy do estymacji jednego procesu losowego z obserwacji innego: odszumianie, wyrównywanie kanału (equalizer), przewidywanie, separacja sygnału od zakłóceń. Pokazuje, że „idealny” filtr nie musi mieć ostrego zbocza — wystarczy, że w każdym zakresie częstotliwości przepuszcza tyle, ile wynika ze stosunku sygnału do szumu. Jest też punktem wyjścia dla filtrów adaptacyjnych (temat 06), które dochodzą do rozwiązania Wienera bez znajomości statystyk.

## Teoria w pigułce

### Filtr FIR (równania Wienera–Hopfa)

Szukamy $\hat d[n] = \sum_{k=0}^{L-1}h_kx[n-k]$ minimalizującego $E[(d[n] - \hat d[n])^2]$. Z zasady ortogonalności:

$$\mathbf R_x\mathbf h = \mathbf r_{dx}, \qquad \mathrm{MSE}_{min} = \sigma_d^2 - \mathbf h^T\mathbf r_{dx}$$

$\mathbf R_x$ — macierz autokorelacji wejścia (Toeplitza), $\mathbf r_{dx}$ — korelacja wzajemna sygnału pożądanego z wejściem. Rozwiązuje się ją efektywnie algorytmem Levinsona–Durbina ($O(L^2)$).

Zastosowania jednego wzoru:

| Zadanie | $d[n]$ | $x[n]$ |
|---|---|---|
| Odszumianie | $s[n]$ | $s[n] + v[n]$ |
| Predykcja (LPC, kompresja mowy) | $x[n + 1]$ | $x[n]$ |
| Equalizer | Nadany symbol $a[n - \Delta]$ | Wyjście kanału |
| Identyfikacja systemu | Wyjście systemu | Wejście systemu |

### Filtr nieprzyczynowy (w dziedzinie częstotliwości)

Dla sygnału i niezależnego szumu addytywnego:

$$H(e^{j\omega}) = \frac{S_s(e^{j\omega})}{S_s(e^{j\omega}) + S_v(e^{j\omega})}$$

— przepuszcza pasma, gdzie sygnał dominuje, tłumi te, gdzie dominuje szum; nigdy nie wzmacnia. Wymaga całego zapisu (przetwarzanie offline, obrazy). Filtr przyczynowy IIR wymaga faktoryzacji widmowej; przyczynowa wersja rekurencyjna dla modeli w przestrzeni stanów to filtr Kalmana.

### Odejmowanie widmowe

Praktyczna wersja do odszumiania mowy: widmo szumu estymowane w przerwach, w każdym bloku STFT wzmocnienie $\max(1 - \hat S_v/\lvert X\rvert^2, \beta)$ — „szum muzyczny” przy zbyt agresywnych ustawieniach.

## Przykład rozwiązany

**Odszumianie procesu AR(1)** ($a = 0\text{,}95$, wariancja sygnału 1) w szumie białym o wariancji 1 (SNR 0 dB):

| Filtr | MSE |
|---|---|
| Brak filtracji | 1,000 |
| Wiener FIR, $L = 1$ (samo skalowanie) | 0,500 |
| Wiener FIR, $L = 5$ | 0,253 |
| Wiener FIR, $L = 20$ (praktycznie optimum przyczynowe) | 0,238 |
| Wiener nieprzyczynowy (cały zapis) | 0,156 |

Już kilka współczynników daje 6 dB poprawy; filtr korzystający z przyszłych próbek — kolejne 1,8 dB.

## Typowe pułapki

- **Nieznane statystyki** — filtr Wienera wymaga $\mathbf R_x$ i $\mathbf r_{dx}$; w praktyce estymuje się je z danych (lub używa filtrów adaptacyjnych).
- **Niestacjonarność** — filtr zaprojektowany na jednych statystykach pogarsza wynik, gdy się zmienią (mowa, kanał ruchomy).
- **Zbyt krótkie okno estymacji korelacji** — źle uwarunkowana $\mathbf R_x$, oscylujące współczynniki; regularyzacja $\mathbf R_x + \delta\mathbf I$.
- **Odejmowanie widmowe bez dolnego ograniczenia** — artefakty („szum muzyczny”).
- **Equalizer z wymuszaniem zera** zamiast MMSE — wzmacnianie szumu w zanikach kanału.

## Ćwiczenie komputerowe

Filtr Wienera FIR różnych długości (teoria i symulacja) oraz granica nieprzyczynowa:

```python
import numpy as np
from scipy import signal
from scipy.linalg import toeplitz

rng = np.random.default_rng(4)
a, var_s, var_n, N = 0.95, 1.0, 1.0, 200_000          # sygnał AR(1), SNR = 0 dB
s = signal.lfilter([np.sqrt(var_s*(1 - a**2))], [1, -a], rng.normal(size=N))
x = s + rng.normal(0, np.sqrt(var_n), N)

for L in (1, 5, 20, 50):
    r_s = var_s*a**np.arange(L)                        # autokorelacja sygnału
    R = toeplitz(r_s) + var_n*np.eye(L)                # autokorelacja obserwacji
    h = np.linalg.solve(R, r_s)                        # równania Wienera–Hopfa (estymacja s[n] z x[n..n-L+1])
    mse_th = var_s - h @ r_s
    y = signal.lfilter(h, [1], x)
    print(f"filtr Wienera FIR, L = {L:2d}: MSE teoria {mse_th:.4f}, symulacja {np.mean((y[100:] - s[100:])**2):.4f}")
print(f"bez filtracji MSE = {var_n:.4f}")

# filtr nieprzyczynowy (granica): H = S_s/(S_s + S_n) w dziedzinie częstotliwości
w = np.linspace(0, np.pi, 20001)
Ss = var_s*(1 - a**2)/np.abs(1 - a*np.exp(-1j*w))**2
mse_nc = np.trapezoid(Ss*var_n/(Ss + var_n), w)/np.pi
print(f"nieprzyczynowy filtr Wienera: MSE = {mse_nc:.4f}")
```

## Zadania

1. Dla $L = 1$ wyprowadź współczynnik Wienera i MSE przy odszumianiu sygnału o wariancji $\sigma_s^2$ w szumie $\sigma_v^2$.
2. Sygnał ma widmo płaskie do 1 kHz (gęstość 10), szum biały ma gęstość 1. Jak wygląda nieprzyczynowy filtr Wienera?
3. Zapisz równania Wienera–Hopfa dla predykcji jednokrokowej procesu AR(1). Jaki jest wynik?
4. Dlaczego filtr Wienera nigdy nie ma wzmocnienia większego niż 1 (dla odszumiania)?
5. Jak filtr Wienera wiąże się z filtrem Kalmana?

<details>
<summary>Odpowiedzi</summary>

1. $h = \sigma_s^2/(\sigma_s^2 + \sigma_v^2)$; $\mathrm{MSE} = \sigma_s^2\sigma_v^2/(\sigma_s^2 + \sigma_v^2)$ (przy SNR 0 dB: 0,5)
2. W paśmie do 1 kHz $H = 10/11 \approx 0\text{,}91$, powyżej $H = 0$ (sam szum) — filtr dolnoprzepustowy z lekkim tłumieniem w paśmie
3. $R_x(0)h = R_x(1)$, z $R_x(k) = \sigma_x^2a^{\lvert k\rvert}$ → $h = a$, czyli $\hat x[n+1] = ax[n]$ (zgodnie z modelem); MSE = $\sigma_w^2$
4. $H = S_s/(S_s + S_v)$ i obie gęstości są nieujemne, więc $0 \leq H \leq 1$
5. Filtr Kalmana jest rekurencyjnym rozwiązaniem tego samego zadania LMMSE dla sygnału opisanego modelem w przestrzeni stanów; działa także dla procesów niestacjonarnych i w stanie ustalonym (stacjonarnym) jest równoważny przyczynowemu filtrowi Wienera
</details>

## Źródła

- [MIT 6.011 Signals, Systems and Inference](https://ocw.mit.edu/courses/6-011-signals-systems-and-inference-spring-2018/) — filtr Wienera
- [MIT 6.432 Stochastic Processes, Detection, and Estimation](https://ocw.mit.edu/courses/6-432-stochastic-processes-detection-and-estimation-spring-2004/) — filtracja Wienera, faktoryzacja widmowa
- S. Haykin — *Adaptive Filter Theory* (płatna) — rozdział o filtrach Wienera
