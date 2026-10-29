# M01.07 — Filtr Kalmana

## Po co to jest

Filtr Kalmana łączy model dynamiki obiektu z zaszumionymi pomiarami i w każdym kroku daje optymalną (LMMSE) estymatę stanu wraz z jej niepewnością. Nawigował statki Apollo, a dziś działa w odbiornikach GNSS, nawigacji inercyjnej, śledzeniu celów radarowych, estymacji stanu naładowania baterii (SoC), sterowaniu silnikami bez czujnika położenia, pętlach synchronizacji i prognozowaniu. Jest rekurencyjny — potrzebuje tylko poprzedniej estymaty, a nie całej historii.

## Teoria w pigułce

### Model

$$\mathbf x_k = \mathbf F\mathbf x_{k-1} + \mathbf B\mathbf u_k + \mathbf w_k, \quad \mathbf w_k \sim \mathcal N(\mathbf 0, \mathbf Q)$$
$$\mathbf z_k = \mathbf H\mathbf x_k + \mathbf v_k, \quad \mathbf v_k \sim \mathcal N(\mathbf 0, \mathbf R)$$

(model dyskretny w przestrzeni stanów — [10.06](../../modules/10-automatyka/06-przestrzen-stanow.md)).

### Algorytm

**Predykcja:**
$$\hat{\mathbf x}_{k|k-1} = \mathbf F\hat{\mathbf x}_{k-1|k-1} + \mathbf B\mathbf u_k, \qquad \mathbf P_{k|k-1} = \mathbf F\mathbf P_{k-1|k-1}\mathbf F^T + \mathbf Q$$

**Aktualizacja:**
$$\mathbf S = \mathbf H\mathbf P_{k|k-1}\mathbf H^T + \mathbf R, \quad \mathbf K = \mathbf P_{k|k-1}\mathbf H^T\mathbf S^{-1}$$
$$\hat{\mathbf x}_{k|k} = \hat{\mathbf x}_{k|k-1} + \mathbf K(\mathbf z_k - \mathbf H\hat{\mathbf x}_{k|k-1}), \qquad \mathbf P_{k|k} = (\mathbf I - \mathbf K\mathbf H)\mathbf P_{k|k-1}$$

- **Innowacja** $\boldsymbol\nu = \mathbf z - \mathbf H\hat{\mathbf x}_{k|k-1}$ o kowariancji $\mathbf S$ — część pomiaru, której model nie przewidział.
- **Wzmocnienie** $\mathbf K$ równoważy zaufanie do modelu ($\mathbf P$) i pomiaru ($\mathbf R$).
- Krok aktualizacji to LMMSE z tematu 04, z predykcją jako priorytetem.
- Postać Josepha $\mathbf P = (\mathbf I - \mathbf K\mathbf H)\mathbf P(\mathbf I - \mathbf K\mathbf H)^T + \mathbf K\mathbf R\mathbf K^T$ — numerycznie stabilniejsza (zachowuje symetrię i dodatnią określoność).

### Stan ustalony

Dla systemu niezmiennego w czasie $\mathbf P$ i $\mathbf K$ zbiegają do stałych wartości — rozwiązania dyskretnego **algebraicznego równania Riccatiego**. Stałe wzmocnienie (filtr α–β dla modelu stałej prędkości) jest tanie w implementacji na mikrokontrolerze.

### Strojenie i sprawdzanie

- $\mathbf R$ — z karty katalogowej lub pomiaru czujnika w spoczynku.
- $\mathbf Q$ — „ile model się myli”: dla modelu stałej prędkości to wariancja niemodelowanego przyspieszenia; za małe $\mathbf Q$ — filtr za wolno reaguje (opóźnienie, rozbieżność), za duże — za bardzo ufa pomiarom (szum).
- **Testy spójności:** innowacje powinny być białe i mieć kowariancję $\mathbf S$; NIS $= \boldsymbol\nu^T\mathbf S^{-1}\boldsymbol\nu$ ma rozkład $\chi^2$ z $\dim\mathbf z$ stopniami swobody; NEES (w symulacji, ze znaną prawdą) sprawdza zgodność $\mathbf P$ z rzeczywistym błędem.
- **Obserwowalność** — stan musi być wyznaczalny z pomiarów (np. sama prędkość nie wyznaczy położenia).

