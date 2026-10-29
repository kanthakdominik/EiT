# M01.03 — Największa wiarygodność i najmniejsze kwadraty

## Po co to jest

Estymator największej wiarygodności (ML) to uniwersalny przepis: wybierz parametr, przy którym zaobserwowane dane są najbardziej prawdopodobne. Dla szumu gaussowskiego i modelu liniowego sprowadza się do metody najmniejszych kwadratów, którą znasz z dopasowania prostej ([20.04](../../modules/20-metody-numeryczne/04-interpolacja-i-aproksymacja.md)) — tu dostaje ona uzasadnienie statystyczne, wzór na kowariancję wyniku i wersję ważoną. W praktyce ML/LS stoi za estymacją kanału w łączności, kalibracją czujników, lokalizacją, pomiarem amplitudy i fazy (analizatory impedancji, pomiary sieci energetycznej) i identyfikacją systemów.

## Teoria w pigułce

### Estymator największej wiarygodności

$$\hat\theta_{ML} = \arg\max_\theta p(\mathbf x;\theta) = \arg\max_\theta\ln p(\mathbf x;\theta)$$

- **Asymptotycznie** (duże $N$ lub wysoki SNR): nieobciążony, efektywny (osiąga CRLB) i gaussowski.
- **Niezmienniczość:** ML funkcji parametru to funkcja ML parametru ($\widehat{g(\theta)} = g(\hat\theta)$) — np. amplituda $\sqrt{\hat a^2 + \hat b^2}$ z estymat składowych I/Q.
- Zwykle wymaga optymalizacji numerycznej ([20.08](../../modules/20-metody-numeryczne/08-optymalizacja-i-dopasowanie.md)); funkcja wiarygodności może mieć wiele maksimów lokalnych (częstotliwość, opóźnienie) — start z siatki lub FFT.

### Model liniowy

$\mathbf x = \mathbf H\boldsymbol\theta + \mathbf w$, $\mathbf w \sim \mathcal N(\mathbf 0, \mathbf C)$:

$$\hat{\boldsymbol\theta} = (\mathbf H^T\mathbf C^{-1}\mathbf H)^{-1}\mathbf H^T\mathbf C^{-1}\mathbf x, \qquad \mathrm{cov}(\hat{\boldsymbol\theta}) = (\mathbf H^T\mathbf C^{-1}\mathbf H)^{-1}$$

- Dla $\mathbf C = \sigma^2\mathbf I$: zwykłe LS, $\mathrm{cov} = \sigma^2(\mathbf H^T\mathbf H)^{-1}$ — **równe CRLB**: estymator efektywny dla każdego $N$.
- Bez założenia o rozkładzie (tylko średnia zero i kowariancja) ten sam wzór daje **BLUE** — najlepszy liniowy estymator nieobciążony (twierdzenie Gaussa–Markowa).
- **Ważone LS:** próbki o większej wariancji dostają mniejszą wagę.
- Numerycznie: QR lub SVD, nie odwracanie $\mathbf H^T\mathbf H$ ([20.03](../../modules/20-metody-numeryczne/03-uklady-rownan-liniowych.md)).
- **Liniowość względem parametrów, nie danych:** sinusoida o znanej częstotliwości $a\cos\omega t + b\sin\omega t$ to model liniowy; częstotliwość — już nie.

### Najmniejsze kwadraty nieliniowe i rozdzielne

- Gauss–Newton/Levenberg–Marquardt dla $\min\lVert\mathbf x - \mathbf s(\boldsymbol\theta)\rVert^2$.
- **Model rozdzielny** (np. sinusoida: amplituda i faza liniowo, częstotliwość nieliniowo): dla każdej częstotliwości parametry liniowe liczy się wzorem LS, a optymalizuje się tylko po częstotliwości — znacznie prostsze zadanie.
- **Rekurencyjne LS** — aktualizacja wyniku z każdą nową próbką bez ponownego rozwiązywania (temat 06).

## Przykład rozwiązany

**Amplituda i faza 50 Hz** w 200 próbkach (0,2 s przy 1 kHz), szum $\sigma = 0\text{,}5$, nieznany offset. Model: $x[n] = a\cos\omega n + b\sin\omega n + c + w[n]$, macierz $\mathbf H$ o kolumnach $\cos$, $\sin$, $1$.

- Ponieważ okno obejmuje 10 pełnych okresów, kolumny są ortogonalne i $\mathrm{var}(\hat a) = \mathrm{var}(\hat b) = 2\sigma^2/N = 0\text{,}0025$ → $\sigma_{\hat a} = 0\text{,}05$; $\sigma_{\hat c} = \sigma/\sqrt N = 0\text{,}035$ — symulacja potwierdza.
- Amplituda $\hat R = \sqrt{\hat a^2 + \hat b^2}$ (niezmienniczość ML).
- Gdy połowa próbek ma 4-krotnie większy szum, zwykłe LS daje $\sigma_{\hat a} = 0\text{,}143$, a ważone — $0\text{,}069$: wagi pozwalają „zignorować” złe dane, zamiast je uśredniać.

## Typowe pułapki

- **LS przy szumie niejednorodnym lub skorelowanym** bez wag — wynik nieobciążony, ale nieefektywny, a podana kowariancja $\sigma^2(\mathbf H^T\mathbf H)^{-1}$ jest błędna.
- **Wartości odstające** — LS (i ML dla Gaussa) są bardzo wrażliwe; dla danych z odstającymi: estymatory odporne (Huber, mediana, RANSAC).
- **Źle uwarunkowane $\mathbf H$** (bliskie kolumny, np. dwie bliskie częstotliwości w krótkim oknie) — ogromna wariancja; sprawdzaj $\kappa(\mathbf H)$.
- **ML nieliniowe z jednego punktu startowego** — maksimum lokalne.
- **Szacowanie $\sigma^2$ z reszt bez poprawki** na liczbę parametrów: $\hat\sigma^2 = \lVert\mathbf r\rVert^2/(N - p)$.

