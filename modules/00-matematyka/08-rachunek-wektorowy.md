# 00.08 — Rachunek wektorowy

## Po co to jest

Równania Maxwella zapisuje się za pomocą operatorów gradientu, dywergencji i rotacji. Bez nich moduł [11 Pole EM, linie, anteny](../11-pole-em-linie-anteny/) jest niezrozumiały. Ten temat można odłożyć do czasu, gdy zaczniesz moduł 02 lub 11.

## Teoria w pigułce

Operator nabla w układzie kartezjańskim: $\nabla = \left(\dfrac{\partial}{\partial x}, \dfrac{\partial}{\partial y}, \dfrac{\partial}{\partial z}\right)$.

| Operator | Działa na | Wynik | Sens fizyczny | Gdzie w EM |
|---|---|---|---|---|
| Gradient $\nabla V$ | pole skalarne | wektor | Kierunek i szybkość najszybszego wzrostu | $\mathbf{E} = -\nabla V$ |
| Dywergencja $\nabla\cdot\mathbf{A}$ | pole wektorowe | skalar | „Źródłowość” — ile pola wypływa z punktu | $\nabla\cdot\mathbf{D} = \rho$ |
| Rotacja $\nabla\times\mathbf{A}$ | pole wektorowe | wektor | „Wirowość” — krążenie pola wokół punktu | $\nabla\times\mathbf{E} = -\partial\mathbf{B}/\partial t$ |
| Laplasjan $\nabla^2 V$ | pole skalarne | skalar | Różnica między wartością w punkcie a średnią wokół | Równanie Poissona, równanie falowe |

**Twierdzenia całkowe** — most między postacią różniczkową i całkową równań Maxwella:

- **Gaussa (Ostrogradskiego):** $\oint_S \mathbf{A}\cdot d\mathbf{S} = \int_V \nabla\cdot\mathbf{A}\,dV$ — strumień przez zamkniętą powierzchnię równa się sumie źródeł wewnątrz.
- **Stokesa:** $\oint_L \mathbf{A}\cdot d\mathbf{l} = \int_S (\nabla\times\mathbf{A})\cdot d\mathbf{S}$ — cyrkulacja po konturze równa się strumieniowi rotacji przez powierzchnię rozpiętą na konturze.

Inne układy współrzędnych (cylindryczny, sferyczny) są wygodne dla przewodów, kabli koncentrycznych i anten — wzory na operatory w tych układach warto mieć w ściądze, nie w pamięci.

## Przykład rozwiązany

Potencjał $V(x, y, z) = x^2 y$. Wyznacz pole elektryczne w punkcie $(1, 2, 0)$.

1. $\nabla V = (2xy,\ x^2,\ 0)$.
2. $\mathbf{E} = -\nabla V = (-2xy,\ -x^2,\ 0)$.
3. W punkcie $(1, 2, 0)$: $\mathbf{E} = (-4,\ -1,\ 0)$ V/m.

## Typowe pułapki

- **Gradient pola wektorowego** albo **dywergencja pola skalarnego** — takie działania nie mają sensu w tym kontekście.
- **Wzory kartezjańskie w układzie cylindrycznym.** Operatory w innych układach mają dodatkowe współczynniki.
- **Kierunek normalnej** w twierdzeniu Gaussa (na zewnątrz) i orientacja konturu w twierdzeniu Stokesa (reguła prawej dłoni).

## Ćwiczenie komputerowe

```python
import sympy as sp
from sympy.vector import CoordSys3D, gradient, divergence, curl

N = CoordSys3D('N')
x, y, z = N.x, N.y, N.z
print(gradient(x**2 * y))
print(divergence(x*N.i + y*N.j + z*N.k))
print(curl(-y*N.i + x*N.j))
```

## Zadania

1. Wyznacz $\nabla V$ dla $V = x^2 y$.
2. Oblicz $\nabla\cdot\mathbf{A}$ dla $\mathbf{A} = (x, y, z)$.
3. Oblicz $\nabla\times\mathbf{A}$ dla $\mathbf{A} = (-y, x, 0)$. Jak wygląda to pole?
4. Pole $\mathbf{A} = (x, y, z)$. Oblicz strumień przez sferę o promieniu $R$ wprost i z twierdzenia Gaussa.
5. Wyjaśnij słownie, dlaczego pole elektrostatyczne ma rotację równą zeru.

<details>
<summary>Odpowiedzi</summary>

1. $(2xy,\ x^2,\ 0)$
2. $3$
3. $(0,\ 0,\ 2)$ — pole wirujące wokół osi $z$, o stałej wirowości
4. Na sferze $\mathbf{A}\cdot\hat{\mathbf{n}} = R$, więc strumień $= R\cdot 4\pi R^2 = 4\pi R^3$. Z Gaussa: $\int 3\,dV = 3\cdot\frac{4}{3}\pi R^3 = 4\pi R^3$ ✓
5. Pole elektrostatyczne jest potencjalne ($\mathbf{E} = -\nabla V$), a rotacja gradientu jest zawsze zerowa. Fizycznie: praca po zamkniętej drodze jest zerowa, więc napięcie zależy tylko od punktów końcowych (to jest prawo napięciowe Kirchhoffa).
</details>

## Źródła

- [Electromagnetics, Vol. 1 — Ellingson](https://doi.org/10.21061/electromagnetics-vol-1) — rozdział wstępny o wektorach i układach współrzędnych, dodatek z wzorami
- [MIT 8.02 Physics II: Electricity and Magnetism](https://ocw.mit.edu/courses/8-02-physics-ii-electricity-and-magnetism-spring-2007/) — podręcznik kursu z zastosowaniami
