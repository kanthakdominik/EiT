# 17.03 — Symulacja i testbenche

## Po co to jest

W FPGA debugowanie na sprzęcie jest powolne i ma słabą widoczność — dlatego większość błędów usuwa się w symulacji. Testbench to kod, który pobudza projekt, obserwuje wyjścia i **sam ocenia**, czy wynik jest poprawny. Dobry testbench znajduje błąd w sekundę, zamiast godzin z oscyloskopem i ponownej syntezy.

## Teoria w pigułce

### Budowa testbenchu

1. Moduł bez portów (`module tb_nazwa;`), deklaracje sygnałów (`reg` dla wejść, `wire` dla wyjść).
2. **Generator zegara:** `always #5 clk = ~clk;` (okres 10 ns przy `timescale 1ns/1ps`).
3. Instancja testowanego modułu (DUT).
4. **Pobudzenia** w bloku `initial`: reset, dane wejściowe, oczekiwanie na zdarzenia (`@(posedge clk)`, `wait(sygnał)`, `repeat (n)`).
5. **Sprawdzanie:** porównanie z wartością oczekiwaną lub z **modelem referencyjnym**; licznik błędów; na końcu `PASS`/`FAIL` i `$finish`.
6. Opcjonalnie zapis przebiegów: `$dumpfile("tb.vcd"); $dumpvars(0, tb_nazwa);` → przeglądarka GTKWave lub wbudowana w EDA Playground.

### Unikanie wyścigów w symulacji

Testbench i projekt reagujące na to samo zbocze zegara mogą „ścigać się” o kolejność. Proste reguły:
- **Pobudzenia zmieniaj na opadającym zboczu** (`@(negedge clk)`), a projekt pracuje na narastającym;
- **sprawdzaj wyjścia na opadającym zboczu** (stabilne w połowie okresu);
- w kodzie projektu konsekwentnie `<=` w blokach sekwencyjnych.

Tak napisane są wszystkie testbenche w [hdl/](hdl/).

### Strategie weryfikacji

| Metoda | Opis |
|---|---|
| Testy kierunkowe | Konkretne przypadki: zerowe, graniczne, typowe |
| **Losowe z modelem** | Losowe dane wejściowe, wynik porównywany z modelem behawioralnym w testbenchu (lub w Pythonie) |
| Pokrycie | Czy przetestowano wszystkie stany automatu, gałęzie, wartości graniczne |
| Asercje (SystemVerilog) | Warunki, które muszą zawsze zachodzić (`assert property`) |
| Weryfikacja formalna | Matematyczny dowód właściwości (np. SymbiYosys) — znajduje przypadki, których testy nie trafiły |
| Kosymulacja z Pythonem | cocotb — testbench w Pythonie, model referencyjny w numpy |

### Narzędzia

