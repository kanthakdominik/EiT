# 05.02 — Algebra Boole'a i minimalizacja

## Po co to jest

Algebra Boole'a pozwala opisać i uprościć logikę, zanim się ją zbuduje. Mniej bramek to mniejsze opóźnienie, pobór mocy i koszt. W FPGA minimalizację robi syntezator, ale żeby czytać raporty i pisać dobry kod HDL, trzeba rozumieć, co on robi.

## Teoria w pigułce

### Podstawowe prawa

| Prawo | Postać |
|---|---|
| Tożsamości | $A + 0 = A$, $A\cdot 1 = A$, $A + 1 = 1$, $A\cdot 0 = 0$ |
| Idempotentność | $A + A = A$, $A\cdot A = A$ |
| Dopełnienie | $A + \overline{A} = 1$, $A\cdot\overline{A} = 0$ |
| Pochłanianie | $A + AB = A$, $A(A + B) = A$ |
| Uproszczenie | $A + \overline{A}B = A + B$ |
| **De Morgana** | $\overline{A + B} = \overline{A}\cdot\overline{B}$, $\overline{AB} = \overline{A} + \overline{B}$ |
| Konsensus | $AB + \overline{A}C + BC = AB + \overline{A}C$ |

Bramki **NAND** i **NOR** są funkcjonalnie pełne — z samych NAND-ów zbuduje się dowolną funkcję. W CMOS NAND i NOR są „naturalne” (jedna warstwa tranzystorów), AND i OR wymagają dodatkowego inwertera.

### Postacie kanoniczne

- **Suma iloczynów (SOP)**, suma mintermów: $f = \sum m(\dots)$ — każdy minterm to iloczyn wszystkich zmiennych dla jednej jedynki w tablicy prawdy.
- **Iloczyn sum (POS)**, iloczyn makstermów: $f = \prod M(\dots)$ — dla zer.

Realizacja: SOP → dwa poziomy NAND–NAND, POS → NOR–NOR.

### Tablice Karnaugha

Komórki ułożone w kodzie Graya, więc sąsiednie (także „przez krawędź”) różnią się jedną zmienną. Łączymy jedynki w prostokątne grupy o rozmiarze $2^k$, jak największe i jak najmniej liczne. Każda grupa to iloczyn zmiennych, które się w niej nie zmieniają. **Wartości nieokreślone (X, don't care)** można dołączać do grup, jeśli to pomaga.

Dla więcej niż 5–6 zmiennych — metoda Quine'a–McCluskeya lub algorytmy heurystyczne (Espresso) w narzędziach.

### Hazardy

Przy przejściu między grupami, które się nie stykają, różne czasy propagacji mogą wywołać krótką szpilkę (**hazard statyczny**). Usuwa się go, dodając grupę nadmiarową (składnik konsensusu). W układach synchronicznych hazardy kombinacyjne zwykle nie przeszkadzają, bo stan próbkuje się dopiero przy zboczu zegara — ale **nigdy nie używaj wyjścia logiki kombinacyjnej jako zegara ani asynchronicznego resetu**.

## Przykład rozwiązany

$f(A, B, C, D) = \sum m(0, 2, 5, 7, 8, 10, 13, 15)$.

Tablica (wiersze $AB$, kolumny $CD$, oba w kodzie Graya 00, 01, 11, 10):

| $AB \backslash CD$ | 00 | 01 | 11 | 10 |
|---|---|---|---|---|
| 00 | 1 | 0 | 0 | 1 |
| 01 | 0 | 1 | 1 | 0 |
| 11 | 0 | 1 | 1 | 0 |
| 10 | 1 | 0 | 0 | 1 |

1. Cztery narożniki (m0, m2, m8, m10) tworzą grupę: $B = 0$, $D = 0$ → $\overline{B}\,\overline{D}$.
2. Środkowy kwadrat (m5, m7, m13, m15): $B = 1$, $D = 1$ → $BD$.
3. $f = \overline{B}\,\overline{D} + BD = \overline{B \oplus D}$ — jedna bramka XNOR zamiast ośmiu mintermów.

## Typowe pułapki

- **Kolejność 00, 01, 10, 11** zamiast 00, 01, 11, 10 na osiach tablicy.
- **Pominięte sąsiedztwo przez krawędź** (narożniki tablicy są sąsiadami).
- **Grupy o rozmiarze 3 lub 6** — dozwolone są tylko potęgi dwójki.
- **De Morgan zastosowany do jednego składnika** zamiast do całego wyrażenia pod negacją.

## Ćwiczenie komputerowe

Zbuduj w [Digital](https://github.com/hneemann/Digital) funkcję z przykładu: wpisz tablicę prawdy, wygeneruj automatycznie zminimalizowane wyrażenie i porównaj z ręcznym wynikiem. W Pythonie:

```python
from itertools import product
f = lambda A,B,C,D: (not B and not D) or (B and D)
print([i for i,(A,B,C,D) in enumerate(product([0,1],repeat=4)) if f(A,B,C,D)])
```

## Zadania

1. Uprość: $AB + A\overline{B} + \overline{A}B$.
2. Udowodnij prawo $A + \overline{A}B = A + B$.
3. Zminimalizuj $f = \sum m(1, 3, 5, 7, 9, 11, 13, 15)$.
4. Zminimalizuj $f = \sum m(0, 1, 2, 3, 4, 6, 8, 9, 10, 11, 12, 14)$.
5. Zminimalizuj $f = \sum m(1, 3, 7, 11, 15) + d(0, 2, 5)$ ($d$ — wartości nieokreślone).
6. Zrealizuj $f = AB + CD$ wyłącznie na bramkach NAND.

<details>
<summary>Odpowiedzi</summary>

1. $A + B$
2. $A + \overline{A}B = (A + \overline{A})(A + B) = A + B$ (rozdzielność dodawania względem mnożenia)
3. $f = D$
4. $f = \overline{B} + \overline{D}$
5. $f = \overline{A}\,\overline{B} + CD$ (grupa $\overline{A}\,\overline{B}$ z m0, m1, m2, m3 z użyciem d0, d2; grupa $CD$ z m3, m7, m11, m15)
6. $f = \overline{\overline{AB}\cdot\overline{CD}}$ — dwie bramki NAND na wejściu i jedna NAND na wyjściu
</details>

## Źródła

- [All About Circuits — tom Digital, rozdziały *Boolean Algebra* i *Karnaugh Mapping*](https://www.allaboutcircuits.com/textbook/)
- [MIT 6.004 Computation Structures](https://ocw.mit.edu/courses/6-004-computation-structures-spring-2017/) — logika kombinacyjna i jej synteza
- [nand2tetris](https://www.nand2tetris.org/) — projekt 1: budowa wszystkich bramek z NAND
