# 17.01 — Architektura FPGA i przepływ projektowy

## Po co to jest

FPGA to „sprzęt, który można przeprogramować”: tysiące–miliony bloków logicznych połączonych konfigurowalną siecią. Pozwala zbudować układy równoległe i deterministyczne czasowo, których mikrokontroler nie osiągnie — przetwarzanie sygnałów z dziesiątków kanałów, szybkie interfejsy, sterowanie w nanosekundach, prototypy układów scalonych. Zrozumienie, z czego składa się FPGA, tłumaczy, dlaczego kod HDL pisze się tak, a nie inaczej.

## Teoria w pigułce

### Zasoby

| Zasób | Opis |
|---|---|
| **LUT** (look-up table) | Mała pamięć realizująca dowolną funkcję 4–6 wejść; podstawowa „bramka” FPGA |
| **Przerzutnik** (FF) | Przy każdym LUT; rejestry, liczniki, potoki |
| Logika przeniesień (carry chain) | Szybkie sumatory i liczniki |
| **Sieć połączeń** (routing) | Konfigurowalne połączenia — często większa część opóźnienia niż sama logika |
| **Blokowa pamięć RAM** (BRAM) | Kilkanaście–kilkadziesiąt kbit na blok, dwuportowa — FIFO, bufory, tablice |
| **Bloki DSP** | Mnożarka (np. 18 × 18 lub 18 × 25) z sumatorem/akumulatorem — filtry, FFT |
| **Zarządzanie zegarem** (PLL, MMCM) | Mnożenie/dzielenie częstotliwości, przesuwanie fazy, globalna sieć zegarowa o małym skosie |
| **Bloki I/O** | Standardy napięciowe (LVCMOS, LVDS), rejestry wejścia/wyjścia, opóźnienia, SERDES |
| Bloki specjalne | Transceivery wielogigabitowe, kontrolery pamięci, PCIe, procesory (SoC) |

Konfiguracja przechowywana w pamięci SRAM (ładowana po włączeniu z zewnętrznej Flash) lub nieulotnej (Flash/antifuse w części rodzin).

### FPGA, mikrokontroler, ASIC

| | Mikrokontroler | FPGA | ASIC |
|---|---|---|---|
| Działanie | Sekwencyjne wykonywanie instrukcji | Równoległy sprzęt | Równoległy sprzęt, optymalny |
| Czas reakcji | µs (przerwania) | ns, deterministyczny | ns |
| Elastyczność | Program | Konfiguracja sprzętu | Brak (po produkcji) |
| Koszt jednostkowy / NRE | Niski / niski | Średni–wysoki / niski | Bardzo niski w dużej serii / bardzo wysoki |
| Pobór mocy | Mały | Średni | Najmniejszy dla danej funkcji |

Typowe zastosowania FPGA: akwizycja i przetwarzanie sygnałów (radary, SDR, obrazowanie), sterowanie napędami i energoelektroniką, szybkie interfejsy i protokoły, akceleracja obliczeń, prototypowanie ASIC, krótkie serie produktów.

### Przepływ projektowy

1. **Opis** w HDL (Verilog/SystemVerilog, VHDL) lub narzędziach wyższego poziomu (HLS z C++, Chisel, Amaranth).
2. **Symulacja funkcjonalna** z testbenchem ([17.03](03-symulacja-i-testbench.md)).
3. **Synteza** — HDL → sieć LUT, FF, BRAM, DSP; raport zasobów i ostrzeżeń (zatrzaski!).
4. **Implementacja:** rozmieszczenie (place) i prowadzenie połączeń (route) w konkretnym układzie, z **ograniczeniami** (constraints): zegary, przypisanie pinów, standardy I/O.
5. **Analiza czasowa** ([17.05](05-analiza-czasowa.md)) — czy wszystkie ścieżki mieszczą się w okresie zegara.
6. **Plik konfiguracyjny** (bitstream), programowanie układu lub pamięci Flash.
7. **Weryfikacja na sprzęcie** — wbudowane analizatory logiczne (ILA/SignalTap), diody, UART.

Narzędzia: producentów (AMD Vivado, Intel Quartus, Lattice Radiant/Diamond, Gowin, Microchip Libero) oraz otwarte (Yosys + nextpnr dla iCE40, ECP5, części Gowin; [OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build)).

## Przykład rozwiązany

