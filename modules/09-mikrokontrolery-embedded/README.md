# 09 — Mikrokontrolery i systemy wbudowane

> **Status:** 🟡 szkielet — zakres, cele i główne źródła. Pełne notatki i zadania w kolejnym etapie.

## Cel modułu

Łączyć sprzęt i oprogramowanie: programować mikrokontroler na poziomie rejestrów i bibliotek, obsługiwać peryferia i interfejsy, uruchamiać układy z czujnikami.

## Wymagania wstępne

- [05 Technika cyfrowa](../05-technika-cyfrowa/), [04 Układy analogowe](../04-uklady-analogowe/) (podstawy), znajomość języka C.

## Tematy

### Architektura
- [ ] Budowa mikrokontrolera: rdzeń, pamięci, magistrale, mapa pamięci
- [ ] Architektury Harvard i von Neumann, rodziny AVR, ARM Cortex-M, RISC-V
- [ ] Zegar, reset, tryby niskiego poboru mocy

### Peryferia
- [ ] GPIO: konfiguracja, wyjścia push-pull i open-drain, rezystory podciągające
- [ ] Przerwania, priorytety, opóźnienia obsługi
- [ ] Timery: tryby pracy, PWM, przechwytywanie (input capture)
- [ ] ADC i DAC w mikrokontrolerze — konfiguracja, próbkowanie, DMA
- [ ] Watchdog

### Interfejsy komunikacyjne
- [ ] UART, RS-232, RS-485
- [ ] SPI, I²C — protokoły, diagramy czasowe, typowe błędy
- [ ] CAN, USB — wprowadzenie
- [ ] Komunikacja bezprzewodowa: Wi-Fi, BLE, LoRa — wprowadzenie

### Oprogramowanie
- [ ] Programowanie w C dla systemów wbudowanych, `volatile`, operacje bitowe
- [ ] Architektura programu: superpętla, automaty stanów, RTOS
- [ ] Debugowanie: JTAG/SWD, analizator stanów logicznych

### Sprzęt wokół mikrokontrolera
- [ ] Zasilanie, odsprzęganie, reset, oscylator kwarcowy
- [ ] Sterowanie obciążeniami: tranzystor jako klucz, przekaźnik, silnik
- [ ] Ochrona wejść, poziomy logiczne 3,3 V i 5 V

## Główne źródła

- [Embedded Controllers Using C and Arduino — J. M. Fiore](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html) — podręcznik z instrukcją laboratoryjną
- [Ben Eater](https://eater.net/8bit/) — architektura komputera i magistrale od strony sprzętu
- Dokumentacja producenta wybranego mikrokontrolera (reference manual + datasheet) — podstawowe źródło przy tym module

## Ćwiczenie modułowe

Rejestrator danych: czujnik analogowy (przez tor z modułu 04) + czujnik I²C, próbkowanie z timera, filtr cyfrowy z modułu 07, transmisja UART do komputera i wykres w Pythonie.

## Sprawdzian umiejętności

- Konfiguruję timer do generowania PWM o zadanej częstotliwości i wypełnieniu.
- Debuguję komunikację I²C analizatorem stanów logicznych.
- Projektuję zasilanie i odsprzęganie mikrokontrolera na schemacie.
