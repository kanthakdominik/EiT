# M04 — Technika mikrofalowa, szyki antenowe i numeryczne metody pola

> **Status:** ✅ pełny · ścieżka magisterska (II stopień)

## Cel modułu

Projektować układy mikrofalowe na poziomie, na którym wykonuje się je na płytce lub w układzie scalonym: analizować sieci wielowrotowe macierzami S i ABCD, usuwać wpływ przyrządów pomiarowych, zamieniać prototypy LC na odcinki linii, projektować filtry, dzielniki i sprzęgacze, wzmacniacz o maksymalnym wzmocnieniu przy zachowaniu stabilności, anteny łatkowe i szyki z syntezą charakterystyki — oraz rozumieć i samodzielnie zaimplementować dwie podstawowe metody numeryczne elektromagnetyzmu: metodę różnic skończonych w dziedzinie czasu (FDTD) i metodę momentów (MoM). Moduł rozwija [11 Pole EM, linie, anteny](../../modules/11-pole-em-linie-anteny/) i [12 Technikę w.cz.](../../modules/12-technika-wcz-rf/).

## Wymagania wstępne

- [11 Pole EM, linie, anteny](../../modules/11-pole-em-linie-anteny/) — linie transmisyjne, wykres Smitha, anteny.
- [12 Technika w.cz.](../../modules/12-technika-wcz-rf/) — parametry S ([12.02](../../modules/12-technika-wcz-rf/02-parametry-s.md)), dopasowanie, wzmacniacze, szumy.
- [20 Metody numeryczne](../../modules/20-metody-numeryczne/) — układy równań, równania różniczkowe, stabilność.
- [M02.04 Szyki antenowe i kształtowanie wiązki](../M02-mimo-i-kodowanie/04-szyki-i-ksztaltowanie-wiazki.md).

## Tematy

| # | Temat | Czas |
|---|---|---|
| 01 | [Sieci mikrofalowe: macierze S, ABCD i de-embedding](01-sieci-mikrofalowe.md) | 8 h |
| 02 | [Elementy rozłożone i rezonatory](02-elementy-rozlozone-i-rezonatory.md) | 8 h |
| 03 | [Filtry mikrofalowe](03-filtry-mikrofalowe.md) | 10 h |
| 04 | [Dzielniki mocy i sprzęgacze](04-dzielniki-i-sprzegacze.md) | 8 h |
| 05 | [Projekt wzmacniacza mikrofalowego](05-wzmacniacz-mikrofalowy.md) | 10 h |
| 06 | [Anteny łatkowe i synteza szyków](06-anteny-latkowe-i-synteza-szykow.md) | 10 h |
| 07 | [Metoda FDTD](07-metoda-fdtd.md) | 10 h |
| 08 | [Metoda momentów i metoda elementów skończonych](08-metoda-momentow-i-fem.md) | 10 h |

## Test wejściowy (diagnoza)

Około 60 minut.

1. Ile wynosi impedancja wejściowa zwartego odcinka linii o długości λ/4? A rozwartego?
2. Jak łączy się macierze ABCD kaskadowo połączonych dwuwrotników?
3. Co oznacza $\lvert S_{21}\rvert = -3$ dB i $\lvert S_{11}\rvert = -20$ dB?
4. Dla jakiego $\Gamma_L$ wzmocnienie dostępne tranzystora jest maksymalne (bez warunku stabilności)?
5. Zapisz równania Maxwella rotacji w postaci różniczkowej.
6. Co to jest warunek Couranta w metodach jawnych?

<details>
<summary>Odpowiedzi</summary>

1. Zwarty λ/4: nieskończona (rozwarcie); rozwarty λ/4: zero (zwarcie)
2. Mnożąc je w kolejności połączenia: $\mathbf M = \mathbf M_1\mathbf M_2\cdots$
3. Połowa mocy przechodzi na wyjście; współczynnik odbicia 0,1 (1% mocy odbite, dopasowanie dobre)
4. Dla dopasowania sprzężonego: $\Gamma_L = \Gamma_{out}^*$ (przy jednoczesnym $\Gamma_S = \Gamma_{in}^*$)
5. $\nabla\times\mathbf E = -\partial\mathbf B/\partial t$, $\nabla\times\mathbf H = \mathbf J + \partial\mathbf D/\partial t$
6. Krok czasowy nie może być większy niż czas przejścia fali przez komórkę siatki (z odpowiednim współczynnikiem dla wymiaru) — inaczej metoda jest niestabilna ([20.06](../../modules/20-metody-numeryczne/06-rownania-rozniczkowe-zwyczajne.md))

