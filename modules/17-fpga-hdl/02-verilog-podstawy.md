# 17.02 — Verilog: podstawy opisu sprzętu

## Po co to jest

Verilog (i jego następca SystemVerilog) to najczęściej używany język opisu sprzętu. Wygląda podobnie do C, ale opisuje równolegle działające układy — każdy blok `always` i każde przypisanie `assign` to osobny kawałek sprzętu działający jednocześnie z pozostałymi. Kilka prostych reguł decyduje o tym, czy kod da się zsyntezować i czy zachowa się w układzie tak samo jak w symulacji.

## Teoria w pigułce

### Moduł

```verilog
module nazwa #(parameter integer W = 8) (     // parametr — stała konfigurowana przy użyciu
    input  wire         clk,
    input  wire [W-1:0] a, b,
    output wire [W:0]   suma,                 // logika kombinacyjna z assign
    output reg  [W-1:0] q                     // rejestr przypisywany w always
);
    assign suma = a + b;                      // ciągłe przypisanie — przewód
    always @(posedge clk) q <= a;             // przerzutnik
endmodule
```

Hierarchia: moduły łączy się instancjami z nazwanymi portami (`blink #(.CLK_HZ(20)) u1 (.clk(clk), .rst(rst), .led(led));`).

### Typy i wartości

- `wire` — połączenie (wartość z `assign` lub wyjścia instancji); `reg` — zmienna przypisywana w `always` (**nie musi** oznaczać przerzutnika). W SystemVerilogu oba zastępuje `logic`.
- Wektory `[7:0]`, liczby z rozmiarem i podstawą: `8'hFF`, `4'b1010`, `12'sd1000` (ze znakiem); `signed` dla arytmetyki ze znakiem, `>>>` — przesunięcie arytmetyczne.
- Cztery wartości: 0, 1, **x** (nieznana), **z** (wysoka impedancja). `x` w symulacji zwykle oznacza brak resetu lub konflikt.
- Operatory: bitowe `& | ^ ~`, redukcyjne `&a`, logiczne `&& || !`, porównania, konkatenacja `{a, b}`, powielenie `{4{1'b0}}`, warunkowy `?:`.

### Logika kombinacyjna i sekwencyjna — zasady

| Logika | Konstrukcja | Przypisanie |
|---|---|---|
| Kombinacyjna | `assign` lub `always @(*)` | `=` (blokujące); **każde wyjście przypisane w każdej ścieżce** (inaczej zatrzask) |
| Sekwencyjna | `always @(posedge clk)` | `<=` (nieblokujące) |

**Dlaczego `<=` w przerzutnikach:** wszystkie prawe strony są obliczane z wartości sprzed zbocza, przypisania wykonują się „naraz” — jak w prawdziwych przerzutnikach. Rejestr przesuwny:

```verilog
always @(posedge clk) begin
    d1 <= d0;     // z <= kolejność linii nie ma znaczenia
    d2 <= d1;     // z = d2 dostałoby nową wartość d1 (= d0) — inny układ!
end
```

**Zatrzask niezamierzony:** `always @(*) if (en) q = d;` — brak `else`, więc q pamięta wartość → zatrzask. Rozwiązanie: wartość domyślna na początku bloku lub kompletne `if/else`, `case` z `default`.

### Reset

Synchroniczny (`if (rst)` wewnątrz `always @(posedge clk)`) lub asynchroniczny (`always @(posedge clk or posedge rst)`). Zalecenia producentów różnią się; ważne: **reset zewnętrzny trzeba zsynchronizować** przy zwalnianiu ([17.06](06-domeny-zegarowe-cdc.md)). Nie każdy rejestr potrzebuje resetu (np. potok danych) — mniej połączeń, łatwiejsze trasowanie.

### Parametryzacja i generowanie

`parameter`/`localparam`, `$clog2` do szerokości liczników, `generate for` do powielania struktur (np. kanały, stopnie filtra). Moduły parametryzowane (szerokość, głębokość, częstotliwość) wielokrotnego użytku.

### Konstrukcje niesyntezowalne

`#opóźnienia`, `initial` (poza inicjalizacją pamięci/rejestrów w FPGA), `$display`, `forever`, pętle zależne od danych — tylko w testbenchach. Pętla `for` w kodzie syntezowalnym jest **rozwijana** w sprzęt (powielenie), a nie wykonywana w czasie.

## Przykład rozwiązany

Dzielnik zegara z diodą — [hdl/blink.v](hdl/blink.v):

