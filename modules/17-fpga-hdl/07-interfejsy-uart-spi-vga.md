# 17.07 — Interfejsy: UART, SPI, VGA

## Po co to jest

FPGA rozmawia ze światem przez interfejsy, które w mikrokontrolerze daje gotowe peryferium, a tu trzeba je zbudować samemu — za to dokładnie takie, jakie są potrzebne, w dowolnej liczbie i z dowolną szybkością. UART, SPI i generator obrazu VGA to klasyczne pierwsze projekty: uczą automatów, liczników czasu i dokładnego przestrzegania wymagań czasowych protokołu.

## Teoria w pigułce

### UART

Protokół — [09.05](../09-mikrokontrolery-embedded/05-uart-spi-i2c.md). W FPGA: licznik `CLKS_PER_BIT` = $f_{clk}/\text{baud}$ (50 MHz / 115 200 ≈ 434, błąd 0,007%), automat START–DATA–STOP ([17.04](04-automaty-stanow.md)). Odbiornik: synchronizator wejścia, próbkowanie w środku bitu; wersja odporniejsza — **nadpróbkowanie ×16** z głosowaniem większościowym trzech próbek wokół środka. Kod: [hdl/uart_tx.v](hdl/uart_tx.v), [hdl/uart_rx.v](hdl/uart_rx.v), test w pętli zwrotnej [hdl/tb_uart.v](hdl/tb_uart.v).

### SPI

Tryby CPOL/CPHA — [09.05](../09-mikrokontrolery-embedded/05-uart-spi-i2c.md). Master w FPGA generuje SCK z zegara systemowego dzielnikiem ($f_{SCK} = f_{clk}/(2\cdot CLK\_DIV)$), **nie** używa SCK jako zegara logiki — wszystko w jednej domenie, SCK to zwykłe wyjście z rejestru. W trybie 0: MOSI ustawione przed pierwszym zboczem narastającym, MISO próbkowane na narastającym, zmiana MOSI na opadającym. Kod: [hdl/spi_master.v](hdl/spi_master.v), test z MOSI połączonym z MISO [hdl/tb_spi_master.v](hdl/tb_spi_master.v). **Slave SPI** w FPGA jest trudniejszy: SCK przychodzi z zewnątrz, więc albo nadpróbkowanie zegarem systemowym (gdy $f_{clk} \gg f_{SCK}$, np. ≥ 4–8×), albo osobna domena z CDC ([17.06](06-domeny-zegarowe-cdc.md)).

### VGA

Sygnał analogowy RGB + dwa sygnały synchronizacji. Tryb 640 × 480 @ 60 Hz:

| Parametr | Poziomo (piksele) | Pionowo (linie) |
|---|---|---|
| Obszar widoczny | 640 | 480 |
| Front porch | 16 | 10 |
| Impuls synchronizacji (ujemny) | 96 | 2 |
| Back porch | 48 | 33 |
| **Razem** | **800** | **525** |

Zegar piksela 25,175 MHz → $25\text{,}175\cdot 10^6/(800\cdot 525) \approx 59\text{,}94$ Hz (monitory zwykle akceptują 25,0 MHz → 59,5 Hz). Generator: dwa liczniki (x, y) i porównania — [hdl/vga_timing.v](hdl/vga_timing.v), test liczący piksele, linie i długości impulsów [hdl/tb_vga_timing.v](hdl/tb_vga_timing.v). Kolory: rezystory tworzące prosty przetwornik C/A (0–0,7 V na 75 Ω) lub gotowe moduły; współcześnie częściej HDMI/DVI (kodowanie TMDS, szeregowo ×10 zegara piksela — SERDES).

### Inne typowe interfejsy

I²C (open-drain, wymaga obsługi trójstanowej linii: `assign sda = sda_oe ? 1'b0 : 1'bz;`), PWM i sterowanie silnikami, przetworniki A/C i C/A (równoległe, LVDS, JESD204), kamery (DVP, MIPI CSI-2), Ethernet (MAC + PHY przez RGMII), pamięci (SDRAM, DDR — przez kontrolery producenta).

## Przykład rozwiązany

**Generator obrazu z paskami kolorów:** zegar 25 MHz z PLL, `vga_timing` daje x, y, `de`; kolor z trzech najstarszych bitów x:

```verilog
wire [2:0] bar = x[9:7];                 // 8 pasków po 80 pikseli (x = 0…639)
assign r = de & bar[2];
assign g = de & bar[1];
assign b = de & bar[0];
```

