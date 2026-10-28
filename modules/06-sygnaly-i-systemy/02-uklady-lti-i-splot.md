# 06.02 — Układy LTI, odpowiedź impulsowa i splot

## Po co to jest

Układy liniowe i stacjonarne (LTI) mają niezwykłą właściwość: jedna funkcja — odpowiedź impulsowa — opisuje je całkowicie. Odpowiedź na dowolny sygnał to splot sygnału z odpowiedzią impulsową. Na tym opiera się filtracja cyfrowa (filtr FIR to splot), pogłos w audio i analiza kanałów transmisyjnych.

## Teoria w pigułce

### Właściwości układów

| Właściwość | Definicja | Test |
|---|---|---|
| **Liniowość** | Superpozycja: $a x_1 + b x_2 \to a y_1 + b y_2$ | Sprawdź addytywność i jednorodność; $x = 0$ musi dawać $y = 0$ |
| **Stacjonarność** (niezmienność w czasie) | $x(t - t_0) \to y(t - t_0)$ | Współczynniki nie zależą od czasu |
| Przyczynowość | Wyjście nie zależy od przyszłych wartości wejścia | $h(t) = 0$ dla $t < 0$ |
| Stabilność BIBO | Ograniczone wejście → ograniczone wyjście | $\int\lvert h(t)\rvert dt < \infty$ |
| Pamięć | Wyjście zależy od przeszłych wartości | $h(t)$ nie jest samą deltą |

### Splot

Każdy sygnał to suma przesuniętych i przeskalowanych delt. Układ LTI odpowiada na każdą z nich przesuniętą i przeskalowaną odpowiedzią impulsową:

$$y(t) = (x * h)(t) = \int_{-\infty}^{\infty}x(\tau)h(t - \tau)\,d\tau, \qquad y[n] = \sum_{k}x[k]h[n - k]$$

**Metoda graficzna:** odbij $h(\tau)$, przesuń o $t$, pomnóż przez $x(\tau)$, policz pole; powtarzaj dla kolejnych $t$.

### Własności splotu

Przemienność, łączność (układy szeregowe: $h_1 * h_2$), rozdzielność względem dodawania (układy równoległe: $h_1 + h_2$), $x * \delta = x$, $x * \delta(t - t_0) = x(t - t_0)$.

Długość wyniku splotu dyskretnego: $N + M - 1$ próbek. Splot dwóch prostokątów daje trójkąt (lub trapez).

### Odpowiedź skokowa

$s(t) = \int_{-\infty}^{t}h(\tau)d\tau$, czyli $h(t) = \dfrac{ds(t)}{dt}$. W praktyce łatwiej zmierzyć odpowiedź skokową niż impulsową.

**Odpowiedź na wykładnik zespolony:** $e^{st} \to H(s)e^{st}$, gdzie $H(s) = \int h(t)e^{-st}dt$ — to transformata Laplace'a odpowiedzi impulsowej, czyli transmitancja ([06.05](05-transmitancja-i-bieguny.md)).

## Przykład rozwiązany

**Splot dyskretny** $[1, 2, 3] * [1, 1]$:

| $n$ | Składniki | $y[n]$ |
|---|---|---|
| 0 | $1\cdot 1$ | 1 |
| 1 | $2\cdot 1 + 1\cdot 1$ | 3 |
| 2 | $3\cdot 1 + 2\cdot 1$ | 5 |
| 3 | $3\cdot 1$ | 3 |

Długość: $3 + 2 - 1 = 4$ ✓. Ten splot to filtr „suma dwóch kolejnych próbek”.

**Filtr RC jako układ LTI:** $h(t) = \dfrac{1}{RC}e^{-t/RC}u(t)$. Odpowiedź na skok: $s(t) = \int_0^t h\,d\tau = 1 - e^{-t/RC}$ — ten sam wynik co w [01.04](../01-teoria-obwodow/04-stany-nieustalone-1-rzedu.md).

## Typowe pułapki

- **Układ z przesunięciem poziomu ($y = 2x + 3$) uznany za liniowy** — jest afiniczny, nie liniowy.
- **Układ ze współczynnikiem zależnym od czasu ($y = t\,x(t)$) uznany za stacjonarny.**
- **Granice całkowania w splocie** przy sygnałach przyczynowych — iloczyn jest niezerowy tylko tam, gdzie oba sygnały są niezerowe.
- **Zapomniane odbicie** $h(-\tau)$ — wtedy liczy się korelację zamiast splotu.

## Ćwiczenie komputerowe

```python
import numpy as np, matplotlib.pyplot as plt
print(np.convolve([1, 2, 3], [1, 1]))           # [1 3 5 3]
dt = 1e-3; t = np.arange(0, 5, dt)
h = np.exp(-t)                                  # RC = 1 s
x = (t < 2).astype(float)                       # impuls 2 s
y = np.convolve(x, h)[:len(t)]*dt
plt.plot(t, x, t, y); plt.grid(); plt.show()   # ładowanie i rozładowanie kondensatora
```

## Zadania

1. Które z układów są liniowe, a które stacjonarne: (a) $y(t) = 2x(t) + 3$, (b) $y(t) = x(t - 2)$, (c) $y(t) = t\,x(t)$, (d) $y[n] = x^2[n]$, (e) $y[n] = x[n] - x[n - 1]$?
2. Oblicz $[1, 2, 3] * [1, 1]$ i $[1, 1, 1] * [1, 1, 1]$.
3. Splot dwóch impulsów prostokątnych o amplitudzie 1 i czasie trwania 1. Jaki kształt i amplituda?
4. Układ ma $h(t) = e^{-2t}u(t)$. Czy jest przyczynowy i stabilny? Wyznacz odpowiedź skokową.
5. Układ ma $h[n] = 2^n u[n]$. Czy jest stabilny?
6. Dwa układy o $h_1(t) = e^{-t}u(t)$ i $h_2(t) = \delta(t - 1)$ połączono szeregowo. Wyznacz wypadkową odpowiedź impulsową.

<details>
<summary>Odpowiedzi</summary>

1. (a) nieliniowy, stacjonarny; (b) liniowy, stacjonarny; (c) liniowy, niestacjonarny; (d) nieliniowy, stacjonarny; (e) liniowy, stacjonarny
2. $[1, 3, 5, 3]$; $[1, 2, 3, 2, 1]$
3. Trójkąt o podstawie 2 i wysokości 1
4. Przyczynowy i stabilny ($\int\lvert h\rvert = 1/2$); $s(t) = \tfrac12(1 - e^{-2t})u(t)$
5. Nie — $\sum 2^n$ jest rozbieżna
6. $h(t) = e^{-(t-1)}u(t - 1)$ — ten sam filtr opóźniony o 1 s
</details>

## Źródła

- [MIT 6.003 Signals and Systems](https://ocw.mit.edu/courses/6-003-signals-and-systems-fall-2011/) — wykłady o splocie i układach LTI
- [MIT RES.6-007 Signals and Systems](https://ocw.mit.edu/courses/res-6-007-signals-and-systems-spring-2011/) — wykłady 4–5: splot ciągły i dyskretny, właściwości układów LTI
- [The Scientist and Engineer's Guide to DSP — rozdziały 5–7](http://www.dspguide.com/) — układy liniowe i splot
- [Think DSP — rozdział o splocie](https://greenteapress.com/wp/think-dsp/)
