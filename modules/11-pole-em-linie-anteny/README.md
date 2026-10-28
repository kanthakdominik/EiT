# 11 — Pole elektromagnetyczne, linie transmisyjne i anteny

> **Status:** 🟡 szkielet — zakres, cele i główne źródła. Pełne notatki i zadania w kolejnym etapie.

## Cel modułu

Rozumieć propagację fal elektromagnetycznych, zachowanie linii transmisyjnych i podstawy anten. To fundament techniki w.cz., integralności sygnałów i kompatybilności EM.

## Wymagania wstępne

- [00 Matematyka](../00-matematyka/) (rachunek wektorowy), [02 Fizyka](../02-fizyka-i-materialy/), [01 Teoria obwodów](../01-teoria-obwodow/) (AC).

## Tematy

### Równania Maxwella
- [ ] Postać całkowa i różniczkowa, operatory dywergencji i rotacji
- [ ] Prąd przesunięcia, równanie ciągłości
- [ ] Warunki brzegowe na granicy ośrodków
- [ ] Energia i wektor Poyntinga

### Fale płaskie
- [ ] Równanie falowe, fala płaska w ośrodku bezstratnym i stratnym
- [ ] Impedancja falowa, stała propagacji, głębokość wnikania (naskórkowość)
- [ ] Polaryzacja: liniowa, kołowa, eliptyczna
- [ ] Odbicie i załamanie na granicy ośrodków

### Linie transmisyjne
- [ ] Model linii o parametrach rozłożonych, równania telegrafistów
- [ ] Impedancja charakterystyczna, współczynnik odbicia, WFS (VSWR)
- [ ] Impedancja wejściowa linii, linie ćwierćfalowe
- [ ] Wykres Smitha, dopasowanie impedancji (stub, transformator λ/4)
- [ ] Stany nieustalone na liniach, wykres odbić (bounce diagram)
- [ ] Linie praktyczne: koncentryczna, mikropaskowa, para skręcona

### Falowody i anteny
- [ ] Falowody prostokątne — rodzaje fal, częstotliwość odcięcia
- [ ] Parametry anten: charakterystyka promieniowania, zysk, kierunkowość, impedancja
- [ ] Dipol półfalowy, monopol, szyki antenowe
- [ ] Równanie transmisji Friisa, tłumienie wolnej przestrzeni
- [ ] Propagacja fal radiowych: fala przyziemna, jonosferyczna, wielodrogowość

## Główne źródła

- [Electromagnetics, Vol. 1 — Ellingson](https://doi.org/10.21061/electromagnetics-vol-1) — linie transmisyjne, elektrostatyka, magnetostatyka, fale płaskie (z zadaniami i rozwiązaniami)
- [Electromagnetics, Vol. 2 — Ellingson](https://doi.org/10.21061/electromagnetics-vol-2) — odbicia, falowody, anteny
- [MIT 8.02 Physics II: Electricity and Magnetism](https://ocw.mit.edu/courses/8-02-physics-ii-electricity-and-magnetism-spring-2007/) — równania Maxwella na poziomie fizyki
- [Falstad — przykłady linii transmisyjnych](https://falstad.com/circuit/e-index.html) — animowane symulacje

## Ćwiczenie modułowe

Symuluj w LTspice linię bezstratną (element T) obciążoną różnymi impedancjami: zobacz odbicia przy skoku napięcia, porównaj z wykresem odbić narysowanym ręcznie. Następnie zaprojektuj dopasowanie ćwierćfalowe i sprawdź je analizą AC.

## Sprawdzian umiejętności

- Liczę impedancję wejściową linii obciążonej i zaznaczam ją na wykresie Smitha.
- Projektuję dopasowanie stubem równoległym.
- Liczę budżet łącza radiowego z równania Friisa.
