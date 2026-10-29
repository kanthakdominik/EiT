# M06.01 — Sterowanie optymalne: LQR i LQG

## Po co to jest

Regulator PID dobiera się dla jednej pętli; obiekt o wielu stanach i wejściach (wahadło na wózku, dron, zawieszenie magnetyczne, przekształtnik z filtrem LC) wymaga sprzężenia od całego stanu. LQR daje je w sposób systematyczny: zamiast lokować bieguny „na oko”, formułuje się kompromis między uchybem a energią sterowania jako koszt kwadratowy, a optymalne wzmocnienia wynikają z równania Riccatiego. Dodanie filtru Kalmana ([M01.07](../M01-estymacja-detekcja-filtracja/07-filtr-kalmana.md)) daje LQG — regulator od pomiarów, a nie od stanu, z gwarantowaną (przez zasadę separacji) stabilnością układu nominalnego.

## Teoria w pigułce

### LQR

Obiekt dyskretny $x_{k+1} = Ax_k + Bu_k$, koszt

$$J = \sum_{k=0}^{\infty}\left(x_k^TQx_k + u_k^TRu_k\right),\quad Q \succeq 0,\ R \succ 0.$$

Rozwiązanie: $u_k = -Kx_k$, $K = (R + B^TPB)^{-1}B^TPA$, gdzie $P$ spełnia **dyskretne algebraiczne równanie Riccatiego** (DARE)

$$P = A^TPA - A^TPB(R + B^TPB)^{-1}B^TPA + Q.$$

(W czasie ciągłym: $K = R^{-1}B^TP$, $A^TP + PA - PBR^{-1}B^TP + Q = 0$.) Warunki: $(A, B)$ stabilizowalna, $(A, Q^{1/2})$ wykrywalna. Właściwości ciągłego LQR z pełnym stanem: zapas wzmocnienia od 1/2 do ∞ i fazy co najmniej 60° w każdym kanale.

**Dobór wag** (reguła Brysona): $Q_{ii} = 1/x_{i,\max}^2$, $R_{jj} = 1/u_{j,\max}^2$ — dopuszczalne wartości uchybów i sterowań; dalej strojenie jednym współczynnikiem $\rho$ ($R \to \rho R$).

### LQG i zasada separacji

Gdy mierzymy tylko $y_k = Cx_k + v_k$, a obiekt jest zakłócany szumem $w_k$: estymata stanu z filtru Kalmana (stan ustalony — drugie, dualne równanie Riccatiego) i $u_k = -K\hat x_k$. **Zasada separacji:** wartości własne układu zamkniętego to wartości własne $A - BK$ (regulator) i $A - LCA$ (obserwator) — projektuje się je niezależnie. Uwaga: LQG **nie ma** gwarantowanych zapasów stabilności LQR (Doyle, 1978) — odporność trzeba sprawdzić osobno ([03](03-sterowanie-odporne.md)); metoda LTR (odzyskiwanie transmitancji pętli) przywraca je częściowo.

### Śledzenie wartości zadanej i całkowanie

Dla zera uchybu ustalonego przy stałych zakłóceniach dodaje się stan całkujący uchyb ($x_I$), rozszerza model i projektuje LQR dla układu rozszerzonego (LQI).

## Przykład rozwiązany

**Wahadło odwrócone na wózku** (wózek 1 kg, masa wahadła 0,1 kg, długość 0,5 m, $T_s = 20$ ms), start z odchyleniem 0,2 rad (11,5°), symulacja pełnego modelu nieliniowego:

| Wagi | $K$ | max $\lvert u\rvert$ | $\lvert\theta\rvert < 0\text{,}01$ rad po |
|---|---|---|---|
| łagodne $Q = \mathrm{diag}(1, 0, 10, 0)$, $R = 1$ | [−0,9; −1,7; −27,5; −6,0] | 5,5 N | 2,22 s |
| agresywne $Q = \mathrm{diag}(100, 0, 100, 0)$, $R = 0\text{,}1$ | [−26,3; −20,2; −87,0; −18,5] | 17,4 N | 1,66 s |

Z zakłóceniem siłowym (0,5 N RMS) i pomiarem tylko położenia wózka (szum 5 mm) i kąta (2 mrad):

| Regulator | std kąta | std położenia wózka | std sterowania |
|---|---|---|---|
| LQR od pełnego stanu | 7,4 mrad | 10,6 cm | 0,24 N |
| LQG (filtr Kalmana + te same $K$) | 14,8 mrad | 9,2 cm | 0,38 N |

