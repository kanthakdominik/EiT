# M06.02 — Sterowanie predykcyjne (MPC)

## Po co to jest

Każdy rzeczywisty napęd, zawór czy przekształtnik ma ograniczenia: maksymalny prąd, napięcie, prędkość, temperaturę. LQR ich nie zna — po prostu „obcina” sygnał, co psuje dynamikę i może destabilizować układ. **Sterowanie predykcyjne** w każdym kroku rozwiązuje zadanie optymalizacji na skończonym horyzoncie z jawnymi ograniczeniami, stosuje pierwsze sterowanie i powtarza obliczenia w następnym kroku. To standard w przemyśle procesowym, coraz częściej w motoryzacji (autonomiczna jazda), robotyce, energoelektronice (MPC dla falowników, FCS-MPC) i zarządzaniu energią.

## Teoria w pigułce

### Sformułowanie

W chwili $k$, znając stan $x_k$, rozwiąż

$$\min_{u_0,\dots,u_{N-1}}\ \sum_{i=0}^{N-1}\left(x_i^TQx_i + u_i^TRu_i\right) + x_N^TPx_N$$

przy $x_{i+1} = Ax_i + Bu_i$, $x_0 = x_k$, $u_{\min} \leq u_i \leq u_{\max}$, $x_{\min} \leq x_i \leq x_{\max}$. Zastosuj $u_0$, odrzuć resztę — **zasada horyzontu przesuwnego**.

### Postać skondensowana i programowanie kwadratowe

Predykcja $\mathbf X = \Phi x_k + \Gamma\mathbf U$ → koszt $\tfrac12\mathbf U^T\mathbf H\mathbf U + \mathbf f^T\mathbf U$ z $\mathbf H = 2(\Gamma^T\bar Q\Gamma + \bar R)$ — zadanie **QP** (programowania kwadratowego) z ograniczeniami liniowymi; wypukłe, więc rozwiązywalne szybko i niezawodnie (metody aktywnego zbioru, punktu wewnętrznego, ADMM — np. OSQP). Postać rzadka (zmienne $x$ i $u$ razem) skaluje się lepiej przy długich horyzontach.

### Stabilność i wykonalność

- **Koszt końcowy** $P$ z równania Riccatiego (koszt LQR „po horyzoncie”) i **zbiór końcowy** zapewniają stabilność; przy braku ograniczeń aktywnych MPC = LQR.
- **Wykonalność rekursywna:** jeśli zadanie ma rozwiązanie teraz, ma je i w następnym kroku — wymaga odpowiedniego zbioru końcowego; w praktyce ograniczenia stanu „miękkie” (z karą) chronią przed brakiem rozwiązania.
- **Zero uchybu ustalonego:** model rozszerzony o zakłócenie stałe estymowane obserwatorem (offset-free MPC).
- **Czas obliczeń** musi zmieścić się w okresie próbkowania: QP na mikrokontrolerze (ms), MPC jawne (explicit — prawo sterowania odcinkowo-liniowe policzone wcześniej) dla bardzo szybkich układów.

## Przykład rozwiązany

**Podwójny integrator** (pozycjonowanie, $T_s = 0\text{,}1$ s), start 5 m od celu, $\lvert u\rvert \leq 1$, $Q = \mathrm{diag}(1; 0\text{,}1)$, $R = 0\text{,}01$:

| Regulator | max $\lvert u\rvert$ | Przeregulowanie | Czas ustalania (5 cm) | Koszt $J$ |
|---|---|---|---|---|
| LQR bez ograniczeń | 38,1 | 0,02 m | 1,5 s | 150,6 |
| LQR z obcięciem do ±1 | 1 | 2,13 m | 9,8 s | 553,0 |
| MPC, $N = 5$ | 1 | 1,71 m | 8,5 s | 506,6 |
| MPC, $N = 20$ | 1 | 0,29 m | 5,6 s | 448,3 |
| MPC, $N = 40$ | 1 | 0,22 m | 5,5 s | 448,2 |

