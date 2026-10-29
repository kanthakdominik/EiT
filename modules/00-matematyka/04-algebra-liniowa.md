# 00.04 — Algebra liniowa

## Po co to jest

Metoda węzłowa i oczkowa prowadzą do układu równań liniowych — w zapisie macierzowym $\mathbf{G}\mathbf{V} = \mathbf{I}$ albo $\mathbf{R}\mathbf{I} = \mathbf{E}$. Czwórniki opisuje się macierzami 2×2. W automatyce i analizie obwodów wyższego rzędu pojawia się opis w przestrzeni stanów, gdzie wartości własne macierzy to bieguny układu.

## Teoria w pigułce

- **Układ równań** $\mathbf{A}\mathbf{x} = \mathbf{b}$ ma dokładnie jedno rozwiązanie, gdy $\det\mathbf{A} \neq 0$.
- **Eliminacja Gaussa** — sprowadzanie macierzy rozszerzonej do postaci schodkowej. Najbardziej uniwersalna metoda ręczna.
- **Wzory Cramera** — wygodne dla 2×2 i 3×3: $x_i = \dfrac{\det\mathbf{A}_i}{\det\mathbf{A}}$, gdzie $\mathbf{A}_i$ to $\mathbf{A}$ z $i$-tą kolumną zastąpioną przez $\mathbf{b}$.
- **Macierz odwrotna 2×2:**

$$\begin{bmatrix} a & b \\ c & d \end{bmatrix}^{-1} = \frac{1}{ad - bc}\begin{bmatrix} d & -b \\ -c & a \end{bmatrix}$$

- **Wartości własne** $\lambda$: $\det(\mathbf{A} - \lambda\mathbf{I}) = 0$. Dla układu $\dot{\mathbf{x}} = \mathbf{A}\mathbf{x}$ rozwiązania mają postać $e^{\lambda t}$, więc wartości własne decydują o stabilności.

**Ważna obserwacja dla elektronika:** macierz konduktancji w metodzie węzłowej (bez źródeł sterowanych) jest **symetryczna**, a na przekątnej ma sumy konduktancji przyłączonych do węzła. To pozwala ją pisać „z oka”.

## Przykład rozwiązany

Rozwiąż: $3x_1 - x_2 = 4$, $-x_1 + 2x_2 = 3$.

1. $\det\mathbf{A} = 3\cdot 2 - (-1)(-1) = 5$.
2. $x_1 = \dfrac{\begin{vmatrix} 4 & -1 \\ 3 & 2 \end{vmatrix}}{5} = \dfrac{8 + 3}{5} = 2\text{,}2$.
3. $x_2 = \dfrac{\begin{vmatrix} 3 & 4 \\ -1 & 3 \end{vmatrix}}{5} = \dfrac{9 + 4}{5} = 2\text{,}6$.
4. Sprawdzenie: $3\cdot 2\text{,}2 - 2\text{,}6 = 4$ ✓, $-2\text{,}2 + 5\text{,}2 = 3$ ✓.

## Typowe pułapki

- **Błąd znaku w wyznaczniku 3×3** — przy rozwinięciu Laplace'a znaki dopełnień algebraicznych układają się w szachownicę.
- **Mnożenie macierzy nie jest przemienne:** $\mathbf{AB} \neq \mathbf{BA}$. Ma to znaczenie przy łączeniu czwórników kaskadowo.
- **Nie sprawdzasz wyniku.** Podstawienie rozwiązania do jednego z równań zajmuje 10 sekund i wyłapuje większość pomyłek.

## Symulacja / ćwiczenie komputerowe

```python
import numpy as np

A = np.array([[ 2, -1,  0],
              [-1,  3, -1],
              [ 0, -1,  2]], dtype=float)
b = np.array([1, 0, 1], dtype=float)
x = np.linalg.solve(A, b)
print(x)                          # [0.75 0.5  0.75]
print(np.linalg.eigvals(A))       # wartości własne
```

Ćwiczenie: dla dowolnego obwodu z modułu 01 zapisz macierz konduktancji, rozwiąż ją w NumPy i porównaj z punktem pracy (`.op`) w LTspice.

## Zadania

1. Oblicz $\det\begin{bmatrix} 2 & 1 & 0 \\ 1 & 3 & 1 \\ 0 & 1 & 2 \end{bmatrix}$.
2. Rozwiąż $\begin{bmatrix} 2 & -1 & 0 \\ -1 & 3 & -1 \\ 0 & -1 & 2 \end{bmatrix}\mathbf{x} = \begin{bmatrix} 1 \\ 0 \\ 1 \end{bmatrix}$ eliminacją Gaussa.
3. Wyznacz macierz odwrotną do $\begin{bmatrix} 1 & 2 \\ 3 & 4 \end{bmatrix}$.
4. Wyznacz wartości własne $\begin{bmatrix} 0 & 1 \\ -2 & -3 \end{bmatrix}$. Porównaj z równaniem charakterystycznym zadania 3 z tematu [03](03-rownania-rozniczkowe.md).
5. Zapisz równanie $\ddot{y} + 3\dot{y} + 2y = 0$ jako układ dwóch równań 1. rzędu w postaci $\dot{\mathbf{x}} = \mathbf{A}\mathbf{x}$, gdzie $\mathbf{x} = [y, \dot{y}]^T$.

<details>
<summary>Odpowiedzi</summary>

1. $2(6 - 1) - 1(2 - 0) + 0 = 8$
2. $\mathbf{x} = [0\text{,}75;\ 0\text{,}5;\ 0\text{,}75]^T$
3. $\begin{bmatrix} -2 & 1 \\ 1\text{,}5 & -0\text{,}5 \end{bmatrix}$
4. $\lambda^2 + 3\lambda + 2 = 0 \Rightarrow \lambda = -1, -2$ — te same liczby co pierwiastki równania charakterystycznego
5. $\mathbf{A} = \begin{bmatrix} 0 & 1 \\ -2 & -3 \end{bmatrix}$ — to macierz z zadania 4
</details>

## Źródła

- [MIT 18.06SC Linear Algebra (G. Strang)](https://ocw.mit.edu/courses/18-06sc-linear-algebra-fall-2011/) — wykłady, filmy z rozwiązywania zadań, zestawy z rozwiązaniami
- [3Blue1Brown](https://www.3blue1brown.com/) — seria *Essence of Linear Algebra*
- [DC Electrical Circuit Analysis — J. M. Fiore](https://eng.libretexts.org/Bookshelves/Electrical_Engineering/Electronics/DC_Electrical_Circuit_Analysis_-_A_Practical_Approach_%28Fiore%29) — dodatek o metodach rozwiązywania układów równań liniowych