Cena za brak pomiaru prędkości i szum pomiarów: dwukrotnie większe wahania kąta i większa aktywność sterowania.

## Typowe pułapki

- **Wagi $Q$, $R$ bez skalowania jednostek** — stan w metrach i radianach ma inne rzędy wielkości; reguła Brysona porządkuje to od razu.
- **Projekt na modelu ciągłym, implementacja dyskretna z dużym $T_s$** — utrata zapasów; projektuje się od razu na modelu dyskretnym (ZOH).
- **Nasycenie sterowania pominięte** — „optymalne” wzmocnienia z małym $R$ przekraczają możliwości napędu ([02](02-sterowanie-predykcyjne-mpc.md)).
- **Założenie, że LQG jest odporny jak LQR** — nie jest.
- **Brak całkowania** — uchyb ustalony przy stałym zakłóceniu (np. tarcie, nachylenie).

## Ćwiczenie komputerowe

LQR dla wahadła na wózku (dwie wagi), następnie LQG z filtrem Kalmana i porównanie z pełnym stanem:

```python
import numpy as np
from scipy import linalg, signal

# Wahadło odwrócone na wózku (masa punktowa), theta = 0 w górze
M, m, l, g = 1.0, 0.1, 0.5, 9.81
Ac = np.array([[0, 1, 0, 0],
               [0, 0, -m * g / M, 0],
               [0, 0, 0, 1],
               [0, 0, (M + m) * g / (M * l), 0]])
Bc = np.array([[0], [1 / M], [0], [-1 / (M * l)]])
Ts = 0.02
A, B, *_ = signal.cont2discrete((Ac, Bc, np.eye(4), np.zeros((4, 1))), Ts)

def dlqr(A, B, Q, R):
    P = linalg.solve_discrete_are(A, B, Q, R)
    return np.linalg.solve(R + B.T @ P @ B, B.T @ P @ A)

def f(s, u):                                   # pełne równania nieliniowe
    x, v, th, w = s
    Mm = np.array([[M + m, m * l * np.cos(th)], [np.cos(th), l]])
    rhs = np.array([u + m * l * w**2 * np.sin(th), g * np.sin(th)])
    acc = np.linalg.solve(Mm, rhs)
    return np.array([v, acc[0], w, acc[1]])

def krok(s, u, n=10):                          # RK4 z napięciem stałym w okresie Ts
    h = Ts / n
    for _ in range(n):
        k1 = f(s, u); k2 = f(s + h / 2 * k1, u); k3 = f(s + h / 2 * k2, u); k4 = f(s + h * k3, u)
        s = s + h / 6 * (k1 + 2 * k2 + 2 * k3 + k4)
    return s

def symuluj(K, L=None, T=6.0, szum=False, seed=0):
    rng = np.random.default_rng(seed)
    s = np.array([0.0, 0.0, 0.2, 0.0])         # odchylenie wahadła 0,2 rad (11,5 st.)
    xh = np.zeros(4)                            # estymata stanu (LQG)
    C = np.array([[1, 0, 0, 0], [0, 0, 1, 0]])
    hist = []
    for _ in range(int(T / Ts)):
        if L is None:
            u = -(K @ s).item()                 # pełny stan
        else:
            y = C @ s + (rng.normal(0, [0.005, 0.002]) if szum else 0)
            xh = xh + L @ (y - C @ xh)          # korekcja (filtr Kalmana w stanie ustalonym)
            u = -(K @ xh).item()
            xh = A @ xh + B[:, 0] * u           # predykcja
        d = rng.normal(0, 0.5) if szum else 0.0 # zakłócenie siłowe [N]
        s = krok(s, u + d)
        hist.append([*s, u])
    return np.array(hist)

for nazwa, Q, R in (("łagodny", np.diag([1, 0, 10, 0]), np.array([[1.0]])),
                    ("agresywny", np.diag([100, 0, 100, 0]), np.array([[0.1]]))):
    K = dlqr(A, B, Q, R)
    h = symuluj(K)
    t_ust = Ts * np.max(np.flatnonzero(np.abs(h[:, 2]) > 0.01))
    bieguny = np.abs(np.linalg.eigvals(A - B @ K))
    print(f"LQR {nazwa:9s}: K = {np.round(K.ravel(), 1)}, max|u| = {np.max(np.abs(h[:, 4])):5.1f} N,"
          f" |theta| < 0,01 rad po {t_ust:.2f} s, max |biegun| = {bieguny.max():.3f}")

# LQG: pomiar tylko położenia wózka i kąta, szum pomiarowy i zakłócenie siłowe
K = dlqr(A, B, np.diag([1, 0, 10, 0]), np.array([[1.0]]))
C = np.array([[1, 0, 0, 0], [0, 0, 1, 0]])
Qw = B @ B.T * 0.5**2                           # kowariancja zakłócenia procesu
Rv = np.diag([0.005**2, 0.002**2])
P = linalg.solve_discrete_are(A.T, C.T, Qw + 1e-9 * np.eye(4), Rv)
L = P @ C.T @ np.linalg.inv(C @ P @ C.T + Rv)   # wzmocnienie Kalmana (postać filtrująca)
for nazwa, h in (("LQR, pełny stan", symuluj(K, T=20, szum=True, seed=1)),
                 ("LQG, pomiar x i theta", symuluj(K, L, T=20, szum=True, seed=1))):
    print(f"{nazwa:22s}: std kąta {np.std(h[100:, 2]) * 1e3:5.1f} mrad,"
          f" wózka {np.std(h[100:, 0]) * 100:4.1f} cm, sterowania {np.std(h[100:, 4]):.2f} N")
print(f"bieguny obserwatora |A - LCA|: {np.round(np.sort(np.abs(np.linalg.eigvals(A - L @ C @ A))), 3)}")
```

