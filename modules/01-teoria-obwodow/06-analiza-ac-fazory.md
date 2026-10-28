# 01.06 — Analiza obwodów prądu sinusoidalnego: fazory, impedancja, moc

## Po co to jest

W stanie ustalonym przy wymuszeniu sinusoidalnym wszystkie napięcia i prądy w obwodzie liniowym są sinusoidami o tej samej częstotliwości. Różnią się tylko amplitudą i fazą — a to dokładnie opisuje liczba zespolona. Dzięki fazorom równania różniczkowe zamieniają się w algebrę, a wszystkie metody z tematów 01–03 działają bez zmian.

## Teoria w pigułce

### Fazor

Przebiegowi $u(t) = U_m\cos(\omega t + \varphi)$ odpowiada fazor $\underline{U} = U\angle\varphi$, gdzie $U = U_m/\sqrt{2}$ to wartość skuteczna (w elektrotechnice) albo $U_m$ (w części literatury elektronicznej). **Sprawdzaj, którą konwencję stosuje źródło.** W tym repozytorium: fazory skuteczne, chyba że napisano inaczej.

Różniczkowanie w dziedzinie czasu = mnożenie fazora przez $j\omega$.

### Impedancja i admitancja

| Element | Impedancja $\underline{Z}$ | Faza napięcia względem prądu |
|---|---|---|
| R | $R$ | 0° |
| L | $j\omega L = jX_L$ | +90° (napięcie wyprzedza) |
| C | $\dfrac{1}{j\omega C} = -jX_C$ | −90° (napięcie opóźnia się) |

$\underline{Z} = R + jX$ (rezystancja + reaktancja), $\underline{Y} = 1/\underline{Z} = G + jB$ (konduktancja + susceptancja).

Prawo Ohma $\underline{U} = \underline{Z}\,\underline{I}$, prawa Kirchhoffa, dzielniki, Thévenin, metody węzłowa i oczkowa — wszystko obowiązuje dla fazorów.

### Moc w obwodach AC

| Moc | Wzór | Jednostka | Znaczenie |
|---|---|---|---|
| Czynna | $P = UI\cos\varphi = I^2R$ | W | Zamieniana na ciepło lub pracę |
| Bierna | $Q = UI\sin\varphi = I^2X$ | var | „Przelewa się” między źródłem a polem L lub C |
| Pozorna | $S = UI = \sqrt{P^2 + Q^2}$ | VA | Obciąża przewody i transformatory |
| Zespolona | $\underline{S} = \underline{U}\,\underline{I}^* = P + jQ$ | VA | Wszystko naraz |

Współczynnik mocy $\cos\varphi = P/S$. Kompensacja mocy biernej indukcyjnej: równoległy kondensator o $Q_C = Q_L$, czyli $C = \dfrac{Q}{\omega U^2}$.

## Przykład rozwiązany

Odbiornik: $R = 30\ \Omega$ szeregowo z cewką o $X_L = 40\ \Omega$, zasilanie 230 V, 50 Hz.

1. $\underline{Z} = 30 + j40 = 50\angle 53{,}13^\circ\ \Omega$.
2. $\underline{I} = \dfrac{230\angle 0^\circ}{50\angle 53{,}13^\circ} = 4{,}6\angle -53{,}13^\circ$ A.
3. $P = I^2R = 4{,}6^2\cdot 30 \approx 635$ W, $Q = I^2X = 846$ var, $S = 230\cdot 4{,}6 = 1058$ VA, $\cos\varphi = 0{,}6$.
4. Kompensacja do $\cos\varphi = 1$: kondensator równolegle do odbiornika o $C = \dfrac{846}{2\pi\cdot 50\cdot 230^2} \approx 51\ \mu$F. Prąd pobierany z sieci spada z 4,6 A do $635/230 \approx 2{,}76$ A.

## Typowe pułapki

