# 20.04 — Interpolacja i aproksymacja

## Po co to jest

Nota katalogowa podaje charakterystykę w kilkunastu punktach, a potrzebujesz wartości pomiędzy nimi. Termistor, termopara, czujnik ciśnienia mają nieliniowe charakterystyki, które trzeba zlinearyzować tablicą ([19.06](../19-programowanie/06-struktury-danych-i-algorytmy.md)). Kalibracja przetwornika to dopasowanie prostej do zaszumionych punktów ([08.01](../08-miernictwo/01-metrologia-i-niepewnosc.md)). **Interpolacja** przechodzi przez dane punkty, **aproksymacja** szuka prostego modelu, który najlepiej je opisuje.

## Teoria w pigułce

### Interpolacja

- **Liniowa** — odcinki między punktami; prosta, szybka, wystarczająca przy gęstej tablicy. Błąd $\leq \tfrac18 h^2 \max\lvert f''\rvert$.
- **Wielomian interpolacyjny** stopnia $N-1$ przez $N$ punktów (Lagrange, Newton) — jednoznaczny, ale przy równoodległych węzłach i dużym $N$ oscyluje na brzegach (**efekt Rungego**).
- **Węzły Czebyszewa** $x_i = \cos\dfrac{(2i+1)\pi}{2N}$ — zagęszczone przy brzegach, usuwają efekt Rungego.
- **Splajn sześcienny** — wielomiany 3. stopnia na każdym przedziale, z ciągłą pierwszą i drugą pochodną. **Domyślny wybór** do gładkich danych (`scipy.interpolate.CubicSpline`). Wersja monotoniczna (PCHIP) nie tworzy „przestrzałów” — dobra dla charakterystyk czujników.

### Aproksymacja metodą najmniejszych kwadratów

Model liniowy względem parametrów $y \approx \sum_j c_j\,\varphi_j(x)$ (np. $c_0 + c_1x$, wielomian, $a + b\ln x$). Minimalizujemy $\sum_i (y_i - \hat y_i)^2$:

$$\mathbf A\mathbf c \approx \mathbf y, \qquad \mathbf c = \arg\min\lVert\mathbf A\mathbf c - \mathbf y\rVert^2$$

- Rozwiązanie: QR lub SVD (`np.linalg.lstsq`, `np.polyfit`); równania normalne $\mathbf A^T\mathbf A\mathbf c = \mathbf A^T\mathbf y$ są prostsze, ale podnoszą uwarunkowanie do kwadratu.
- Dla prostej: $a = \dfrac{\sum(x_i - \bar x)(y_i - \bar y)}{\sum(x_i - \bar x)^2}$, $b = \bar y - a\bar x$.
- **Reszty** $r_i = y_i - \hat y_i$: ich rozrzut szacuje szum, a struktura (np. łuk) zdradza zły model.
- Odchylenie standardowe reszt: $s = \sqrt{\sum r_i^2/(N - p)}$, $p$ — liczba parametrów.
- Modele nieliniowe względem parametrów (np. $I_S(e^{V/nU_T} - 1)$) — temat [20.08](08-optymalizacja-i-dopasowanie.md); często da się je zlinearyzować (logarytm).

## Przykład rozwiązany

**Kalibracja przetwornika A/C.** Na wejście podano napięcia wzorcowe 0…4 V, odczyty (w jednostkach ADC):

| $U$ [V] | 0 | 1 | 2 | 3 | 4 |
|---|---|---|---|---|---|
| odczyt | 12 | 1018 | 2031 | 3029 | 4047 |

Dopasowanie prostej: $\bar x = 2$, $\bar y = 2027\text{,}4$, $a = \dfrac{\sum (x_i - 2)(y_i - 2027\text{,}4)}{10} = 1008\text{,}1$ LSB/V, $b = 2027\text{,}4 - 2\cdot 1008\text{,}1 = 11\text{,}2$ LSB (przesunięcie zera).

Reszty: 0,8; −1,3; 3,6; −6,5; 3,4 LSB; $s = \sqrt{\sum r^2/3} = 4\text{,}8$ LSB. Korekcja odczytu: $U = (\text{odczyt} - 11\text{,}2)/1008\text{,}1$ V. Reszty nie układają się w łuk — model liniowy jest wystarczający; gdyby był łuk, trzeba by dodać człon kwadratowy (nieliniowość całkowa ADC).

**Efekt Rungego** dla $f(x) = 1/(1+25x^2)$ na $[-1, 1]$ — maksymalny błąd interpolacji:

| Węzły | Wielomian, równoodległe | Wielomian, Czebyszew | Splajn sześcienny |
|---|---|---|---|
| 11 | 1,92 | 0,109 | 0,022 |
| 21 | 59,8 | 0,015 | 0,0032 |

Więcej równoodległych węzłów = **gorzej**. Wniosek praktyczny: do tablic charakterystyk używaj interpolacji odcinkowej (liniowej lub splajnu), nie wielomianu wysokiego stopnia.

## Typowe pułapki