## Przykład rozwiązany

**Śledzenie położenia i prędkości** z pomiarów położenia co 0,1 s ($\sigma = 1$ m), model stałej prędkości z niemodelowanym przyspieszeniem $q = 0\text{,}5$ m/s².

- Stan $\mathbf x = [p, v]^T$, $\mathbf F = \begin{bmatrix} 1 & \Delta t \\ 0 & 1\end{bmatrix}$, $\mathbf Q = q^2\mathbf G\mathbf G^T$, $\mathbf G = [\Delta t^2/2,\ \Delta t]^T$, $\mathbf H = [1,\ 0]$.
- Wynik symulacji: błąd położenia 0,27 m wobec 1,0 m samego pomiaru; prędkość 0,18 m/s — a prędkość liczona z różnic pomiarów miałaby błąd ok. 14 m/s.
- Stan ustalony z równania Riccatiego: $\mathbf K = [0\text{,}095,\ 0\text{,}048]^T$ (filtr α–β z $\alpha \approx 0\text{,}095$, $\beta \approx 0\text{,}048\cdot\Delta t$), $\sigma_p = 0\text{,}31$ m, $\sigma_v = 0\text{,}22$ m/s.

## Typowe pułapki

- **$\mathbf Q = 0$** („model jest idealny”) — wzmocnienie dąży do zera, filtr przestaje słuchać pomiarów i rozbiega się przy pierwszym manewrze.
- **Błędne jednostki lub skale w $\mathbf Q$ i $\mathbf R$** (wariancje vs odchylenia).
- **Pomiary opóźnione lub o różnych częstotliwościach** przetwarzane „jak przyszły” — trzeba aktualizować w odpowiedniej chwili (predykcja do czasu pomiaru).
- **Niesymetryczna lub nieujemnie określona $\mathbf P$** po wielu krokach — postać Josepha, filtry pierwiastkowe (UD, Cholesky).
- **Brak testów spójności** — filtr „działa” na wykresie, ale jego deklarowana niepewność jest kilkakrotnie za mała.

## Ćwiczenie komputerowe

Filtr Kalmana dla modelu stałej prędkości i stan ustalony z równania Riccatiego:

```python
import numpy as np
from scipy.linalg import solve_discrete_are

rng = np.random.default_rng(6)
dt, N, r, q = 0.1, 600, 1.0, 0.5                # pomiar położenia co 0,1 s (σ = 1 m), szum przyspieszenia q [m/s²]
F = np.array([[1, dt], [0, 1]])
G = np.array([[0.5*dt**2], [dt]])
Q = q**2*(G @ G.T)
Hm = np.array([[1.0, 0.0]]); R = np.array([[r**2]])

x = np.array([0.0, 5.0]); xs, zs = [], []
for _ in range(N):                              # trajektoria: prędkość ok. 5 m/s z losowym przyspieszeniem
    x = F @ x + (G*rng.normal(0, q)).ravel()
    xs.append(x.copy()); zs.append(x[0] + rng.normal(0, r))
xs, zs = np.array(xs), np.array(zs)

xh, P = np.array([zs[0], 0.0]), np.diag([r**2, 100.0])
est = []
for z in zs:
    xh = F @ xh; P = F @ P @ F.T + Q                              # predykcja
    S = Hm @ P @ Hm.T + R; K = P @ Hm.T @ np.linalg.inv(S)        # wzmocnienie Kalmana
    xh = xh + (K @ (z - Hm @ xh)).ravel(); P = (np.eye(2) - K @ Hm) @ P   # aktualizacja
    est.append(xh.copy())
est = np.array(est)
sl = slice(50, None)
print(f"RMSE położenia: pomiar {np.sqrt(np.mean((zs[sl] - xs[sl, 0])**2)):.3f} m, Kalman {np.sqrt(np.mean((est[sl, 0] - xs[sl, 0])**2)):.3f} m")
print(f"RMSE prędkości (Kalman): {np.sqrt(np.mean((est[sl, 1] - xs[sl, 1])**2)):.3f} m/s; "
      f"różnica pomiarów / dt: {np.sqrt(np.mean((np.diff(zs)[49:]/dt - xs[50:, 1])**2)):.2f} m/s")

# stan ustalony: rozwiązanie równania Riccatiego
Pinf = solve_discrete_are(F.T, Hm.T, Q, R)
Kinf = Pinf @ Hm.T @ np.linalg.inv(Hm @ Pinf @ Hm.T + R)
P_post = (np.eye(2) - Kinf @ Hm) @ Pinf
print(f"stan ustalony: K = {np.round(Kinf.ravel(), 4)}, σ położenia a posteriori = {np.sqrt(P_post[0, 0]):.3f} m, "
      f"σ prędkości = {np.sqrt(P_post[1, 1]):.3f} m/s")
```

