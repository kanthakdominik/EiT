# 06 — Sygnały i systemy

> **Status:** 🟡 szkielet — zakres, cele i główne źródła. Pełne notatki i zadania w kolejnym etapie.

## Cel modułu

Opisywać sygnały i układy liniowe w dziedzinie czasu i częstotliwości, w czasie ciągłym i dyskretnym. To język, którym posługują się DSP, telekomunikacja i automatyka.

## Wymagania wstępne

- [00 Matematyka](../00-matematyka/) (liczby zespolone, całki, równania różniczkowe, transformata Laplace'a), [01 Teoria obwodów](../01-teoria-obwodow/) (AC, transmitancja).

## Tematy

### Sygnały
- [ ] Klasyfikacja: ciągłe/dyskretne, deterministyczne/losowe, okresowe, energii i mocy
- [ ] Sygnały elementarne: skok, delta Diraca, wykładniczy zespolony
- [ ] Operacje: przesunięcie, skalowanie, odwrócenie; parzystość i nieparzystość

### Układy LTI
- [ ] Liniowość, stacjonarność, przyczynowość, stabilność BIBO
- [ ] Odpowiedź impulsowa, splot ciągły i dyskretny
- [ ] Opis równaniami różniczkowymi i różnicowymi

### Analiza częstotliwościowa
- [ ] Szereg Fouriera — trygonometryczny i zespolony, widmo prążkowe, twierdzenie Parsevala
- [ ] Przekształcenie Fouriera — własności, para transformat, widmo ciągłe
- [ ] Transformata Laplace'a w analizie układów, transmitancja, bieguny i zera, stabilność
- [ ] Charakterystyki amplitudowa i fazowa, wykresy Bodego
- [ ] Transformata Z, transmitancja dyskretna

### Próbkowanie
- [ ] Twierdzenie o próbkowaniu (Nyquista–Shannona), aliasing
- [ ] Rekonstrukcja sygnału, filtr antyaliasingowy
- [ ] Przekształcenie Fouriera w czasie dyskretnym (DTFT)

### Sygnały losowe (wstęp)
- [ ] Wartość średnia, wariancja, funkcja autokorelacji, gęstość widmowa mocy
- [ ] Szum biały, przejście szumu przez układ liniowy

## Główne źródła

- [MIT 6.003 Signals and Systems (2011)](https://ocw.mit.edu/courses/6-003-signals-and-systems-fall-2011/) — wideo, notatki, zadania z rozwiązaniami
- [MIT RES.6-007 Signals and Systems (Oppenheim)](https://ocw.mit.edu/courses/res-6-007-signals-and-systems-spring-2011/)
- [Fundamentals of Electrical Engineering I — D. Johnson](https://open.umn.edu/opentextbooks/textbooks/fundamentals-of-electrical-engineering-1)

## Ćwiczenie modułowe

Notatnik Jupyter: dla filtra RC i RLC wyznacz analitycznie transmitancję, narysuj Bodego, oblicz odpowiedź na skok przez splot numeryczny i przez odwrotną transformatę Laplace'a (SymPy). Porównaj z LTspice. Następnie spróbkuj sygnał przy różnych częstotliwościach próbkowania i pokaż aliasing.

## Sprawdzian umiejętności

- Liczę splot dwóch sygnałów prostokątnych ręcznie i interpretuję wynik.
- Wyznaczam widmo sygnału okresowego i wskazuję, które prążki przejdą przez dany filtr.
- Dobieram częstotliwość próbkowania i filtr antyaliasingowy do zadanego sygnału.
