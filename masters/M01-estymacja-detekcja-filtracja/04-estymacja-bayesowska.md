# M01.04 — Estymacja bayesowska: MAP, MMSE, LMMSE

## Po co to jest

Często wiemy coś o parametrze przed pomiarem: temperatura w pomieszczeniu jest w okolicy 20 °C, kanał radiowy ma znaną statystykę zaników, poprzedni stan obiektu przewiduje obecny. Podejście bayesowskie traktuje parametr jako zmienną losową z rozkładem **a priori** i łączy go z danymi. Wynik ma mniejszy błąd średniokwadratowy niż estymator klasyczny — szczególnie przy słabych danych — a jego rekurencyjna wersja to filtr Kalmana (temat 07).

## Teoria w pigułce

### Rozkład a posteriori

$$p(\theta\mid\mathbf x) = \frac{p(\mathbf x\mid\theta)\,p(\theta)}{p(\mathbf x)}$$

| Estymator | Definicja | Minimalizuje |
|---|---|---|
| **MMSE** | $\hat\theta = E[\theta\mid\mathbf x]$ — średnia a posteriori | Błąd średniokwadratowy $E[(\theta - \hat\theta)^2]$ |
| **MAP** | $\hat\theta = \arg\max_\theta p(\theta\mid\mathbf x)$ — maksimum a posteriori | Prawdopodobieństwo błędu (koszt „trafiony/nie”) |
| Mediana a posteriori | — | Błąd bezwzględny |

Dla rozkładu a posteriori gaussowskiego wszystkie trzy są równe. Przy płaskim priorytecie MAP = ML.

### Przypadek gaussowski (sprzężony)

Parametr $\theta \sim \mathcal N(\mu_0, \sigma_0^2)$, $N$ pomiarów $x_i = \theta + w_i$, $w_i \sim \mathcal N(0, \sigma^2)$:

$$\hat\theta_{MMSE} = \frac{\sigma_0^2}{\sigma_0^2 + \sigma^2/N}\,\bar x + \frac{\sigma^2/N}{\sigma_0^2 + \sigma^2/N}\,\mu_0, \qquad \frac{1}{\mathrm{MSE}} = \frac{1}{\sigma_0^2} + \frac{N}{\sigma^2}$$

Informacje (odwrotności wariancji) się dodają: priorytet działa jak dodatkowe pomiary. Przy wielu dobrych pomiarach waga priorytetu → 0; przy słabych — wynik pozostaje blisko $\mu_0$.

### LMMSE (liniowy estymator MMSE)

Gdy znamy tylko średnie i kowariancje (nie pełne rozkłady), najlepszy **liniowy** estymator:

$$\hat{\boldsymbol\theta} = \boldsymbol\mu_\theta + \mathbf C_{\theta x}\mathbf C_{xx}^{-1}(\mathbf x - \boldsymbol\mu_x), \qquad \mathbf C_{\epsilon} = \mathbf C_{\theta\theta} - \mathbf C_{\theta x}\mathbf C_{xx}^{-1}\mathbf C_{x\theta}$$

Dla modelu liniowego $\mathbf x = \mathbf H\boldsymbol\theta + \mathbf w$: $\mathbf K = \mathbf C_\theta\mathbf H^T(\mathbf H\mathbf C_\theta\mathbf H^T + \mathbf C_w)^{-1}$, $\hat{\boldsymbol\theta} = \boldsymbol\mu_\theta + \mathbf K(\mathbf x - \mathbf H\boldsymbol\mu_\theta)$ — dokładnie krok aktualizacji filtru Kalmana. **Zasada ortogonalności:** błąd estymacji jest nieskorelowany z danymi.

### Zastosowania

- **Estymacja kanału LMMSE** w OFDM ([13.07](../../modules/13-telekomunikacja/07-ofdm-i-wielodostep.md)) — wykorzystuje korelację kanału między podnośnymi.
- **Equalizer MMSE** — kompromis między wymuszaniem zera ISI a wzmacnianiem szumu (M02).
- **Odszumianie** — filtr Wienera (temat 05) to LMMSE dla procesów.
- **Regularyzacja** (grzbietowa/Tichonowa) w źle uwarunkowanych problemach LS to estymator MAP z gaussowskim priorytetem.

## Przykład rozwiązany

**Termometr z wiedzą a priori:** temperatura 20 ± 2 °C (priorytet), 4 pomiary z szumem 0,5 °C.

- $\sigma^2/N = 0\text{,}0625$; waga pomiaru $4/4\text{,}0625 = 0\text{,}985$; $\mathrm{MSE} = 1/(0\text{,}25 + 16) = 0\text{,}0615$ (σ = 0,248 °C) wobec 0,0625 dla samej średniej — zysk znikomy, bo dane są dużo lepsze od priorytetu.
- Jeden pomiar z szumem 3 °C: waga pomiaru tylko 0,31, MSE 2,77 °C² wobec 9 °C² dla samego pomiaru — priorytet daje ogromną poprawę.

## Typowe pułapki

- **Zbyt pewny priorytet** — estymator ignoruje dane i jest obciążony, jeśli priorytet jest błędny; wnioski zawsze sprawdzaj z różnymi priorytetami.
- **Porównanie MSE bayesowskiego z CRLB** — to różne kryteria (średnie po rozkładzie parametru vs. dla ustalonego parametru).
- **LMMSE przy silnie niegaussowskich danych** — jest najlepszy tylko wśród estymatorów liniowych; optimum nieliniowe może być dużo lepsze (np. detekcja symboli dyskretnych).
- **Odwracanie źle uwarunkowanej $\mathbf C_{xx}$** — używaj rozkładu Cholesky'ego.

