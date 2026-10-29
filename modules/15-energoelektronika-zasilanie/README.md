# 15 — Energoelektronika i układy zasilające

> **Status:** ✅ pełny

## Cel modułu

Projektować zasilanie urządzeń elektronicznych — od zasilacza liniowego i stabilizatora LDO po przetwornice impulsowe nieizolowane i izolowane — z uwzględnieniem sprawności, ciepła, stabilności pętli regulacji i zakłóceń. Rozumieć zasilanie bateryjne i podstawy falowników sterujących silnikami. Każde urządzenie zaczyna się od zasilania, a większość awarii „niewyjaśnionych” zaczyna się właśnie tam.

## Wymagania wstępne

- [03 Przyrządy półprzewodnikowe](../03-przyrzady-polprzewodnikowe/) — MOSFET jako klucz ([03.07](../03-przyrzady-polprzewodnikowe/07-mosfet-model-i-klucz.md)), termika ([03.09](../03-przyrzady-polprzewodnikowe/09-datasheety-i-termika.md)).
- [04 Układy analogowe](../04-uklady-analogowe/) — prostowniki ([04.01](../04-uklady-analogowe/01-uklady-z-diodami.md)), stabilizatory ([04.11](../04-uklady-analogowe/11-stabilizatory.md)).
- [01 Teoria obwodów](../01-teoria-obwodow/) — stany nieustalone RL/RC, sprzężenia magnetyczne ([01.10](../01-teoria-obwodow/10-sprzezenia-magnetyczne.md)), obwody trójfazowe ([01.11](../01-teoria-obwodow/11-obwody-trojfazowe.md)).
- [10 Automatyka](../10-automatyka/) — stabilność i kompensacja pętli ([10.08](../10-automatyka/08-zastosowania-w-elektronice.md)).

## Tematy

| # | Temat | Czas (od zera / odświeżenie) |
|---|---|---|
| 01 | [Zasilacze liniowe i stabilizatory LDO](01-zasilacze-liniowe-i-ldo.md) | 6 h / 2 h |
| 02 | [Przetwornica obniżająca (buck)](02-przetwornica-buck.md) | 8 h / 3 h |
| 03 | [Boost, buck-boost i pompy ładunku](03-boost-buck-boost-pompy.md) | 6 h / 2 h |
| 04 | [Dobór elementów, straty i sprawność](04-elementy-straty-sprawnosc.md) | 8 h / 3 h |
| 05 | [Przetwornice izolowane: flyback i forward](05-przetwornice-izolowane.md) | 8 h / 3 h |
| 06 | [Sterowanie i kompensacja pętli](06-sterowanie-i-kompensacja.md) | 8 h / 3 h |
| 07 | [Termika, układ płytki i zakłócenia](07-termika-plytka-emi.md) | 6 h / 2 h |
| 08 | [Baterie, ładowanie i falowniki](08-baterie-i-falowniki.md) | 8 h / 3 h |

## Test wejściowy (diagnoza)

Około 60 minut, bez notatek.

1. Transformator 12 V AC (skutecznie), mostek Graetza, kondensator 4700 µF, prąd 1 A. Ile wynosi napięcie szczytowe i tętnienia?
2. Stabilizator 7805 zasilany z ok. 14,3 V przy 1 A. Jaka moc się w nim wydziela i jaka jest sprawność?
3. Przetwornica buck 12 V → 3,3 V. Ile wynosi współczynnik wypełnienia (idealnie)?
4. Jak dobrać indukcyjność buck, aby tętnienia prądu wynosiły 30% prądu wyjściowego (12 → 3,3 V, 1 A, 500 kHz)?
5. Przetwornica boost 3,7 V → 5 V, 0,5 A. Wypełnienie i średni prąd wejściowy (idealnie)?
6. Czym różnią się straty przewodzenia od strat przełączania w tranzystorze? Jak każde zależy od częstotliwości?
7. Dlaczego w przetwornicy flyback potrzebny jest obwód tłumiący (snubber) na tranzystorze?
8. Jak przebiega ładowanie ogniwa Li-ion?

<details>
<summary>Odpowiedzi</summary>

