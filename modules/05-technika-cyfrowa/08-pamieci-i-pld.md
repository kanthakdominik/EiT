# 05.08 — Pamięci i układy programowalne

## Po co to jest

Pamięci przechowują program i dane w każdym systemie cyfrowym. Układy programowalne (CPLD, FPGA) pozwalają zbudować dowolną logikę bez projektowania własnego układu scalonego. Ten temat zamyka technikę cyfrową i otwiera moduły [09](../09-mikrokontrolery-embedded/) i [17](../17-fpga-hdl/).

## Teoria w pigułce

### Organizacja pamięci

Pamięć $2^n \times m$: $n$ linii adresowych, $m$ bitów słowa. Rozszerzanie: równolegle (szersze słowo) lub z dekoderem (więcej adresów).

| Typ | Ulotna | Zasada | Cechy | Zastosowanie |
|---|---|---|---|---|
| **SRAM** | tak | Przerzutnik (6 tranzystorów na bit) | Szybka, droga, duża powierzchnia | Pamięci podręczne, RAM mikrokontrolerów |
| **DRAM** | tak | Kondensator + tranzystor | Gęsta, tania; wymaga odświeżania | Pamięć operacyjna komputerów |
| ROM / mask ROM | nie | Zapis w produkcji | — | Bootloadery |
| **EEPROM** | nie | Pływająca bramka, zapis bajtowy | Mała pojemność, dużo cykli zapisu | Konfiguracja, kalibracja |
| **Flash NOR** | nie | Pływająca bramka, kasowanie blokami | Odczyt swobodny, wykonywanie kodu | Pamięć programu |
| **Flash NAND** | nie | j.w., dostęp stronami | Duża gęstość, błędy bitowe (ECC) | Karty SD, dyski SSD |
| FRAM, MRAM | nie | Ferroelektryk / magnetyzm | Szybki zapis, bardzo dużo cykli | Rejestratory danych |

Parametry: czas dostępu, przepustowość, liczba cykli zapisu (Flash: typowo $10^4$–$10^5$), czas przechowywania danych, interfejs (równoległy, SPI, QSPI, SDRAM/DDR).

### Układy programowalne

| Układ | Budowa | Cechy |
|---|---|---|
| PAL / GAL | Programowalna matryca AND + stała OR | Historyczne, kilka funkcji |
| **CPLD** | Kilka bloków typu PAL + połączenia | Konfiguracja nieulotna, przewidywalne opóźnienia, małe |
| **FPGA** | Tysiące bloków logicznych (LUT + przerzutnik), bloki RAM, DSP, PLL, programowalne połączenia | Konfiguracja zwykle w SRAM (ładowana z Flash przy starcie), bardzo duża pojemność |

**LUT (look-up table)** — mała pamięć $2^k\times 1$ (typowo $k$ = 4–6), która realizuje dowolną funkcję $k$ zmiennych. To połączenie tematów: pamięć jako układ kombinacyjny.

Przepływ projektowy FPGA: HDL → symulacja → synteza → rozmieszczenie i połączenie → analiza czasowa → plik konfiguracyjny. Szczegóły w module [17](../17-fpga-hdl/).

## Przykład rozwiązany

Pamięć 1M × 16 bitów.

1. Linie adresowe: $2^{20} = 1\text{M}$ → 20 linii.
2. Pojemność: $2^{20}\cdot 16$ bitów = 2 MB.
3. Zbudowanie 2M × 16 z dwóch takich układów: wspólne linie $A_0$–$A_{19}$ i dane, linia $A_{20}$ przez dekoder (inwerter) steruje wejściami wyboru $\overline{CS}$ obu układów.

## Typowe pułapki

- **Zapis do Flash w pętli** (np. co sekundę) — przekroczenie liczby cykli po kilku dniach. Stosuje się buforowanie, rozkładanie zapisów (wear leveling) albo FRAM.
- **Mylenie bitów i bajtów** w pojemnościach (Mb i MB).
- **Brak ECC na NAND Flash.**
- **FPGA traktowane jak procesor** — kod HDL opisuje sprzęt działający równolegle, a nie sekwencję instrukcji.

## Ćwiczenie w symulatorze

- [ ] W Logisim-evolution użyj komponentu ROM jako dekodera wyświetlacza 7-segmentowego: zapisz w nim tablicę prawdy dla cyfr 0–F.
- [ ] Zbuduj pamięć RAM 16 × 4 z rejestrów i dekodera adresu, z sygnałami zapisu i odczytu.

## Zadania

1. Ile linii adresowych ma pamięć 64K × 8? Jaka jest jej pojemność w bajtach?
2. Pamięć 1M × 16: liczba linii adresowych i pojemność w MB.
3. Zbuduj pamięć 32K × 16 z układów 32K × 8. Jak połączysz linie danych i adresowe?
4. LUT 4-wejściowy — ile bitów konfiguracji zawiera? Ile różnych funkcji może zrealizować?
5. Rejestrator zapisuje próbkę do Flash co 10 s. Flash wytrzymuje $10^5$ cykli kasowania na sektor. Ile czasu wytrzyma, jeśli każdy zapis kasuje ten sam sektor? Jak to poprawić?

<details>
<summary>Odpowiedzi</summary>

1. 16 linii; 64 kB
2. 20 linii; 2 MB
3. Wspólne linie adresowe $A_0$–$A_{14}$ i sygnały sterujące; jeden układ daje bity $D_0$–$D_7$, drugi $D_8$–$D_{15}$
4. 16 bitów; $2^{16} = 65\,536$ funkcji
5. $10^5\cdot 10\ \text{s} = 10^6$ s ≈ 11,6 dnia. Buforować próbki w RAM i zapisywać całe strony, rozkładać zapisy na wiele sektorów (wear leveling) albo użyć FRAM
</details>

## Źródła

- [All About Circuits — tom Digital, rozdział *Digital Storage (Memory)*](https://www.allaboutcircuits.com/textbook/)
- [MIT 6.004 Computation Structures](https://ocw.mit.edu/courses/6-004-computation-structures-spring-2017/) — hierarchia pamięci, technologie pamięci
- [MIT 6.111 Introductory Digital Systems Laboratory](https://ocw.mit.edu/courses/6-111-introductory-digital-systems-laboratory-spring-2006/) — wprowadzenie do FPGA i pamięci w systemach cyfrowych
- [nand2tetris](https://www.nand2tetris.org/) — projekty 3 i 5: pamięć i architektura komputera