**Szacowanie zasobów:** filtr FIR 64-współczynnikowy dla sygnału 16-bitowego przy 100 MS/s.
- Implementacja w pełni równoległa: 64 mnożenia na próbkę → 64 bloki DSP (lub 32 przy wykorzystaniu symetrii współczynników), suma — w łańcuchach DSP.
- Przy zegarze 400 MHz i próbkowaniu 100 MS/s każdy DSP może obsłużyć 4 mnożenia (multipleksowanie w czasie) → 16 bloków DSP.
- Mikrokontroler 200 MHz z jednym MAC na takt: 64 × 100 MS/s = 6,4·10⁹ MAC/s — ok. 32 razy za mało.

## Typowe pułapki

- **Myślenie sekwencyjne** („najpierw to, potem tamto”) przy opisie sprzętu.
- **Brak ograniczeń czasowych** — narzędzie nie wie, jak szybki ma być układ; raport „bez błędów” nic nie znaczy.
- **Generowanie zegarów logiką** (dzielnik zegara użyty jako zegar innego bloku) zamiast PLL lub sygnału zezwolenia (clock enable).
- **Ignorowanie ostrzeżeń syntezy** (zatrzaski, ucięte sygnały, niepodłączone wejścia).
- **Przypisanie pinów i standardów napięć niezgodne ze schematem płytki** — możliwe uszkodzenie.

## Ćwiczenie komputerowe

Szacowanie liczby bloków DSP i porównanie wydajności z procesorem:

```python
import math

def fir_dsp(taps, fs, fclk, symmetric=False):
    mults = math.ceil(taps/2) if symmetric else taps
    share = max(1, int(fclk // fs))                  # ile mnożeń jeden DSP może wykonać na próbkę
    return math.ceil(mults/share), mults*fs

for taps, fs, fclk, sym in [(64, 100e6, 100e6, False), (64, 100e6, 400e6, False), (64, 100e6, 400e6, True),
                            (255, 1e6, 100e6, False)]:
    dsp, macs = fir_dsp(taps, fs, fclk, sym)
    print(f"{taps} współczynników, fs = {fs/1e6:g} MS/s, zegar {fclk/1e6:g} MHz, symetria={sym}: "
          f"{dsp} bloków DSP, {macs/1e9:.2f} GMAC/s = {macs/200e6:.1f}x możliwości procesora 200 MHz (1 MAC/takt)")
```

## Zadania

1. Ile wejść ma typowy LUT współczesnych FPGA i ile funkcji logicznych może zrealizować LUT6?
2. Filtr 128 współczynników, próbkowanie 50 MS/s, zegar 200 MHz. Ile bloków DSP (bez wykorzystania symetrii)?
3. Wymień trzy sytuacje, w których wybierzesz FPGA zamiast mikrokontrolera.
4. Dlaczego sieć połączeń wpływa na maksymalną częstotliwość pracy bardziej niż w układzie ASIC?
5. Do czego służą ograniczenia (constraints) w przepływie projektowym?

<details>
<summary>Odpowiedzi</summary>

1. 4–6 (współczesne: 6); LUT6 realizuje dowolną z $2^{64}$ funkcji 6 zmiennych
2. Każdy DSP może wykonać 4 mnożenia na próbkę → 32 bloki
3. Np. równoległe przetwarzanie wielu kanałów przy dużych szybkościach; deterministyczne opóźnienia rzędu ns (sterowanie, synchronizacja); niestandardowe szybkie interfejsy (kamery, przetworniki LVDS/JESD); akceleracja algorytmów
4. Połączenia w FPGA przechodzą przez programowalne przełączniki i segmenty o większej rezystancji i pojemności; w ASIC połączenia są „na wymiar”
5. Informują narzędzia o częstotliwościach zegarów, relacjach między nimi, opóźnieniach wejść/wyjść, przypisaniu pinów i standardach — bez nich implementacja nie może optymalizować ani weryfikować czasów
</details>

## Źródła

- [nandland](https://nandland.com/) — czym jest FPGA, bloki logiczne, przepływ projektowy
- [MIT 6.111 Introductory Digital Systems Laboratory](https://ocw.mit.edu/courses/6-111-introductory-digital-systems-laboratory-spring-2006/) — architektura FPGA i projektowanie systemów
- [OSS CAD Suite (YosysHQ)](https://github.com/YosysHQ/oss-cad-suite-build) — otwarty przepływ: synteza, implementacja, symulacja
- [ZipCPU](https://zipcpu.com/) — praktyczne artykuły o projektowaniu dla FPGA
