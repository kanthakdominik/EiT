# 17.05 — Analiza czasowa i potokowanie

## Po co to jest

Projekt, który działa w symulacji, może nie działać w układzie, bo sygnały nie zdążą przejść przez logikę i połączenia przed kolejnym zboczem zegara. Statyczna analiza czasowa (STA) sprawdza to dla każdej ścieżki — pod warunkiem, że narzędzie dostało poprawne ograniczenia. Umiejętność czytania raportu czasowego i skracania ścieżki krytycznej (potokowanie) to podstawa wydajnych projektów.

## Teoria w pigułce

### Ścieżka rejestr–rejestr

Dane opuszczają przerzutnik źródłowy po $t_{co}$ (clock-to-out), przechodzą przez logikę i połączenia, muszą dotrzeć do przerzutnika docelowego $t_{su}$ przed zboczem i być stabilne $t_h$ po nim ([05.06](../05-technika-cyfrowa/06-parametry-czasowe.md)).

$$T_{clk} \geq t_{co} + t_{logika} + t_{poł} + t_{su} - t_{skos},\qquad f_{max} = \frac{1}{t_{co} + t_{logika} + t_{poł} + t_{su} - t_{skos}}$$

**Slack** (zapas) = wymagany czas przybycia − rzeczywisty; ujemny slack = naruszenie. Raport pokazuje **ścieżkę krytyczną** (najmniejszy slack), WNS (najgorszy slack) i TNS (suma ujemnych slacków). **Hold** — sprawdzany osobno; naruszenia hold usuwa narzędzie (dodając opóźnienia), o ile zegary są poprawnie zdefiniowane.

### Ograniczenia (constraints)

| Ograniczenie | Przykład (składnia w stylu SDC/XDC) |
|---|---|
| Definicja zegara | `create_clock -period 10.0 [get_ports clk]` (100 MHz) |
| Zegary wygenerowane | Z PLL — zwykle automatycznie; dzielniki logiką — `create_generated_clock` |
| Opóźnienia wejść/wyjść | `set_input_delay`, `set_output_delay` — czasy zewnętrznych układów |
| Relacje między zegarami | `set_clock_groups -asynchronous` dla domen niezależnych (z synchronizatorami — [17.06](06-domeny-zegarowe-cdc.md)) |
| Wyjątki | `set_false_path`, `set_multicycle_path` — tylko świadomie! |

### Skracanie ścieżki krytycznej

| Technika | Zasada | Koszt |
|---|---|---|
| **Potokowanie** | Rejestry pośrednie dzielą długą logikę na etapy | Opóźnienie (latencja) w taktach, więcej przerzutników |
| Retiming | Narzędzie przesuwa rejestry przez logikę | Automatyczne, zmienia strukturę |
| Wykorzystanie bloków DSP/carry | Mnożenia i sumy w dedykowanych blokach z wewnętrznymi rejestrami | — |
| Mniejsze rozgałęzienia (fan-out) | Powielenie rejestrów sterujących wieloma odbiornikami | Więcej przerzutników |
| Lepsze rozmieszczenie | Ograniczenia obszaru (floorplanning) | Praca ręczna |

**Przepustowość a opóźnienie:** potok o $k$ etapach przyjmuje nową daną co takt (przepustowość = $f_{clk}$), a wynik pojawia się po $k$ taktach. Filtr [hdl/fir5.v](hdl/fir5.v) ma 4 etapy: mnożenie, sumy częściowe, suma, skalowanie.

## Przykład rozwiązany

1. Ścieżka: $t_{co}$ = 0,5 ns, logika 2 ns, połączenia 1,5 ns, $t_{su}$ = 0,3 ns → 4,3 ns → **$f_{max} \approx 233$ MHz**. Przy zegarze 250 MHz (4 ns) slack = −0,3 ns — naruszenie.
2. Potok: podział logiki na dwa etapy po ok. 1 ns (+ połączenia po ok. 0,8 ns) → ścieżka ok. 0,5 + 1 + 0,8 + 0,3 = 2,6 ns → ok. 385 MHz, kosztem jednego taktu opóźnienia.
3. Suma 8 liczb: łańcuch 7 sumatorów vs drzewo sumatorów (3 poziomy) — drzewo z rejestrami między poziomami daje krótką ścieżkę krytyczną, jak w `fir5` (`s01`, `s23` → `s`).

