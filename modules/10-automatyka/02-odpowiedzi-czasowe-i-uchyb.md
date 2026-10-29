# 10.02 — Odpowiedzi czasowe i uchyb ustalony

## Po co to jest

Wymagania na układ regulacji formułuje się w czasie: „bez przeregulowania powyżej 5%”, „ustala się w 2 s”, „zero uchybu dla stałej wartości zadanej”. Trzeba umieć przełożyć je na położenie biegunów i strukturę regulatora.

## Teoria w pigułce

### Wskaźniki odpowiedzi skokowej

| Wskaźnik | Definicja |
|---|---|
| Czas narastania $t_r$ | 10% → 90% wartości ustalonej |
| Przeregulowanie $M_p$ | $(y_{max} - y_{ust})/y_{ust}$ |
| Czas ustalania $t_s$ | Ostatnie wejście w pasmo ±2% (lub ±5%) |
| Uchyb ustalony $e_{ss}$ | $\lim_{t\to\infty} e(t)$ |

### Układ drugiego rzędu

$$T(s) = \frac{\omega_n^2}{s^2 + 2\zeta\omega_n s + \omega_n^2},\qquad s_{1,2} = -\zeta\omega_n \pm j\omega_n\sqrt{1 - \zeta^2}$$

| Zależność | Wzór |
|---|---|
| Przeregulowanie | $M_p = e^{-\pi\zeta/\sqrt{1-\zeta^2}}$ |
| Czas ustalania (2%) | $t_s \approx \dfrac{4}{\zeta\omega_n}$ |
| Czas narastania (przybliżenie dla $\zeta \approx 0\text{,}5$) | $t_r \approx 1\text{,}8/\omega_n$ |
| Czas do maksimum | $t_p = \dfrac{\pi}{\omega_n\sqrt{1-\zeta^2}}$ |

| $\zeta$ | 0,3 | 0,5 | 0,7 | 1,0 |
|---|---|---|---|---|
| $M_p$ | 37% | 16% | 4,6% | 0 |

**Interpretacja na płaszczyźnie s:** część rzeczywista bieguna ($\zeta\omega_n$) decyduje o czasie ustalania, kąt od osi ujemnej ($\cos\theta = \zeta$) — o przeregulowaniu, odległość od zera ($\omega_n$) — o szybkości.

**Bieguny dominujące:** w układzie wyższego rzędu bieguny położone najbliżej osi urojonej dominują, jeśli pozostałe są co najmniej kilka razy dalej. Zera transmitancji zmieniają odpowiedź (zero w lewej półpłaszczyźnie zwiększa przeregulowanie, w prawej — powoduje początkowy ruch w złą stronę).

### Uchyb ustalony i typ układu

Typ układu = liczba całkowań w pętli otwartej $L(s)$. Z twierdzenia o wartości końcowej $e_{ss} = \lim_{s\to 0} s\cdot\dfrac{1}{1 + L(s)}R(s)$:

| Typ | Skok | Rampa | Parabola |
|---|---|---|---|
| 0 | $\dfrac{1}{1 + K_p}$, $K_p = L(0)$ | ∞ | ∞ |
| 1 | 0 | $\dfrac{1}{K_v}$, $K_v = \lim sL(s)$ | ∞ |
| 2 | 0 | 0 | $\dfrac{1}{K_a}$ |

Dlatego regulator PI (dodaje całkowanie) usuwa uchyb dla stałej wartości zadanej i stałych zakłóceń.

## Przykład rozwiązany

**Wymaganie:** przeregulowanie ≤ 5%, czas ustalania ≤ 1 s.

1. $M_p \leq 5\%$ → $\zeta \geq 0\text{,}69$; przyjmij $\zeta = 0\text{,}7$.
2. $t_s = 4/(\zeta\omega_n) \leq 1$ → $\zeta\omega_n \geq 4$ → $\omega_n \geq 5\text{,}7$ rad/s.
3. Obszar dozwolony na płaszczyźnie s: na lewo od prostej $\sigma = -4$ i wewnątrz klina $\pm 45\text{,}6°$ od ujemnej osi rzeczywistej.

**Uchyb dla rampy:** $L(s) = \dfrac{10}{s(0\text{,}1s + 1)}$ — typ 1, $K_v = 10$, uchyb przy rampie jednostkowej $e_{ss} = 0\text{,}1$.