- **Wielomian wysokiego stopnia** przez wszystkie punkty pomiarowe — interpoluje szum i oscyluje.
- **Ekstrapolacja** poza zakres danych — wielomian i splajn mogą dać dowolną wartość.
- **Dopasowanie bez oglądania reszt** — dobry współczynnik $R^2$ nie oznacza dobrego modelu.
- **Punkty z różną niepewnością traktowane jednakowo** — użyj wag (`np.polyfit(..., w=1/sigma)`).
- **Dopasowanie po linearyzacji logarytmem** zmienia wagi błędów — małe wartości dostają za dużą wagę.

## Ćwiczenie komputerowe

```python
import numpy as np
from scipy.interpolate import CubicSpline, PchipInterpolator

# kalibracja
U = np.array([0, 1, 2, 3, 4.]); code = np.array([12, 1018, 2031, 3029, 4047.])
a, b = np.polyfit(U, code, 1)
r = code - (a*U + b)
print(f"a = {a:.1f} LSB/V, b = {b:.1f} LSB, reszty = {np.round(r, 1)}, s = {np.sqrt(np.sum(r**2)/(len(U)-2)):.1f} LSB")

# efekt Rungego
f = lambda x: 1/(1 + 25*x**2)
xx = np.linspace(-1, 1, 2001)
for N in (11, 21):
    xe = np.linspace(-1, 1, N)
    xc = np.cos((2*np.arange(N) + 1)*np.pi/(2*N))
    err_eq = np.max(np.abs(np.polyval(np.polyfit(xe, f(xe), N - 1), xx) - f(xx)))
    err_ch = np.max(np.abs(np.polyval(np.polyfit(xc, f(xc), N - 1), xx) - f(xx)))
    err_sp = np.max(np.abs(CubicSpline(xe, f(xe))(xx) - f(xx)))
    print(f"N = {N}: równoodległe {err_eq:.3g}, Czebyszew {err_ch:.3g}, splajn {err_sp:.2g}")

# splajn kontra PCHIP na danych schodkowych (charakterystyka z nasyceniem)
x = np.array([0, 1, 2, 3, 4, 5.]); y = np.array([0, 0, 0, 1, 1, 1.])
xs = np.linspace(0, 5, 501)
print(f"splajn: min {CubicSpline(x, y)(xs).min():.3f}, max {CubicSpline(x, y)(xs).max():.3f}; "
      f"PCHIP: min {PchipInterpolator(x, y)(xs).min():.3f}, max {PchipInterpolator(x, y)(xs).max():.3f}")
```

Ostatni przykład pokazuje, że splajn „przestrzeliwuje” poza zakres danych (wartości < 0 i > 1), a PCHIP nie.

## Zadania

1. Tablica NTC co 10 °C, druga pochodna charakterystyki $T(R)$ w danym obszarze odpowiada błędowi interpolacji liniowej 0,3 °C. Jaki krok tablicy da błąd 0,05 °C?
2. Dopasuj prostą do punktów (0; 1), (1; 3), (2; 4), (3; 7). Podaj $a$, $b$ i reszty.
3. Dlaczego splajn sześcienny jest lepszy od wielomianu 20. stopnia przez 21 punktów?
4. Charakterystyka $R(T)$ termistora jest wykładnicza. Jak dopasować $B$ i $R_{25}$ metodą najmniejszych kwadratów liniowych?
5. Kiedy użyjesz PCHIP zamiast zwykłego splajnu?

<details>
<summary>Odpowiedzi</summary>

1. Błąd $\sim h^2$: $h = 10\cdot\sqrt{0\text{,}05/0\text{,}3} \approx 4\text{,}1$ °C → krok 4 °C
2. $\bar x = 1\text{,}5$, $\bar y = 3\text{,}75$; $a = \dfrac{(-1\text{,}5)(-2\text{,}75) + (-0\text{,}5)(-0\text{,}75) + 0\text{,}5\cdot 0\text{,}25 + 1\text{,}5\cdot 3\text{,}25}{5} = 1\text{,}9$; $b = 3\text{,}75 - 2\text{,}85 = 0\text{,}9$; reszty: 0,1; 0,2; −0,7; 0,4
3. Splajn składa się z wielomianów niskiego stopnia na krótkich przedziałach — brak oscylacji Rungego, lokalny wpływ każdego punktu, dobre uwarunkowanie
4. $\ln R = \ln R_{25} - B/298\text{,}15 + B\cdot(1/T)$ — prosta w zmiennych $(1/T, \ln R)$: nachylenie $B$, z wyrazu wolnego $R_{25}$
5. Gdy dane są monotoniczne (lub mają płaskie odcinki) i interpolacja nie może wyjść poza zakres sąsiednich wartości — charakterystyki czujników, krzywe nasycenia, tablice LUT
</details>

## Źródła

- [MIT 18.330 Introduction to Numerical Analysis](https://ocw.mit.edu/courses/18-330-introduction-to-numerical-analysis-spring-2012/) — interpolacja, Czebyszew
- [SciPy — Interpolation](https://docs.scipy.org/doc/scipy/tutorial/interpolate.html)
- [NIST/SEMATECH e-Handbook of Statistical Methods](https://www.itl.nist.gov/div898/handbook/) — rozdział 4: dopasowanie modeli, analiza reszt
