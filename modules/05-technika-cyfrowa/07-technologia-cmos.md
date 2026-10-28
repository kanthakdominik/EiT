# 05.07 — Bramki CMOS, poziomy logiczne i interfejsy

## Po co to jest

Bramka logiczna to układ analogowy z tranzystorów. Jej właściwości elektryczne decydują o tym, czy dwa układy mogą ze sobą rozmawiać, ile prądu pobiera system, jak szybkie są zbocza i dlaczego magistrala I²C potrzebuje rezystorów podciągających.

## Teoria w pigułce

### Bramki CMOS

**Inwerter:** pMOS do zasilania, nMOS do masy, bramki połączone. W stanie ustalonym zawsze jeden jest wyłączony — **brak prądu statycznego** (poza upływem). NAND: nMOS szeregowo, pMOS równolegle; NOR — odwrotnie.

### Pobór mocy

$$P_{dyn} = \alpha CV_{DD}^2f$$

$\alpha$ — współczynnik aktywności (jaka część węzłów przełącza się w cyklu), $C$ — przełączana pojemność. Dochodzą: prąd zwarcia w czasie przełączania (gdy oba tranzystory przewodzą) i upływ (dominujący w nowoczesnych procesach). Kwadratowa zależność od napięcia to powód obniżania napięć zasilania rdzeni (1,8 → 1,2 → 0,8 V).

### Poziomy logiczne i margines szumowy

| Parametr | Znaczenie |
|---|---|
| $V_{OH,min}$ / $V_{OL,max}$ | Najgorsze napięcie wyjściowe dla stanu 1 / 0 (przy danym obciążeniu) |
| $V_{IH,min}$ / $V_{IL,max}$ | Minimalne napięcie rozpoznawane jako 1 / maksymalne jako 0 |
| Margines szumowy | $NM_H = V_{OH,min} - V_{IH,min}$, $NM_L = V_{IL,max} - V_{OL,max}$ |

Przykład dla LVCMOS/LVTTL 3,3 V (typowe wartości z dokumentacji): $V_{OH,min} = 2{,}4$ V, $V_{OL,max} = 0{,}4$ V, $V_{IH,min} = 2{,}0$ V, $V_{IL,max} = 0{,}8$ V → marginesy po 0,4 V.

**Łączenie 3,3 V i 5 V:** wyjście 3,3 V do wejścia 5 V CMOS (próg $V_{IH} \approx 3{,}5$ V) — **nie działa niezawodnie**; do wejścia 5 V typu TTL (próg 2 V) — działa. Wyjście 5 V do wejścia 3,3 V — tylko jeśli wejście toleruje 5 V; inaczej dzielnik, bufor z tolerancją albo translator poziomów.

### Typy wyjść

| Wyjście | Cechy | Zastosowanie |
|---|---|---|
| Przeciwsobne (push-pull) | Aktywnie wymusza 0 i 1 | Większość sygnałów |
| **Otwarty dren / kolektor** | Tylko ściąga do 0; 1 daje rezystor podciągający | I²C, linie przerwań, łączenie „przewodowe AND”, zmiana poziomu napięcia |
| Trójstanowe | Dodatkowo stan wysokiej impedancji | Magistrale współdzielone |

Rezystor podciągający dla otwartego drenu: górna granica wynika z czasu narastania $t_r \approx 0{,}85RC$ (od 30% do 70% $V_{DD}$), dolna — z prądu, który wyjście może ściągnąć przy $V_{OL,max}$.

### Inne

Nieużywane wejścia CMOS **nie mogą wisieć** (podłącz do masy lub zasilania). Wejścia z przerzutnikiem Schmitta dla wolnych zboczy. Ochrona ESD i diody wejściowe do szyn zasilania (prąd przez nie może zasilić cały układ przy odłączonym zasilaniu — „zasilanie fantomowe”).

## Przykład rozwiązany

**Rezystory podciągające I²C:** 3,3 V, pojemność magistrali 200 pF, tryb Fast (400 kHz) wymaga $t_r \leq 300$ ns, wyjście ściąga do 0,4 V przy 3 mA.

