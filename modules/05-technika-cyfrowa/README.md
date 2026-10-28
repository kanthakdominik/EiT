# 05 — Technika cyfrowa

> **Status:** 🟡 szkielet — zakres, cele i główne źródła. Pełne notatki i zadania w kolejnym etapie.

## Cel modułu

Projektować układy kombinacyjne i sekwencyjne, rozumieć ich ograniczenia czasowe oraz to, jak bramki zbudowane są z tranzystorów.

## Wymagania wstępne

- [01 Teoria obwodów](../01-teoria-obwodow/) (podstawy), dla części o bramkach CMOS — [03 Przyrządy półprzewodnikowe](../03-przyrzady-polprzewodnikowe/).

## Tematy

### Podstawy
- [ ] Systemy liczbowe, kody (NKB, BCD, Gray, U2), arytmetyka binarna
- [ ] Algebra Boole'a, prawa De Morgana, postaci kanoniczne
- [ ] Minimalizacja: tablice Karnaugha, metoda Quine'a–McCluskeya

### Układy kombinacyjne
- [ ] Multipleksery, demultipleksery, dekodery, kodery
- [ ] Sumatory, komparatory, ALU
- [ ] Hazardy statyczne i dynamiczne

### Układy sekwencyjne
- [ ] Przerzutniki: RS, D, JK, T; zatrzaski a przerzutniki wyzwalane zboczem
- [ ] Rejestry, rejestry przesuwne, liczniki synchroniczne i asynchroniczne
- [ ] Automaty Moore'a i Mealy'ego, kodowanie stanów, minimalizacja
- [ ] Parametry czasowe: setup, hold, czas propagacji, maksymalna częstotliwość zegara
- [ ] Metastabilność i synchronizacja sygnałów asynchronicznych

### Technologie i parametry
- [ ] Bramki CMOS na poziomie tranzystorów, pobór mocy statyczny i dynamiczny
- [ ] Poziomy logiczne, marginesy szumowe, obciążalność, wyjścia trójstanowe i otwarty dren

### Pamięci i struktury programowalne
- [ ] ROM, SRAM, DRAM, Flash — budowa i organizacja
- [ ] Wprowadzenie do PLD i FPGA (rozwinięcie w module 17)

## Główne źródła

- [All About Circuits — Digital](https://www.allaboutcircuits.com/textbook/) — tom o technice cyfrowej
- [nand2tetris](https://www.nand2tetris.org/) — budowa komputera od bramki NAND
- [Ben Eater — 8-bit breadboard computer](https://eater.net/8bit/) — komputer z układów 74xx na płytkach stykowych
- Narzędzia: [Logisim-evolution](https://github.com/logisim-evolution/logisim-evolution), [Digital](https://github.com/hneemann/Digital)

## Ćwiczenie modułowe

Zaprojektuj w Logisim-evolution lub Digital sterownik sygnalizacji świetlnej z przyciskiem dla pieszych jako automat Moore'a. Dodaj licznik czasu i synchronizator wejścia przycisku. Sprawdź działanie na wykresach czasowych.

## Sprawdzian umiejętności

- Minimalizuję funkcję 4 zmiennych tablicą Karnaugha i realizuję ją na bramkach NAND.
- Projektuję licznik synchroniczny modulo N od zera.
- Wyznaczam maksymalną częstotliwość zegara ścieżki rejestr–logika–rejestr.
