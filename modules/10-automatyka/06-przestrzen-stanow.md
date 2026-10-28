# 10.06 — Przestrzeń stanów

## Po co to jest

Opis w przestrzeni stanów obsługuje układy wielowymiarowe (wiele wejść i wyjść), daje bezpośredni dostęp do wewnętrznych zmiennych (prądy, napięcia, położenia, prędkości) i jest językiem nowoczesnej teorii sterowania: lokowania biegunów, obserwatorów, filtru Kalmana i regulatora LQR. To także naturalny sposób symulacji obwodów i układów nieliniowych.

## Teoria w pigułce

### Równania stanu

$$\dot{\mathbf x} = A\mathbf x + B\mathbf u,\qquad \mathbf y = C\mathbf x + D\mathbf u$$

Zmienne stanu: najmniejszy zbiór zmiennych, którego znajomość w chwili $t_0$ wraz z wejściem wyznacza przyszłość. W obwodach: napięcia kondensatorów i prądy cewek. W mechanice: położenia i prędkości.

**Bieguny = wartości własne $A$.** Transmitancja: $G(s) = C(sI - A)^{-1}B + D$. Jedna transmitancja ma nieskończenie wiele realizacji w przestrzeni stanów (różne wybory zmiennych stanu).

### Sterowalność i obserwowalność

- **Sterowalność:** wejściem można sprowadzić stan do dowolnej wartości ⇔ macierz $\mathcal C = [B\ \ AB\ \ \dots\ \ A^{n-1}B]$ ma rząd $n$.
- **Obserwowalność:** z pomiarów wyjścia można odtworzyć stan ⇔ $\mathcal O = [C;\ CA;\ \dots;\ CA^{n-1}]$ ma rząd $n$.

### Sprzężenie od stanu (lokowanie biegunów)

$u = -K\mathbf x + k_r r$ → układ zamknięty $\dot{\mathbf x} = (A - BK)\mathbf x + Bk_r r$. Dla sterowalnego układu **bieguny $A - BK$ można umieścić dowolnie**. Ograniczenia praktyczne: amplituda sterowania (szybkie bieguny = duże wzmocnienia), szum, niepewność modelu. Alternatywa: **LQR** — $K$ minimalizujące $\int(\mathbf x^TQ\mathbf x + u^TRu)\,dt$ (kompromis jakość/koszt sterowania wyrażony wagami).

### Obserwator stanu

Gdy nie mierzymy wszystkich stanów:

$$\dot{\hat{\mathbf x}} = A\hat{\mathbf x} + B\mathbf u + L(\mathbf y - C\hat{\mathbf x})$$

Błąd estymacji zanika z dynamiką $A - LC$. Obserwator projektuje się 2–5 razy szybszy od pętli regulacji. **Zasada separacji:** regulator i obserwator można projektować niezależnie. Optymalny obserwator dla szumów gaussowskich to **filtr Kalmana** (w praktyce: fuzja czujników, np. akcelerometr + żyroskop).

## Przykład rozwiązany

**1. Szeregowy obwód RLC** ($R = 10$ Ω, $L = 1$ mH, $C = 10$ µF), stan $\mathbf x = [u_C,\ i_L]^T$:

$$A = \begin{bmatrix} 0 & 1/C \\ -1/L & -R/L\end{bmatrix} = \begin{bmatrix} 0 & 10^5 \\ -1000 & -10^4\end{bmatrix},\qquad B = \begin{bmatrix}0\\ 1/L\end{bmatrix}$$

Wartości własne: $s^2 + 10^4s + 10^8 = 0$ → $s = -5000 \pm j8660$ ($\omega_n = 10^4$ rad/s, $\zeta = 0{,}5$) — zgodnie z [01.05](../01-teoria-obwodow/05-obwody-2-rzedu.md).

**2. Podwójny integrator** (masa sterowana siłą, $\ddot x = u$): $A = \begin{bmatrix}0&1\\0&0\end{bmatrix}$, $B = \begin{bmatrix}0\\1\end{bmatrix}$.
Sterowalność: $[B\ AB] = \begin{bmatrix}0&1\\1&0\end{bmatrix}$, rząd 2. Zadane bieguny $\omega_n = 2$, $\zeta = 0{,}7$: $s^2 + 2{,}8s + 4$.
$A - BK = \begin{bmatrix}0&1\\-k_1&-k_2\end{bmatrix}$ → $s^2 + k_2s + k_1$ → **$k_1 = 4$, $k_2 = 2{,}8$**.

## Typowe pułapki

