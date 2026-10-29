# 20 — Metody numeryczne

> **Status:** ✅ pełny

## Cel modułu

Rozumieć, jak komputer naprawdę liczy: skąd biorą się błędy zaokrągleń, jak rozwiązuje się równania nieliniowe, układy równań liniowych i równania różniczkowe, jak całkuje się i interpoluje dane pomiarowe oraz jak dopasowuje się model do pomiaru. Kulminacją modułu jest **własny mini-SPICE** — symulator obwodów w ok. 100 liniach Pythona, który pokazuje, co dzieje się w LTspice po kliknięciu „Run” i dlaczego symulacja czasem „nie zbiega się”.

## Wymagania wstępne

- [00 Matematyka](../00-matematyka/) — pochodne, całki, szereg Taylora ([00.02](../00-matematyka/02-rachunek-rozniczkowy-i-calkowy.md)), równania różniczkowe ([00.03](../00-matematyka/03-rownania-rozniczkowe.md)), macierze ([00.04](../00-matematyka/04-algebra-liniowa.md)).
- [19 Programowanie](../19-programowanie/) — Python i numpy ([19.01](../19-programowanie/01-python-podstawy.md), [19.02](../19-programowanie/02-python-naukowy.md)).
- Do tematu 07: analiza węzłowa z [01 Teorii obwodów](../01-teoria-obwodow/).

## Tematy

| # | Temat | Czas (od zera / odświeżenie) |
|---|---|---|
| 01 | [Arytmetyka zmiennoprzecinkowa i błędy](01-arytmetyka-i-bledy.md) | 6 h / 2 h |
| 02 | [Równania nieliniowe: bisekcja, Newton](02-rownania-nieliniowe.md) | 6 h / 2 h |
| 03 | [Układy równań liniowych](03-uklady-rownan-liniowych.md) | 8 h / 2 h |
| 04 | [Interpolacja i aproksymacja](04-interpolacja-i-aproksymacja.md) | 6 h / 2 h |
| 05 | [Różniczkowanie i całkowanie numeryczne](05-rozniczkowanie-i-calkowanie.md) | 5 h / 2 h |
| 06 | [Równania różniczkowe zwyczajne](06-rownania-rozniczkowe-zwyczajne.md) | 8 h / 3 h |
| 07 | [Jak działa SPICE — symulator od podstaw](07-jak-dziala-spice.md) | 10 h / 3 h |
| 08 | [Optymalizacja i dopasowanie modeli](08-optymalizacja-i-dopasowanie.md) | 6 h / 2 h |

Kod korzysta z `numpy`, `scipy` i `matplotlib`. Algorytmy są napisane „ręcznie”, żeby było widać, co robią, a obok podane są gotowe funkcje `scipy`, których używa się w praktyce.

## Test wejściowy (diagnoza)

Około 45 minut.

1. Czy w arytmetyce zmiennoprzecinkowej `0.1 + 0.2 == 0.3`? Dlaczego?
2. Zapisz jeden krok metody Newtona dla równania $f(x) = 0$.
3. Ile mniej więcej operacji wymaga rozwiązanie układu $n$ równań liniowych metodą eliminacji Gaussa?
4. Całkujesz $\sin x$ na $[0, \pi]$ metodą trapezów. Jak zmieni się błąd, gdy podwoisz liczbę przedziałów?
5. Metoda Eulera jawna dla $\dot y = -y/\tau$. Przy jakim kroku $h$ rozwiązanie numeryczne zaczyna oscylować z rosnącą amplitudą?
6. Czym różni się interpolacja od aproksymacji (dopasowania)?
7. Co to znaczy, że macierz jest źle uwarunkowana?

<details>
<summary>Odpowiedzi</summary>

1. Nie — 0,1 i 0,2 nie mają dokładnej reprezentacji dwójkowej; wynik to 0,30000000000000004
2. $x_{k+1} = x_k - f(x_k)/f'(x_k)$
3. Ok. $\tfrac{2}{3}n^3$ operacji zmiennoprzecinkowych
4. Zmaleje ok. 4 razy (błąd $\sim h^2$)
5. Dla $h > 2\tau$ (niestabilność); dla $\tau < h < 2\tau$ oscyluje, ale zanika
6. Interpolacja przechodzi dokładnie przez wszystkie punkty; aproksymacja dopasowuje prostszą funkcję, minimalizując np. sumę kwadratów odchyłek (nie musi przechodzić przez punkty)
7. Małe zmiany danych (lub zaokrąglenia) powodują duże zmiany rozwiązania; miarą jest wskaźnik uwarunkowania $\kappa(A)$

