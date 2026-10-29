# 01.09 — Czwórniki

## Po co to jest

Czwórnik to „czarna skrzynka” z wejściem i wyjściem. Tak opisuje się wzmacniacze, filtry, linie transmisyjne, tranzystory (parametry $h$) i elementy w.cz. (parametry S). Łączenie czwórników kaskadowo sprowadza się do mnożenia macierzy.

## Teoria w pigułce

Zaciski wejściowe 1–1′ ($U_1$, $I_1$ wpływający), wyjściowe 2–2′ ($U_2$, $I_2$ wpływający — konwencja symetryczna; w macierzy łańcuchowej często przyjmuje się prąd **wypływający** z wyjścia, co zmienia znaki, więc zawsze sprawdzaj konwencję źródła).

| Parametry | Równania | Zastosowanie |
|---|---|---|
| **Z** (impedancyjne) | $\begin{bmatrix} U_1 \\ U_2 \end{bmatrix} = \mathbf{Z}\begin{bmatrix} I_1 \\ I_2 \end{bmatrix}$ | Łączenie szeregowe czwórników |
| **Y** (admitancyjne) | $\begin{bmatrix} I_1 \\ I_2 \end{bmatrix} = \mathbf{Y}\begin{bmatrix} U_1 \\ U_2 \end{bmatrix}$ | Łączenie równoległe, układy z FET |
| **H** (hybrydowe) | $\begin{bmatrix} U_1 \\ I_2 \end{bmatrix} = \mathbf{H}\begin{bmatrix} I_1 \\ U_2 \end{bmatrix}$ | Tranzystor bipolarny ($h_{ie}$, $h_{fe}$, …) |
| **A** (łańcuchowe, ABCD) | $\begin{bmatrix} U_1 \\ I_1 \end{bmatrix} = \begin{bmatrix} A & B \\ C & D \end{bmatrix}\begin{bmatrix} U_2 \\ I_2' \end{bmatrix}$, $I_2'$ wypływa | **Łączenie kaskadowe** — mnożenie macierzy |

### Elementarne macierze ABCD

- Impedancja szeregowa $Z$: $\begin{bmatrix} 1 & Z \\ 0 & 1 \end{bmatrix}$
- Admitancja równoległa $Y$: $\begin{bmatrix} 1 & 0 \\ Y & 1 \end{bmatrix}$
- Transformator idealny $n:1$: $\begin{bmatrix} n & 0 \\ 0 & 1/n \end{bmatrix}$

### Przydatne wielkości z ABCD

- Wzmocnienie napięciowe w stanie jałowym: $\dfrac{U_2}{U_1} = \dfrac{1}{A}$
- Impedancja wejściowa przy obciążeniu $Z_L$: $Z_{we} = \dfrac{AZ_L + B}{CZ_L + D}$
- Czwórnik odwracalny (pasywny, z elementów R, L, C, M): $AD - BC = 1$; dla parametrów Z: $z_{12} = z_{21}$
- Czwórnik symetryczny: $A = D$

## Przykład rozwiązany

Ogniwo Γ: szeregowy $R_1 = 1$ kΩ, potem równoległy $R_2 = 1$ kΩ.

1. $\mathbf{A} = \begin{bmatrix} 1 & R_1 \\ 0 & 1 \end{bmatrix}\begin{bmatrix} 1 & 0 \\ 1/R_2 & 1 \end{bmatrix} = \begin{bmatrix} 1 + R_1/R_2 & R_1 \\ 1/R_2 & 1 \end{bmatrix} = \begin{bmatrix} 2 & 1\ \text{k}\Omega \\ 1\ \text{mS} & 1 \end{bmatrix}$
2. Wzmocnienie jałowe: $1/A = 0\text{,}5$ — zgodne z dzielnikiem.
3. Impedancja wejściowa z obciążeniem $R_L = 1$ kΩ: $\dfrac{2\cdot 1\text{k} + 1\text{k}}{10^{-3}\cdot 1\text{k} + 1} = 1\text{,}5$ kΩ — zgodne z $R_1 + R_2\parallel R_L$.
4. Odwracalność: $AD - BC = 2 - 1 = 1$ ✓.

