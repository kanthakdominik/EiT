# M01.02 — Podstawy estymacji i granica Craméra–Rao

## Po co to jest

Estymacja to wyznaczanie nieznanych parametrów z zaszumionych danych: częstotliwości i fazy sygnału, opóźnienia (odległości), amplitudy, położenia. Zanim zaprojektuje się algorytm, warto wiedzieć, **jaka dokładność jest w ogóle możliwa**. Granica Craméra–Rao (CRLB) podaje najmniejszą wariancję, jaką może mieć jakikolwiek estymator nieobciążony — jest więc miarą jakości algorytmów i narzędziem projektowania systemu (ile próbek, jaki SNR, jakie pasmo).

## Teoria w pigułce

### Własności estymatorów

- **Obciążenie:** $b(\theta) = E[\hat\theta] - \theta$; estymator nieobciążony: $b = 0$ dla każdego $\theta$.
- **Wariancja** i **błąd średniokwadratowy** $\mathrm{MSE} = \mathrm{var}(\hat\theta) + b^2$.
- **Zgodność:** $\hat\theta \to \theta$ przy $N \to \infty$.
- **Efektywność:** estymator nieobciążony osiągający CRLB.

### Granica Craméra–Rao

Dla nieobciążonego estymatora i funkcji wiarygodności $p(\mathbf x;\theta)$ spełniającej warunki regularności:

$$\mathrm{var}(\hat\theta) \geq \frac{1}{I(\theta)}, \qquad I(\theta) = -E\left[\frac{\partial^2\ln p(\mathbf x;\theta)}{\partial\theta^2}\right]$$

$I(\theta)$ — **informacja Fishera**. Dla wektora parametrów: $\mathrm{cov}(\hat{\boldsymbol\theta}) \succeq \mathbf I^{-1}(\boldsymbol\theta)$.

**Sygnał deterministyczny w szumie białym gaussowskim** $x[n] = s[n;\theta] + w[n]$:

$$I(\theta) = \frac{1}{\sigma^2}\sum_n\left(\frac{\partial s[n;\theta]}{\partial\theta}\right)^2$$

— parametr jest tym lepiej określony, im silniej sygnał od niego zależy.

| Problem | CRLB |
|---|---|
| Poziom stały $A$ | $\sigma^2/N$ (osiąga go średnia) |
| Amplituda sinusoidy o znanej częstotliwości i fazie | $2\sigma^2/N$ |
| **Częstotliwość** sinusoidy (cykle/próbkę), $\eta = A^2/(2\sigma^2)$ | $\dfrac{12}{(2\pi)^2\eta N(N^2 - 1)}$ |
| Faza sinusoidy | $\approx \dfrac{2(2N - 1)}{\eta N(N + 1)}$ (przy nieznanej częstotliwości), $1/(\eta N)$ przy znanej |
| Opóźnienie sygnału (odległość) | $\dfrac{1}{(2E/N_0)\,\overline{F^2}\,(2\pi)^2}$, $\overline{F^2}$ — średni kwadrat szerokości pasma |

Ważne wnioski: wariancja częstotliwości maleje jak $1/N^3$ (dłuższa obserwacja pomaga bardzo szybko), a dokładność pomiaru opóźnienia zależy od **pasma** sygnału (radar, GNSS: szerokie pasmo → dokładna odległość).

### Kiedy granica jest (nie)osiągalna

- Estymator ML jest asymptotycznie efektywny (temat 03).
- Przy niskim SNR estymatory nieliniowe (częstotliwość, opóźnienie) mają **próg**: poniżej pewnego SNR błąd gwałtownie rośnie ponad CRLB (pojawiają się wartości odstające — maksimum w złym miejscu).
- Estymator obciążony (np. bayesowski, temat 04) może mieć MSE mniejsze niż CRLB.

## Przykład rozwiązany

**Pomiar częstotliwości:** 100 próbek z $f_s = 1$ kHz (0,1 s), SNR = 10 dB ($\eta = 10$).

$$\mathrm{var}(\hat f) \geq \frac{12}{(2\pi)^2\cdot 10\cdot 100\cdot 9999} = 3\text{,}04\cdot 10^{-8}\ (\text{cykl/próbkę})^2 \;\Rightarrow\; \sigma_{\hat f} \geq 1\text{,}74\cdot 10^{-4}\cdot 1000 = 0\text{,}174\ \text{Hz}$$

Rozdzielczość FFT tego zapisu to 10 Hz — mimo to częstotliwość można zmierzyć **60 razy dokładniej** niż odstęp binów. Estymator: maksimum FFT z dopełnieniem zerami i interpolacją paraboliczną — symulacja daje 0,179 Hz, praktycznie na granicy. Przy 20 dB estymator jest już ok. 35% gorszy od granicy: ogranicza go siatka interpolacji i przeciek obrazu z ujemnej częstotliwości; pomaga dokładniejsza interpolacja lub iteracja Newtona na funkcji wiarygodności.

## Typowe pułapki

