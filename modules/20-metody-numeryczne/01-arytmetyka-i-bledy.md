# 20.01 — Arytmetyka zmiennoprzecinkowa i błędy

## Po co to jest

Komputer nie liczy na liczbach rzeczywistych, tylko na skończonym zbiorze liczb zmiennoprzecinkowych. Zwykle tego nie widać — dopóki filtr IIR na `float` nie zacznie się wzbudzać ([07.06](../07-cps-dsp/06-realizacja-filtrow.md)), suma milionów próbek nie odpłynie albo wzór podręcznikowy nie zwróci zera tam, gdzie wynik wynosi 0,5. Ten temat uczy rozpoznawać takie sytuacje i przepisywać obliczenia tak, by były stabilne.

## Teoria w pigułce

### Format IEEE 754

Liczba = znak · mantysa · $2^{\text{wykładnik}}$.

| Format | Bity (znak / wykładnik / mantysa) | Cyfry dziesiętne | Epsilon maszynowy $\varepsilon$ | Zakres |
|---|---|---|---|---|
| `float` (single) | 1 / 8 / 23 | ~7 | $1\text{,}19\cdot 10^{-7}$ | $\sim 10^{\pm 38}$ |
| `double` | 1 / 11 / 52 | ~16 | $2\text{,}22\cdot 10^{-16}$ | $\sim 10^{\pm 308}$ |

- **Epsilon maszynowy** — odstęp między 1 a następną liczbą; błąd względny zaokrąglenia pojedynczej operacji ≤ $\varepsilon/2$.
- Wartości specjalne: `inf`, `-inf`, `nan` (np. $0/0$), zero ze znakiem, liczby zdenormalizowane (bardzo małe, wolne na niektórych procesorach).
- Liczby całkowite do $2^{53}$ są w `double` dokładne; ułamki dziesiętne (0,1) — **nie**.

### Źródła błędów

| Błąd | Przykład |
|---|---|
| **Zaokrąglenia** | 0,1 + 0,2 = 0,30000000000000004 |
| **Utrata cyfr znaczących (cancellation)** | Odejmowanie bliskich liczb: $1 - \cos x$ dla małego $x$ |
| **Pochłanianie (absorpcja)** | Dodanie małej liczby do dużej: $10^{16} + 1 = 10^{16}$ |
| **Kumulacja** | Suma milionów składników w `float` |
| **Przepełnienie / niedomiar** | $e^{1000}$ = `inf`; iloczyn wielu prawdopodobieństw → 0 (licz logarytmy) |
| **Obcięcia (metody)** | Zastąpienie pochodnej różnicą, całki — sumą (tematy 05–06) |

### Uwarunkowanie i stabilność

