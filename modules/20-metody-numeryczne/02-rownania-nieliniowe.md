# 20.02 — Równania nieliniowe: bisekcja, Newton

## Po co to jest

Punkt pracy diody, tranzystora, przetwornicy — to rozwiązanie równania nieliniowego. Każdy symulator SPICE w analizie DC rozwiązuje metodą Newtona układ takich równań ([20.07](07-jak-dziala-spice.md)), a komunikat „Time step too small” czy „no convergence” to właśnie porażka tej metody. To samo równanie rozwiązuje się przy liczeniu temperatury termistora, częstotliwości rezonansowej czy parametru z równania przestępnego.

## Teoria w pigułce

### Bisekcja

Jeśli $f$ ciągła i $f(a)\,f(b) < 0$, pierwiastek leży w $[a, b]$. Dzielimy przedział na pół i zostawiamy połowę ze zmianą znaku.

- **Zawsze zbieżna**, liniowo: po $k$ krokach przedział ma długość $(b-a)/2^k$.
- Dokładność $10^{-12}$ przy przedziale 1 → ok. 40 kroków.

### Metoda Newtona (Newtona–Raphsona)

$$x_{k+1} = x_k - \frac{f(x_k)}{f'(x_k)}$$

- Zbieżność **kwadratowa** blisko pierwiastka — liczba poprawnych cyfr podwaja się w każdym kroku.
- Wymaga pochodnej i **dobrego punktu startowego**; może się rozbiec, oscylować lub „przestrzelić”.
- Dla układu równań: $\mathbf J(\mathbf x_k)\,\Delta\mathbf x = -\mathbf f(\mathbf x_k)$, gdzie $\mathbf J$ — macierz Jacobiego.

### Inne metody

- **Sieczne** — pochodna przybliżona różnicą dwóch ostatnich punktów (zbieżność rzędu 1,6, bez liczenia pochodnej).
- **Brent** (`scipy.optimize.brentq`) — łączy bisekcję (pewność) z interpolacją (szybkość). **Domyślny wybór** dla jednej niewiadomej z przedziałem.
- **Iteracja prosta** $x = g(x)$ — zbieżna, gdy $\lvert g'(x)\rvert < 1$ w otoczeniu pierwiastka.

### Zabezpieczenia Newtona (to robi SPICE)

- **Ograniczanie kroku** (damping): $\lvert\Delta x\rvert \leq \Delta_{max}$; dla złącz p-n — ograniczanie napięcia (w SPICE funkcja typu *pnjlim*).
- **Kontynuacja (source stepping):** rozwiązanie dla źródeł 10%, 20%, … 100% — każdy etap startuje z poprzedniego wyniku.
- **gmin stepping:** małe przewodności do masy przy każdym węźle, stopniowo usuwane.
- **Kryteria zbieżności:** zmiana napięć $< \text{reltol}\cdot\lvert V\rvert + \text{vntol}$ i bilans prądów.

## Przykład rozwiązany

**Punkt pracy diody:** źródło 5 V, rezystor 1 kΩ, dioda $I_S = 10^{-14}$ A, $n = 1$, $U_T = 25\text{,}85$ mV. Równanie prądów w węźle:

$$f(V) = \frac{V - 5}{1000} + I_S\left(e^{V/U_T} - 1\right) = 0$$

| Metoda / start | Kroki do $\lvert\Delta V\rvert < 10^{-9}$ V |
|---|---|
| Bisekcja na [0, 1] V (do $10^{-12}$) | 40 |
| Newton, start 0,7 V | 5 |
| Newton, start 0,6 V | 32 |
| Newton, start 0,6 V, krok ograniczony do 0,1 V | 6 |
| Newton, start 0 V | 173 |
| Newton, start 0 V, krok ograniczony do 0,1 V | 12 |

Wynik: $V = 0\text{,}6925$ V, $I = 4\text{,}307$ mA.

Dlaczego start z 0,6 V jest taki zły? W punkcie 0,6 V dioda przewodzi mało, styczna jest płaska i pierwszy krok „wystrzeliwuje” do 1,36 V, gdzie $e^{V/U_T}$ jest gigantyczne. Stamtąd każdy krok Newtona zmniejsza napięcie tylko o ok. $U_T$ (26 mV), bo wykładnik dominuje — potrzeba kilkudziesięciu kroków. Ograniczenie kroku usuwa problem. To dokładnie powód, dla którego SPICE ogranicza zmiany napięć na złączach.

## Typowe pułapki

- **Newton bez ograniczeń** dla funkcji wykładniczych — przepełnienie (`exp(1000)` = `inf`) lub setki iteracji.
- **Bisekcja bez sprawdzenia zmiany znaku** na końcach — „znajdzie” cokolwiek.
- **Pochodna liczona z błędem** (pomyłka w znaku) — Newton zbiega się wolno albo wcale; sprawdź ją numerycznie.
- **Kryterium stopu tylko na $\lvert f\rvert$** — przy płaskiej funkcji $\lvert f\rvert$ jest małe daleko od pierwiastka; sprawdzaj też $\lvert\Delta x\rvert$.
- **Wiele pierwiastków** (układy z histerezą, przerzutnik Schmitta, oscylator) — wynik zależy od startu; to fizyka, nie błąd.

## Ćwiczenie komputerowe

```python
import numpy as np
from scipy.optimize import brentq

Vs, R, Is, n, VT = 5.0, 1e3, 1e-14, 1.0, 0.025852
f  = lambda v: (v - Vs)/R + Is*(np.exp(v/(n*VT)) - 1)
df = lambda v: 1/R + Is/(n*VT)*np.exp(v/(n*VT))

def bisection(f, a, b, tol=1e-12):
    assert f(a)*f(b) < 0, "brak zmiany znaku"
    k = 0
    while b - a > tol:
        m = (a + b)/2
        a, b = (m, b) if f(a)*f(m) > 0 else (a, m)
        k += 1
    return (a + b)/2, k

def newton(f, df, x, max_step=None, tol=1e-9, kmax=500):
    for k in range(1, kmax + 1):
        dx = -f(x)/df(x)
        if max_step is not None:
            dx = float(np.clip(dx, -max_step, max_step))
        x += dx
        if abs(dx) < tol:
            return x, k
    raise RuntimeError("brak zbieżności")

v, k = bisection(f, 0, 1); print(f"bisekcja: V = {v:.6f} V w {k} krokach")
for v0, lim in [(0.7, None), (0.6, None), (0.6, 0.1), (0.0, None), (0.0, 0.1)]:
    v, k = newton(f, df, v0, lim)
    print(f"Newton start {v0} V, ograniczenie {lim}: V = {v:.6f} V w {k} krokach")
v = brentq(f, 0, 1); print(f"brentq: V = {v:.6f} V, I = {(Vs - v)/R*1e3:.3f} mA")
```

Rozszerzenie: dodaj rezystancję szeregową diody $R_S = 10$ Ω (równanie staje się uwikłane w prądzie) i rozwiąż je dla prądu.

## Zadania

1. Ile kroków bisekcji potrzeba, by z przedziału [0, 5] V znaleźć napięcie z dokładnością 1 µV?
2. Zapisz krok Newtona dla $f(x) = x^2 - a$ (pierwiastek kwadratowy). Wykonaj dwa kroki dla $a = 2$ od $x_0 = 1$.
3. Termistor: $R(T) = R_{25}\,e^{B(1/T - 1/298\text{,}15)}$. Dlaczego do wyznaczenia $T$ z $R$ nie trzeba metody numerycznej, a dla modelu Steinharta–Harta z członem $\ln^3 R$ też nie?
4. Dlaczego Newton dla diody startujący z bardzo dużego napięcia (np. 5 V) zachowuje się źle?
5. Jak działa „source stepping” w SPICE i kiedy pomaga?

<details>
<summary>Odpowiedzi</summary>

1. $5/2^k < 10^{-6}$ → $k = 23$ ($2^{23} \approx 8\text{,}4\cdot 10^6$)
2. $x_{k+1} = \tfrac12(x_k + a/x_k)$; $x_1 = 1\text{,}5$, $x_2 = 1\text{,}41667$ (dokładnie 1,41421)
3. W obu przypadkach wzór daje $1/T$ jawnie jako funkcję $\ln R$; numeryka jest potrzebna dopiero przy odwrotnym zadaniu w postaci uwikłanej (np. $R$ z $T$ dla Steinharta–Harta — rozwiązanie równania sześciennego) albo przy samonagrzewaniu
4. $e^{5/0\text{,}02585} \approx 10^{84}$ — prąd diody jest absurdalnie duży, a każdy krok Newtona zmniejsza napięcie tylko o ok. $U_T$; do zbieżności potrzeba 172 kroków. Przy jeszcze większym napięciu startowym (powyżej ok. 18 V) $e^{V/U_T}$ przekracza zakres `double` i wynik staje się `inf`/`nan`
5. Rozwiązuje się obwód ze źródłami przeskalowanymi do małej wartości (gdzie rozwiązanie jest łatwe, prawie liniowe), a potem zwiększa się je stopniowo, startując za każdym razem z poprzedniego wyniku — pomaga w obwodach silnie nieliniowych i ze sprzężeniem zwrotnym
</details>

## Źródła

- [MIT 18.330 Introduction to Numerical Analysis](https://ocw.mit.edu/courses/18-330-introduction-to-numerical-analysis-spring-2012/) — równania nieliniowe
- [SciPy — optimize: root finding](https://docs.scipy.org/doc/scipy/reference/optimize.html)
- [Ngspice — dokumentacja](https://ngspice.sourceforge.io/docs.html) — opcje zbieżności (`reltol`, `gmin`, `srcsteps`)