Wyjścia koloru i synchronizacji warto **zarejestrować** (wyrównanie opóźnień i brak szpilek): `always @(posedge clk_pix) {r_q, g_q, b_q, hs_q, vs_q} <= {r, g, b, hsync, vsync};`.

**SPI do przetwornika A/C** 1 MS/s, ramka 16 bitów: SCK ≥ 16 MHz (+ czas CS) → przy zegarze 100 MHz CLK_DIV = 3 daje 16,7 MHz; ramka 16 × 60 ns ≈ 0,96 µs — na granicy; z CLK_DIV = 2 (25 MHz) — 0,64 µs, zapas na czas konwersji.

## Typowe pułapki

- **SCK master SPI używany jako zegar** wewnętrznej logiki — nowa domena zegarowa bez potrzeby.
- **Odwrócona polaryzacja synchronizacji VGA** lub złe porch — monitor nie wyświetla obrazu albo przesuwa go.
- **Kolor wystawiany poza obszarem widocznym** (`de = 0`) — monitor może źle kalibrować poziom czerni.
- **I²C z wyjściem push-pull** zamiast otwartego drenu.
- **Brak synchronizatora** na wejściu UART/SPI slave.

## Ćwiczenie komputerowe

Parametry interfejsów: dzielniki UART i błąd prędkości, częstotliwość odświeżania VGA, czas ramki SPI:

```python
for clk in [12e6, 25e6, 50e6, 100e6]:
    for baud in [9600, 115200, 1e6]:
        cpb = round(clk/baud); err = (clk/cpb - baud)/baud*100
        print(f"f_clk {clk/1e6:5.1f} MHz, {baud:>8.0f} bit/s: CLKS_PER_BIT = {cpb:5d}, błąd {err:+.3f}%")
for fpix in [25.175e6, 25.0e6]:
    print(f"VGA 640x480, zegar {fpix/1e6:.3f} MHz: {fpix/(800*525):.2f} Hz")
for div in [2, 3, 4]:
    fsck = 100e6/(2*div); print(f"SPI, CLK_DIV = {div}: SCK = {fsck/1e6:.2f} MHz, 16 bitów = {16/fsck*1e9:.0f} ns")
```

## Zadania

1. Policz CLKS_PER_BIT i błąd prędkości dla 12 MHz i 115 200 bit/s. Czy to akceptowalne?
2. Jaką rozdzielczość i częstotliwość odświeżania da zegar piksela 40 MHz przy parametrach 800 × 600 (całkowity 1056 × 628)?
3. Dlaczego master SPI w FPGA generuje SCK jako wyjście rejestru, a nie z bloku PLL?
4. Zaprojektuj (opisz) odbiornik UART z nadpróbkowaniem ×16. Ile taktów zegara 50 MHz przypada na próbkę przy 115 200 bit/s?
5. Wykonaj testbenche [tb_spi_master.v](hdl/tb_spi_master.v) i [tb_vga_timing.v](hdl/tb_vga_timing.v); zmodyfikuj SPI do trybu 3 (CPOL = 1, CPHA = 1) i dopasuj testbench.

<details>
<summary>Odpowiedzi</summary>

1. $12\cdot 10^6/115\,200 = 104\text{,}17$ → 104, błąd +0,16% — akceptowalne
2. $40\cdot 10^6/(1056\cdot 628) \approx 60\text{,}3$ Hz (tryb SVGA 800 × 600 @ 60 Hz)
3. SCK musi być w ustalonej relacji z danymi (MOSI, próbkowanie MISO) generowanymi przez logikę w domenie zegara systemowego; wygenerowanie SCK licznikiem w tej samej domenie zachowuje jedną domenę i proste ograniczenia czasowe; PLL dałby osobny zegar wymagający CDC lub dodatkowych ograniczeń
4. Licznik dzieli zegar do 16 × baud ($50\cdot 10^6/(16\cdot 115\,200) \approx 27$ taktów na próbkę); po wykryciu zbocza startu odlicz 8 próbek (środek bitu startu), potem co 16 próbek; w każdym bicie weź próbki 7, 8, 9 i wybierz wartość większościową
5. —
</details>

## Źródła

- [nandland](https://nandland.com/) — UART, SPI i VGA w Verilogu/VHDL z testbenchami
- [Project F — FPGA tutorials](https://github.com/projf/projf-explore) — grafika: generatory VGA/DVI, bufory obrazu, rysowanie
- [ZipCPU](https://zipcpu.com/) — UART, SPI, magistrale, ich weryfikacja
- [09.05 UART, SPI, I²C](../09-mikrokontrolery-embedded/05-uart-spi-i2c.md) — protokoły od strony mikrokontrolera