- **Uwarunkowanie zadania** — jak bardzo wynik zmienia się przy małej zmianie danych (cecha problemu, nie algorytmu). Wskaźnik $\kappa \approx \left|\dfrac{x f'(x)}{f(x)}\right|$; dla układów równań $\kappa(A)$ ([20.03](03-uklady-rownan-liniowych.md)). Utrata cyfr ≈ $\log_{10}\kappa$.
- **Stabilność algorytmu** — czy algorytm nie wzmacnia błędów zaokrągleń ponad to, co wynika z uwarunkowania.
- Ten sam problem można liczyć algorytmem stabilnym lub niestabilnym — przykład niżej.

## Przykład rozwiązany

**Pierwiastki $x^2 - 10^8 x + 1 = 0$.** Dokładnie: $x_1 \approx 10^8$, $x_2 \approx 10^{-8}$.

Wzór szkolny: $x_2 = \dfrac{-b - \sqrt{b^2 - 4c}}{2}$ z $b = -10^8$. Wtedy $\sqrt{b^2 - 4} \approx 10^8$ i odejmujemy dwie prawie równe liczby → w `double` wychodzi $x_2 = 7\text{,}45\cdot 10^{-9}$ — **błąd 25%**.

Wersja stabilna: policz najpierw pierwiastek, przy którym nie ma odejmowania, $x_1 = \dfrac{-b + \sqrt{b^2 - 4c}}{2} = 10^8$, a drugi ze wzoru Viète'a $x_1x_2 = c$: $x_2 = c/x_1 = 1\text{,}0000\cdot 10^{-8}$ ✓.

Podobnie $\dfrac{1 - \cos x}{x^2}$ dla $x = 10^{-8}$: wprost wychodzi 0 (bo $\cos x$ zaokrągla się do 1), a po przekształceniu $1 - \cos x = 2\sin^2(x/2)$ — poprawne 0,5.

## Typowe pułapki

- **Porównanie `==` liczb zmiennoprzecinkowych** — używaj tolerancji względnej i bezwzględnej (`math.isclose`, `np.allclose`).
- **Akumulator `float` w długiej pętli** — dodanie $10^7$ razy 0,1 w `float` daje ok. 1 087 937 zamiast 1 000 000 (błąd 9%). Rozwiązania: `double`, sumowanie Kahana, sumowanie parami (`np.sum` robi to automatycznie).
- **Licznik czasu w `float`** (np. sekundy od startu) — po kilku dniach rozdzielczość spada do milisekund; czas trzymaj w liczbach całkowitych (tyknięcia).
- **Wzory z różnicą bliskich wartości** — wariancja jako $\overline{x^2} - \bar x^2$ przy dużej składowej stałej (użyj $\overline{(x - \bar x)^2}$ lub algorytmu Welforda).
- **Iloczyn wielu małych liczb** (prawdopodobieństwa, wzmocnienia) — sumuj logarytmy lub decybele.

## Ćwiczenie komputerowe

```python
import math
import numpy as np

print("0.1 + 0.2 =", repr(0.1 + 0.2), "| isclose:", math.isclose(0.1 + 0.2, 0.3))
print("eps double =", np.finfo(float).eps, " eps float =", np.finfo(np.float32).eps)

# utrata cyfr znaczących
x = 1e-8
print("(1-cos x)/x^2 wprost:", (1 - math.cos(x))/x**2, " stabilnie:", 2*math.sin(x/2)**2/x**2)

# pierwiastki równania kwadratowego
b, c = -1e8, 1.0
d = math.sqrt(b*b - 4*c)
print("x2 wprost:", (-b - d)/2, " stabilnie:", c/((-b + d)/2))

# kumulacja błędu w float32 (10^6 składników, żeby było szybko)
v = np.full(1_000_000, 0.1, dtype=np.float32)
naive = np.float32(0)
for s in v[:1_000_000]:
    naive += s
print(f"suma naiwna float32: {naive:.1f}, np.sum float32: {np.sum(v):.1f}, double: {np.sum(v.astype(float)):.1f}")

# wariancja przy dużej składowej stałej (napięcie 10 000 jednostek + szum o sigma = 1)
rng = np.random.default_rng(0)
y = (1e4 + rng.normal(0, 1, 100_000)).astype(np.float32)
print("wariancja E[x^2]-E[x]^2 (float32):", np.mean(y**2) - np.mean(y)**2,
      " np.var (dwa przebiegi):", np.var(y))
```

Zwróć uwagę: wzór $E[x^2] - E[x]^2$ w `float32` daje bezsensowny wynik (wariancję ujemną, −8 zamiast 1), bo $x^2 \approx 10^8$ ma w `float32` rozdzielczość 8. Funkcja `np.var` najpierw odejmuje średnią i daje poprawne 1,0003.

## Zadania

1. Ile cyfr znaczących ma `float`? Czy da się w nim zapisać dokładnie liczbę 16 777 217?
2. Przepisz $\sqrt{x+1} - \sqrt{x}$ w postać stabilną dla dużych $x$.
3. Policz wskaźnik uwarunkowania funkcji $f(x) = x - 1$ w punkcie $x = 1\text{,}000001$. Ile cyfr znaczących można stracić?
4. Licznik czasu w sekundach jako `float` (single). Jaka jest jego rozdzielczość po 1 dniu ($86\,400$ s)?
5. Dlaczego w obliczeniach statystycznych na dużych zbiorach (np. łączne prawdopodobieństwo) używa się sumy logarytmów?

<details>
<summary>Odpowiedzi</summary>

1. Ok. 7; nie — $2^{24} + 1 = 16\,777\,217$ zaokrągli się do 16 777 216 (mantysa 24 bity z bitem ukrytym)
2. $\dfrac{1}{\sqrt{x+1} + \sqrt{x}}$
3. $\kappa = \lvert x/(x-1)\rvert \approx 10^6$ — można stracić ok. 6 cyfr znaczących
4. $86\,400 \approx 2^{16\text{,}4}$, więc odstęp liczb to $2^{16 - 23} = 2^{-7} \approx 7\text{,}8$ ms
5. Iloczyn wielu liczb < 1 szybko daje niedomiar (0); logarytmy zamieniają go na sumę, bez problemu z zakresem
</details>

## Źródła

- [D. Goldberg — What Every Computer Scientist Should Know About Floating-Point Arithmetic](https://docs.oracle.com/cd/E19957-01/816-2464/ncg_goldberg.html)
- [MIT 18.335J Introduction to Numerical Methods](https://ocw.mit.edu/courses/18-335j-introduction-to-numerical-methods-spring-2019/) — arytmetyka zmiennoprzecinkowa, stabilność
- [Python — Floating Point Arithmetic: Issues and Limitations](https://docs.python.org/3/tutorial/floatingpoint.html)