**Ocena:** 1 — temat 01; 2 — 02; 3, 7 — 03; 6 — 04; 4 — 05; 5 — 06.
</details>

## Projekt modułowy: symulator obwodów i dopasowanie modelu diody

- [ ] **Mini-SPICE (temat 07):** rozbuduj symulator z tematu 07 o źródło prądowe, wybór metody całkowania (Euler wsteczny / trapezy) i analizę AC (macierz zespolona przy zadanej częstotliwości).
- [ ] **Walidacja:** te same trzy obwody (dzielnik z diodą, filtr RC, prostownik z kondensatorem) w mini-SPICE i w LTspice — porównanie wyników na wspólnym wykresie, różnice wyjaśnione (krok, model diody).
- [ ] **Pomiar i dopasowanie (temat 08):** zmierz charakterystykę I–U diody (np. 1N4148) multimetrem/zasilaczem w 10–15 punktach ([08.02](../08-miernictwo/02-multimetr-i-pomiary-podstawowe.md)), dopasuj $I_S$, $n$ i rezystancję szeregową $R_S$, wstaw model do mini-SPICE.
- [ ] **Raport:** zbieżność Newtona (liczba iteracji z ograniczaniem kroku i bez), błąd całkowania w funkcji kroku, niepewność dopasowanych parametrów.

## Sprawdzian końcowy modułu

- [ ] Wyjaśniam epsilon maszynowy, utratę cyfr znaczących i przepełnienie; przepisuję wzór na postać stabilną numerycznie.
- [ ] Rozwiązuję równanie nieliniowe bisekcją i metodą Newtona, wiem, kiedy Newton zawodzi i jak go zabezpieczyć.
- [ ] Rozwiązuję układ równań przez rozkład LU z częściowym wyborem elementu głównego, oceniam uwarunkowanie.
- [ ] Interpoluję splajnem, dopasowuję model metodą najmniejszych kwadratów, unikam efektu Rungego.
- [ ] Całkuję metodą trapezów i Simpsona, dobieram krok różniczkowania numerycznego.
- [ ] Rozwiązuję równania różniczkowe metodami Eulera, trapezów i Rungego–Kutty, rozpoznaję sztywność i dobieram metodę niejawną.
- [ ] Buduję macierz analizy węzłowej (MNA) obwodu i wyjaśniam, jak SPICE liczy punkt pracy i stany nieustalone.
- [ ] Dopasowuję nieliniowy model do pomiarów i podaję niepewność parametrów.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [MIT 18.330 Introduction to Numerical Analysis (2012)](https://ocw.mit.edu/courses/18-330-introduction-to-numerical-analysis-spring-2012/) | Podstawowy kurs metod numerycznych |
| [MIT 18.335J Introduction to Numerical Methods (2019)](https://ocw.mit.edu/courses/18-335j-introduction-to-numerical-methods-spring-2019/) | Algebra liniowa numeryczna, stabilność, uwarunkowanie |
| [Numerical Recipes (darmowy dostęp do starszych wydań)](https://numerical.recipes/) | Praktyczne algorytmy z opisem, kiedy działają |
| [SciPy — User Guide](https://docs.scipy.org/doc/scipy/tutorial/index.html) | Gotowe implementacje: `optimize`, `integrate`, `interpolate`, `linalg` |
| [D. Goldberg — What Every Computer Scientist Should Know About Floating-Point Arithmetic](https://docs.oracle.com/cd/E19957-01/816-2464/ncg_goldberg.html) | Klasyczny tekst o arytmetyce IEEE 754 |
| [Ngspice — dokumentacja](https://ngspice.sourceforge.io/docs.html) | Opcje symulatora (tolerancje, metody całkowania) — temat 07 |
| [Steve Brunton — wykłady (YouTube)](https://www.youtube.com/results?search_query=Steve+Brunton+numerical+methods+differential+equations) | Metody całkowania równań różniczkowych |
| [3Blue1Brown — Essence of Linear Algebra (YouTube)](https://www.youtube.com/results?search_query=3Blue1Brown+Essence+of+linear+algebra) | Intuicja macierzy przed tematem 03 |
| L. O. Chua, P.-M. Lin — *Computer-Aided Analysis of Electronic Circuits* (płatna) | Teoria symulatorów obwodów |