**Ocena:** 1 — temat 02; 2–3 — 01; 4 — 05; 5–6 — 07.
</details>

## Projekt modułowy: front-end 2,4 GHz na płytce FR4

- [ ] **Projekt (tematy 01–06):** filtr pasmowy (np. na liniach sprzężonych lub z rezonatorami), dzielnik Wilkinsona i antena łatkowa 2,45 GHz zasilana linią mikropaskową; obliczenia w Pythonie, symulacja w openEMS.
- [ ] **Wykonanie:** płytka dwuwarstwowa FR4 1,6 mm ([16](../../modules/16-pcb-emc-konstrukcja/)), złącza SMA.
- [ ] **Pomiar:** parametry S tanim analizatorem wektorowym (NanoVNA) po kalibracji SOLT; porównanie z symulacją, de-embedding złączy.
- [ ] **Analiza rozbieżności:** tolerancja $\varepsilon_r$ FR4, straty dielektryka, wpływ złączy i obudowy; poprawiony projekt.

## Sprawdzian końcowy modułu

- [ ] Przeliczam macierze S, Z, Y, ABCD; kaskaduję i usuwam przyrządy (de-embedding).
- [ ] Zamieniam elementy skupione na odcinki linii (Richards, Kuroda), liczę dobroć rezonatorów.
- [ ] Projektuję filtry dolno- i pasmowoprzepustowe z prototypów, przewiduję pasma pasożytnicze.
- [ ] Projektuję i analizuję dzielnik Wilkinsona i sprzęgacz gałęziowy.
- [ ] Oceniam stabilność tranzystora (K, μ), projektuję dopasowanie dla maksymalnego wzmocnienia i minimalnego szumu.
- [ ] Projektuję antenę łatkową i szyk o zadanym poziomie listków bocznych.
- [ ] Implementuję FDTD 1D/2D z warunkiem Couranta i warunkami pochłaniającymi.
- [ ] Rozumiem metodę momentów i FEM, implementuję MoM dla prostego zagadnienia elektrostatycznego.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [S. J. Orfanidis — Electromagnetic Waves and Antennas (darmowa książka)](https://www.ece.rutgers.edu/~orfanidi/ewa) | Linie, sprzęgacze, anteny, szyki, synteza charakterystyk, metody numeryczne |
| [MIT 6.632 Electromagnetic Wave Theory (2003)](https://ocw.mit.edu/courses/6-632-electromagnetic-wave-theory-spring-2003/) | Teoria fal, falowody — poziom magisterski |
| [MIT 6.635 Advanced Electromagnetism (2003)](https://ocw.mit.edu/courses/6-635-advanced-electromagnetism-spring-2003/) | Elektromagnetyzm zaawansowany, metody analityczne i numeryczne |
| [openEMS](https://openems.de) ([dokumentacja](https://docs.openems.de/intro.html)) | Otwarty symulator FDTD 3D (Python/Matlab) — anteny, filtry, płytki |
| [scikit-rf](https://scikit-rf.readthedocs.io) | Parametry S, kalibracja VNA, de-embedding w Pythonie |
| [MIT 6.013 Electromagnetics and Applications (2005)](https://ocw.mit.edu/courses/6-013-electromagnetics-and-applications-fall-2005/) | Powtórka podstaw |
| D. M. Pozar — *Microwave Engineering* (płatna) | Główny podręcznik techniki mikrofalowej |
| C. A. Balanis — *Antenna Theory: Analysis and Design* (płatna) | Anteny i szyki |
| A. Taflove, S. Hagness — *Computational Electrodynamics: The FDTD Method* (płatna) | FDTD |
