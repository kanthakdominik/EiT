# 17 — Układy programowalne FPGA i języki HDL

> **Status:** ✅ pełny

## Cel modułu

Opisywać sprzęt w języku HDL (Verilog), weryfikować go symulacją z testbenchami, rozumieć syntezę, analizę czasową i przenoszenie sygnałów między domenami zegarowymi, a na koniec zaimplementować projekt w układzie FPGA. Kluczowa zmiana myślenia: **kod HDL nie jest programem wykonywanym krok po kroku, tylko opisem równolegle działających układów** — przerzutników, bramek i połączeń.

## Wymagania wstępne

- [05 Technika cyfrowa](../05-technika-cyfrowa/) — logika kombinacyjna i sekwencyjna, automaty ([05.05](../05-technika-cyfrowa/05-liczniki-i-automaty.md)), parametry czasowe ([05.06](../05-technika-cyfrowa/06-parametry-czasowe.md)), układy programowalne ([05.08](../05-technika-cyfrowa/08-pamieci-i-pld.md)).
- [07 DSP](../07-cps-dsp/) — dla tematu 08 (filtry, arytmetyka stałoprzecinkowa — [07.06](../07-cps-dsp/06-realizacja-filtrow.md)).
- [09.05 UART, SPI, I²C](../09-mikrokontrolery-embedded/05-uart-spi-i2c.md) — protokoły z tematu 07.

## Tematy

| # | Temat | Czas (od zera / odświeżenie) |
|---|---|---|
| 01 | [Architektura FPGA i przepływ projektowy](01-architektura-i-przeplyw.md) | 5 h / 2 h |
| 02 | [Verilog: podstawy opisu sprzętu](02-verilog-podstawy.md) | 10 h / 3 h |
| 03 | [Symulacja i testbenche](03-symulacja-i-testbench.md) | 6 h / 2 h |
| 04 | [Automaty stanów i sterowanie](04-automaty-stanow.md) | 6 h / 2 h |
| 05 | [Analiza czasowa i potokowanie](05-analiza-czasowa.md) | 6 h / 2 h |
| 06 | [Domeny zegarowe i reset](06-domeny-zegarowe-cdc.md) | 6 h / 2 h |
| 07 | [Interfejsy: UART, SPI, VGA](07-interfejsy-uart-spi-vga.md) | 8 h / 3 h |
| 08 | [Przetwarzanie sygnałów w FPGA i systemy SoC](08-dsp-i-soc.md) | 8 h / 3 h |

## Kod i testy

Katalog [hdl/](hdl/) zawiera moduły i samosprawdzające się testbenche (każdy wypisuje `PASS` lub `FAIL`):

| Moduł | Testbench | Temat |
|---|---|---|
| [blink.v](hdl/blink.v) — dzielnik zegara | [tb_blink.v](hdl/tb_blink.v) | 02 |
| [debounce.v](hdl/debounce.v) — synchronizator + eliminacja drgań | [tb_debounce.v](hdl/tb_debounce.v) | 04, 06 |
| [uart_tx.v](hdl/uart_tx.v), [uart_rx.v](hdl/uart_rx.v) — UART 8N1 | [tb_uart.v](hdl/tb_uart.v) (pętla zwrotna) | 04, 07 |
| [fifo_sync.v](hdl/fifo_sync.v) — kolejka FIFO | [tb_fifo_sync.v](hdl/tb_fifo_sync.v) | 06 |
| [fir5.v](hdl/fir5.v) — potokowy filtr FIR | [tb_fir5.v](hdl/tb_fir5.v) (porównanie z modelem) | 05, 08 |
| [spi_master.v](hdl/spi_master.v) — master SPI, tryb 0 | [tb_spi_master.v](hdl/tb_spi_master.v) (MOSI → MISO) | 07 |
| [vga_timing.v](hdl/vga_timing.v) — synchronizacja VGA 640 × 480 | [tb_vga_timing.v](hdl/tb_vga_timing.v) (pełna ramka) | 07 |

