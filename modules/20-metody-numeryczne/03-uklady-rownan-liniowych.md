# 20.03 — Układy równań liniowych

## Po co to jest

Analiza węzłowa obwodu to układ równań $\mathbf A\mathbf x = \mathbf b$ ([01 Teoria obwodów](../01-teoria-obwodow/)). Symulator rozwiązuje go w każdej iteracji Newtona i w każdym kroku czasowym — miliony razy na jedną symulację. Te same układy pojawiają się w dopasowaniu metodą najmniejszych kwadratów (temat 04), metodach pola (FDTD, MoM) i w regulacji (przestrzeń stanów). Trzeba wiedzieć, jak się je rozwiązuje, ile to kosztuje i kiedy wynikowi nie można ufać.

## Teoria w pigułce

### Eliminacja Gaussa i rozkład LU

- Eliminacja sprowadza macierz do trójkątnej górnej, potem podstawianie wsteczne. Koszt ok. $\tfrac23 n^3$ operacji.
- **Rozkład LU:** $\mathbf A = \mathbf L\mathbf U$ (z permutacją wierszy $\mathbf P$). Raz rozłożona macierz pozwala rozwiązać układ dla wielu prawych stron kosztem $O(n^2)$ każda — np. ten sam obwód przy różnych pobudzeniach.
- **Częściowy wybór elementu głównego (pivoting):** zamiana wierszy tak, by dzielić przez największy element w kolumnie — bez tego algorytm jest niestabilny (dzielenie przez mały element wzmacnia błędy).
- **Nigdy nie licz $\mathbf A^{-1}$**, żeby rozwiązać układ — wolniej i mniej dokładnie; używaj `np.linalg.solve` / `scipy.linalg.lu_factor` + `lu_solve`.

### Inne rozkłady

| Rozkład | Kiedy |
|---|---|
| Cholesky $\mathbf A = \mathbf L\mathbf L^T$ | Macierz symetryczna dodatnio określona (np. obwód RC bez źródeł sterowanych) — 2× szybciej |
| QR | Najmniejsze kwadraty (stabilniej niż równania normalne) |
| SVD | Macierze bliskie osobliwym, rząd, pseudoodwrotność |

### Macierze rzadkie i metody iteracyjne

Macierz obwodu z 10 000 węzłów ma $10^8$ elementów, ale tylko kilka niezerowych w wierszu (węzeł łączy się z kilkoma sąsiadami). Symulatory używają **rozkładu LU dla macierzy rzadkich** z porządkowaniem minimalizującym wypełnienie (SPICE: biblioteka Sparse/KLU). Dla bardzo dużych układów (siatki pola, PDN płytki) — **metody iteracyjne**: Jacobi, Gauss–Seidel, gradienty sprzężone (CG), GMRES.

### Uwarunkowanie

$$\kappa(\mathbf A) = \lVert\mathbf A\rVert\,\lVert\mathbf A^{-1}\rVert, \qquad \frac{\lVert\delta\mathbf x\rVert}{\lVert\mathbf x\rVert} \lesssim \kappa(\mathbf A)\,\frac{\lVert\delta\mathbf b\rVert}{\lVert\mathbf b\rVert}$$

- Tracisz ok. $\log_{10}\kappa$ cyfr znaczących z ok. 16 dostępnych w `double`.
- Przykłady: macierz Hilberta $10\times 10$ — $\kappa \approx 1\text{,}6\cdot 10^{13}$ (zostają ok. 3 cyfry); obwód z rezystorami 1 mΩ i 1 MΩ w jednym węźle — $\kappa \approx 5\cdot 10^8$.
- Dlatego SPICE ma problemy z obwodami o skrajnie różnych impedancjach (np. bocznik 1 mΩ i wejście 1 GΩ).

## Przykład rozwiązany

**Analiza węzłowa ze źródłem napięcia (MNA).** Źródło $U_1 = 10$ V w węźle 1; $R_1 = 1$ kΩ (węzły 1–2), $R_2 = 2$ kΩ (2–masa), $R_3 = 1$ kΩ (2–3), $R_4 = 3$ kΩ (3–masa); źródło prądowe 2 mA wpływające do węzła 3.

Niewiadome: $V_1, V_2, V_3$ i prąd źródła napięcia $I_U$ (zmodyfikowana analiza węzłowa — MNA, [20.07](07-jak-dziala-spice.md)). Przewodności w mS:

$$\begin{bmatrix} 1 & -1 & 0 & 1 \\ -1 & 1 + 0\text{,}5 + 1 & -1 & 0 \\ 0 & -1 & 1 + 0\text{,}333 & 0 \\ 1 & 0 & 0 & 0 \end{bmatrix}\begin{bmatrix} V_1 \\ V_2 \\ V_3 \\ I_U \end{bmatrix} = \begin{bmatrix} 0 \\ 0 \\ 2 \\ 10 \end{bmatrix}$$

(prądy w mA, napięcia w V, przewodności w mS). Ostatni wiersz to równanie źródła $V_1 = 10$, ostatnia kolumna — prąd źródła w bilansie węzła 1.

