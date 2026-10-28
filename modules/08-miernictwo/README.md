# 08 — Miernictwo elektroniczne

> **Status:** 🟡 szkielet — zakres, cele i główne źródła. Pełne notatki i zadania w kolejnym etapie.

## Cel modułu

Mierzyć świadomie: znać przyrządy, ich ograniczenia, źródła błędów i sposób szacowania niepewności.

## Wymagania wstępne

- [01 Teoria obwodów](../01-teoria-obwodow/), [04 Układy analogowe](../04-uklady-analogowe/) (podstawy), [06 Sygnały i systemy](../06-sygnaly-i-systemy/) (widmo).

## Tematy

### Podstawy metrologii
- [ ] Jednostki SI, wzorce, spójność pomiarowa
- [ ] Błędy systematyczne i przypadkowe, niepewność typu A i B, niepewność złożona
- [ ] Rozdzielczość, dokładność, precyzja — różnice

### Przyrządy
- [ ] Multimetr: zasada działania, wartość skuteczna (True RMS), wpływ rezystancji wewnętrznej
- [ ] Oscyloskop: pasmo, czas narastania, próbkowanie, wyzwalanie, sondy 1:1 i 10:1, kompensacja sondy
- [ ] Generator funkcyjny i DDS
- [ ] Analizator widma, częstościomierz
- [ ] Mostki pomiarowe, pomiary impedancji (LCR)

### Techniki pomiarowe
- [ ] Pomiar napięcia, prądu, mocy, fazy
- [ ] Pomiar charakterystyk częstotliwościowych
- [ ] Pomiary czteroprzewodowe (Kelvina), pomiary małych sygnałów, ekranowanie, pętle masy
- [ ] Pomiary szumów

### Systemy pomiarowe
- [ ] Tor pomiarowy: czujnik → kondycjonowanie → A/C → przetwarzanie
- [ ] Czujniki: temperatury, siły, światła, prądu
- [ ] Automatyzacja pomiarów (SCPI, Python)

## Główne źródła

- [Modular Electronics Learning (ModEL) Project](https://ibiblio.org/kuphaldt/socratic/model/) — moduły o pomiarach, w tym pomiarach RF
- [All About Circuits — Experiments](https://www.allaboutcircuits.com/textbook/) — tom z ćwiczeniami i obsługą przyrządów
- [Analog Devices — Engineering University Program](https://wiki.analog.com/university) — ćwiczenia laboratoryjne

## Ćwiczenie modułowe

Zmierz charakterystykę częstotliwościową filtra z modułu 04 dwiema metodami (sweep generatora + oscyloskop oraz odpowiedź na skok + FFT). Policz niepewność wyników i porównaj z symulacją.

## Sprawdzian umiejętności

- Szacuję niepewność pomiaru na podstawie specyfikacji przyrządu.
- Dobieram pasmo oscyloskopu i sondę do mierzonego sygnału.
- Rozpoznaję typowe artefakty pomiarowe (pętla masy, obciążenie sondą, aliasing).
