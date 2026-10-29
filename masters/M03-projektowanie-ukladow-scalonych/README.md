# M03 — Projektowanie układów scalonych (analogowych i cyfrowych)

> **Status:** ✅ pełny · ścieżka magisterska (II stopień)

## Cel modułu

Zaprojektować układ scalony od schematu (lub RTL) do pliku GDS gotowego do produkcji — wyłącznie otwartymi narzędziami i na otwartych PDK (SkyWater SKY130, GlobalFoundries GF180MCU, IHP SG13G2). W części analogowej: modele tranzystora dla projektanta i metoda $g_m/I_D$, podstawowe bloki, dwustopniowy wzmacniacz operacyjny, niedopasowanie, szum i layout. W części cyfrowej: logika CMOS, opóźnienia i moc, przepływ RTL → GDS z syntezą, rozmieszczeniem, drzewem zegara, trasowaniem i statyczną analizą czasową. Na koniec: weryfikacja w narożnikach procesu, układy mieszane (przetwornik SAR) i przygotowanie do produkcji w programach wielu projektów (np. Tiny Tapeout). Moduł rozwija [23 Technologię mikroelektroniczną](../../modules/23-technologia-mikroelektroniczna/).

## Wymagania wstępne

- [03.06–03.07 MOSFET](../../modules/03-przyrzady-polprzewodnikowe/06-mosfet.md), [04 Układy analogowe](../../modules/04-uklady-analogowe/) — w szczególności [04.04 Wzmacniacz różnicowy i lustra](../../modules/04-uklady-analogowe/04-wzmacniacz-roznicowy-i-lustra.md) i [04.06 Stabilność](../../modules/04-uklady-analogowe/06-sprzezenie-zwrotne-i-stabilnosc.md).
- [05 Technika cyfrowa](../../modules/05-technika-cyfrowa/) i [17 FPGA i HDL](../../modules/17-fpga-hdl/) — Verilog, analiza czasowa.
- [23 Technologia mikroelektroniczna](../../modules/23-technologia-mikroelektroniczna/) — proces CMOS, połączenia, uzysk.
- [21.06 Szum w układach elektronicznych](../../modules/21-procesy-losowe-szum/06-szum-w-ukladach-elektronicznych.md).

## Tematy

| # | Temat | Czas |
|---|---|---|
| 01 | [Przepływ projektowy, PDK i otwarte narzędzia](01-przeplyw-i-pdk.md) | 8 h |
| 02 | [Tranzystor MOS dla projektanta: metoda gm/ID](02-mosfet-dla-projektanta-gm-id.md) | 10 h |
| 03 | [Podstawowe bloki analogowe](03-bloki-analogowe.md) | 10 h |
| 04 | [Dwustopniowy wzmacniacz operacyjny CMOS](04-wzmacniacz-operacyjny-cmos.md) | 12 h |
| 05 | [Niedopasowanie, szum i layout analogowy](05-niedopasowanie-szum-layout.md) | 10 h |
| 06 | [Logika CMOS: opóźnienie, wysiłek logiczny, moc](06-logika-cmos.md) | 8 h |
| 07 | [Przepływ cyfrowy RTL → GDS i analiza czasowa](07-przeplyw-cyfrowy-i-sta.md) | 12 h |
| 08 | [Weryfikacja, układy mieszane i produkcja](08-weryfikacja-mieszane-tapeout.md) | 10 h |

## Test wejściowy (diagnoza)

Około 60 minut.

1. Zapisz prąd drenu MOSFET-a w nasyceniu w modelu kwadratowym. Ile wynosi transkonduktancja $g_m$?
2. Ile wynosi wzmocnienie stopnia ze wspólnym źródłem z obciążeniem aktywnym, jeśli $g_m = 1$ mS, $r_{o,n} = r_{o,p} = 100$ kΩ?
3. Do czego służy kompensacja Millera w dwustopniowym wzmacniaczu operacyjnym?
4. Od czego zależy moc dynamiczna układu cyfrowego CMOS?
5. Co oznacza ujemny zapas (slack) czasu ustalania w raporcie analizy czasowej?
6. Co to jest DRC i LVS?

<details>
<summary>Odpowiedzi</summary>

1. $I_D = \tfrac12\mu C_{ox}\tfrac WL(U_{GS} - U_T)^2$; $g_m = \mu C_{ox}\tfrac WL(U_{GS} - U_T) = 2I_D/(U_{GS} - U_T)$
2. $-g_m(r_{o,n}\parallel r_{o,p}) = -10^{-3}\cdot 50\cdot 10^3 = -50$ (34 dB)
3. Rozsuwa bieguny (biegun dominujący na wyjściu pierwszego stopnia, drugi przesuwa się w górę), zapewniając zapas fazy przy sprzężeniu zwrotnym
4. $P = \alpha CU^2f$ — współczynnik aktywności, pojemność przełączana, kwadrat napięcia, częstotliwość
5. Najdłuższa ścieżka nie zdąży przed zboczem zegara — układ nie spełni wymagań czasowych przy tej częstotliwości (w tym narożniku)
6. DRC — sprawdzenie reguł geometrycznych layoutu (szerokości, odstępy, zakładki); LVS — porównanie połączeń wyekstrahowanych z layoutu ze schematem

