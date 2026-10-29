# 17.04 — Automaty stanów i sterowanie

## Po co to jest

Prawie każdy blok sterujący w FPGA — interfejs komunikacyjny, sekwencer pomiarów, kontroler pamięci, obsługa przycisków — to automat stanów. W HDL opisuje się go bezpośrednio jako rejestr stanu i funkcję przejść ([05.05](../05-technika-cyfrowa/05-liczniki-i-automaty.md)). Czytelny, jednolity styl pisania automatów zmniejsza liczbę błędów i ułatwia weryfikację.

## Teoria w pigułce

### Style opisu

| Styl | Opis | Cechy |
|---|---|---|
| **Jeden blok** `always @(posedge clk)` | Stan, liczniki i wyjścia przypisywane w jednym bloku sekwencyjnym | Zwarty, wyjścia rejestrowane (bez szpilek), opóźnione o takt — jak w [uart_tx.v](hdl/uart_tx.v) |
| **Dwa bloki** | Rejestr stanu (`always @(posedge clk) state <= next;`) + logika następnego stanu i wyjść (`always @(*)`) | Zgodny z teorią Moore'a/Mealy'ego, wyjścia od razu; uwaga na zatrzaski — wartości domyślne |
| Trzy bloki | Osobno wyjścia rejestrowane | Większe projekty |

### Kodowanie stanów

Stałe `localparam` (czytelne nazwy); kodowanie binarne (mało przerzutników), **one-hot** (jeden przerzutnik na stan — prosta logika, często szybsze w FPGA), Graya. Narzędzia syntezy zwykle same wybierają kodowanie (można wymusić atrybutem). W SystemVerilogu: `typedef enum logic [1:0] {IDLE, START, ...} state_t;`.

### Dobre praktyki

- Stan po resecie jednoznaczny; `default` w `case` prowadzący do stanu bezpiecznego (nieużywane kody stanu — [05.05](../05-technika-cyfrowa/05-liczniki-i-automaty.md)).
- **Liczniki czasu** w stanach (opóźnienia, czas bitu) zamiast osobnych automatów.
- Wejścia asynchroniczne **synchronizowane** przed użyciem w warunkach przejść ([17.06](06-domeny-zegarowe-cdc.md)).
- Wyjścia sterujące innymi blokami jako impulsy jednego taktu (`valid`, `done`).
- Diagram stanów w dokumentacji, zgodny z kodem.

## Przykład rozwiązany

**Odbiornik UART** — [hdl/uart_rx.v](hdl/uart_rx.v), automat jednoblokowy z czterema stanami:

| Stan | Działanie | Przejście |
|---|---|---|
| IDLE | Czekaj na 0 na (zsynchronizowanym) wejściu | → START |
| START | Odlicz pół bitu; sprawdź, czy nadal 0 | → DATA (lub IDLE — zakłócenie) |
| DATA | Co CLKS_PER_BIT taktów próbkuj bit (środek), 8 razy | → STOP |
| STOP | Odlicz bit; jeśli 1 — zapisz dane i wystaw `valid` | → IDLE |

```verilog
START: begin                                 // czekaj do środka bitu startu
    if (clk_cnt == (CLKS_PER_BIT - 1) / 2) begin
        clk_cnt <= 0;
        state   <= (rx_s1 == 1'b0) ? DATA : IDLE;   // odrzuć krótkie zakłócenie
    end else clk_cnt <= clk_cnt + 1'b1;
end
```

Testbench [hdl/tb_uart.v](hdl/tb_uart.v) łączy nadajnik z odbiornikiem i sprawdza 6 bajtów (w tym 0x00 i 0xFF — przypadki graniczne). Ten sam automat w Pythonie (model cyklowy) odtworzył wszystkie bajty — zob. ćwiczenie.

**Eliminacja drgań** — [hdl/debounce.v](hdl/debounce.v): de facto automat dwustanowy (wyjście 0/1) z licznikiem stabilności; testbench [hdl/tb_debounce.v](hdl/tb_debounce.v) sprawdza, że drgania krótsze niż N taktów nie zmieniają wyjścia.

## Typowe pułapki

- **Brak `default`** w `case` (stan nieużywany → zawieszenie) i niepełne przypisania w stylu dwublokowym (zatrzaski).
- **Asynchroniczne wejście w warunku przejścia bez synchronizacji** — automat może przejść do kilku stanów „naraz” (część przerzutników kodu stanu widzi 0, część 1).
- **Wyjścia kombinacyjne z automatu Mealy'ego** sterujące zegarami lub resetami — szpilki.
- **Liczniki o złej szerokości** (`$clog2` od niewłaściwej wartości) — przepełnienie przed osiągnięciem wartości końcowej.

## Ćwiczenie komputerowe

Model cyklowy nadajnika i odbiornika UART w Pythonie — ta sama logika co w Verilogu (stan, licznik, numer bitu), z przypisaniami „nieblokującymi”:

