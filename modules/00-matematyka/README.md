# 00 — Matematyka dla elektronika

> **Status:** ✅ pełny

## Cel modułu

Odbudować dokładnie tę matematykę, której potrzebuje elektronik — nie całą analizę matematyczną, tylko narzędzia, które wracają w każdym kolejnym module. Każdy temat pokazuje od razu, gdzie dane narzędzie zostanie użyte.

## Po co elektronikowi każdy temat

| Temat | Gdzie wraca |
|---|---|
| [01 Liczby zespolone](01-liczby-zespolone.md) | Fazory, impedancja, transmitancja, widmo, modulacje — **wszędzie** |
| [02 Rachunek różniczkowy i całkowy](02-rachunek-rozniczkowy-i-calkowy.md) | Prąd kondensatora i napięcie cewki, wartości średnie i skuteczne, linearyzacja (modele małosygnałowe) |
| [03 Równania różniczkowe](03-rownania-rozniczkowe.md) | Stany nieustalone RC, RL, RLC; automatyka |
| [04 Algebra liniowa](04-algebra-liniowa.md) | Metody węzłowa i oczkowa, czwórniki, przestrzeń stanów |
| [05 Szeregi Fouriera i transformata Laplace'a](05-szeregi-i-transformaty.md) | Widmo sygnałów, analiza obwodów operatorowa, sygnały i systemy |
| [06 Prawdopodobieństwo i statystyka](06-prawdopodobienstwo-i-statystyka.md) | Szumy, niepewność pomiaru, BER w telekomunikacji |
| [07 Decybele i skale logarytmiczne](07-decybele.md) | Wzmocnienie, tłumienie, wykresy Bodego, budżet łącza |
| [08 Rachunek wektorowy](08-rachunek-wektorowy.md) | Pole elektromagnetyczne, równania Maxwella |

## Kolejność i czas

Tematy 01–04 są niezbędne przed modułem [01 Teoria obwodów](../01-teoria-obwodow/). Tematy 05–08 można przerabiać równolegle z dalszymi modułami, gdy staną się potrzebne.

| Temat | Szacowany czas (od zera) | Odświeżenie |
|---|---|---|
| 01 Liczby zespolone | 10–15 h | 3–5 h |
| 02 Rachunek różniczkowy i całkowy | 25–40 h | 6–10 h |
| 03 Równania różniczkowe | 20–30 h | 5–8 h |
| 04 Algebra liniowa | 20–30 h | 5–8 h |
| 05 Szeregi i transformaty | 20–30 h | 6–10 h |
| 06 Prawdopodobieństwo i statystyka | 15–25 h | 4–6 h |
| 07 Decybele | 3–5 h | 1 h |
| 08 Rachunek wektorowy | 10–15 h | 3–5 h |

## Test wejściowy (diagnoza)

Rozwiąż bez notatek, około 60 minut. Wynik pokaże, które tematy wystarczy przejrzeć, a które przerobić w całości.

1. Zapisz $z = -1 + j\sqrt{3}$ w postaci wykładniczej.
2. Oblicz $\dfrac{10\angle 30^\circ}{2\angle -60^\circ}$.
3. Oblicz pochodną $f(t) = e^{-2t}\sin(5t)$.
4. Oblicz wartość skuteczną przebiegu $u(t) = 4\sin(\omega t)$.
5. Rozwiąż $\dot{y} + 10y = 20$, $y(0) = 0$.
6. Rozwiąż układ: $2x + y = 5$, $x - y = 1$.
7. Wyznacz $\mathcal{L}\{e^{-3t}\}$ i $\mathcal{L}^{-1}\left\{\dfrac{1}{s(s+1)}\right\}$.
8. Wzmacniacz ma wzmocnienie napięciowe 1000 V/V. Ile to dB?

<details>
<summary>Odpowiedzi</summary>

1. $z = 2e^{j\,2\pi/3}$ (moduł 2, argument 120°)
2. $5\angle 90^\circ = j5$
3. $f'(t) = e^{-2t}\left(5\cos 5t - 2\sin 5t\right)$
4. $U_{RMS} = 4/\sqrt{2} \approx 2\text{,}83$
5. $y(t) = 2\left(1 - e^{-10t}\right)$
6. $x = 2$, $y = 1$
7. $\dfrac{1}{s+3}$ oraz $1 - e^{-t}$
8. 60 dB

**Ocena:** 7–8 poprawnych — przejrzyj tylko pułapki i zadania w każdym temacie. 4–6 — przerób tematy, w których był błąd. Mniej niż 4 — przerób moduł w całości.
</details>

## Sprawdzian końcowy modułu

Moduł uznaj za zaliczony, gdy bez notatek:

- [ ] przeliczasz liczby zespolone między postaciami i wykonujesz na nich działania w pamięci dla prostych kątów,
- [ ] rozwiązujesz równanie różniczkowe 1. i 2. rzędu ze stałymi współczynnikami i warunkami początkowymi,
- [ ] rozwiązujesz układ 3 równań liniowych metodą eliminacji i sprawdzasz wynik w Pythonie,
- [ ] wyznaczasz transformatę odwrotną Laplace'a przez rozkład na ułamki proste,
- [ ] przeliczasz wzmocnienia i poziomy sygnałów na dB i odwrotnie.

## Narzędzia do sprawdzania wyników

```python
import numpy as np
import sympy as sp

# liczby zespolone
z = (3 + 4j) * (1 - 1j) / (2 + 1j)
print(abs(z), np.degrees(np.angle(z)))

# równanie różniczkowe
t = sp.symbols('t')
y = sp.Function('y')
print(sp.dsolve(y(t).diff(t) + 10*y(t) - 20, ics={y(0): 0}))

# transformata Laplace'a
s = sp.symbols('s')
print(sp.inverse_laplace_transform(1/(s*(s+1)), s, t))
```