Rozszerzenie: zmień $q$ w filtrze na 0,05 i 5 (przy prawdziwym 0,5) i porównaj błąd RMS i statystykę NIS — zobaczysz skutki złego strojenia.

## Zadania

1. Skalarny filtr Kalmana: $x_k = x_{k-1}$ (stała), $z_k = x_k + v_k$, $\mathrm{var}(v) = r$, $P_0 = \infty$. Pokaż, że estymata to średnia pomiarów.
2. Model błądzenia losowego $x_k = x_{k-1} + w_k$, $\mathrm{var}(w) = q$, pomiar z wariancją $r$. Wyznacz wariancję a priori w stanie ustalonym dla $q = r = 1$.
3. Dlaczego prędkość jest dobrze estymowana, choć mierzone jest tylko położenie?
4. Czujnik GNSS daje położenie co 1 s, a akcelerometr co 10 ms. Jak włączyć oba do filtru?
5. Średnia wartość NIS w długiej symulacji wynosi 5 przy jednowymiarowym pomiarze. Co to oznacza?

<details>
<summary>Odpowiedzi</summary>

1. $P_{k|k-1} = P_{k-1|k-1}$, $K_k = P/(P + r)$; z $P_0 \to \infty$: $K_1 = 1$, $P_1 = r$, $K_2 = 1/2$, $P_2 = r/2$, …, $K_k = 1/k$ → $\hat x_k = \hat x_{k-1} + \tfrac1k(z_k - \hat x_{k-1})$ — rekurencyjna średnia
2. $P^- = P^+ + q$, $P^+ = P^-r/(P^- + r)$ → $P^- = P^-r/(P^- + r) + q$; dla $q = r = 1$: $(P^-)^2 - P^- - 1 = 0$ → $P^- = (1 + \sqrt5)/2 = 1\text{,}618$, $K = 0\text{,}618$
3. Stan jest obserwowalny: model wiąże prędkość ze zmianą położenia, a filtr optymalnie uśrednia wiele pomiarów (różnice pomiarów są bardzo zaszumione, ale ich ważona historia — nie)
4. Akcelerometr jako sterowanie $\mathbf u$ w predykcji co 10 ms (lub jako pomiar w modelu z przyspieszeniem w stanie), GNSS jako aktualizacja co 1 s (gdy nadejdzie pomiar); dodatkowo w stanie dryf akcelerometru (bias)
5. Oczekiwana wartość NIS to 1 — innowacje są ok. 5 razy większe (w wariancji) niż filtr przewiduje: za małe $\mathbf Q$ lub $\mathbf R$ albo błędny model; filtr jest „zbyt pewny siebie”
</details>

## Źródła

- [G. Welch, G. Bishop — An Introduction to the Kalman Filter](https://www.cs.unc.edu/~welch/kalman/kalmanIntro.html)
- [R. Labbe — Kalman and Bayesian Filters in Python](https://github.com/rlabbe/Kalman-and-Bayesian-Filters-in-Python) — rozdziały o filtrze Kalmana i projektowaniu filtrów
- [MIT 2.160 Identification, Estimation, and Learning](https://ocw.mit.edu/courses/2-160-identification-estimation-and-learning-spring-2006/) — filtr Kalmana
- D. Simon — *Optimal State Estimation* (płatna)
