# 20.06 — Równania różniczkowe zwyczajne

## Po co to jest

Każdy obwód z kondensatorami i cewkami opisuje układ równań różniczkowych ([01 Teoria obwodów](../01-teoria-obwodow/), [00.03](../00-matematyka/03-rownania-rozniczkowe.md)). Analiza stanów nieustalonych w SPICE (`.tran`), symulacja przetwornicy ([15.02](../15-energoelektronika-zasilanie/02-przetwornica-buck.md)), modelu termicznego czy pętli regulacji ([10.06](../10-automatyka/06-przestrzen-stanow.md)) — wszystko to numeryczne całkowanie równania $\dot{\mathbf y} = \mathbf f(t, \mathbf y)$. Wybór metody i kroku decyduje o dokładności, czasie symulacji i o tym, czy wynik w ogóle jest stabilny.

## Teoria w pigułce

### Metody jednokrokowe

| Metoda | Krok | Rząd | Uwagi |
|---|---|---|---|
| **Euler jawny** | $y_{n+1} = y_n + h\,f(t_n, y_n)$ | 1 | Najprostsza; stabilna tylko dla małego $h$ |
| **Euler niejawny (wsteczny)** | $y_{n+1} = y_n + h\,f(t_{n+1}, y_{n+1})$ | 1 | Stabilna dla każdego $h$ (A-stabilna), tłumi numerycznie |
| **Trapezów** | $y_{n+1} = y_n + \tfrac h2[f(t_n, y_n) + f(t_{n+1}, y_{n+1})]$ | 2 | A-stabilna, domyślna w SPICE; może dawać „dzwonienie” numeryczne |
| **Runge–Kutta 4 (RK4)** | 4 wartości $f$ na krok | 4 | Dokładna dla układów niesztywnych |

**Metody niejawne** wymagają rozwiązania równania (w ogólności nieliniowego — Newton, [20.02](02-rownania-nieliniowe.md)) w każdym kroku, ale pozwalają na duży krok.

### Stabilność — równanie testowe $\dot y = \lambda y$

- Euler jawny: $y_{n+1} = (1 + h\lambda)\,y_n$ — stabilny, gdy $\lvert 1 + h\lambda\rvert \leq 1$. Dla $\lambda = -1/\tau$: **$h \leq 2\tau$**; dla $\tau < h < 2\tau$ wynik oscyluje (zanikając), czego układ fizyczny nie robi.
- Euler wsteczny: $y_{n+1} = y_n/(1 - h\lambda)$ — stabilny dla każdego $h > 0$ przy $\lambda < 0$.
- Trapezy: współczynnik $\dfrac{1 + h\lambda/2}{1 - h\lambda/2}$ — stabilny, ale dla $h \gg \tau$ dąży do $-1$ (oscylacja na granicy — źródło „dzwonienia” trapezów w SPICE po skoku; Gear/BDF tego nie robi).

### Sztywność

Układ jest **sztywny**, gdy ma stałe czasowe różniące się o rzędy wielkości (np. 1 µs i 1 ms — szybki obwód sterujący i wolne obciążenie, przetwornica z filtrem). Metoda jawna musi trzymać krok poniżej najmniejszej stałej czasowej przez cały czas symulacji, nawet gdy szybki składnik dawno zanikł. Metody niejawne (BDF/Gear, Radau, trapezy) dobierają krok do tego, co się aktualnie zmienia. **Obwody elektroniczne są prawie zawsze sztywne** — dlatego SPICE używa metod niejawnych.

### Sterowanie krokiem

