# 09.08 — Sprzęt wokół mikrokontrolera

## Po co to jest

Mikrokontroler potrzebuje zasilania, resetu, zegara i ochrony wejść, a jego piny nie sterują bezpośrednio silnikami ani przekaźnikami. Dobrze zaprojektowany schemat „wokół” mikrokontrolera to warunek, żeby oprogramowanie w ogóle miało szansę działać stabilnie.

## Teoria w pigułce

### Zasilanie i odsprzęganie

- Stabilizator (LDO lub przetwornica, [04.11](../04-uklady-analogowe/11-stabilizatory.md), moduł [15](../15-energoelektronika-zasilanie/)) z zapasem prądu na szczyty (radio, rozruch).
- **Kondensator 100 nF przy każdym pinie zasilania**, jak najbliżej, z krótką drogą do masy; do tego kondensator objętościowy (np. 4,7–10 µF) na zasilanie układu.
- Zasilanie analogowe (VDDA) filtrowane osobno (koralik ferrytowy + kondensatory).
- Detektor spadku napięcia (brown-out) — reset przy zbyt niskim napięciu zamiast niekontrolowanego działania.

### Reset i programowanie

Pin resetu z rezystorem podciągającym (często wewnętrzny) i kondensatorem (np. 100 nF) zgodnie z dokumentacją; złącze programowania/debugowania (SWD: SWDIO, SWCLK, GND, VCC, opcjonalnie RESET i SWO) — zawsze na płytce.

### Zegar kwarcowy

Kondensatory obciążenia:

$$C_1 = C_2 = 2(C_L - C_{str})$$

$C_L$ — pojemność obciążenia z dokumentacji kwarcu, $C_{str}$ — pojemność pasożytnicza (typowo 2–5 pF). Kwarc blisko układu, krótkie ścieżki, pod nim masa, bez sygnałów przechodzących obok.

### Sterowanie obciążeniami

| Obciążenie | Rozwiązanie |
|---|---|
| LED (kilka mA) | Bezpośrednio z pinu przez rezystor |
| LED mocy, taśmy LED | MOSFET low-side (logic level) + PWM |
| Przekaźnik, elektrozawór | Tranzystor + **dioda gasząca** |
| Silnik DC | Mostek H (układ scalony) z PWM; kondensatory przy silniku |
| Silnik krokowy | Driver z regulacją prądu |
| Obciążenie sieciowe | Przekaźnik lub triak z transoptorem — izolacja galwaniczna |

### Ochrona wejść i interfejsów

Rezystor szeregowy (ograniczenie prądu przez diody ESD), diody TVS na złączach zewnętrznych, filtr RC na wolnych wejściach, transoptory lub izolatory cyfrowe dla sygnałów z innych urządzeń. **Translacja poziomów** 3,3 V ↔ 5 V — [05.07](../05-technika-cyfrowa/07-technologia-cmos.md).

## Przykład rozwiązany

**Kwarc 8 MHz, $C_L = 12$ pF**, pojemność pasożytnicza 3 pF → $C_1 = C_2 = 2(12 - 3) = 18$ pF. Złe kondensatory przesuwają częstotliwość o kilkadziesiąt ppm lub uniemożliwiają start oscylatora w niskiej temperaturze.

**Przekaźnik 5 V / 70 mA z pinu 3,3 V:** tranzystor npn, $\beta_{min} = 100$, przesterowanie 3× → $I_B \approx 2\text{,}1$ mA, $R_B = (3\text{,}3 - 0\text{,}8)/2\text{,}1\ \text{mA} \approx 1\text{,}2$ kΩ; dioda 1N4148 równolegle do cewki. Alternatywa: MOSFET logic level z rezystorem 100 kΩ bramka–źródło ([03.07](../03-przyrzady-polprzewodnikowe/07-mosfet-model-i-klucz.md)).

## Typowe pułapki

- **Jeden kondensator odsprzęgający na kilka pinów zasilania**, daleko od układu.
- **Brak złącza debugowania** na prototypie.
- **Kondensatory kwarcu równe $C_L$** zamiast wyliczonych.
- **Pin mikrokontrolera bezpośrednio na złączu zewnętrznym** bez ochrony — uszkodzenie od ESD przy pierwszym podłączeniu kabla.
- **Silnik i mikrokontroler na wspólnym zasilaniu bez filtracji** — resety przy rozruchu silnika.

## Ćwiczenie praktyczne

- [ ] Przeanalizuj schemat płytki ewaluacyjnej swojego mikrokontrolera: znajdź odsprzęganie, filtr VDDA, obwód resetu, kwarce i ich kondensatory, złącze debugowania, ochronę USB.
- [ ] Zaprojektuj w KiCad schemat minimalnego systemu z mikrokontrolerem (zasilanie z USB przez LDO, reset, kwarc, SWD, LED, przycisk, wyjście na przekaźnik) — przyda się w module [16](../16-pcb-emc-konstrukcja/).

## Zadania

1. Kwarc $C_L = 12$ pF, pojemność pasożytnicza 3 pF. Kondensatory?
2. Mikrokontroler ma 4 pary pinów zasilania. Jakie kondensatory i gdzie umieścisz?
3. Dobierz tranzystor i rezystor bazy do przekaźnika 5 V / 70 mA sterowanego z 3,3 V.
4. Dlaczego zasilanie analogowe przetwornika A/C filtruje się osobno?
5. Wejście mikrokontrolera ma być podłączone do sygnału 0–24 V z maszyny. Zaproponuj układ wejściowy.

<details>
<summary>Odpowiedzi</summary>

1. 18 pF
2. 4 × 100 nF przy każdej parze pinów + jeden 4,7–10 µF na szynie zasilania; osobny filtr dla VDDA
3. Np. BC547/2N3904 (β ≥ 100, $I_C$ max ≥ 100 mA), $R_B \approx 1\text{,}2$ kΩ, dioda gasząca; albo MOSFET logic level
4. Szum od przełączania części cyfrowej (prąd impulsowy) przenosi się na odniesienie i wejście przetwornika, obniżając efektywną rozdzielczość
5. Dzielnik napięcia (np. 47 kΩ / 6,8 kΩ) z ograniczeniem prądu, kondensator filtrujący, dioda ochronna do 3,3 V lub Zener; najlepiej transoptor zapewniający izolację galwaniczną
</details>

## Źródła

- [Embedded Systems — Shape the World (J. Valvano)](https://users.ece.utexas.edu/~valvano/Volume1/E-Book/) — interfejsy sprzętowe, sterowanie obciążeniami
- [Embedded Controllers Using C and Arduino — J. M. Fiore](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html)
- Nota aplikacyjna producenta „hardware design guidelines” / „getting started with hardware development” dla wybranej rodziny — zalecane odsprzęganie, kwarce, reset
