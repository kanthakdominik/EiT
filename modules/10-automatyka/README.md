# 10 — Podstawy automatyki

> **Status:** 🟡 szkielet — zakres i cele. Pełne notatki, zadania i dedykowane źródła w kolejnym etapie.

## Cel modułu

Opisywać układy dynamiczne i projektować proste układy regulacji ze sprzężeniem zwrotnym. Ta wiedza wraca w stabilności wzmacniaczy, przetwornicach i pętlach PLL.

## Wymagania wstępne

- [06 Sygnały i systemy](../06-sygnaly-i-systemy/) (transformata Laplace'a, transmitancja, Bode).

## Tematy

- [ ] Modele obiektów: człony proporcjonalny, inercyjny, całkujący, różniczkujący, opóźniający, oscylacyjny
- [ ] Schematy blokowe i ich przekształcanie
- [ ] Odpowiedzi czasowe: skokowa i impulsowa, czas ustalania, przeregulowanie
- [ ] Uchyb ustalony, typ układu
- [ ] Stabilność: kryterium Hurwitza, kryterium Nyquista, zapas fazy i wzmocnienia
- [ ] Linie pierwiastkowe (root locus)
- [ ] Regulatory P, PI, PD, PID; dobór nastaw (np. metodą Zieglera–Nicholsa)
- [ ] Opis w przestrzeni stanów, sterowalność i obserwowalność
- [ ] Regulacja cyfrowa: dyskretyzacja regulatora, wpływ okresu próbkowania
- [ ] Zastosowania w elektronice: pętla PLL, regulacja przetwornicy, stabilizacja temperatury

## Główne źródła

- [MIT 6.003 Signals and Systems (2011)](https://ocw.mit.edu/courses/6-003-signals-and-systems-fall-2011/) — wykłady o sprzężeniu zwrotnym i biegunach
- [MIT RES.6-007 Signals and Systems (Oppenheim)](https://ocw.mit.edu/courses/res-6-007-signals-and-systems-spring-2011/) — wykład o sprzężeniu zwrotnym

Dedykowany kurs automatyki zostanie dodany po weryfikacji w kolejnym etapie.

## Ćwiczenie modułowe

Regulacja temperatury: model cieplny (człon inercyjny z opóźnieniem) w Pythonie, dobór regulatora PI, symulacja odpowiedzi skokowej, a następnie implementacja na mikrokontrolerze z grzałką (rezystor mocy) i czujnikiem.

## Sprawdzian umiejętności

- Wyznaczam transmitancję zastępczą złożonego schematu blokowego.
- Oceniam stabilność układu zamkniętego z charakterystyki układu otwartego.
- Dobieram nastawy regulatora PI do zadanego przeregulowania.