1. $R_{max} = \dfrac{300\ \text{ns}}{0{,}8473\cdot 200\ \text{pF}} \approx 1{,}77$ kΩ.
2. $R_{min} = \dfrac{3{,}3 - 0{,}4}{3\ \text{mA}} \approx 0{,}97$ kΩ.
3. Wybór: 1,5 kΩ → $t_r \approx 254$ ns ✓.

**Moc dynamiczna:** $C = 500$ pF, $\alpha = 0{,}15$, $f = 50$ MHz, $V_{DD} = 1{,}2$ V → $P \approx 5{,}4$ mW. Przy 3,3 V byłoby 7,6 razy więcej.

## Typowe pułapki

- **Rezystor podciągający 10 kΩ „bo tak zawsze”** na szybkiej magistrali I²C — zbyt wolne zbocza.
- **Wejście 3,3 V zasilone sygnałem 5 V** bez sprawdzenia tolerancji (5 V tolerant).
- **Pływające wejścia** — pobór prądu, oscylacje, losowe stany.
- **Sygnał podany na układ bez zasilania** — prąd przez diody ESD zasila układ i może go uszkodzić.

## Symulacja

W LTspice zbuduj inwerter CMOS z dwóch MOSFET-ów (modele poziomu 1, nMOS $V_t = 0{,}7$ V, pMOS $V_t = -0{,}7$ V), zasilanie 3,3 V:
- [ ] `.dc` — charakterystyka przejściowa $U_{wy}(U_{we})$, odczytaj progi i marginesy,
- [ ] `.tran` z obciążeniem 10 pF — zmierz czasy narastania i opadania oraz prąd pobierany w chwili przełączania,
- [ ] porównaj energię pobraną w jednym cyklu z $CV_{DD}^2$.

## Zadania

1. Policz marginesy szumowe dla poziomów z tabeli (3,3 V).
2. Czy wyjście 3,3 V push-pull można podłączyć bezpośrednio do wejścia układu 5 V CMOS o $V_{IH,min} = 0{,}7V_{DD}$? Zaproponuj rozwiązanie.
3. Dobierz rezystory podciągające I²C: 3,3 V, 200 pF, 400 kHz, $I_{OL} = 3$ mA.
4. Układ pobiera 50 mW przy 3,3 V i 100 MHz (moc dynamiczna). Ile przy 1,8 V i tej samej częstotliwości?
5. Dlaczego linię przerwania wspólną dla kilku układów realizuje się wyjściami otwarty dren?

<details>
<summary>Odpowiedzi</summary>

1. $NM_H = 2{,}4 - 2{,}0 = 0{,}4$ V, $NM_L = 0{,}8 - 0{,}4 = 0{,}4$ V
2. Nie: $V_{IH} = 3{,}5$ V > 3,3 V. Translator poziomów, bufor z rodziny HCT (próg TTL) zasilany z 5 V albo wyjście otwarty dren z podciąganiem do 5 V (jeśli wyjście to toleruje)
3. Zakres ok. 0,97–1,77 kΩ, np. 1,5 kΩ
4. $50\cdot(1{,}8/3{,}3)^2 \approx 14{,}9$ mW
5. Każdy układ może ściągnąć linię do zera bez konfliktu z innymi (żaden nie wymusza aktywnie jedynki), a stan niski oznacza „ktoś zgłasza przerwanie” — realizacja funkcji AND przewodowo
</details>

## Źródła

- [MIT 6.004 Computation Structures](https://ocw.mit.edu/courses/6-004-computation-structures-spring-2017/) — abstrakcja cyfrowa, marginesy szumowe, technologia CMOS
- [MIT 6.002 Circuits and Electronics](https://ocw.mit.edu/courses/6-002-circuits-and-electronics-spring-2007/) — abstrakcja cyfrowa, energia i moc w CMOS
- [All About Circuits — tom Digital, rozdział *Logic Gates*](https://www.allaboutcircuits.com/textbook/) — TTL, CMOS, wyjścia otwarty kolektor i trójstanowe