## Ćwiczenie komputerowe

Estymator MMSE z priorytetem gaussowskim (teoria i Monte Carlo) i LMMSE wektorowe:

```python
import numpy as np

# MMSE z priorytetem gaussowskim: temperatura (wiedza a priori 20 ± 2 °C), 4 pomiary z szumem 0,5 °C
mu0, s0, s, N = 20.0, 2.0, 0.5, 4
w = s0**2/(s0**2 + s**2/N)
mse_bayes = 1/(1/s0**2 + N/s**2)
print(f"waga pomiaru {w:.4f}; MSE: Bayes {mse_bayes:.4f} (σ = {np.sqrt(mse_bayes):.3f} °C), "
      f"sama średnia {s**2/N:.4f} (σ = {s/np.sqrt(N):.3f} °C)")

rng = np.random.default_rng(3)
M = 200_000
theta = rng.normal(mu0, s0, M)
y = theta[:, None] + rng.normal(0, s, (M, N))
ybar = y.mean(axis=1)
est_b = w*ybar + (1 - w)*mu0
print(f"symulacja: MSE Bayes = {np.mean((est_b - theta)**2):.4f}, MSE średniej = {np.mean((ybar - theta)**2):.4f}")

# gdy pomiar jest słaby (1 pomiar, szum 3 °C), priorytet ma duże znaczenie
s_bad = 3.0
w2 = s0**2/(s0**2 + s_bad**2)
print(f"słaby pomiar (σ = 3 °C): waga pomiaru {w2:.3f}, MSE Bayes {1/(1/s0**2 + 1/s_bad**2):.2f} vs pomiar {s_bad**2:.1f}")

# LMMSE wektorowe: dwa skorelowane parametry, obserwujemy tylko sumę
mu = np.array([1.0, 2.0]); C = np.array([[1.0, 0.6], [0.6, 2.0]])
Hm = np.array([[1.0, 1.0]]); Cw = np.array([[0.1]])
K = C @ Hm.T @ np.linalg.inv(Hm @ C @ Hm.T + Cw)
P = C - K @ Hm @ C
print("LMMSE: wzmocnienie K =", np.round(K.ravel(), 3), "kowariancja a posteriori diag =", np.round(np.diag(P), 3))
```

W przykładzie LMMSE obserwujemy tylko sumę dwóch parametrów, a mimo to wariancje obu maleją — dzięki ich korelacji a priori.

## Zadania

1. Priorytet $\theta \sim \mathcal N(0, 1)$, jeden pomiar $x = \theta + w$, $w \sim \mathcal N(0, 1)$, zmierzono $x = 2$. Podaj estymatę MMSE i jej wariancję.
2. Ile pomiarów o wariancji $\sigma^2$ „jest wart” priorytet o wariancji $\sigma_0^2$?
3. Wykaż, że dla płaskiego priorytetu estymator MAP jest równy ML.
4. Dlaczego regresja grzbietowa ($\min\lVert\mathbf x - \mathbf H\boldsymbol\theta\rVert^2 + \lambda\lVert\boldsymbol\theta\rVert^2$) jest estymatorem MAP? Jaki priorytet odpowiada $\lambda$?
5. Co mówi zasada ortogonalności o błędzie estymatora LMMSE?

<details>
<summary>Odpowiedzi</summary>

1. Waga $1/(1 + 1) = 0\text{,}5$ → $\hat\theta = 1$; wariancja a posteriori $1/(1 + 1) = 0\text{,}5$
2. $N_{eq} = \sigma^2/\sigma_0^2$ pomiarów (informacja $1/\sigma_0^2$ = informacja $N_{eq}$ pomiarów po $1/\sigma^2$)
3. $p(\theta\mid\mathbf x) \propto p(\mathbf x\mid\theta)\cdot\text{const}$ — maksimum względem $\theta$ jest tam, gdzie maksimum wiarygodności
4. Dla szumu $\mathcal N(0, \sigma^2\mathbf I)$ i priorytetu $\boldsymbol\theta \sim \mathcal N(\mathbf 0, \sigma_\theta^2\mathbf I)$ logarytm a posteriori to $-\tfrac{1}{2\sigma^2}\lVert\mathbf x - \mathbf H\boldsymbol\theta\rVert^2 - \tfrac{1}{2\sigma_\theta^2}\lVert\boldsymbol\theta\rVert^2$; maksymalizacja = minimalizacja funkcji grzbietowej z $\lambda = \sigma^2/\sigma_\theta^2$
5. Błąd $\boldsymbol\theta - \hat{\boldsymbol\theta}$ jest nieskorelowany z każdą składową danych (i z każdą liniową funkcją danych) — nie da się go dalej zmniejszyć żadną liniową poprawką z danych
</details>

## Źródła

- [MIT 6.011 Signals, Systems and Inference](https://ocw.mit.edu/courses/6-011-signals-systems-and-inference-spring-2018/) — estymacja bayesowska i LMMSE
- [MIT 6.432 Stochastic Processes, Detection, and Estimation](https://ocw.mit.edu/courses/6-432-stochastic-processes-detection-and-estimation-spring-2004/)
- S. M. Kay — *Fundamentals of Statistical Signal Processing, t. I* (płatna) — rozdziały 10–12
