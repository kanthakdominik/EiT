# 17 — Układy programowalne FPGA i języki HDL

> **Status:** 🟡 szkielet — zakres, cele i główne źródła. Pełne notatki i zadania w kolejnym etapie.

## Cel modułu

Opisywać sprzęt w języku HDL, symulować go i implementować w układzie FPGA. Rozumieć różnicę między programem a opisem sprzętu.

## Wymagania wstępne

- [05 Technika cyfrowa](../05-technika-cyfrowa/).

## Tematy

- [ ] Architektura FPGA: bloki logiczne (LUT, przerzutniki), zasoby połączeń, bloki RAM, DSP, PLL
- [ ] Przepływ projektowy: opis HDL → symulacja → synteza → implementacja → plik konfiguracyjny
- [ ] Verilog lub VHDL: moduły, sygnały, procesy, logika kombinacyjna i sekwencyjna
- [ ] Testbench i weryfikacja symulacyjna
- [ ] Automaty stanów w HDL
- [ ] Analiza czasowa: ograniczenia (constraints), ścieżka krytyczna, slack
- [ ] Domeny zegarowe i przekraczanie domen (CDC), synchronizatory, FIFO
- [ ] Interfejsy: UART, SPI, VGA w HDL
- [ ] Przetwarzanie sygnałów w FPGA: arytmetyka stałoprzecinkowa, filtr FIR w potoku
- [ ] Wprowadzenie do soft-procesorów i SoC FPGA

## Główne źródła

- [nand2tetris](https://www.nand2tetris.org/) — prosty HDL i symulator, budowa procesora
- [Logisim-evolution](https://github.com/logisim-evolution/logisim-evolution) i [Digital](https://github.com/hneemann/Digital) — eksport schematów do HDL jako most między schematem a kodem

Dedykowany kurs Verilog/VHDL zostanie dodany po weryfikacji w kolejnym etapie.

## Ćwiczenie modułowe

Zaimplementuj w HDL odbiornik UART z nadpróbkowaniem, napisz testbench z losowymi danymi, zsyntezuj na wybranej płytce FPGA i wyświetl odebrane znaki na diodach lub wyświetlaczu.

## Sprawdzian umiejętności

- Piszę automat stanów w HDL z testbenchem.
- Czytam raport czasowy i wskazuję ścieżkę krytyczną.
- Bezpiecznie przenoszę sygnał między domenami zegarowymi.
