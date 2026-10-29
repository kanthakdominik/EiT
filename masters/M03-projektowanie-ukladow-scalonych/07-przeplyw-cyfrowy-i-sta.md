# M03.07 — Przepływ cyfrowy RTL → GDS i analiza czasowa

## Po co to jest

Opis w Verilogu, który w [module 17](../../modules/17-fpga-hdl/) trafiał do FPGA, może stać się fizycznym układem scalonym. Różnica: zamiast gotowej struktury programowalnej narzędzia rozmieszczają i łączą tysiące–miliony komórek standardowych, budują sieć zasilania i drzewo zegara, a statyczna analiza czasowa musi przejść we wszystkich narożnikach procesu, napięcia i temperatury — bo po produkcji niczego nie da się poprawić. Otwarte narzędzia (Yosys, OpenROAD, LibreLane) pozwalają przejść całą drogę na otwartym PDK.

## Teoria w pigułce

### Etapy

| Etap | Narzędzie (otwarte) | Wynik i sprawdzenia |
|---|---|---|
| RTL i weryfikacja | Icarus, Verilator, cocotb | Testbenche, pokrycie, sprawdzenia formalne (SymbiYosys) |
| **Synteza** | Yosys + ABC | Netlista z komórek biblioteki; raport powierzchni, wstępne czasy |
| **Plan rozmieszczenia** (floorplan) | OpenROAD | Wymiary rdzenia, wyprowadzenia, makra, **sieć zasilania** (PDN) |
| **Rozmieszczenie** | OpenROAD (RePlAce, detailed placement) | Położenie komórek, optymalizacja czasów (zmiana rozmiarów, bufory) |
| **Drzewo zegara** (CTS) | OpenROAD (TritonCTS) | Bufory zegara, minimalizacja przesunięcia (skew) |
| **Trasowanie** | OpenROAD (globalne i szczegółowe) | Połączenia w warstwach metalu |
| **Ekstrakcja i STA** | OpenRCX, OpenSTA | Zapas czasu po trasowaniu we wszystkich narożnikach |
| **Weryfikacja fizyczna** | Magic/KLayout (DRC), Netgen (LVS) | Zgodność z regułami i z netlistą; reguły antenowe, gęstości |
| GDS | — | Plik do produkcji |

LibreLane spina te kroki w powtarzalny przepływ z plikiem konfiguracyjnym (częstotliwość zegara, gęstość rozmieszczenia, wymiary) — to ten sam mechanizm, którego używa Tiny Tapeout dla projektów cyfrowych.

### Statyczna analiza czasowa (STA)

Sprawdza wszystkie ścieżki między przerzutnikami bez symulacji wektorów testowych.

- **Ustalanie (setup):** $t_{clk\to Q} + t_{logika} + t_{setup} \leq T_{clk} + t_{skew} - t_{jitter}$ — dane muszą zdążyć przed kolejnym zboczem; zapas (slack) = czas wymagany − czas dotarcia.
- **Trzymanie (hold):** $t_{clk\to Q} + t_{logika,min} \geq t_{hold} + t_{skew}$ — dane nie mogą zmienić się za wcześnie; **nie zależy od częstotliwości** — błędu hold nie naprawi wolniejszy zegar.
- **Narożniki:** setup sprawdza się w najwolniejszym (SS, niskie napięcie, wysoka lub niska temperatura — przy małych napięciach odwrócenie temperaturowe), hold — w najszybszym (FF).
- **Ograniczenia (SDC):** okres zegara, opóźnienia wejść i wyjść względem zegarów zewnętrznych, ścieżki fałszywe i wielocyklowe, przejścia między domenami zegara.
- Naprawa naruszeń: setup — podział logiki (potokowanie), szybsze/większe komórki, lepsze rozmieszczenie; hold — wstawienie buforów opóźniających.

### Sieć zasilania i integralność

