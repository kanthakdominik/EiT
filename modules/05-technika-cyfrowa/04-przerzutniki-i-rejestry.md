# 05.04 — Przerzutniki i rejestry

## Po co to jest

Przerzutniki dają układom cyfrowym pamięć — bez nich nie ma liczników, automatów, rejestrów procesora ani interfejsów szeregowych. Rozróżnienie zatrzasku i przerzutnika wyzwalanego zboczem to podstawa poprawnego projektowania synchronicznego.

## Teoria w pigułce

### Zatrzaski (latch) — wrażliwe na poziom

- **Zatrzask RS** — dwie bramki NOR (lub NAND) ze sprzężeniem krzyżowym. Stan $S = R = 1$ (dla NOR) jest zabroniony.
- **Zatrzask D** — przy aktywnym sygnale zezwolenia $E$ wyjście „przepuszcza” wejście $D$ (jest przezroczyste); po jego dezaktywacji pamięta ostatnią wartość.

### Przerzutniki — wyzwalane zboczem

| Typ | Równanie stanu następnego | Uwagi |
|---|---|---|
| **D** | $Q^+ = D$ | Standard w projektowaniu synchronicznym i FPGA |
| JK | $Q^+ = J\overline{Q} + \overline{K}Q$ | $J = K = 1$ → zmiana stanu |
| T | $Q^+ = T \oplus Q$ | Liczniki |

Przerzutnik D wyzwalany zboczem buduje się z dwóch zatrzasków (master–slave) sterowanych przeciwnymi fazami zegara.

**Wejścia asynchroniczne** (set, reset) działają niezależnie od zegara — zwykle tylko do inicjalizacji przy włączeniu zasilania.

### Rejestry

| Rejestr | Zastosowanie |
|---|---|
| Równoległy (zatrzaskowy, $n$ przerzutników D ze wspólnym zegarem) | Przechowanie słowa danych |
| Przesuwny SISO / SIPO / PISO | Konwersja szeregowo-równoległa (SPI, UART), linie opóźniające |
| Z zezwoleniem zapisu | Zapis tylko gdy $EN = 1$ (multiplekser przed wejściem D, **nie** bramkowanie zegara) |
| Pierścieniowy, Johnsona | Proste liczniki i generatory sekwencji |
| **LFSR** (rejestr z liniowym sprzężeniem zwrotnym) | Generatory pseudolosowe, CRC, skramblery |

Typowe układy scalone: 74HC74 (2× D), 74HC595 (SIPO z zatrzaskiem wyjściowym — rozszerzanie wyjść mikrokontrolera), 74HC165 (PISO — rozszerzanie wejść).

## Przykład rozwiązany

**Rozszerzenie wyjść mikrokontrolera rejestrem 74HC595.** Mikrokontroler ma wysterować 16 diod LED, a ma wolne tylko 3 piny.

1. Dwa układy 595 połączone kaskadowo (wyjście szeregowe pierwszego do wejścia drugiego).
2. Piny: dane (SER), zegar przesuwania (SRCLK), zegar zatrzasku wyjściowego (RCLK).
3. Wysyłasz 16 bitów (16 zboczy SRCLK), potem jedno zbocze RCLK — wszystkie wyjścia zmieniają się naraz. Zatrzask wyjściowy zapobiega „przemykaniu” danych przez diody podczas przesuwania.
4. Interfejs SPI mikrokontrolera robi to sprzętowo: MOSI → SER, SCK → SRCLK, dowolny GPIO → RCLK.

## Typowe pułapki

- **Bramkowanie zegara** (AND zegara z sygnałem zezwolenia) — powoduje szpilki i przesunięcia zegara. Zezwolenie realizuje się multiplekserem na wejściu D.
- **Zatrzask zamiast przerzutnika** — w HDL powstaje przypadkiem, gdy w bloku kombinacyjnym nie każda gałąź przypisuje wartość sygnałowi.
- **Asynchroniczny reset zwalniany w dowolnej chwili** — zwolnienie blisko zbocza zegara może dać metastabilność; reset zwalnia się synchronicznie ([05.06](06-parametry-czasowe.md)).

## Ćwiczenie w symulatorze

- [ ] Zbuduj zatrzask RS z bramek NOR i sprawdź stan zabroniony.
- [ ] Zbuduj przerzutnik D master–slave z dwóch zatrzasków D i sprawdź, że reaguje tylko na zbocze.
- [ ] Zbuduj 4-bitowy LFSR z odczepami dla wielomianu $x^4 + x^3 + 1$ i sprawdź, że przechodzi przez 15 stanów niezerowych.

## Zadania

1. Wypełnij tablicę stanów zatrzasku RS z bramek NOR. Dlaczego stan $S = R = 1$ jest zabroniony?
2. Przerzutnik JK ma $J = K = 1$, zegar 1 MHz. Jaki przebieg pojawi się na wyjściu?
3. Ile cykli zegara trzeba, aby przez rejestr SIPO przesłać jeden bajt?
4. Zaprojektuj rejestr 1-bitowy z zezwoleniem zapisu (przerzutnik D + multiplekser).
5. Ile stanów przechodzi maksymalny 8-bitowy LFSR? Dlaczego nie $2^8$?

<details>
<summary>Odpowiedzi</summary>

1. $S = R = 0$ — pamiętanie; $S = 1$ — ustawienie $Q = 1$; $R = 1$ — kasowanie; $S = R = 1$ daje $Q = \overline{Q} = 0$, a po jednoczesnym powrocie do 0 stan końcowy jest nieokreślony
2. Prostokąt 500 kHz (dzielnik przez 2)
3. 8
4. $D = EN\cdot D_{in} + \overline{EN}\cdot Q$
5. $2^8 - 1 = 255$ — stan zerowy jest stanem „zakleszczonym”, z którego LFSR nie wychodzi
</details>

## Źródła

- [All About Circuits — tom Digital, rozdziały *Multivibrators* i *Shift Registers*](https://www.allaboutcircuits.com/textbook/)
- [MIT 6.004 Computation Structures](https://ocw.mit.edu/courses/6-004-computation-structures-spring-2017/) — elementy pamiętające, dyscyplina synchroniczna
- [nand2tetris](https://www.nand2tetris.org/) — projekt 3: pamięć sekwencyjna
- [Ben Eater](https://eater.net/8bit/) — budowa zatrzasków, przerzutników i rejestrów na płytce stykowej