**Ocena:** 1–3 — tematy 02–04; 4 — 06; 5 — 07; 6 — 01, 08.
</details>

## Projekt modułowy: układ mieszany na Tiny Tapeout

- [ ] **Środowisko (temat 01):** kontener IIC-OSIC-TOOLS z PDK (SKY130, GF180 lub IHP); przejdź samouczek inwertera: xschem → ngspice → layout → DRC → LVS → ekstrakcja.
- [ ] **Część analogowa (tematy 02–05):** komparator lub wzmacniacz operacyjny zaprojektowany metodą $g_m/I_D$; symulacje w narożnikach i Monte Carlo; layout z technikami dopasowania.
- [ ] **Część cyfrowa (tematy 06–07):** sterownik (np. logika przetwornika SAR, licznik, interfejs SPI) w Verilogu z testbenchem; synteza i implementacja w LibreLane/OpenROAD; zapas czasu w narożnikach.
- [ ] **Integracja (temat 08):** przetwornik SAR 6–8 bitów lub inny blok mieszany; symulacja całości; lista kontrolna przed produkcją.
- [ ] **Produkcja (opcjonalnie):** zgłoszenie projektu do najbliższego otwartego naboru Tiny Tapeout; po otrzymaniu układu — pomiary na płytce z modułu [16](../../modules/16-pcb-emc-konstrukcja/).

## Sprawdzian końcowy modułu

- [ ] Opisuję zawartość PDK i przepływy analogowy i cyfrowy, posługuję się otwartymi narzędziami.
- [ ] Dobieram wymiary tranzystorów metodą $g_m/I_D$, rozumiem kompromis szybkość–wzmocnienie–pobór prądu.
- [ ] Projektuję lustra prądowe, stopnie wzmacniające i kaskody, liczę wzmocnienie i rezystancje wyjściowe.
- [ ] Projektuję dwustopniowy wzmacniacz Millera z rezystorem zerującym na zadane GBW i zapas fazy.
- [ ] Szacuję offset (Pelgrom) i szum, stosuję techniki layoutu analogowego.
- [ ] Liczę opóźnienie i moc logiki CMOS, dobieram łańcuch buforów metodą wysiłku logicznego.
- [ ] Przeprowadzam przepływ RTL → GDS, interpretuję raport STA (setup, hold, narożniki).
- [ ] Weryfikuję układ w narożnikach PVT i Monte Carlo, projektuję przetwornik SAR, przygotowuję projekt do produkcji.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [IIC-OSIC-TOOLS (JKU, GitHub)](https://github.com/iic-jku/IIC-OSIC-TOOLS) | Gotowy kontener z kompletem otwartych narzędzi i PDK — start w kilka minut |
| [Tiny Tapeout](https://tinytapeout.com/) | Tani dostęp do produkcji własnego układu, szablony, samouczki analogowe i cyfrowe |
| [SkyWater SKY130 PDK (GitHub)](https://github.com/google/skywater-pdk) i [dokumentacja otwartych PDK](https://open-source-pdks.readthedocs.io) | Proces 130 nm: reguły, modele, biblioteki komórek |
| [IHP Open PDK SG13G2 (GitHub)](https://github.com/IHP-GmbH/IHP-Open-PDK) | Proces 130 nm BiCMOS (SiGe) — także do układów w.cz.; [dokumentacja z przykładem gm/ID](https://ihp-open-pdk-docs.readthedocs.io/en/main/analog/pygmid.html) |
| [LibreLane](https://github.com/librelane/librelane) i [OpenROAD](https://openroad.readthedocs.io/) | Przepływ cyfrowy RTL → GDSII |
| [xschem](https://sourceforge.net/projects/xschem/) | Edytor schematów do symulacji w ngspice |
| [MIT 6.374 Analysis and Design of Digital Integrated Circuits (2003)](https://ocw.mit.edu/courses/6-374-analysis-and-design-of-digital-integrated-circuits-fall-2003/) | Projektowanie cyfrowych układów scalonych |
| [MIT 6.012 Microelectronic Devices and Circuits (2009)](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-spring-2009/) | Modele MOSFET i podstawowe stopnie |
| B. Razavi — *Design of Analog CMOS Integrated Circuits* (płatna) | Główny podręcznik części analogowej |
| P. Jespers, B. Murmann — *Systematic Design of Analog CMOS Circuits* (płatna) | Metoda gm/ID |
| N. Weste, D. Harris — *CMOS VLSI Design* (płatna) | Projektowanie cyfrowe VLSI |