```verilog
localparam integer HALF = CLK_HZ / (2 * BLINK_HZ);
localparam integer W    = $clog2(HALF);
reg [W-1:0] cnt;
always @(posedge clk) begin
    if (rst) begin
        cnt <= 0;  led <= 1'b0;
    end else if (cnt == HALF - 1) begin
        cnt <= 0;  led <= ~led;
    end else begin
        cnt <= cnt + 1'b1;
    end
end
```

Przy 50 MHz i 1 Hz: HALF = 25 000 000, licznik 25-bitowy ($\lceil\log_2 25\cdot 10^6\rceil = 25$). Synteza: 25 przerzutników licznika + komparator + przerzutnik diody (kilkadziesiąt LUT). Testbench [hdl/tb_blink.v](hdl/tb_blink.v) sprawdza wersję z CLK_HZ = 20 (dioda zmienia stan co 10 taktów).

**Dlaczego nie „zegar 1 Hz”:** zamiast tworzyć nowy zegar z licznika, w dużych projektach licznik generuje impuls **zezwolenia** (`tick`) na jeden takt, a cała logika pracuje na zegarze głównym (`if (tick) ...`) — jedna domena zegarowa.

## Typowe pułapki

- **`=` w `always @(posedge clk)`** — kolejność linii zmienia układ, symulacja może różnić się od syntezy.
- **Niepełna lista czułości** w starym stylu `always @(a or b)` — używaj `@(*)`.
- **Zatrzaski** z niepełnych `if`/`case`.
- **Mieszanie liczb ze znakiem i bez** — jeden operand bez znaku zmienia całe wyrażenie na bez znaku.
- **Ten sam `reg` przypisywany w dwóch blokach `always`** — niesyntezowalne (dwa sterowniki).
- **Ucięcie szerokości** — `a + b` dwóch liczb 8-bitowych przypisane do 8 bitów gubi przeniesienie.

## Ćwiczenie komputerowe

Szerokości liczników i błąd dzielnika częstotliwości dla różnych zegarów (to samo liczy `$clog2` i dzielenie całkowite w Verilogu):

```python
import math

for clk, target in [(50e6, 1), (12e6, 2), (100e6, 1000), (27e6, 1000)]:
    half = int(clk // (2*target)) if target < clk/2 else 1
    w = math.ceil(math.log2(half)) if half > 1 else 1
    f_real = clk/(2*half)
    print(f"zegar {clk/1e6:6.2f} MHz, cel {target:>9g} Hz: HALF = {half:>9d}, licznik {w:2d} bit, "
          f"rzeczywiste {f_real:.4f} Hz (błąd {abs(f_real - target)/target*100:.3f}%)")
```

## Zadania

1. Napisz moduł multipleksera 4:1 dla sygnałów 8-bitowych (kombinacyjny, `case` z `default`).
2. Co zsyntezuje się z poniższego kodu i dlaczego? `always @(posedge clk) begin b = a; c = b; end`
3. Dlaczego `always @(*) case (sel) 2'b00: y = a; 2'b01: y = b; endcase` tworzy zatrzask? Popraw.
4. Ile bitów potrzebuje licznik dzielący 100 MHz do 1 kHz (przełączanie co pół okresu)?
5. Jak rozszerzyć liczbę 8-bitową ze znakiem do 16 bitów w Verilogu?

<details>
<summary>Odpowiedzi</summary>

1. `always @(*) case (sel) 2'd0: y = a; 2'd1: y = b; 2'd2: y = c; default: y = d; endcase` (y jako `reg [7:0]`)
2. Jeden przerzutnik: `c` dostaje nową wartość `b`, czyli `a` z tego samego zbocza (b i c to ten sam przerzutnik lub b staje się połączeniem) — zamiast rejestru przesuwnego dwóch stopni; z `<=` byłyby dwa przerzutniki
3. Dla sel = 2'b10 i 2'b11 `y` nie ma przypisania — musi pamiętać wartość; dodaj `default: y = 8'd0;` lub przypisanie domyślne przed `case`
4. HALF = 50 000 → 16 bitów
5. `{{8{x[7]}}, x}` albo deklaracja `wire signed [15:0] y = x;` przy `x` zadeklarowanym jako `signed`
</details>

## Źródła

- [nandland — samouczki Verilog](https://nandland.com/) — składnia, logika kombinacyjna i sekwencyjna, przypisania blokujące i nieblokujące
- [ZipCPU](https://zipcpu.com/) — dobre praktyki, typowe błędy
- [Project F](https://github.com/projf/projf-explore) — przykłady kodu w stylu nowoczesnego (System)Veriloga
- D. Harris, S. Harris — *Digital Design and Computer Architecture* (płatna) — rozdział o HDL