Rozszerzenia: wyznacz zapasy wzmocnienia i fazy pętli LQG (przecięcie pętli na wejściu obiektu) i porównaj z LQR; dodaj stan całkujący i stałe zakłócenie 1 N; ogranicz $\lvert u\rvert \leq 10$ N i sprawdź, przy jakim kącie początkowym regulator zawodzi. Porównaj wynik z `control.dlqr` z biblioteki python-control.

## Zadania

1. Obiekt skalarny $x_{k+1} = ax_k + bu_k$. Wyprowadź DARE i wzmocnienie dla $a = 1\text{,}2$, $b = 1$, $q = 1$, $r = 1$.
2. Dlaczego zwiększanie $R$ spowalnia układ zamknięty?
3. Co oznacza warunek wykrywalności $(A, Q^{1/2})$?
4. Dlaczego zasada separacji pozwala projektować regulator i obserwator niezależnie? Czy oznacza to, że wynik jest odporny?
5. Według reguły Brysona dopuszczalny kąt to 0,05 rad, położenie 0,2 m, siła 10 N. Podaj $Q$ i $R$.

<details>
<summary>Odpowiedzi</summary>

1. $p = a^2p - \dfrac{a^2b^2p^2}{r + b^2p} + q$; dla $b = q = r = 1$ po pomnożeniu przez $1 + p$: $p^2 - a^2p - 1 = 0$, czyli $p^2 - 1\text{,}44p - 1 = 0$ → $p = 1\text{,}952$; $K = abp/(r + b^2p) = 1\text{,}2\cdot 1\text{,}952/2\text{,}952 = 0\text{,}794$; biegun układu zamkniętego $a - bK = 0\text{,}406$
2. Sterowanie jest „droższe”, więc optymalny regulator używa mniejszych sygnałów — bieguny zbliżają się do biegunów obiektu (lub ich odbić stabilnych)
3. Każdy niestabilny mod obiektu musi być „widoczny” w koszcie — inaczej optymalne byłoby pozostawienie go bez sterowania (koszt by go nie karał)
4. Uchyb estymacji ewoluuje niezależnie od sterowania (układ trójkątny blokowo), więc wartości własne się rozdzielają; nie — separacja dotyczy modelu nominalnego, zapasy odporności nie są gwarantowane
5. $Q = \mathrm{diag}(1/0\text{,}2^2, 0, 1/0\text{,}05^2, 0) = \mathrm{diag}(25, 0, 400, 0)$, $R = 1/100 = 0\text{,}01$
</details>

## Źródła

- [MIT 16.323 Principles of Optimal Control (2008)](https://ocw.mit.edu/courses/16-323-principles-of-optimal-control-spring-2008/) — LQR, LQG, równania Riccatiego
- [R. Tedrake — Underactuated Robotics, rozdział LQR](https://underactuated.mit.edu/lqr.html)
- [K. J. Åström, R. M. Murray — Feedback Systems (wyd. 2, darmowe)](https://www.cds.caltech.edu/~murray/amwiki/Second_Edition.html) — sprzężenie od stanu, estymatory
- [python-control](https://python-control.readthedocs.io) — `lqr`, `dlqr`, `lqe`