## Typowe pułapki

- **Wzory na $M_p$ i $t_s$ stosowane do układów z zerami** lub bez wyraźnie dominujących biegunów — tylko przybliżenia.
- **Twierdzenie o wartości końcowej dla układu niestabilnego** — daje bezsensowny wynik.
- **Mylenie typu układu (całkowania w $L$) z rzędem** (stopień mianownika).
- **Zbyt ambitne wymagania** wobec obiektu z opóźnieniem — szybkość ograniczona przez $L$, nie przez regulator.

## Ćwiczenie komputerowe

Wskaźniki odpowiedzi skokowej dla kilku wartości $\zeta$ i porównanie z wzorami:

```python
import numpy as np
from scipy import signal
import matplotlib.pyplot as plt

wn = 10.0
t = np.linspace(0, 2, 4001)
for z in [0.3, 0.5, 0.7, 1.0]:
    _, y = signal.step(([wn**2], [1, 2*z*wn, wn**2]), T=t)
    Mp = (y.max() - 1)*100
    ts = t[np.where(abs(y - 1) > 0.02)[0][-1]]
    Mp_f = 100*np.exp(-np.pi*z/np.sqrt(1 - z*z)) if z < 1 else 0
    print(f"zeta={z}: Mp={Mp:5.1f}% (wzór {Mp_f:5.1f}%), ts={ts:.3f} s (4/(zeta wn)={4/(z*wn):.3f} s)")
    plt.plot(t, y, label=f'ζ={z}')
plt.xlabel('t [s]'); plt.legend(); plt.grid(); plt.show()
```

Zauważ: wzór $4/(\zeta\omega_n)$ jest przybliżeniem obwiedni — dla małych $\zeta$ zawyża czas ustalania (0,3: 1,33 s wobec 1,12 s), a dla $\zeta \geq 0\text{,}7$ go zaniża (1,0: 0,40 s wobec 0,58 s). Jest dobry do szacunków, nie do odbioru układu.

## Zadania

1. Wymaganie $M_p \leq 10\%$. Jakie minimalne $\zeta$?
2. $\zeta = 0\text{,}5$, $\omega_n = 10$ rad/s. Przeregulowanie, czas ustalania (2%), czas do maksimum.
3. Pętla otwarta $L(s) = \dfrac{4}{(s+1)^3}$. Uchyb ustalony dla skoku jednostkowego?
4. Pętla $L(s) = \dfrac{K}{s(0\text{,}1s + 1)}$. Jakie $K$ daje uchyb 0,05 przy rampie jednostkowej? Jaki to ma wpływ na $\zeta$ układu zamkniętego?
5. Układ ma bieguny $-2 \pm 3j$ i $-20$. Czy biegun $-20$ można pominąć? Oszacuj przeregulowanie i czas ustalania.

<details>
<summary>Odpowiedzi</summary>

1. $\zeta \geq 0\text{,}59$
2. 16,3%; 0,8 s; $t_p = \pi/(10\cdot 0\text{,}866) \approx 0\text{,}36$ s
3. $1/(1 + 4) = 0\text{,}2$
4. $K_v = 20$ → $K = 20$; układ zamknięty $s^2\cdot 0\text{,}1 + s + K$: $\omega_n = \sqrt{10K}$, $\zeta = 1/(2\sqrt{0\text{,}1K})$ = 0,35 (dla K = 10 było 0,5) — dokładność śledzenia kosztem tłumienia
5. Tak (10 razy dalej); $\omega_n = \sqrt{13} \approx 3\text{,}6$, $\zeta = 2/3\text{,}6 \approx 0\text{,}55$ → $M_p \approx 12\%$, $t_s \approx 4/2 = 2$ s
</details>

## Źródła

- [Feedback Systems — Åström, Murray](https://www.cds.caltech.edu/~murray/amwiki/Second_Edition.html) — rozdziały 5–6 (odpowiedzi, wskaźniki jakości)
- [MIT 6.003 Signals and Systems](https://ocw.mit.edu/courses/6-003-signals-and-systems-fall-2011/) — bieguny a odpowiedź czasowa
- [Brian Douglas — Control Systems Lectures](https://www.youtube.com/results?search_query=Brian+Douglas+Control+System+Lectures) — odpowiedzi czasowe, uchyb ustalony