Uruchomienie lokalnie (Icarus Verilog): `bash hdl/run_tests.sh`. Te same testy uruchamia automatycznie GitHub Actions przy każdym pushu ([plik konfiguracji](../../.github/workflows/checks.yml)) — wynik widać w zakładce *Actions* repozytorium. Bez instalacji można też wkleić moduł i testbench do [EDA Playground](https://edaplayground.com) (symulator w przeglądarce).

## Test wejściowy (diagnoza)

Około 45 minut, bez notatek.

1. Czym różni się przypisanie blokujące (`=`) od nieblokującego (`<=`) i którego używa się w logice sekwencyjnej?
2. Co zostanie zsyntezowane z `always @(*) if (en) q = d;` (bez `else`)?
3. Ścieżka ma: $t_{co}$ = 0,5 ns, logika 2 ns, połączenia 1,5 ns, $t_{su}$ = 0,3 ns. Jaka maksymalna częstotliwość zegara?
4. Dlaczego sygnał z przycisku trzeba przepuścić przez dwa przerzutniki przed użyciem w układzie synchronicznym?
5. Ile taktów zegara 50 MHz trwa bit UART przy 115 200 bit/s?
6. Jakie są parametry trybu VGA 640 × 480 @ 60 Hz (zegar piksela, liczba pikseli w linii i linii w ramce)?
7. Do czego służą bloki DSP w FPGA?

<details>
<summary>Odpowiedzi</summary>

1. Blokujące — natychmiastowa zmiana, kolejne instrukcje widzą nową wartość (logika kombinacyjna w `always @(*)`); nieblokujące — wszystkie prawe strony obliczane jednocześnie, przypisanie na końcu kroku czasowego — modeluje przerzutniki (`always @(posedge clk)`)
2. Zatrzask (latch) — przy `en = 0` q musi pamiętać wartość; zwykle niezamierzony
3. $1/(0\text{,}5 + 2 + 1\text{,}5 + 0\text{,}3)\ \text{ns} \approx 233$ MHz
4. Sygnał asynchroniczny może zmienić się w oknie setup/hold — przerzutnik wchodzi w stan metastabilny; drugi przerzutnik daje czas na jego rozstrzygnięcie (synchronizator)
5. $50\cdot 10^6/115\,200 \approx 434$
6. Zegar ok. 25,175 MHz, 800 pikseli na linię (640 widocznych), 525 linii (480 widocznych), ok. 59,94 Hz
7. Sprzętowe mnożarki z akumulatorem (MAC) — szybkie mnożenie i sumowanie w filtrach, FFT, arytmetyce

**Ocena:** 1–2 — temat 02; 3 — 05; 4 — 06; 5–6 — 07; 7 — 08.
</details>

## Projekt modułowy: odbiornik UART z wyświetlaniem na FPGA

- [ ] Uruchom testbenche z katalogu [hdl/](hdl/) i zmodyfikuj `tb_uart.v` tak, by wysyłał losowe bajty i sprawdzał także odrzucanie ramek z błędnym bitem stopu.
- [ ] Rozszerz odbiornik o **nadpróbkowanie ×16** z głosowaniem większościowym trzech próbek w środku bitu i porównaj odporność na zakłócenia (zaszumiony sygnał w testbenchu).
- [ ] Zsyntezuj projekt dla wybranej płytki FPGA (narzędzia producenta lub otwarte: Yosys + nextpnr dla układów iCE40/ECP5): odbiornik UART + FIFO + wyświetlanie odebranych znaków na diodach lub wyświetlaczu 7-segmentowym; nadajnik odsyłający echo.
- [ ] Zdefiniuj ograniczenia czasowe (zegar), przeczytaj raport czasowy, znajdź ścieżkę krytyczną.
- [ ] Zmierz analizatorem stanów logicznych przebiegi TX/RX przy komunikacji z komputerem (przejściówka USB–UART).

## Sprawdzian końcowy modułu

- [ ] Rozumiem budowę FPGA (LUT, przerzutniki, BRAM, DSP, PLL, I/O) i przepływ projektowy.
- [ ] Piszę syntezowalny Verilog: logika kombinacyjna i sekwencyjna, parametry, generatory, bez niezamierzonych zatrzasków.
- [ ] Piszę samosprawdzające się testbenche i analizuję przebiegi w symulatorze.
- [ ] Projektuję automaty stanów w HDL.
- [ ] Czytam raport czasowy, rozumiem slack, setup/hold i potokowanie.
- [ ] Bezpiecznie przenoszę sygnały i dane między domenami zegarowymi; poprawnie projektuję reset.
- [ ] Implementuję UART, SPI i generator sygnału VGA.
- [ ] Implementuję filtr FIR w arytmetyce stałoprzecinkowej i rozumiem rolę soft-procesorów i SoC FPGA.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [nandland — samouczki FPGA, Verilog i VHDL](https://nandland.com/) | Przystępne wprowadzenie z przykładami (UART, automaty, testbenche) |
| [Project F — FPGA tutorials (repozytorium)](https://github.com/projf/projf-explore) | Projekty krok po kroku: grafika VGA/DVI, dźwięk, arytmetyka, z kodem |
| [ZipCPU — blog D. Gisselquista](https://zipcpu.com/) | Projektowanie i weryfikacja (w tym formalna), magistrale, CDC, praktyka |
| [MIT 6.111 Introductory Digital Systems Laboratory](https://ocw.mit.edu/courses/6-111-introductory-digital-systems-laboratory-spring-2006/) | Kurs projektowania systemów cyfrowych na FPGA |
| [Icarus Verilog — dokumentacja](https://steveicarus.github.io/iverilog/) | Darmowy symulator Verilog |
| [EDA Playground](https://edaplayground.com) | Symulatory HDL w przeglądarce, bez instalacji |
| [OSS CAD Suite (YosysHQ)](https://github.com/YosysHQ/oss-cad-suite-build) | Otwarty zestaw: Yosys, nextpnr, symulatory, weryfikacja formalna |
| [nand2tetris](https://www.nand2tetris.org/) | Budowa komputera od bramki NAND — fundament dla architektury procesora |
| D. Harris, S. Harris — *Digital Design and Computer Architecture* (płatna) | Podręcznik: logika, HDL (SystemVerilog/VHDL), mikroarchitektura procesora |