```python
CPB = 16
IDLE, START, DATA, STOP = range(4)

def run(bytes_out, cpb_tx=CPB, cpb_rx=CPB):
    tx = dict(state=IDLE, tx=1, cnt=0, bit=0, sh=0)
    rx = dict(s0=1, s1=1, state=IDLE, cnt=0, bit=0, sh=0, data=0, valid=0)
    got, queue = [], list(bytes_out)
    def tx_step(t, start, data):
        n = dict(t)
        if t['state'] == IDLE:
            n.update(tx=1, cnt=0, bit=0)
            if start: n.update(sh=data, state=START)
        elif t['state'] == START:
            n['tx'] = 0
            n.update(cnt=0, state=DATA) if t['cnt'] == cpb_tx - 1 else n.update(cnt=t['cnt'] + 1)
        elif t['state'] == DATA:
            n['tx'] = (t['sh'] >> t['bit']) & 1
            if t['cnt'] == cpb_tx - 1:
                n['cnt'] = 0
                n.update(state=STOP) if t['bit'] == 7 else n.update(bit=t['bit'] + 1)
            else: n['cnt'] = t['cnt'] + 1
        else:
            n['tx'] = 1
            n.update(cnt=0, state=IDLE) if t['cnt'] == cpb_tx - 1 else n.update(cnt=t['cnt'] + 1)
        return n
    def rx_step(r, line):
        n = dict(r, s0=line, s1=r['s0'], valid=0)
        if r['state'] == IDLE:
            n.update(cnt=0, bit=0, state=START if r['s1'] == 0 else IDLE)
        elif r['state'] == START:
            if r['cnt'] == (cpb_rx - 1)//2: n.update(cnt=0, state=DATA if r['s1'] == 0 else IDLE)
            else: n['cnt'] = r['cnt'] + 1
        elif r['state'] == DATA:
            if r['cnt'] == cpb_rx - 1:
                n.update(cnt=0, sh=(r['sh'] & ~(1 << r['bit'])) | (r['s1'] << r['bit']))
                n.update(state=STOP) if r['bit'] == 7 else n.update(bit=r['bit'] + 1)
            else: n['cnt'] = r['cnt'] + 1
        else:
            if r['cnt'] == cpb_rx - 1:
                n.update(cnt=0, state=IDLE)
                if r['s1'] == 1: n.update(data=r['sh'], valid=1)
            else: n['cnt'] = r['cnt'] + 1
        return n
    for _ in range(20000):
        start = tx['state'] == IDLE and bool(queue)
        data = queue.pop(0) if start else 0
        line = tx['tx']
        tx, rx = tx_step(tx, start, data), rx_step(rx, line)
        if rx['valid']: got.append(rx['data'])
    return got

msg = [0x55, 0xA3, 0x00, 0xFF, 0x0F, 0x81]
print("ta sama prędkość:", run(msg) == msg)
for cpb_rx in [94, 95, 97, 103, 105, 106]:      # nadajnik CPB = 100, odbiornik z inną prędkością
    print(f"CPB nadajnika 100, odbiornika {cpb_rx} (błąd {abs(cpb_rx - 100)}%): poprawnie {run(msg, 100, cpb_rx) == msg}")
```

## Zadania

1. Narysuj diagram stanów nadajnika [uart_tx.v](hdl/uart_tx.v) z warunkami przejść.
2. Przepisz automat odbiornika w stylu dwublokowym (rejestr stanu + `always @(*)` z logiką następnego stanu). Gdzie łatwo o zatrzask?
3. Dlaczego odbiornik sprawdza wejście w środku bitu startu, a nie od razu po wykryciu zbocza?
4. Ile przerzutników potrzebuje automat o 12 stanach przy kodowaniu binarnym, a ile przy one-hot?
5. Jaki maksymalny błąd prędkości toleruje odbiornik próbkujący w środku bitu przy ramce 8N1 (bit stopu sprawdzany w środku)? Porównaj z wynikiem ćwiczenia.

<details>
<summary>Odpowiedzi</summary>

1. IDLE —start→ START —CPB taktów→ DATA —8×CPB taktów→ STOP —CPB taktów→ IDLE
2. W bloku `always @(*)` każde wyjście i `next_state` muszą mieć przypisanie w każdej gałęzi — najlepiej wartości domyślne na początku bloku (`next_state = state; valid_n = 0;`)
3. Odrzuca krótkie zakłócenia (szpilki) i ustala fazę próbkowania na środek bitu — kolejne próbki co CPB taktów trafiają w środki bitów danych
4. Binarnie 4 ($\lceil\log_2 12\rceil$), one-hot 12
5. Ostatnia próbka (bit stopu) przypada ok. 9,5 bitu po zboczu startu; łączny błąd musi być mniejszy niż ok. pół bitu → ok. $0\text{,}5/9\text{,}5 \approx 5\text{,}3\%$ (w praktyce mniej przez synchronizator, jitter i zakłócenia). Model z ćwiczenia: przy CPB = 100 odbiór działa dla błędu do 5%, a przy 6% już nie — zgodnie z szacunkiem. Dlatego zaleca się łączny błąd prędkości obu stron poniżej ok. 2–3%
</details>

## Źródła

- [nandland](https://nandland.com/) — automaty stanów i UART w Verilogu/VHDL
- [ZipCPU](https://zipcpu.com/) — projektowanie i weryfikacja automatów (m.in. odbiornik i nadajnik UART)
- [MIT 6.111](https://ocw.mit.edu/courses/6-111-introductory-digital-systems-laboratory-spring-2006/) — automaty stanów w projektach FPGA