## Typowe pułapki

- **Konwencja zwrotu prądu wyjściowego** różna w różnych źródłach — prowadzi do błędów znaku.
- **Mnożenie macierzy kaskady w złej kolejności** — kolejność musi odpowiadać kolejności czwórników od wejścia do wyjścia.
- **Parametry wyznaczane przy złym warunku** — np. $z_{11}$ wymaga rozwarcia wyjścia ($I_2 = 0$), $y_{11}$ — zwarcia ($U_2 = 0$).

## Ćwiczenie komputerowe

```python
import numpy as np
series = lambda Z: np.array([[1, Z], [0, 1]], dtype=complex)
shunt  = lambda Y: np.array([[1, 0], [Y, 1]], dtype=complex)

G = series(1e3) @ shunt(1e-3)
K = G @ G                          # dwa ogniwa kaskadowo
A, B, C, D = K.ravel()
print(K.real, "AD-BC =", (A*D - B*C).real)
ZL = 1e3
print("Zwe =", ((A*ZL + B)/(C*ZL + D)).real)
```

Ćwiczenie: zbuduj w ten sposób filtr drabinkowy LC 3. rzędu i porównaj jego charakterystykę z analizą `.ac` w LTspice.

## Zadania

1. Czwórnik typu T: ramiona szeregowe $Z_1 = Z_2 = 100\ \Omega$, gałąź poprzeczna $Z_3 = 200\ \Omega$. Wyznacz parametry Z.
2. Wyznacz macierz ABCD kaskady dwóch ogniw Γ z przykładu rozwiązanego. Ile wynosi wzmocnienie jałowe?
3. Wyznacz impedancję wejściową kaskady z zadania 2 przy rozwartym wyjściu. Sprawdź wynik, licząc rezystancję zastępczą drabinki.
4. Tranzystor ma $h_{ie} = 2\text{,}5$ kΩ, $h_{fe} = 100$, a $h_{re}$ i $h_{oe}$ są pomijalne. Jakie jest wzmocnienie napięciowe przy obciążeniu 2 kΩ w układzie wspólnego emitera?
5. Sprawdź warunek odwracalności dla macierzy z zadania 2.

<details>
<summary>Odpowiedzi</summary>

1. $z_{11} = Z_1 + Z_3 = 300\ \Omega$, $z_{12} = z_{21} = Z_3 = 200\ \Omega$, $z_{22} = Z_2 + Z_3 = 300\ \Omega$
2. $\begin{bmatrix} 5 & 3\ \text{k}\Omega \\ 3\ \text{mS} & 2 \end{bmatrix}$; wzmocnienie jałowe $1/5 = 0\text{,}2$
3. $A/C = 5/3\ \text{mS} \approx 1\text{,}667$ kΩ; drabinka: $1\text{k} + 1\text{k}\parallel(1\text{k} + 1\text{k}) = 1\text{,}667$ kΩ ✓
4. $K_u \approx -\dfrac{h_{fe}R_L}{h_{ie}} = -\dfrac{100\cdot 2\text{k}}{2\text{,}5\text{k}} = -80$
5. $5\cdot 2 - 3\text{k}\cdot 3\text{m} = 10 - 9 = 1$ ✓
</details>

## Źródła

- [Neso Academy — Network Theory](https://www.classcentral.com/classroom/youtube-network-theory-48208) — seria o czwórnikach (two-port networks)
- [MIT 6.002 Circuits and Electronics](https://ocw.mit.edu/courses/6-002-circuits-and-electronics-spring-2007/) — modele małosygnałowe wzmacniaczy jako czwórniki
- [Semiconductor Devices — J. M. Fiore](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html) — modele tranzystora (zastosowanie parametrów $h$)