[Icarus Verilog](https://steveicarus.github.io/iverilog/) (`iverilog`, `vvp`) — prosty, darmowy; Verilator — bardzo szybki (kompiluje do C++), dobry do dużych projektów; symulatory producentów (Vivado, Questa); [EDA Playground](https://edaplayground.com) w przeglądarce.

## Przykład rozwiązany

Testbench filtru FIR — [hdl/tb_fir5.v](hdl/tb_fir5.v) — model referencyjny jako funkcja:

```verilog
function integer model(input integer j);       // ta sama suma co w sprzęcie, bez potoku
    model = (sample(j) + 4*sample(j-1) + 6*sample(j-2) + 4*sample(j-3) + sample(j-4)) >>> 4;
endfunction
...
for (m = 0; m < N + 6; m = m + 1) begin
    @(negedge clk);
    if (m >= 5 && m - 5 < N) begin               // potok: wynik dla x(m-5) widoczny teraz
        checks = checks + 1;
        if (y != model(m - 5)) errors = errors + 1;
    end
    x = (m < N) ? in_mem[m] : 12'sd0;            // nowe dane na zboczu opadającym
end
```

Zamiast ręcznie wyliczać oczekiwane wartości, testbench liczy je sam (model jest prosty i oczywiście poprawny). Opóźnienie (5 zboczy opadających = 4 takty potoku + 1 takt od zmiany wejścia do pierwszego zbocza) sprawdzono także modelem cyklowym w Pythonie poniżej.

## Typowe pułapki

- **Testbench, który tylko generuje przebiegi** do oglądania — błąd łatwo przeoczyć; testbench ma sam mówić PASS/FAIL.
- **Wyścigi** — pobudzenia na tym samym zboczu, na którym pracuje projekt.
- **Sprawdzanie zbyt wcześnie** (przed ustaleniem wyniku) albo zła liczba taktów opóźnienia.
- **Brak testu resetu i przypadków granicznych** (pełna kolejka, pusty bufor, wartości maksymalne).
- **Zaufanie symulacji bez syntezy** — kod z `#` opóźnieniami lub zatrzaskami działa w symulacji, a w sprzęcie inaczej.

## Ćwiczenie komputerowe

Model cyklowy filtra `fir5` w Pythonie (semantyka przypisań nieblokujących: wszystkie rejestry aktualizowane naraz) — weryfikacja opóźnienia założonego w testbenchu:

```python
import random

random.seed(1)
N = 60
inp = [1000]*10 + [-1000]*10 + [random.randint(-2047, 2047) for _ in range(N - 20)]
g = lambda k: inp[k] if 0 <= k < N else 0
f = lambda j: (g(j) + 4*g(j-1) + 6*g(j-2) + 4*g(j-3) + g(j-4)) >> 4     # >> w Pythonie: podłoga (jak >>>)

d = [0]*5; p = [0]*5; s01 = s23 = s4 = s = y = 0; errors = 0
for m in range(N + 6):
    if 5 <= m < N + 5 and y != f(m - 5): errors += 1                        # zbocze opadające: sprawdzenie
    x = inp[m] if m < N else 0
    # zbocze narastające: nowe wartości liczone ze starych (jak <=)
    d, p, s01, s23, s4, s, y = ([x] + d[:4], [d[0], 4*d[1], 6*d[2], 4*d[3], d[4]],
                                p[0] + p[1], p[2] + p[3], p[4], s01 + s23 + s4, s >> 4)
print(f"porównań: {N}, błędów: {errors}; y po skoku +1000: {f(9)}, po skoku -1000: {f(15)}")
```

## Zadania

1. Uruchom testbenche z [hdl/](hdl/) w Icarus Verilog lub EDA Playground. Dodaj `$dumpvars` do `tb_uart.v` i obejrzyj przebiegi TX i stany automatu odbiornika.
2. Wprowadź celowo błąd do `uart_rx.v` (np. próbkowanie bez czekania do środka bitu startu) i sprawdź, czy testbench go wykryje. Przy jakich warunkach błąd mógłby się „ukryć”?
3. Dopisz do `tb_fifo_sync.v` test jednoczesnego zapisu i odczytu przy częściowo zapełnionej kolejce.
4. Dlaczego pobudzenia zmienia się na opadającym zboczu zegara?
5. Czym różni się Verilator od Icarus Verilog i kiedy wybierzesz każdy z nich?

<details>
<summary>Odpowiedzi</summary>

1. —
2. Przy idealnym sygnale bez zakłóceń i dokładnie równej prędkości obu stron próbkowanie blisko zbocza może nadal działać; błąd ujawni się przy różnicy prędkości (np. CLKS_PER_BIT 16 w nadajniku i 17 w odbiorniku), jitterze lub zakłóceniach — dlatego testy powinny obejmować takie warunki
3. Np. zapis 8 wartości, potem przez 8 taktów jednocześnie `wr_en = rd_en = 1`, sprawdzenie, że liczba elementów się nie zmienia i dane wychodzą w kolejności
4. Projekt reaguje na zbocze narastające; zmiana wejść w połowie okresu gwarantuje, że w chwili zbocza narastającego wejścia są stabilne — brak wyścigu między testbenchem a projektem
5. Icarus — interpretowany, prosty, pełna obsługa konstrukcji testbenchowych Veriloga, wolniejszy; Verilator — kompiluje do C++, bardzo szybki, ograniczony do kodu syntezowalnego (testbench w C++ lub z cocotb), dobry do dużych projektów i długich symulacji
</details>

## Źródła

- [Icarus Verilog — dokumentacja](https://steveicarus.github.io/iverilog/) — kompilacja i uruchamianie symulacji
- [EDA Playground](https://edaplayground.com) — symulacja w przeglądarce
- [ZipCPU](https://zipcpu.com/) — weryfikacja symulacyjna i formalna w praktyce
- [nandland](https://nandland.com/) — pisanie testbenchy