- Spadek napięcia (IR drop) na sieci zasilania spowalnia komórki — analiza statyczna i dynamiczna.
- Elektromigracja w szynach i połączeniach ([23.08](../../modules/23-technologia-mikroelektroniczna/08-obudowy-i-niezawodnosc.md)).
- Przesłuchy między długimi połączeniami — zmiana opóźnień (SI w STA).

## Przykład rozwiązany

**Ścieżka krytyczna przy 800 MHz** ($T_{clk} = 1\text{,}25$ ns), $t_{clk\to Q} = 0\text{,}30$ ns, bramki NAND2 → INV → XOR → AOI → BUF i połączenia po 0,03 ns, $t_{setup} = 0\text{,}08$ ns, przesunięcie zegara +0,05 ns (korzystne), jitter 0,03 ns:

- Czas dotarcia na wejście D: 1,13 ns; zapas setup: $(1\text{,}25 + 0\text{,}05 - 0\text{,}03 - 0\text{,}08) - 1\text{,}13 = +0\text{,}06$ ns ✓ (typowo).
- Najwyższa częstotliwość tej ścieżki: ok. 840 MHz.
- W narożniku SS (opóźnienia ×1,35): zapas **−0,34 ns** ✗ — układ nie spełni wymagań dla części egzemplarzy lub przy niskim napięciu i trzeba poprawić ścieżkę albo obniżyć częstotliwość.
- Hold na najkrótszej ścieżce: zapas +0,77 ns (TT), +0,56 ns (FF) ✓.

## Typowe pułapki

- **STA tylko w narożniku typowym** — układ „działa” w raporcie, ale nie w produkcji.
- **Brak lub błędne ograniczenia wejść/wyjść** — ścieżki do wyprowadzeń nieanalizowane.
- **Przejścia między domenami zegara bez synchronizatorów** i bez oznaczenia w SDC — STA ich nie sprawdzi, a w krzemie pojawi się metastabilność.
- **Za duża gęstość rozmieszczenia** — przekrwienie trasowania, objazdy, pogorszenie czasów lub niemożność dokończenia trasowania.
- **Ignorowanie IR drop** — w krzemie komórki są wolniejsze niż w STA bez spadku napięcia.
- **Brak symulacji na poziomie bramek** z opóźnieniami (SDF) dla krytycznych ścieżek asynchronicznych (reset, interfejsy).

## Ćwiczenie komputerowe

Uproszczona STA: czasy dotarcia w grafie bramek, zapasy setup i hold, wpływ narożników:

```python
import numpy as np

# statyczna analiza czasowa (STA) prostego grafu: najdłuższa ścieżka między przerzutnikami
# węzły: wejścia (wyjścia przerzutników startowych) → bramki → wejście przerzutnika docelowego
gates = {                      # nazwa: (opóźnienie [ns], lista poprzedników)
    "ff_a": (0.30, []), "ff_b": (0.30, []), "ff_c": (0.30, []),     # opóźnienie clk→Q
    "nand1": (0.12, ["ff_a", "ff_b"]), "inv1": (0.05, ["nand1"]),
    "xor1": (0.20, ["inv1", "ff_c"]), "nor1": (0.15, ["ff_b", "ff_c"]),
    "aoi1": (0.18, ["xor1", "nor1"]), "buf1": (0.10, ["aoi1"]),
}
wire = 0.03                      # opóźnienie połączenia na każdej krawędzi
arrival = {}
for g, (d, preds) in gates.items():                  # kolejność słownika jest topologiczna
    arrival[g] = d + max((arrival[p] + wire for p in preds), default=0.0)
path_end = arrival["buf1"] + wire

T_clk, t_setup, t_hold, skew, jitter = 1.25, 0.08, 0.03, 0.05, 0.03   # 800 MHz
slack_setup = (T_clk + skew - jitter - t_setup) - path_end
print(f"czas dotarcia na wejście D: {path_end:.3f} ns; zapas setup = {slack_setup:+.3f} ns przy 800 MHz")
f_max_MHz = 1e3/(path_end + t_setup + jitter - skew)          # czasy w ns → MHz
print(f"maksymalna częstotliwość tej ścieżki ≈ {f_max_MHz:.0f} MHz")

# ścieżka najkrótsza (hold): ff_c → nor1 → aoi1 → buf1
short = 0.30 + wire + 0.15 + wire + 0.18 + wire + 0.10 + wire
slack_hold = short - (t_hold + skew)
print(f"najkrótsza ścieżka: {short:.3f} ns; zapas hold = {slack_hold:+.3f} ns (hold nie zależy od częstotliwości zegara)")

# wpływ narożników procesu: opóźnienia ×1,35 (SS, niskie napięcie, wysoka temperatura) i ×0,75 (FF)
for corner, k in (("SS", 1.35), ("TT", 1.0), ("FF", 0.75)):
    print(f"{corner}: zapas setup {(T_clk + skew - jitter - t_setup) - path_end*k:+.3f} ns, zapas hold {short*k - (t_hold + skew):+.3f} ns")
```