## Typowe pułapki

- **Brak definicji zegara** — analiza nie sprawdza ścieżek albo zakłada domyślną częstotliwość.
- **`set_false_path` na ścieżkach, które są prawdziwe**, żeby „pozbyć się” błędów — układ zawodzi losowo.
- **Zegary generowane logiką** (dzielnik) — ścieżki między domenami bez kontroli, duży skos.
- **Długie łańcuchy porównań i multipleksery szerokie** w jednym takcie (np. wielki `case` z obliczeniami).
- **Ignorowanie ścieżek wejścia/wyjścia** — wewnętrznie OK, a interfejs z zewnętrznym układem nie spełnia wymagań.

## Ćwiczenie komputerowe

Kalkulator $f_{max}$, slacku i efektu potokowania (podział logiki na $k$ etapów, każdy etap dodaje $t_{co} + t_{su}$ i część połączeń):

```python
def fmax(tco, tlog, troute, tsu, skew=0.0):
    return 1/(tco + tlog + troute + tsu - skew)

tco, tsu = 0.5e-9, 0.3e-9
tlog, troute = 2.0e-9, 1.5e-9
f = fmax(tco, tlog, troute, tsu)
print(f"bez potoku: fmax = {f/1e6:.0f} MHz, slack przy 250 MHz = {(4e-9 - 1/f)*1e9:+.2f} ns")
for k in [2, 3, 4]:
    stage = tco + tlog/k + troute/k*1.1 + tsu           # połączenia nie dzielą się idealnie (+10%)
    print(f"potok {k} etapy: ścieżka {stage*1e9:.2f} ns, fmax = {1/stage/1e6:.0f} MHz, latencja {k} takty")
```

## Zadania

1. Okres zegara 8 ns, ścieżka: $t_{co}$ 0,4 ns, logika 4,2 ns, połączenia 3,1 ns, $t_{su}$ 0,2 ns. Slack? Co zrobisz?
2. Dlaczego potokowanie zwiększa przepustowość, choć nie skraca czasu przetworzenia jednej próbki?
3. Napisz ograniczenie dla zegara 125 MHz na porcie `clk125`.
4. Sygnał z innego zegara (asynchronicznego) przechodzi przez synchronizator. Jak opisać tę relację w ograniczeniach i dlaczego?
5. Suma 16 liczb 16-bitowych ma być liczona co takt przy 300 MHz. Zaproponuj strukturę.

<details>
<summary>Odpowiedzi</summary>

1. Ścieżka 7,9 ns → slack +0,1 ns — spełnione, ale na granicy (wrażliwe na temperaturę/rozmieszczenie); warto dodać etap potoku lub uprościć logikę
2. Każdy etap pracuje równolegle nad inną próbką — nowa dana co takt przy wyższej częstotliwości zegara; latencja w nanosekundach podobna lub nieco większa
3. `create_clock -period 8.000 -name clk125 [get_ports clk125]`
4. `set_clock_groups -asynchronous` (lub false path / max delay na ścieżce do pierwszego przerzutnika synchronizatora) — analiza czasowa nie ma sensu dla ścieżki między zegarami bez stałej relacji fazowej; bezpieczeństwo zapewnia synchronizator, a nie STA
5. Drzewo sumatorów 4 poziomy (16 → 8 → 4 → 2 → 1) z rejestrami po każdym poziomie (latencja 4 takty) lub wykorzystanie łańcuchów DSP z rejestrami wewnętrznymi
</details>

## Źródła

- [ZipCPU](https://zipcpu.com/) — potokowanie, analiza czasowa w praktyce
- [MIT 6.111](https://ocw.mit.edu/courses/6-111-introductory-digital-systems-laboratory-spring-2006/) — synchronizacja i parametry czasowe układów cyfrowych
- [05.06 Parametry czasowe](../05-technika-cyfrowa/06-parametry-czasowe.md) — setup, hold, ścieżka krytyczna od podstaw
- Dokumentacja narzędzi producentów (przewodniki po ograniczeniach czasowych i analizie raportów)
