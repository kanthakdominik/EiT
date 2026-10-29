# 01.08 — Metoda operatorowa (transformata Laplace'a w obwodach)

## Po co to jest

Metoda klasyczna (równanie różniczkowe) robi się uciążliwa przy obwodach wyższego rzędu i niezerowych warunkach początkowych. Metoda operatorowa pozwala liczyć stany nieustalone dokładnie tak jak obwody prądu stałego — tylko z impedancjami zależnymi od $s$. Transmitancja $H(s)$ łączy ten temat z sygnałami i systemami oraz automatyką.

Wymaga tematu [00.05 Szeregi Fouriera i transformata Laplace'a](../00-matematyka/05-szeregi-i-transformaty.md).

## Teoria w pigułce

### Schematy zastępcze elementów w dziedzinie $s$

| Element | Impedancja operatorowa | Warunek początkowy jako źródło |
|---|---|---|
| R | $R$ | — |
| L | $sL$ | Szeregowe źródło napięcia $L\,i_L(0^-)$ (zwrot zgodny z prądem — „podtrzymuje” prąd) |
| C | $\dfrac{1}{sC}$ | Szeregowe źródło napięcia $\dfrac{u_C(0^-)}{s}$ |

Źródło stałe $E$ włączane w $t = 0$ → $E/s$. Źródło sinusoidalne → odpowiednia transformata z tabeli.

### Procedura

1. Wyznacz warunki początkowe $u_C(0^-)$, $i_L(0^-)$ z obwodu przed przełączeniem.
2. Narysuj schemat operatorowy (impedancje + źródła warunków początkowych).
3. Rozwiąż go dowolną metodą (dzielnik, węzłowa, Thévenin…) — tak jak obwód DC.
4. Rozłóż wynik na ułamki proste i wróć do dziedziny czasu.

### Transmitancja operatorowa

Przy zerowych warunkach początkowych: $H(s) = \dfrac{U_{wy}(s)}{U_{we}(s)}$.

- **Bieguny** (pierwiastki mianownika) wyznaczają charakter odpowiedzi swobodnej: rzeczywiste ujemne → zanik wykładniczy, zespolone → tłumione oscylacje, z dodatnią częścią rzeczywistą → niestabilność.
- **Odpowiedź impulsowa:** $h(t) = \mathcal{L}^{-1}\{H(s)\}$.
- **Odpowiedź skokowa:** $\mathcal{L}^{-1}\{H(s)/s\}$.
- **Charakterystyka częstotliwościowa:** $H(j\omega)$ — podstaw $s = j\omega$.

## Przykład rozwiązany

**Obwód z tematu 04:** $C = 10\ \mu$F naładowany do $u_0 = 2$ V, dołączony przez $R = 10$ kΩ do $E = 12$ V.

1. Schemat operatorowy: $E/s$, $R$, $\dfrac{1}{sC}$ i źródło $u_0/s$ w gałęzi kondensatora.
2. Prąd: $I(s) = \dfrac{(E - u_0)/s}{R + \dfrac{1}{sC}} = \dfrac{(E - u_0)C}{1 + sRC}$.
3. Napięcie kondensatora: $U_C(s) = \dfrac{u_0}{s} + \dfrac{I(s)}{sC} = \dfrac{u_0}{s} + \dfrac{E - u_0}{s(1 + s\tau)}$, $\tau = RC = 0\text{,}1$ s.
4. $\dfrac{1}{s(1 + s\tau)} = \dfrac{1}{s} - \dfrac{1}{s + 1/\tau}$, więc $u_C(t) = u_0 + (E - u_0)(1 - e^{-t/\tau}) = 12 - 10e^{-10t}$ V — wynik identyczny jak metodą klasyczną.

**Transmitancja szeregowego RLC** (wyjście na C):

$$H(s) = \frac{1/(sC)}{R + sL + 1/(sC)} = \frac{1}{LCs^2 + RCs + 1}$$

Dla $R = 100\ \Omega$, $L = 10$ mH, $C = 1\ \mu$F bieguny: $s = -5000 \pm j8660$ — zgodnie z tematem [05](05-obwody-2-rzedu.md).

## Typowe pułapki

- **Zły zwrot źródła warunku początkowego** cewki lub kondensatora. Sprawdź: źródło $L i_L(0)$ ma „podtrzymywać” prąd cewki, źródło $u_C(0)/s$ odtwarza napięcie kondensatora.
- **Zapomniane $1/s$** przy źródle stałym.
- **Twierdzenie o wartości końcowej** zastosowane do układu z biegunami na osi urojonej lub w prawej półpłaszczyźnie.
- **Transmitancja z niezerowymi warunkami początkowymi** — transmitancja jest zawsze definiowana przy zerowych warunkach.

## Symulacja

LTspice potrafi symulować transmitancję bezpośrednio — źródło sterowane z wyrażeniem Laplace'a:

```spice
* 01.08 transmitancja RLC jako blok Laplace'a i jako obwod
V1 in 0 PULSE(0 1 0 1n 1n 10m 20m) AC 1
E1 out1 0 in 0 Laplace=1/(1e-8*s**2 + 1e-4*s + 1)
R1 in a 100
L1 a b 10m
C1 b 0 1u
.tran 0 3m
.end
```

`V(out1)` i `V(b)` powinny się pokrywać. Zamień `.tran` na `.ac dec 100 100 100k`, aby porównać charakterystyki częstotliwościowe.

## Zadania

1. Wyznacz transmitancję dolnoprzepustowego filtra RC i jego odpowiedź skokową metodą operatorową.
2. Źródło 10 V włączone w $t = 0$ zasila szeregowo $R = 10\ \Omega$ i $L = 0\text{,}1$ H (prąd początkowy zerowy). Wyznacz $I(s)$ i $i(t)$.
3. Wyznacz bieguny transmitancji szeregowego RLC ($R = 100\ \Omega$, $L = 10$ mH, $C = 1\ \mu$F) i określ charakter odpowiedzi.
4. Wyznacz odpowiedź impulsową układu o transmitancji $H(s) = \dfrac{1000}{s + 1000}$.
5. Do szeregowego RLC z zadania 3 przyłożono skok 10 V. Wyznacz wartość ustaloną napięcia na kondensatorze z twierdzenia o wartości końcowej.
6. Cewka $L = 0\text{,}5$ H z prądem 2 A zostaje zwarta przez rezystor 10 Ω (bez źródła). Wyznacz $i(t)$ metodą operatorową.

<details>
<summary>Odpowiedzi</summary>

1. $H(s) = \dfrac{1}{1 + sRC}$; $U_{wy}(s) = \dfrac{1}{s(1 + sRC)} \Rightarrow u(t) = 1 - e^{-t/RC}$ (dla skoku jednostkowego)
2. $I(s) = \dfrac{10}{s(10 + 0\text{,}1s)} = \dfrac{100}{s(s + 100)} \Rightarrow i(t) = 1 - e^{-100t}$ A
3. $s = -5000 \pm j8660$ — tłumione oscylacje, $\zeta = 0\text{,}5$
4. $h(t) = 1000e^{-1000t}$ dla $t \geq 0$
5. $\lim_{s\to 0} s\cdot\dfrac{10}{s}H(s) = 10$ V
6. $I(s) = \dfrac{L i_0}{sL + R} = \dfrac{1}{0\text{,}5s + 10} = \dfrac{2}{s + 20} \Rightarrow i(t) = 2e^{-20t}$ A
</details>

## Źródła

- [Paul's Online Math Notes — Laplace Transforms](https://tutorial.math.lamar.edu/Classes/DE/LaplaceIntro.aspx) — matematyka transformaty
- [MIT 6.003 Signals and Systems](https://ocw.mit.edu/courses/6-003-signals-and-systems-fall-2011/) — transformata Laplace'a, bieguny i zera
- [Neso Academy — Network Theory](https://www.classcentral.com/classroom/youtube-network-theory-48208) — seria o transformacie Laplace'a w obwodach
- [LTspice](https://www.analog.com/en/resources/design-tools-and-calculators/ltspice-simulator.html) — materiały producenta o modelowaniu transmitancji transformatą Laplace'a