Obcięty LQR „nie wie”, że nie zdąży wyhamować — przeregulowanie ponad 2 m. MPC z odpowiednio długim horyzontem planuje hamowanie z wyprzedzeniem; czas zbliża się do granicy sterowania czasooptymalnego $2\sqrt{5} = 4\text{,}47$ s. Zbyt krótki horyzont (0,5 s) jest niewiele lepszy od obcięcia.

## Typowe pułapki

- **Za krótki horyzont** — regulator „nie widzi” konsekwencji ograniczeń (jak $N = 5$ powyżej).
- **Twarde ograniczenia stanu przy zakłóceniach** — zadanie staje się niewykonalne i regulator nie zwraca sterowania; ograniczenia miękkie lub awaryjne prawo sterowania.
- **Model niedokładny** — MPC jest optymalny dla modelu; uchyb ustalony bez estymacji zakłócenia.
- **Czas rozwiązania QP większy od $T_s$** — w praktyce trzeba ograniczyć liczbę iteracji, użyć rozgrzewania (rozwiązanie z poprzedniego kroku) lub MPC jawnego.
- **Brak kosztu końcowego** — możliwa niestabilność przy krótkim horyzoncie.

## Ćwiczenie komputerowe

MPC z ograniczeniem sterowania (zadanie najmniejszych kwadratów z ograniczeniami prostymi, `scipy.optimize.lsq_linear`) w porównaniu z LQR:

```python
import numpy as np
from scipy import linalg
from scipy.optimize import lsq_linear

# Podwójny integrator (np. pozycjonowanie głowicy, napęd liniowy): x = [położenie, prędkość]
Ts = 0.1
A = np.array([[1, Ts], [0, 1]])
B = np.array([[Ts**2 / 2], [Ts]])
Q = np.diag([1.0, 0.1])
R = np.array([[0.01]])
umax = 1.0
P = linalg.solve_discrete_are(A, B, Q, R)            # koszt końcowy = koszt LQR (stabilność MPC)
K = np.linalg.solve(R + B.T @ P @ B, B.T @ P @ A)

def macierze_predykcji(N):
    n = A.shape[0]
    Phi = np.vstack([np.linalg.matrix_power(A, k + 1) for k in range(N)])
    Gam = np.zeros((N * n, N))
    for k in range(N):
        for j in range(k + 1):
            Gam[k * n:(k + 1) * n, j:j + 1] = np.linalg.matrix_power(A, k - j) @ B
    Qb = linalg.block_diag(*([Q] * (N - 1) + [P]))
    return Phi, Gam, linalg.cholesky(Qb), np.sqrt(R[0, 0]) * np.eye(N)

def mpc(x, N, mac):
    Phi, Gam, Qh, Rh = mac
    # min ||Qh (Phi x + Gam U)||^2 + ||Rh U||^2  przy |u| <= umax  — zadanie LS z ograniczeniami
    A_ls = np.vstack([Qh @ Gam, Rh])
    b_ls = np.concatenate([-Qh @ Phi @ x, np.zeros(N)])
    U = lsq_linear(A_ls, b_ls, bounds=(-umax, umax)).x
    return U[0]                                       # zasada horyzontu przesuwnego

def symuluj(regulator, T=15.0):
    x = np.array([5.0, 0.0])                          # start 5 m od celu
    hist, J = [], 0.0
    for _ in range(int(T / Ts)):
        u = regulator(x)
        J += x @ Q @ x + R[0, 0] * u**2
        hist.append([x[0], x[1], u])
        x = A @ x + B[:, 0] * u
    h = np.array(hist)
    t_ust = Ts * (np.max(np.flatnonzero(np.abs(h[:, 0]) > 0.05)) + 1)
    return h, J, t_ust

wyniki = {
    "LQR bez ograniczeń (u nieograniczone)": lambda x: -(K @ x).item(),
    "LQR z nasyceniem |u| <= 1": lambda x: float(np.clip(-(K @ x).item(), -umax, umax)),
}
for N in (5, 20, 40):
    mac = macierze_predykcji(N)
    wyniki[f"MPC, horyzont N = {N}"] = lambda x, N=N, mac=mac: mpc(x, N, mac)

for nazwa, reg in wyniki.items():
    h, J, t_ust = symuluj(reg)
    print(f"{nazwa:38s}: max|u| = {np.max(np.abs(h[:, 2])):5.2f}, przeregulowanie = {max(0, -h[:, 0].min()):.3f} m,"
          f" czas ustalania (5 cm) = {t_ust:.1f} s, koszt J = {J:6.1f}")
```