1. $12\sqrt2 - 2\cdot 0\text{,}8 \approx 15\text{,}4$ V; $\Delta V = I/(2fC) = 1/(100\cdot 0\text{,}0047) \approx 2\text{,}1$ V
2. $(14\text{,}3 - 5)\cdot 1 \approx 9\text{,}3$ W; ok. 35%
3. $D = 3\text{,}3/12 \approx 0\text{,}275$
4. $L = \dfrac{(V_{in} - V_{out})D}{f\,\Delta I} = \dfrac{8\text{,}7\cdot 0\text{,}275}{5\cdot 10^5\cdot 0\text{,}3} \approx 16$ µH → 15 µH
5. $D = 1 - 3\text{,}7/5 = 0\text{,}26$; $I_{in} = 0\text{,}5/0\text{,}74 \approx 0\text{,}68$ A
6. Przewodzenia: $I^2R_{DS(on)}$ — nie zależą od częstotliwości; przełączania: energia tracona przy każdym przełączeniu (przy jednoczesnym napięciu i prądzie, ładowanie pojemności) — proporcjonalne do częstotliwości
7. Indukcyjność rozproszenia transformatora oddaje energię w chwili wyłączenia tranzystora — przepięcie mogłoby przebić tranzystor; snubber (np. RCD) ją pochłania
8. Prąd stały (CC) do 4,2 V (typowo), potem napięcie stałe (CV), aż prąd spadnie do ok. 0,05–0,1C; z kontrolą temperatury, bez ładowania poniżej 0 °C

**Ocena:** 1–2 — temat 01; 3–4 — 02; 5 — 03; 6 — 04; 7 — 05; 8 — 08.
</details>

## Projekt modułowy: zasilacz 12 V → 3,3 V / 1 A

- [ ] **Wymagania:** wejście 9–15 V, wyjście 3,3 V ± 3%, 1 A, tętnienia < 20 mV, sprawność > 85%, temperatura otoczenia do 50 °C.
- [ ] **Porównanie:** policz LDO (straty, radiator) i przetwornicę buck; uzasadnij wybór.
- [ ] **Projekt buck:** częstotliwość, dławik (indukcyjność, prąd nasycenia, DCR), kondensatory (pojemność, ESR, prąd tętnień), tranzystory lub układ scalony z wbudowanymi kluczami, dzielnik sprzężenia zwrotnego.
- [ ] **Symulacja:** w LTspice (gotowy model układu producenta lub przetwornica z elementów) — rozruch, skok obciążenia 0,1 → 1 A, tętnienia, zmiana napięcia wejściowego; symulacja w Pythonie z tematu 02 do porównania.
- [ ] **Bilans strat i termika:** straty w elementach, sprawność, temperatura złącza.
- [ ] **Płytka (opcjonalnie):** układ ścieżek z minimalną pętlą prądu impulsowego (temat 07, moduł [16](../16-pcb-emc-konstrukcja/)), pomiar tętnień oscyloskopem z krótką masą sondy ([08.03](../08-miernictwo/03-oscyloskop.md)), pomiar sprawności.

## Sprawdzian końcowy modułu

- [ ] Projektuję zasilacz liniowy (prostownik, filtr, stabilizator) z bilansem mocy i radiatorem.
- [ ] Wybieram między LDO a przetwornicą dla zadanych wymagań.
- [ ] Liczę wypełnienie, tętnienia prądu i napięcia przetwornic buck i boost; rozpoznaję CCM i DCM.
- [ ] Dobieram dławik, kondensatory i tranzystory; szacuję straty i sprawność.
- [ ] Rozumiem działanie flyback i forward, rolę transformatora i snubbera.
- [ ] Rozumiem sterowanie napięciowe i prądowe oraz kompensację pętli (typ II/III).
- [ ] Projektuję układ płytki przetwornicy z myślą o termice i EMI.
- [ ] Projektuję ładowanie i zabezpieczenia akumulatora Li-ion; rozumiem zasadę falownika i sterowania silnikiem.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [MIT 6.622 Power Electronics (2023)](https://ocw.mit.edu/courses/6-622-power-electronics-spring-2023/) | Główny kurs: przetwornice, magnetyki, sterowanie, falowniki — notatki i zadania |
| [Introduction to Power Electronics — R. Erickson, CU Boulder (Coursera)](https://www.coursera.org/learn/power-electronics) | Kurs autora klasycznego podręcznika *Fundamentals of Power Electronics* (bezpłatny w trybie audytu) |
| [TI SLVA477 — Basic Calculation of a Buck Converter's Power Stage](https://www.ti.com/lit/pdf/SLVA477) | Praktyczne wzory doboru elementów buck |
| [TI SLVA372 — Basic Calculation of a Boost Converter's Power Stage](https://www.ti.com/document-viewer/lit/html/SLVA372) | Praktyczne wzory doboru elementów boost |
| [Analog Devices — Electronics I and II](https://wiki.analog.com/university/courses/electronics/text/electronics-toc) | Zarządzanie zasilaniem, stabilizatory |
| [Operational Amplifiers & Linear ICs — J. M. Fiore](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html) | Stabilizatory liniowe |
| [LTspice](https://www.analog.com/en/resources/design-tools-and-calculators/ltspice-simulator.html) | Symulacje z gotowymi modelami przetwornic i obwodami demonstracyjnymi |
| [Battery University](https://batteryuniversity.com/) | Akumulatory: chemie, ładowanie, starzenie, bezpieczeństwo |