- **Wybór zmiennych stanu, które nie są niezależne** (np. dwa napięcia kondensatorów połączonych równolegle).
- **Bardzo szybkie bieguny zadane „na papierze”** — ogromne wzmocnienia, nasycenie, wzmacnianie szumu.
- **Obserwator wolniejszy od regulatora** — regulator działa na nieaktualnym oszacowaniu.
- **Brak całkowania** w sprzężeniu od stanu — uchyb ustalony przy zakłóceniach i błędach modelu; rozwiązanie: rozszerzenie stanu o całkę uchybu.
- **Złe uwarunkowanie numeryczne** macierzy sterowalności dla układów wyższego rzędu — używaj sprawdzonych funkcji (`place_poles`, `solve_continuous_are`).

## Ćwiczenie komputerowe

```python
import numpy as np
from scipy import signal, linalg

# 1. RLC: bieguny i transmitancja
R, L, C = 10.0, 1e-3, 10e-6
A = np.array([[0, 1/C], [-1/L, -R/L]]); B = np.array([[0], [1/L]])
Cm = np.array([[1, 0]]); D = np.array([[0]])
print("wartości własne:", np.linalg.eigvals(A))
print("transmitancja:", signal.ss2tf(A, B, Cm, D))

# 2. Podwójny integrator: lokowanie biegunów i LQR
A = np.array([[0., 1.], [0., 0.]]); B = np.array([[0.], [1.]])
print("rząd macierzy sterowalności:", np.linalg.matrix_rank(np.hstack([B, A @ B])))
p = np.roots([1, 2.8, 4])
K = signal.place_poles(A, B, p).gain_matrix
print("K (lokowanie biegunów):", K.round(3))

Q, Rw = np.diag([10., 1.]), np.array([[1.]])
P = linalg.solve_continuous_are(A, B, Q, Rw)
K_lqr = np.linalg.solve(Rw, B.T @ P)
print("K (LQR):", K_lqr.round(3), "bieguny:", np.linalg.eigvals(A - B @ K_lqr).round(3))

# 3. Obserwator mierzący tylko położenie, 4x szybszy
Cm = np.array([[1., 0.]])
Lo = signal.place_poles(A.T, Cm.T, 4*p).gain_matrix.T
print("L (obserwator):", Lo.ravel().round(2), "bieguny:", np.linalg.eigvals(A - Lo @ Cm).round(2))
```

## Zadania

1. Zapisz równania stanu obwodu RC (wejście $u$, wyjście $u_C$). Jaka jest macierz $A$ i jej wartość własna?
2. Wyznacz wartości własne macierzy $A$ szeregowego obwodu RLC z przykładu.
3. Dla podwójnego integratora wyznacz $K$ dającego bieguny $-2 \pm 2j$.
4. Układ $A = \begin{bmatrix}-1&0\\0&-2\end{bmatrix}$, $B = \begin{bmatrix}1\\0\end{bmatrix}$. Czy jest sterowalny? Co to oznacza fizycznie?
5. Dlaczego obserwator projektuje się szybszy od regulatora, ale nie dowolnie szybki?

<details>
<summary>Odpowiedzi</summary>

1. $\dot u_C = -\dfrac{1}{RC}u_C + \dfrac{1}{RC}u$; $A = -1/(RC)$, wartość własna $-1/(RC)$
2. $-5000 \pm j8660$
3. $s^2 + 4s + 8$ → $k_1 = 8$, $k_2 = 4$
4. Nie — $[B\ AB] = \begin{bmatrix}1&-1\\0&0\end{bmatrix}$ ma rząd 1; drugi stan nie jest w ogóle połączony z wejściem (zanika sam, ale nie można na niego wpłynąć)
5. Szybki obserwator szybko „dogania” stan rzeczywisty, ale duże wzmocnienie $L$ przenosi szum pomiaru na oszacowanie; w praktyce 2–5 razy szybciej od biegunów regulatora, a filtr Kalmana dobiera kompromis optymalnie do znanych szumów
</details>

## Źródła

- [Feedback Systems — Åström, Murray](https://www.cds.caltech.edu/~murray/amwiki/Second_Edition.html) — rozdziały 3, 7 (sprzężenie od stanu) i 8 (obserwatory, filtr Kalmana)
- [Steve Brunton — Control Bootcamp](https://www.youtube.com/results?search_query=Steve+Brunton+Control+Bootcamp) — przestrzeń stanów, sterowalność, LQR, filtr Kalmana
- [MIT 6.302 Feedback Systems](https://ocw.mit.edu/courses/6-302-feedback-systems-spring-2007/)
- [SciPy — scipy.signal.place_poles](https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.place_poles.html)