Rozszerzenia: dodaj ograniczenie prędkości $\lvert v\rvert \leq 1$ m/s — potrzebny ogólny solver QP (zaimplementuj metodę rzutowanego gradientu dla ograniczeń prostych na $u$ i kary dla ograniczeń stanu albo użyj biblioteki OSQP lub CVXPY); dodaj stałe zakłócenie i obserwator zakłócenia (offset-free MPC); zmierz czas rozwiązania QP w funkcji $N$.

## Zadania

1. Ile zmiennych decyzyjnych ma zadanie MPC dla obiektu z 2 wejściami i horyzontem 30 kroków (postać skondensowana)?
2. Dlaczego przy braku aktywnych ograniczeń MPC z kosztem końcowym $P$ z równania Riccatiego daje to samo sterowanie co LQR?
3. Co to jest wykonalność rekursywna i jak ją zapewnić w praktyce?
4. Jaki jest minimalny czas przeprowadzenia podwójnego integratora z $x = 5$ m, $v = 0$ do zera przy $\lvert u\rvert \leq 1$ m/s²?
5. Kiedy wybierzesz MPC jawne zamiast rozwiązywania QP w czasie rzeczywistym?

<details>
<summary>Odpowiedzi</summary>

1. $2\cdot 30 = 60$ (stany są eliminowane przez predykcję)
2. Koszt końcowy $x_N^TPx_N$ jest dokładnie kosztem LQR od chwili $N$ do nieskończoności; bez ograniczeń zadanie na horyzoncie $N$ z tym kosztem jest równoważne zadaniu nieskończonemu, a jego rozwiązanie to $u = -Kx$
3. Gwarancja, że zadanie optymalizacji ma rozwiązanie w każdym kolejnym kroku, jeśli ma je w obecnym; zapewnia ją zbiór końcowy niezmienniczy dla regulatora końcowego, w praktyce — miękkie ograniczenia stanu z dużą karą
4. Rozpędzanie z $u = -1$ przez połowę drogi i hamowanie $u = +1$: $2\sqrt{x/u_{\max}} = 2\sqrt5 \approx 4\text{,}47$ s (sterowanie typu bang-bang)
5. Gdy obiekt jest mały (kilka stanów, krótki horyzont), a okres próbkowania bardzo krótki (µs–ms, np. przekształtniki) lub sprzęt bez możliwości iteracyjnej optymalizacji — prawo odcinkowo-liniowe to tylko wyszukanie regionu i mnożenie
</details>

## Źródła

- [J. B. Rawlings, D. Q. Mayne, M. M. Diehl — Model Predictive Control: Theory, Computation, and Design (wyd. 2, darmowy PDF)](https://engineering.ucsb.edu/~jbraw/mpc/MPC-book-2nd-edition-1st-printing.pdf)
- [R. Tedrake — Underactuated Robotics](https://underactuated.mit.edu/) — optymalizacja trajektorii i MPC
- [MIT 16.323 Principles of Optimal Control (2008)](https://ocw.mit.edu/courses/16-323-principles-of-optimal-control-spring-2008/)
- F. Borrelli, A. Bemporad, M. Morari — *Predictive Control for Linear and Hybrid Systems* (płatna)