Wynik: $V_2 = 6\text{,}571$ V, $V_3 = 6\text{,}429$ V, $I_U = -3\text{,}429$ mA (znak: prąd płynie ze źródła do obwodu — źródło oddaje 3,43 mA). Kontrola: prąd przez $R_1$: $(10 - 6\text{,}571)/1 = 3\text{,}429$ mA ✓.

Uwaga: macierz MNA ma **zero na przekątnej** (wiersz źródła) — eliminacja bez wyboru elementu głównego dzieliłaby przez zero; z pivotingiem działa bez problemu.

## Typowe pułapki

- **Odwracanie macierzy** zamiast rozwiązywania układu.
- **Gauss bez wyboru elementu głównego** — dzielenie przez zero lub przez bardzo małą liczbę.
- **Ignorowanie uwarunkowania** — wynik „wygląda dokładnie” (16 cyfr), ale tylko kilka pierwszych jest prawdziwych.
- **Macierz osobliwa w obwodzie** — węzeł „pływający” (bez ścieżki DC do masy, np. za kondensatorem szeregowym) albo pętla źródeł napięcia; SPICE zgłasza „singular matrix”.
- **Pełna macierz dla dużego problemu rzadkiego** — pamięć $O(n^2)$, czas $O(n^3)$; użyj `scipy.sparse`.

## Ćwiczenie komputerowe

Własny rozkład LU z częściowym wyborem elementu głównego i porównanie z numpy:

```python
import numpy as np

def lu_solve_pivot(A, b):
    A = A.astype(float).copy(); b = b.astype(float).copy(); n = len(b)
    for k in range(n - 1):
        p = k + np.argmax(np.abs(A[k:, k]))          # wybór elementu głównego
        if A[p, k] == 0:
            raise ValueError("macierz osobliwa")
        A[[k, p]], b[[k, p]] = A[[p, k]], b[[p, k]]  # zamiana wierszy
        for i in range(k + 1, n):
            m = A[i, k]/A[k, k]
            A[i, k:] -= m*A[k, k:]
            b[i] -= m*b[k]
    x = np.zeros(n)
    for i in range(n - 1, -1, -1):                    # podstawianie wsteczne
        x[i] = (b[i] - A[i, i+1:] @ x[i+1:])/A[i, i]
    return x

G = lambda r: 1/r
R1, R2, R3, R4, I1 = 1e3, 2e3, 1e3, 3e3, 2e-3
A = np.array([[ G(R1), -G(R1),               0,             1],
              [-G(R1),  G(R1)+G(R2)+G(R3), -G(R3),          0],
              [ 0,     -G(R3),              G(R3)+G(R4),    0],
              [ 1,      0,                  0,              0]])
b = np.array([0, 0, I1, 10])
print("własne LU:", lu_solve_pivot(A, b))
print("numpy:    ", np.linalg.solve(A, b))
print(f"kappa(A) = {np.linalg.cond(A):.0f}")

# uwarunkowanie: macierz Hilberta
from scipy.linalg import hilbert
for n in (5, 10, 12):
    H = hilbert(n); x_true = np.ones(n)
    x = np.linalg.solve(H, H @ x_true)
    print(f"Hilbert {n:2d}: kappa = {np.linalg.cond(H):.1e}, błąd rozwiązania = {np.max(np.abs(x - x_true)):.1e}")
```

## Zadania

1. Ile razy dłużej trwa rozwiązanie układu 2000 × 2000 niż 1000 × 1000 metodą Gaussa?
2. Obwód z 5 węzłami (bez masy) i 2 źródłami napięcia. Jaki rozmiar ma macierz MNA?
3. Dlaczego kondensator szeregowy w obwodzie może dać „singular matrix” w analizie DC, a w analizie AC — nie?
4. $\kappa(\mathbf A) = 10^{10}$. Ile cyfr znaczących rozwiązania możesz uznać za wiarygodne w `double`?
5. Ten sam obwód trzeba policzyć dla 1000 różnych wartości źródeł (bez zmiany elementów). Jak to zrobić tanio?

<details>
<summary>Odpowiedzi</summary>

1. Ok. 8 razy ($n^3$)
2. $5 + 2 = 7$ — po jednej niewiadomej na węzeł i na prąd każdego źródła napięcia
3. W DC kondensator to przerwa; węzeł połączony z resztą obwodu tylko przez kondensator nie ma ścieżki DC do masy i jego napięcie jest nieokreślone (wiersz zerowy). W AC kondensator ma skończoną admitancję $j\omega C$. SPICE dodaje w takich miejscach $g_{min}$ lub trzeba dodać duży rezystor do masy
4. Ok. $16 - 10 = 6$ cyfr
5. Jeden rozkład LU ($O(n^3)$), potem 1000 tanich podstawień ($O(n^2)$ każde) — `lu_factor` / `lu_solve`; macierz nie zależy od wartości źródeł
</details>

## Źródła

- [MIT 18.335J Introduction to Numerical Methods](https://ocw.mit.edu/courses/18-335j-introduction-to-numerical-methods-spring-2019/) — LU, QR, uwarunkowanie, stabilność
- [MIT 18.06 Linear Algebra (G. Strang)](https://ocw.mit.edu/courses/18-06-linear-algebra-spring-2010/) — eliminacja i rozkłady
- [SciPy — linalg i sparse](https://docs.scipy.org/doc/scipy/tutorial/index.html)