Metody adaptacyjne szacują błąd lokalny (porównując dwa rzędy, np. RK45 Dormanda–Prince'a) i zmieniają krok, by trzymać go poniżej tolerancji `rtol`·|y| + `atol`. W SPICE odpowiada temu `reltol`, `abstol`, `vntol` i kontrola błędu obcięcia ładunku; parametr `maxstep` wymusza mały krok przy sygnałach, których symulator „nie widzi” (np. krótkie impulsy).

## Przykład rozwiązany

**Rozładowanie RC:** $\dot y = -y/\tau$, $\tau = 1$ ms, $y(0) = 1$, wynik w $t = 5$ ms (dokładnie $e^{-5} = 0\text{,}006738$):

| Krok | Euler jawny | Euler wsteczny | Trapezy | RK4 |
|---|---|---|---|---|
| 0,5 ms | 0,000977 | 0,01734 | 0,006047 | 0,006765 |
| 0,1 ms | 0,005154 | 0,008519 | 0,006710 | 0,006738 |
| 2,5 ms ($h > 2\tau$) | 2,25 (!) | 0,0816 | — | — |

Euler jawny z krokiem 2,5 ms daje wynik **rosnący** — rozbieżność numeryczna, nie fizyka. Euler wsteczny zawsze zanika, ale przy dużym kroku zbyt wolno. RK4 z krokiem 0,1 ms jest dokładny do 6 cyfr.

**Układ sztywny** (stałe czasowe 1 µs i 1 ms, symulacja 5 ms, ta sama tolerancja): RK45 potrzebuje ok. 10 700 wywołań funkcji, Radau — ok. 600, BDF — ok. 350.

## Typowe pułapki

- **Metoda jawna dla obwodu** — krok wymuszony przez najszybszą stałą czasową, nawet pasożytniczą (np. 1 pF z 10 Ω = 10 ps).
- **Zaufanie do oscylacji w wyniku** — mogą być artefaktem metody (Euler przy $h > \tau$, trapezy po skoku); zmniejsz krok lub zmień metodę i sprawdź, czy zostają.
- **Za duży krok maksymalny** — symulator przeskakuje krótkie zdarzenia (impuls 10 ns w symulacji 10 ms).
- **Nieciągłości w $f$** (przełączanie kluczy, PWM) — metoda wysokiego rzędu traci dokładność; adaptacyjny krok powinien się na nich zagęszczać (SPICE robi to przy punktach przełączeń źródeł).
- **Tolerancja tylko względna** przy sygnale przechodzącym przez zero — potrzebna też bezwzględna.

## Ćwiczenie komputerowe

```python
import numpy as np
from scipy.integrate import solve_ivp

tau = 1e-3
f = lambda t, y: -y/tau

def euler(h, T=5e-3):
    y = 1.0
    for _ in range(int(round(T/h))): y = y + h*f(0, y)
    return y

def backward_euler(h, T=5e-3):          # dla równania liniowego krok niejawny ma postać jawną
    y = 1.0
    for _ in range(int(round(T/h))): y = y/(1 + h/tau)
    return y

def trapezoidal(h, T=5e-3):
    y = 1.0
    for _ in range(int(round(T/h))): y = y*(1 - h/(2*tau))/(1 + h/(2*tau))
    return y

def rk4(h, T=5e-3):
    y, t = 1.0, 0.0
    for _ in range(int(round(T/h))):
        k1 = f(t, y); k2 = f(t + h/2, y + h/2*k1); k3 = f(t + h/2, y + h/2*k2); k4 = f(t + h, y + h*k3)
        y += h/6*(k1 + 2*k2 + 2*k3 + k4); t += h
    return y

print(f"dokładnie y(5 ms) = {np.exp(-5):.6f}")
for h in (0.5e-3, 0.1e-3):
    print(f"h = {h*1e3:.1f} ms: Euler {euler(h):.6f}, Euler wsteczny {backward_euler(h):.6f}, "
          f"trapezy {trapezoidal(h):.6f}, RK4 {rk4(h):.6f}")
print(f"h = 2.5 ms (h > 2τ): Euler {euler(2.5e-3):.3f}, Euler wsteczny {backward_euler(2.5e-3):.4f}")

# układ sztywny: szybki człon (1 µs) steruje wolnym (1 ms)
def stiff(t, y):
    return [-(y[0] - 1)/1e-6, -(y[1] - y[0])/1e-3]
for method in ("RK45", "Radau", "BDF"):
    sol = solve_ivp(stiff, (0, 5e-3), [0, 0], method=method, rtol=1e-6, atol=1e-9)
    print(f"{method:5s}: {sol.nfev:6d} wywołań funkcji, y2(5 ms) = {sol.y[1, -1]:.5f} (dokładnie ≈ {1 - np.exp(-5):.5f})")
```

Rozszerzenie: zasymuluj obwód RLC szeregowy ($R = 10$ Ω, $L = 1$ mH, $C = 1$ µF) pobudzony skokiem 1 V jako układ dwóch równań pierwszego rzędu (prąd cewki, napięcie kondensatora) i porównaj RK4 z rozwiązaniem analitycznym z [01 Teorii obwodów](../01-teoria-obwodow/).

## Zadania

1. Dla $\dot y = -y/\tau$ i metody Eulera jawnej przy $h = 1\text{,}5\tau$ — jak zachowuje się rozwiązanie numeryczne?
2. Obwód ma stałe czasowe 10 ns i 10 ms. Ile kroków potrzebuje Euler jawny na symulację 50 ms? Dlaczego metoda niejawna potrzebuje ich znacznie mniej?
3. Zapisz krok metody trapezów dla kondensatora $C\,\dot u = i(t)$ (to jest „model zastępczy” kondensatora w SPICE — temat 07).
4. Po skoku napięcia symulacja SPICE pokazuje drobne oscylacje „piłokształtne” na kondensatorze, których nie powinno być. Co może być przyczyną i jak to sprawdzić?
5. Zamień równanie $\ddot x + 2\zeta\omega_0\dot x + \omega_0^2x = u$ na układ równań pierwszego rzędu.

<details>
<summary>Odpowiedzi</summary>

1. Współczynnik $1 - 1\text{,}5 = -0\text{,}5$: zmiana znaku w każdym kroku (oscylacja), ale amplituda maleje 2× na krok — zanika, choć nie tak jak fizyczne rozwiązanie
2. $h \leq 2\cdot 10$ ns → co najmniej $50\ \text{ms}/20\ \text{ns} = 2\text{,}5\cdot 10^6$ kroków. Metoda niejawna jest stabilna dla dowolnego kroku, więc po zaniknięciu szybkiego członu krok może rosnąć do części wolnej stałej czasowej (setki kroków)
3. $u_{n+1} = u_n + \tfrac{h}{2C}(i_n + i_{n+1})$, czyli $i_{n+1} = \tfrac{2C}{h}u_{n+1} - \left(\tfrac{2C}{h}u_n + i_n\right)$ — przewodność $2C/h$ równolegle ze źródłem prądowym
4. Dzwonienie metody trapezów (współczynnik bliski $-1$ dla $h \gg \tau$). Sprawdzenie: zmniejszyć `maxstep` lub przełączyć metodę na Gear (`.options method=gear`) — jeśli oscylacje znikają, były numeryczne
5. $x_1 = x$, $x_2 = \dot x$: $\dot x_1 = x_2$, $\dot x_2 = -\omega_0^2x_1 - 2\zeta\omega_0x_2 + u$
</details>

## Źródła

- [MIT 18.330 Introduction to Numerical Analysis](https://ocw.mit.edu/courses/18-330-introduction-to-numerical-analysis-spring-2012/) — równania różniczkowe zwyczajne
- [SciPy — solve_ivp](https://docs.scipy.org/doc/scipy/reference/generated/scipy.integrate.solve_ivp.html) — metody RK45, Radau, BDF, LSODA
- [Steve Brunton — wykłady o całkowaniu równań różniczkowych (YouTube)](https://www.youtube.com/results?search_query=Steve+Brunton+numerical+methods+differential+equations)
- [Ngspice — dokumentacja](https://ngspice.sourceforge.io/docs.html) — opcje `method`, `maxstep`, `reltol`