## Ćwiczenie komputerowe

Estymacja amplitudy, fazy i offsetu modelem liniowym; zgodność kowariancji z teorią; zwykłe i ważone LS:

```python
import numpy as np

rng = np.random.default_rng(2)
fs, N, f0, sigma = 1000.0, 200, 50.0, 0.5
t = np.arange(N)/fs
H = np.column_stack([np.cos(2*np.pi*f0*t), np.sin(2*np.pi*f0*t), np.ones(N)])   # model: a·cos + b·sin + offset
theta_true = np.array([1.0, -0.5, 0.2])

est = []
for _ in range(5000):
    y = H @ theta_true + rng.normal(0, sigma, N)
    est.append(np.linalg.lstsq(H, y, rcond=None)[0])
est = np.array(est)
C_theory = sigma**2*np.linalg.inv(H.T @ H)
print("odch. std. (symulacja):", np.round(est.std(axis=0), 4))
print("odch. std. (σ²(HᵀH)⁻¹):", np.round(np.sqrt(np.diag(C_theory)), 4), "→ dla a, b: sqrt(2σ²/N) =", round(np.sqrt(2*sigma**2/N), 4))
a, b = est.mean(axis=0)[:2]
print(f"amplituda = {np.hypot(a, b):.4f} (prawdziwa {np.hypot(1, -0.5):.4f}), faza φ w R·cos(ωt + φ) = {np.degrees(np.arctan2(-b, a)):.2f}°")

# ważone LS: połowa próbek z 4× większym szumem
sig_n = np.where(np.arange(N) < N//2, sigma, 4*sigma)
W = np.diag(1/sig_n**2)
ols, wls = [], []
for _ in range(5000):
    y = H @ theta_true + rng.normal(0, sig_n)
    ols.append(np.linalg.lstsq(H, y, rcond=None)[0][0])
    wls.append(np.linalg.solve(H.T @ W @ H, H.T @ W @ y)[0])
print(f"szum niejednorodny: std(a) zwykłe LS = {np.std(ols):.4f}, ważone LS = {np.std(wls):.4f}, "
      f"teoria WLS = {np.sqrt(np.linalg.inv(H.T @ W @ H)[0, 0]):.4f}")
```

## Zadania

1. Wyprowadź estymator ML wariancji $\sigma^2$ z $N$ próbek $\mathcal N(\mu, \sigma^2)$ przy nieznanym $\mu$. Czy jest nieobciążony?
2. Dla prostej $x[n] = A + Bn + w[n]$, $n = 0, \ldots, N-1$, zapisz macierz $\mathbf H$. Dlaczego wariancja $\hat A$ maleje, gdy przesuniemy oś czasu na środek przedziału?
3. Pomiar 50 Hz trwa 0,15 s (7,5 okresu). Czy wzór $2\sigma^2/N$ na wariancję $\hat a$ nadal obowiązuje dokładnie?
4. Co zrobić, gdy w danych do dopasowania prostej jest kilka grubych błędów?
5. Wyjaśnij, dlaczego estymację częstotliwości sinusoidy można sprowadzić do jednowymiarowej optymalizacji.

<details>
<summary>Odpowiedzi</summary>

1. $\hat\sigma^2_{ML} = \tfrac1N\sum(x_i - \bar x)^2$; obciążony: $E = \tfrac{N-1}{N}\sigma^2$ (nieobciążony z $N - 1$ w mianowniku); asymptotycznie nieobciążony
2. $\mathbf H = [\mathbf 1, \mathbf n]$; przy osi od 0 kolumny są silnie skorelowane, więc błąd nachylenia przenosi się na wyraz wolny (ekstrapolacja do $n = 0$ na brzegu danych); przy osi wyśrodkowanej kolumny są ortogonalne i $\mathrm{var}(\hat A) = \sigma^2/N$ — najmniejsza możliwa
3. Nie dokładnie — przy niepełnej liczbie okresów kolumny cos, sin i stała nie są ortogonalne; wariancja wynika z pełnej macierzy $\sigma^2(\mathbf H^T\mathbf H)^{-1}$ i jest nieco większa (oraz różna dla $a$ i $b$)
4. Estymator odporny: minimalizacja sumy modułów lub funkcji Hubera, RANSAC (dopasowanie do losowych podzbiorów i wybór modelu z największą liczbą punktów zgodnych), albo wykrycie i usunięcie odstających na podstawie reszt
5. Model jest rozdzielny: przy ustalonej częstotliwości amplituda i faza (a właściwie $a$ i $b$) są liniowe i mają rozwiązanie LS w postaci jawnej; podstawiając je, otrzymuje się funkcję celu tylko częstotliwości — dla długich zapisów jest to w przybliżeniu periodogram, stąd estymator „maksimum FFT”
</details>

## Źródła

- [MIT 6.432 Stochastic Processes, Detection, and Estimation](https://ocw.mit.edu/courses/6-432-stochastic-processes-detection-and-estimation-spring-2004/)
- [MIT 2.160 Identification, Estimation, and Learning](https://ocw.mit.edu/courses/2-160-identification-estimation-and-learning-spring-2006/) — najmniejsze kwadraty, identyfikacja
- S. M. Kay — *Fundamentals of Statistical Signal Processing, t. I* (płatna) — rozdziały 4, 6–8