Ćwiczenie z narzędziami: przeprowadź projekt z [17.07](../../modules/17-fpga-hdl/07-interfejsy-uart-spi-vga.md) (np. nadajnik UART) przez LibreLane na SKY130 lub GF180; odczytaj raport STA we wszystkich narożnikach, zwiększaj częstotliwość zegara aż do pojawienia się ujemnego zapasu i zidentyfikuj ścieżkę krytyczną.

## Zadania

1. Zegar 500 MHz, $t_{clk\to Q} = 0\text{,}2$ ns, $t_{setup} = 0\text{,}1$ ns, bez przesunięć. Jakie maksymalne opóźnienie logiki?
2. Raport pokazuje naruszenie hold −50 ps. Czy pomoże zmniejszenie częstotliwości zegara? Co zrobić?
3. Dlaczego hold sprawdza się w narożniku FF, a setup — w SS?
4. Co to jest ścieżka wielocyklowa i jak ją oznaczyć?
5. Po co drzewo zegara, skoro można poprowadzić jedną szeroką ścieżkę do wszystkich przerzutników?

<details>
<summary>Odpowiedzi</summary>

1. $2 - 0\text{,}2 - 0\text{,}1 = 1\text{,}7$ ns
2. Nie — warunek hold nie zawiera okresu zegara. Trzeba wstawić bufory opóźniające na krótkiej ścieżce (narzędzia robią to automatycznie przy naprawie hold) lub zmniejszyć przesunięcie zegara
3. Naruszenie hold grozi, gdy dane są najszybsze (najkrótsze opóźnienia — FF), a setup — gdy są najwolniejsze (SS); każdy warunek sprawdza się w najgorszym dla niego przypadku
4. Ścieżka, na której wynik jest potrzebny dopiero po $N$ cyklach (np. dzielnik sterowany sygnałem „ważne co 2 cykle”); w SDC: `set_multicycle_path` z odpowiednią korektą dla hold — tylko gdy logika rzeczywiście to gwarantuje
5. Tysiące wejść zegara to ogromna pojemność; jedna ścieżka miałaby duże opóźnienie i różne czasy dotarcia do odległych przerzutników (duże przesunięcie); drzewo buforów równoważy opóźnienia i zbocza, ograniczając skew i moc
</details>

## Źródła

- [LibreLane (GitHub)](https://github.com/librelane/librelane) — przepływ RTL → GDSII
- [OpenROAD — dokumentacja](https://openroad.readthedocs.io/)
- [Tiny Tapeout](https://tinytapeout.com/) — szablon projektu cyfrowego i automatyczne utwardzanie (hardening)
- [MIT 6.374 Analysis and Design of Digital Integrated Circuits](https://ocw.mit.edu/courses/6-374-analysis-and-design-of-digital-integrated-circuits-fall-2003/) — taktowanie, elementy sekwencyjne
