# M04.08 — Metoda momentów i metoda elementów skończonych

## Po co to jest

FDTD siatkuje całą przestrzeń. Dla anten drutowych, struktur metalowych w otwartej przestrzeni i płytek w wielu warstwach wydajniejsza jest **metoda momentów (MoM)** — niewiadomymi są tylko prądy (lub ładunki) na powierzchniach przewodników, a promieniowanie do nieskończoności jest zawarte w funkcji Greena. Do struktur o złożonych materiałach (ferryty, dielektryki o dowolnym kształcie, wnęki, złącza) i do zagadnień wielofizycznych (pole + ciepło) stosuje się **metodę elementów skończonych (FEM)**. Kto rozumie obie, ten wie, które narzędzie wybrać i jak ocenić jego wynik.

## Teoria w pigułce

### Metoda momentów

1. Równanie całkowe: np. potencjał na przewodniku z ładunku powierzchniowego $\sigma$: $\displaystyle\phi(\mathbf r) = \int_S\frac{\sigma(\mathbf r')}{4\pi\varepsilon_0\lvert\mathbf r - \mathbf r'\rvert}dS'$ (elektrostatyka); dla anten — równanie EFIE z funkcją Greena $e^{-jkR}/(4\pi R)$.
2. Rozwinięcie niewiadomej w **funkcje bazowe** (impulsy, trójkąty, RWG dla powierzchni) z nieznanymi współczynnikami.
3. **Testowanie** (dopasowanie w punktach lub Galerkin) → układ $\mathbf Z\mathbf I = \mathbf V$ z **pełną** macierzą.
4. Rozwiązanie: koszt $O(N^3)$ bezpośrednio, $O(N^2)$ pamięci; szybkie metody (FMM, ACA) zmniejszają koszt do $O(N\log N)$.

Zastosowania: anteny drutowe (NEC), anteny i rozpraszanie na metalach (RCS), płytki warstwowe (solvery 2,5D), ekstrakcja pojemności i indukcyjności połączeń ([16.04](../../modules/16-pcb-emc-konstrukcja/04-integralnosc-sygnalow.md)).

Ważne wyniki odniesienia: dipol półfalowy — impedancja ok. $73 + j42\text{,}5$ Ω (rezonans przy długości nieco mniejszej niż λ/2), kwadratowa płyta 1 m × 1 m — pojemność ok. 40,8 pF.

### Metoda elementów skończonych

1. Obszar dzielony na elementy (trójkąty, czworościany).
2. Postać słaba równania (np. wektorowe równanie falowe $\nabla\times\mu^{-1}\nabla\times\mathbf E - \omega^2\varepsilon\mathbf E = -j\omega\mathbf J$) z funkcjami bazowymi na elementach — dla pól wektorowych **elementy krawędziowe** (Nédélec), bo zwykłe węzłowe dają fałszywe mody.
3. Macierz **rzadka** — rozwiązanie metodami dla macierzy rzadkich ([20.03](../../modules/20-metody-numeryczne/03-uklady-rownan-liniowych.md)).
4. Brzegi otwarte: PML lub warunki promieniowania.

Zastosowania: falowody, wnęki, filtry, złącza, anteny dielektryczne, zagadnienia sprzężone z termiką i mechaniką. Narzędzia otwarte: Elmer, FEniCS, Palace; w praktyce inżynierskiej — pakiety komercyjne.

### Porównanie

| Cecha | FDTD | MoM | FEM |
|---|---|---|---|
| Dziedzina | Czas | Częstotliwość | Częstotliwość (lub czas) |
| Niewiadome | Pola w całej objętości | Prądy/ładunki na powierzchniach | Pola w objętości |
| Macierz | Brak (jawna) | Pełna | Rzadka |
| Mocne strony | Szerokie pasmo, prostota, złożone materiały | Metale w otwartej przestrzeni, anteny | Złożona geometria i materiały, wysoka dokładność |
| Słabości | Schodkowanie, dyspersja numeryczna | Dielektryki niejednorodne | Siatkowanie, duże problemy otwarte |

## Przykład rozwiązany

**Pojemność kwadratowej płyty 1 m × 1 m** metodą momentów (impulsowe funkcje bazowe, dopasowanie w środkach komórek, analityczny wyraz własny komórki):

| Podział | Niewiadomych | C |
|---|---|---|
| 5 × 5 | 25 | 38,8 pF |
| 10 × 10 | 100 | 39,8 pF |
| 20 × 20 | 400 | 40,4 pF |
| 40 × 40 | 1600 | 40,6 pF |

Zbieżność do wartości odniesienia ok. 40,8 pF. Rozkład ładunku jest silnie niejednorodny: w narożniku gęstość jest kilkanaście razy większa niż w środku (osobliwość krawędziowa) — dlatego zbieżność jest powolna, a w praktyce zagęszcza się siatkę przy krawędziach. Dla porównania kula o tej samej powierzchni ma tylko 31,4 pF.

## Typowe pułapki

- **Zbyt rzadkie funkcje bazowe przy krawędziach** — powolna zbieżność, zaniżone pojemności i błędne impedancje anten.
- **Wyraz własny macierzy MoM liczony jak dla odległych komórek** — osobliwość $1/R$; trzeba go wycałkować analitycznie lub specjalną kwadraturą.
- **FEM z elementami węzłowymi** dla pól wektorowych — mody fałszywe.
- **Brak testu zbieżności siatki** — każdy wynik numeryczny powinien być porównany przy co najmniej dwóch gęstościach.
- **Porównanie z pomiarem bez modelu złączy i podłoża** — rozbieżność przypisywana metodzie, a pochodząca z modelu.

## Ćwiczenie komputerowe

Metoda momentów dla pojemności płyty — zbieżność z podziałem siatki:

```python
import numpy as np

eps0 = 8.854187817e-12
def plate_capacitance(a=1.0, n=20):
    """Metoda momentów: kwadratowa płyta a×a pod potencjałem 1 V, funkcje bazowe impulsowe, dopasowanie w punktach."""
    h = a/n
    xc = (np.arange(n) + 0.5)*h - a/2
    X, Y = np.meshgrid(xc, xc); X, Y = X.ravel(), Y.ravel()
    R = np.hypot(X[:, None] - X[None, :], Y[:, None] - Y[None, :])
    with np.errstate(divide="ignore"):
        Z = h**2/(4*np.pi*eps0*R)                       # ładunek komórki jako ładunek punktowy (komórki odległe)
    self_term = h/(np.pi*eps0)*np.log(1 + np.sqrt(2))   # potencjał w środku jednorodnie naładowanego kwadratu o boku h
    np.fill_diagonal(Z, self_term)
    sigma = np.linalg.solve(Z, np.ones(n*n))           # gęstość ładunku [C/m²]
    return sigma.sum()*h**2, sigma.reshape(n, n)

for n in (5, 10, 20, 40):
    C, s = plate_capacitance(n=n)
    print(f"n = {n:2d} ({n*n:4d} niewiadomych): C = {C*1e12:.2f} pF, gęstość ładunku narożnik/środek = {s[0,0]/s[n//2, n//2]:.2f}")
print("wartość odniesienia z literatury dla płyty 1 m × 1 m: ok. 40,8 pF")
print(f"dla porównania: kula o tej samej powierzchni (r = {np.sqrt(1/(4*np.pi)):.3f} m): C = {4*np.pi*eps0*np.sqrt(1/(4*np.pi))*1e12:.1f} pF")
```

Rozszerzenie: dodaj drugą płytę w odległości $d$ (kondensator płaski) i porównaj pojemność z wzorem $\varepsilon_0S/d$ dla różnych $d$ — zobaczysz wpływ pola rozproszonego na brzegach; następnie zaimplementuj MoM dla cienkiego dipola (równanie Hallena) i sprawdź impedancję ok. 73 Ω.

## Zadania

1. Macierz MoM ma 20 000 niewiadomych (liczby zespolone podwójnej precyzji). Ile pamięci zajmuje?
2. Dlaczego macierz MoM jest pełna, a FEM — rzadka?
3. Dlaczego gęstość ładunku na płycie jest największa w narożnikach?
4. Którą metodę wybierzesz do: (a) anteny drutowej Yagi, (b) filtru wnękowego z dielektrykiem, (c) odpowiedzi impulsowej złącza w paśmie 0–40 GHz?
5. Jak sprawdzić, czy wynik symulacji jest zbieżny?

<details>
<summary>Odpowiedzi</summary>

1. $20\,000^2\cdot 16\ \text{B} = 6\text{,}4$ GB
2. W MoM każdy element prądu oddziałuje z każdym przez funkcję Greena (pole sięga daleko), w FEM równanie różniczkowe wiąże tylko sąsiednie elementy
3. Pole przy ostrych krawędziach i narożnikach przewodnika jest osobliwe — ładunek gromadzi się tam, gdzie krzywizna jest największa (jak w ostrzu piorunochronu)
4. (a) MoM (NEC); (b) FEM; (c) FDTD (szerokie pasmo, odpowiedź czasowa) — choć FEM w dziedzinie częstotliwości z przemiataniem też jest stosowany
5. Powtórzyć z gęstszą siatką (i większym obszarem obliczeniowym/dłuższym czasem dla FDTD) i sprawdzić, że wynik zmienia się mniej niż wymagana dokładność; porównać z przypadkiem o znanym rozwiązaniu analitycznym
</details>

## Źródła

- [S. J. Orfanidis — Electromagnetic Waves and Antennas](https://www.ece.rutgers.edu/~orfanidi/ewa) — rozdziały o antenach drutowych i równaniach całkowych (Hallen, Pocklington)
- [MIT 6.635 Advanced Electromagnetism](https://ocw.mit.edu/courses/6-635-advanced-electromagnetism-spring-2003/)
- [20.03 Układy równań liniowych](../../modules/20-metody-numeryczne/03-uklady-rownan-liniowych.md)
- R. F. Harrington — *Field Computation by Moment Methods* (płatna)