- **Mieszanie amplitud i wartości skutecznych** — moc $P = UI\cos\varphi$ dla wartości skutecznych, ale $P = \tfrac12 U_mI_m\cos\varphi$ dla amplitud.
- **Dodawanie modułów zamiast fazorów.** Napięcia na R i L w szeregu: $\sqrt{U_R^2 + U_L^2}$, a nie $U_R + U_L$.
- **Superpozycja fazorów o różnych częstotliwościach.** Fazory sumuje się tylko dla tej samej $\omega$. Dla wielu częstotliwości: osobna analiza dla każdej, suma w dziedzinie czasu.
- **Moc zespolona z $\underline{U}\,\underline{I}$ zamiast $\underline{U}\,\underline{I}^*$.**
- **Kompensacja „za dużym” kondensatorem** daje przekompensowanie (pojemnościowy $\cos\varphi$).

## Symulacja

```spice
* 01.06 odbiornik RL i kompensacja
V1 1 0 SINE(0 325.27 50)
R1 1 2 30
L1 2 0 127.3m
C1 1 0 51u
.tran 0 100m 60m
.end
```

($X_L = 40\ \Omega$ przy 50 Hz → $L \approx 127{,}3$ mH; amplituda 325,27 V = 230 V skuteczne.) Porównaj prąd źródła z kondensatorem i bez niego. W oknie przebiegów **Alt + klik na elemencie** pokazuje moc chwilową, a **Ctrl + klik na nazwie** — wartość średnią (czyli moc czynną).

## Zadania

1. Wyznacz impedancję szeregowego połączenia $R = 100\ \Omega$ i $C = 1\ \mu$F przy $f = 1$ kHz.
2. Wyznacz impedancję równoległego połączenia $R = 1$ kΩ i $L = 100$ mH przy $f = 1$ kHz.
3. Dzielnik: $\underline{U} = 10\angle 0^\circ$ V, rezystor 1 kΩ i kondensator o reaktancji 1 kΩ. Wyznacz napięcie na kondensatorze.
4. Odbiornik pobiera 5 A przy napięciu 230 V, prąd opóźnia się o 30°. Wyznacz $P$, $Q$, $S$.
5. Źródło ma $\underline{E} = 10$ V (skuteczne) i impedancję wewnętrzną $50 + j30\ \Omega$. Jaka impedancja obciążenia pobierze maksymalną moc i ile ona wynosi?
6. Dlaczego w obwodzie zasilanym jednocześnie napięciem 50 Hz i 150 Hz nie można dodać fazorów prądów?

<details>
<summary>Odpowiedzi</summary>

1. $X_C \approx 159{,}2\ \Omega$; $\underline{Z} = 100 - j159{,}2 \approx 188\angle -57{,}9^\circ\ \Omega$
2. $X_L \approx 628{,}3\ \Omega$; $\underline{Z} \approx 283 + j450{,}5 \approx 532\angle 57{,}9^\circ\ \Omega$
3. $\underline{U}_C = 10\cdot\dfrac{-j}{1 - j} = 5 - j5 \approx 7{,}07\angle -45^\circ$ V
4. $P \approx 996$ W, $Q = 575$ var, $S = 1150$ VA
5. $\underline{Z}_L = 50 - j30\ \Omega$, $P_{max} = \dfrac{E^2}{4R} = \dfrac{100}{200} = 0{,}5$ W
6. Fazor zakłada jedną, wspólną pulsację. Dla różnych częstotliwości trzeba liczyć osobno i sumować przebiegi czasowe; moce czynne harmonicznych się sumują.
</details>

## Źródła

- [AC Electrical Circuit Analysis — J. M. Fiore](https://eng.libretexts.org/Bookshelves/Electrical_Engineering/Electronics/AC_Electrical_Circuit_Analysis%3A_A_Practical_Approach_%28Fiore%29) — impedancja szeregowa i równoległa, obwody RLC, moc
- [Khan Academy — AC circuit analysis](https://www.khanacademy.org/science/electrical-engineering) — fazory, impedancja, „ELI the ICE man”
- [All About Circuits — tom AC](https://www.allaboutcircuits.com/textbook/) — reaktancja, impedancja, moc w obwodach AC, współczynnik mocy
- [MIT 6.002 Circuits and Electronics](https://ocw.mit.edu/courses/6-002-circuits-and-electronics-spring-2007/) — wykład o modelu impedancyjnym