- **Mylenie rozdzielczości widmowej z dokładnością estymacji** pojedynczej częstotliwości.
- **Porównanie estymatora obciążonego z CRLB** — granica dotyczy nieobciążonych.
- **CRLB przy niskim SNR** — granica jest wtedy zbyt optymistyczna (efekt progowy).
- **Pominięcie nieznanych parametrów dodatkowych** (faza, amplituda) — CRLB dla jednego parametru przy znanych pozostałych jest zaniżona; liczy się odwrotność pełnej macierzy Fishera.
- **Szum skorelowany** potraktowany jak biały — zawyżona informacja Fishera.

## Ćwiczenie komputerowe

Estymacja częstotliwości (FFT z dopełnieniem zerami i interpolacją) w porównaniu z CRLB oraz efektywność średniej i mediany:

```python
import numpy as np

rng = np.random.default_rng(1)
N, A, f0, fs = 100, 1.0, 123.4, 1000.0       # 100 próbek, częstotliwość 123,4 Hz
n = np.arange(N)
for snr_db in (0, 10, 20):
    sigma2 = A**2/2/10**(snr_db/10)
    snr = A**2/(2*sigma2)
    crlb = 12/((2*np.pi)**2*snr*N*(N**2 - 1))            # [cykle/próbkę]²
    est = []
    for _ in range(2000):
        x = A*np.cos(2*np.pi*f0/fs*n + rng.uniform(0, 2*np.pi)) + rng.normal(0, np.sqrt(sigma2), N)
        X = np.abs(np.fft.rfft(x, 64*N))                 # dopełnienie zerami: siatka 1/64 binu
        k = np.argmax(X)
        a, b, c = X[k-1], X[k], X[k+1]
        k_int = k + 0.5*(a - c)/(a - 2*b + c)            # interpolacja paraboliczna maksimum
        est.append(k_int*fs/(64*N))
    est = np.array(est)
    print(f"SNR = {snr_db:2d} dB: odch. std. estymatora {est.std()*1e3:6.1f} mHz, pierwiastek z CRLB {np.sqrt(crlb)*fs*1e3:6.1f} mHz, "
          f"obciążenie {(est.mean() - f0)*1e3:+5.1f} mHz (bin FFT = {fs/N:.0f} Hz)")

# DC w szumie: średnia osiąga CRLB σ²/N, mediana nie (efektywność ok. 2/π)
sigma, N2 = 1.0, 101
X = rng.normal(5.0, sigma, (20_000, N2))
print(f"DC: var(średnia) = {X.mean(axis=1).var():.5f}, var(mediana) = {np.median(X, axis=1).var():.5f}, CRLB = {sigma**2/N2:.5f}")
```

Mediana ma wariancję ok. $\pi/2$ razy większą niż średnia (dla szumu gaussowskiego) — nie jest efektywna, ale jest odporna na wartości odstające.

## Zadania

1. Wyprowadź CRLB dla poziomu stałego $A$ w szumie białym gaussowskim o wariancji $\sigma^2$.
2. Ile razy zmniejszy się odchylenie standardowe estymaty częstotliwości, gdy czas obserwacji wydłużymy 4 razy (przy tym samym $f_s$ i SNR)?
3. Dlaczego GNSS z sygnałem o szerszym paśmie (np. kody 10 MHz zamiast 1 MHz) daje dokładniejszy pomiar odległości?
4. Estymator $\hat A = \frac{1}{N}\sum x[n] + 0\text{,}1$ ma wariancję równą CRLB. Czy jest efektywny?
5. Podaj macierz informacji Fishera dla modelu liniowego $\mathbf x = \mathbf H\boldsymbol\theta + \mathbf w$, $\mathbf w \sim \mathcal N(0, \sigma^2\mathbf I)$.

<details>
<summary>Odpowiedzi</summary>

1. $\ln p = -\tfrac{N}{2}\ln(2\pi\sigma^2) - \tfrac{1}{2\sigma^2}\sum(x[n] - A)^2$; $\partial^2/\partial A^2 = -N/\sigma^2$ → $I = N/\sigma^2$, CRLB $= \sigma^2/N$
2. Wariancja $\propto 1/N^3$ → odchylenie $\propto N^{-3/2}$: $4^{1\text{,}5} = 8$ razy
3. Wariancja opóźnienia jest odwrotnie proporcjonalna do średniego kwadratu szerokości pasma — korelacja szerokopasmowego sygnału ma ostrzejsze maksimum, więc położenie maksimum jest lepiej określone przy tym samym SNR
4. Nie — jest obciążony (o 0,1), a CRLB i pojęcie efektywności dotyczą estymatorów nieobciążonych; jego MSE $= \sigma^2/N + 0\text{,}01$
5. $\mathbf I = \mathbf H^T\mathbf H/\sigma^2$; CRLB $= \sigma^2(\mathbf H^T\mathbf H)^{-1}$ — osiąga ją estymator najmniejszych kwadratów (temat 03)
</details>

## Źródła

- [MIT 6.432 Stochastic Processes, Detection, and Estimation](https://ocw.mit.edu/courses/6-432-stochastic-processes-detection-and-estimation-spring-2004/) — estymacja parametrów, granice
- [MIT 6.011 Signals, Systems and Inference](https://ocw.mit.edu/courses/6-011-signals-systems-and-inference-spring-2018/)
- S. M. Kay — *Fundamentals of Statistical Signal Processing, t. I: Estimation Theory* (płatna) — rozdziały 2–3
