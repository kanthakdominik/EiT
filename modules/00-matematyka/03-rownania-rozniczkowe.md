# 00.03 — Równania różniczkowe zwyczajne

## Po co to jest

Każdy obwód z kondensatorem lub cewką opisuje równanie różniczkowe. Obwód RC i RL to równanie 1. rzędu, obwód RLC — 2. rzędu. Te same równania opisują obiekty w automatyce, a pojęcia stałej czasowej, tłumienia i częstotliwości drgań własnych wracają w filtrach, wzmacniaczach i pętlach regulacji.

## Teoria w pigułce

### Równanie liniowe 1. rzędu

$$\tau\frac{dx}{dt} + x = x_\infty \quad\Longrightarrow\quad x(t) = x_\infty + \left(x(0^+) - x_\infty\right)e^{-t/\tau}$$

To jest **„wzór na wszystko”** w stanach nieustalonych 1. rzędu: wystarczą wartość początkowa, wartość ustalona i stała czasowa $\tau$.

- Po czasie $\tau$ przebieg pokonuje 63,2% drogi do wartości ustalonej.
- Po $5\tau$ — 99,3% (w praktyce: stan ustalony).

### Równanie liniowe 2. rzędu

$$\ddot{x} + 2\zeta\omega_0\dot{x} + \omega_0^2 x = 0$$

$\omega_0$ — pulsacja drgań nietłumionych, $\zeta$ — współczynnik tłumienia. Równanie charakterystyczne $s^2 + 2\zeta\omega_0 s + \omega_0^2 = 0$ ma pierwiastki:

$$s_{1,2} = -\zeta\omega_0 \pm \omega_0\sqrt{\zeta^2 - 1}$$

| Przypadek | Pierwiastki | Rozwiązanie |
|---|---|---|
| $\zeta > 1$ — przetłumiony (aperiodyczny) | dwa rzeczywiste ujemne | $A e^{s_1 t} + B e^{s_2 t}$ |
| $\zeta = 1$ — krytyczny | podwójny $s = -\omega_0$ | $(A + Bt)e^{-\omega_0 t}$ |
| $\zeta < 1$ — niedotłumiony (oscylacyjny) | zespolone sprzężone $-\alpha \pm j\omega_d$ | $e^{-\alpha t}(A\cos\omega_d t + B\sin\omega_d t)$ |

gdzie $\alpha = \zeta\omega_0$, $\omega_d = \omega_0\sqrt{1 - \zeta^2}$.

Dla równania niejednorodnego (z wymuszeniem): **rozwiązanie = składowa ustalona (wymuszona) + składowa przejściowa (swobodna)**. Stałe $A$, $B$ wyznacza się z warunków początkowych **dla pełnego rozwiązania**, nie dla samej składowej swobodnej.

## Przykład rozwiązany

Rozwiąż $\ddot{x} + 2\dot{x} + 5x = 0$, $x(0) = 1$, $\dot{x}(0) = 0$.

1. Równanie charakterystyczne: $s^2 + 2s + 5 = 0 \Rightarrow s = -1 \pm j2$.
2. Rozwiązanie ogólne: $x(t) = e^{-t}(A\cos 2t + B\sin 2t)$.
3. $x(0) = A = 1$.
4. $\dot{x}(t) = e^{-t}\left[(-A + 2B)\cos 2t + (-B - 2A)\sin 2t\right]$, więc $\dot{x}(0) = -A + 2B = 0 \Rightarrow B = 0\text{,}5$.
5. Wynik: $x(t) = e^{-t}\left(\cos 2t + 0\text{,}5\sin 2t\right)$.

Interpretacja: $\omega_0 = \sqrt{5} \approx 2\text{,}24$ rad/s, $\zeta = 1/\sqrt{5} \approx 0\text{,}45$ — tłumione oscylacje.

## Typowe pułapki

- **Warunki początkowe przykładane tylko do składowej swobodnej.** Najpierw dodaj składową wymuszoną, potem wyznaczaj stałe.
- **Pomylenie $\omega_0$ i $\omega_d$.** Oscylacje mają pulsację $\omega_d$, mniejszą niż $\omega_0$.
- **Znak w równaniu charakterystycznym.** Dla układów stabilnych części rzeczywiste pierwiastków są ujemne — jeśli wychodzi dodatnia, sprawdź znaki.
- **Brak drugiego warunku.** Równanie 2. rzędu potrzebuje dwóch warunków: $x(0)$ i $\dot{x}(0)$. W obwodach drugi warunek bierze się z ciągłości napięcia kondensatora lub prądu cewki.

## Symulacja / ćwiczenie komputerowe

```python
import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp

def rhs(t, x, zeta, w0):
    return [x[1], -2*zeta*w0*x[1] - w0**2*x[0]]

t = np.linspace(0, 10, 1000)
for zeta in [0.1, 0.5, 1.0, 2.0]:
    sol = solve_ivp(rhs, [0, 10], [1, 0], t_eval=t, args=(zeta, 2.0))
    plt.plot(t, sol.y[0], label=f"ζ = {zeta}")
plt.legend(); plt.grid(); plt.xlabel("t [s]"); plt.show()
```

Zobacz, jak zmienia się charakter odpowiedzi przy przejściu przez $\zeta = 1$.

## Zadania

1. Rozwiąż $\dot{y} + 5y = 10$, $y(0) = 0$. Podaj stałą czasową.
2. Rozwiąż $\ddot{y} + 4\dot{y} + 4y = 0$, $y(0) = 1$, $\dot{y}(0) = 0$.
3. Rozwiąż $\ddot{y} + 3\dot{y} + 2y = 0$, $y(0) = 0$, $\dot{y}(0) = 1$.
4. Układ opisuje $\ddot{x} + 50\dot{x} + 10^4 x = 0$. Wyznacz $\omega_0$, $\zeta$, $\omega_d$ i określ charakter odpowiedzi.
5. Rozwiąż $\dot{y} + y = t$, $y(0) = 0$.
6. Po jakim czasie (w wielokrotnościach $\tau$) przebieg $1 - e^{-t/\tau}$ osiąga 90% wartości ustalonej?

<details>
<summary>Odpowiedzi</summary>

1. $y(t) = 2\left(1 - e^{-5t}\right)$, $\tau = 0\text{,}2$ s
2. Pierwiastek podwójny $s = -2$: $y(t) = (1 + 2t)e^{-2t}$
3. Pierwiastki $-1$, $-2$: $y(t) = e^{-t} - e^{-2t}$
4. $\omega_0 = 100$ rad/s, $\zeta = 0\text{,}25$ (niedotłumiony), $\omega_d = 100\sqrt{1 - 0\text{,}0625} \approx 96\text{,}8$ rad/s
5. $y(t) = t - 1 + e^{-t}$
6. $t = \tau\ln 10 \approx 2\text{,}3\tau$
</details>

## Źródła

- [MIT RES.18-009 Learn Differential Equations (Strang, Moler)](https://ocw.mit.edu/courses/res-18-009-learn-differential-equations-up-close-with-gilbert-strang-and-cleve-moler-fall-2015/) — krótkie wykłady wideo
- [Paul's Online Math Notes — Differential Equations](https://tutorial.math.lamar.edu/) — notatki i zadania z rozwiązaniami
- [MIT 6.002 Circuits and Electronics](https://ocw.mit.edu/courses/6-002-circuits-and-electronics-spring-2007/) — wykłady o dynamice układów 1. i 2. rzędu (zastosowanie w obwodach)
