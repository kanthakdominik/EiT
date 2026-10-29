# 16 — Projektowanie PCB, EMC i konstrukcja urządzeń

> **Status:** ✅ pełny

## Cel modułu

Przekuć schemat w działające, powtarzalne urządzenie: zaprojektować płytkę drukowaną z myślą o zasilaniu, integralności sygnałów i kompatybilności elektromagnetycznej, przygotować dokumentację produkcyjną, zmontować i uruchomić prototyp. To moduł, w którym spotyka się prawie wszystko z wcześniejszych: linie transmisyjne ([11](../11-pole-em-linie-anteny/)), odsprzęganie mikrokontrolera ([09.08](../09-mikrokontrolery-embedded/08-sprzet-wokol-mcu.md)), przetwornice ([15.07](../15-energoelektronika-zasilanie/07-termika-plytka-emi.md)) i zakłócenia w pomiarach ([08.07](../08-miernictwo/07-zaklocenia-i-ekranowanie.md)).

## Wymagania wstępne

- [04 Układy analogowe](../04-uklady-analogowe/), [09 Mikrokontrolery](../09-mikrokontrolery-embedded/), [11 Pole EM i linie](../11-pole-em-linie-anteny/), [15 Zasilanie](../15-energoelektronika-zasilanie/).
- Program do projektowania PCB — przykłady odnoszą się do [KiCad](https://www.kicad.org/) (darmowy, otwarty), ale zasady są uniwersalne.

## Tematy

| # | Temat | Czas (od zera / odświeżenie) |
|---|---|---|
| 01 | [Proces projektowy: od wymagań do schematu](01-proces-i-schemat.md) | 6 h / 2 h |
| 02 | [Stos warstw i rozmieszczenie elementów](02-stos-warstw-i-rozmieszczenie.md) | 6 h / 2 h |
| 03 | [Ścieżki, zasilanie i odsprzęganie](03-sciezki-zasilanie-odsprzeganie.md) | 6 h / 2 h |
| 04 | [Integralność sygnałów](04-integralnosc-sygnalow.md) | 8 h / 3 h |
| 05 | [Masa i układy mieszane analogowo-cyfrowe](05-masa-i-uklady-mieszane.md) | 5 h / 2 h |
| 06 | [EMC: mechanizmy, normy i badania wstępne](06-emc-mechanizmy-i-normy.md) | 8 h / 3 h |
| 07 | [Filtracja, ekranowanie i ochrona ESD](07-filtracja-ekranowanie-esd.md) | 6 h / 2 h |
| 08 | [Produkcja, montaż i uruchamianie](08-produkcja-montaz-uruchamianie.md) | 6 h / 2 h |

## Test wejściowy (diagnoza)

Około 45 minut, bez notatek.

1. Jaka szerokość ścieżki zewnętrznej (miedź 35 µm) jest potrzebna dla 1 A przy przyroście temperatury 10 K?
2. Dlaczego pod szybkim sygnałem nie wolno przecinać płaszczyzny masy?
3. Ile wynosi „częstotliwość kolana” sygnału o czasie narastania 1 ns?
4. Na czym polega różnica między emisją różnicową (DM) a wspólną (CM)? Która zwykle dominuje na kablach?
5. Dlaczego kondensator odsprzęgający umieszcza się przy pinie układu, z przelotką do masy przy samej padzie?
6. Jaki jest cel podziału płaszczyzny masy na „analogową” i „cyfrową” i kiedy taki podział szkodzi?
7. Jakie pliki trzeba przekazać producentowi płytek i montażowni?

<details>
<summary>Odpowiedzi</summary>

1. Ok. 0,3 mm (wzór IPC-2221; w praktyce z zapasem 0,4–0,5 mm)
2. Prąd powrotny szybkiego sygnału płynie w płaszczyźnie tuż pod ścieżką; przerwa wymusza objazd — duża pętla, wzrost indukcyjności, przesłuchy i emisja
3. $f_{knee} \approx 0\text{,}35/t_r$ ≈ 350 MHz (a $0\text{,}5/t_r$ = 500 MHz w ostrzejszym przybliżeniu)
4. DM — prąd sygnału i powrotu w pętli (promieniuje jak mała pętla, $\propto f^2A$); CM — prąd płynący w tym samym kierunku po wszystkich przewodach kabla (antena), już kilka µA przekracza limity — dominuje na kablach
5. Liczy się indukcyjność pętli kondensator–pin–masa; każdy mm i przelotka dodaje nH, które obniżają skuteczność odsprzęgania przy wysokich częstotliwościach
6. Cel: utrzymać prądy cyfrowe z dala od czułej części analogowej. Szkodzi, gdy sygnały przechodzą nad przerwą (duże pętle powrotne) — zwykle lepsza jest ciągła masa z przemyślanym rozmieszczeniem elementów
7. Gerber (lub ODB++/IPC-2581) + wiercenia, opis stosu warstw i wymagań (impedancja, wykończenie); dla montażu: BOM, plik pick-and-place, rysunek montażowy, warstwy pasty

**Ocena:** 1 — temat 03; 2–3 — 04; 4 — 06; 5 — 03; 6 — 05; 7 — 08.
</details>

## Projekt modułowy: płytka rejestratora

- [ ] **Schemat** w KiCad rejestratora z modułu [09](../09-mikrokontrolery-embedded/) z przetwornicą z modułu [15](../15-energoelektronika-zasilanie/) (wejście 5–15 V lub USB-C), torem analogowym ([08.06](../08-miernictwo/06-czujniki-i-tor-pomiarowy.md)), złączem programowania, punktami pomiarowymi.
- [ ] **Biblioteki:** sprawdź footprinty z kartami katalogowymi (zwłaszcza obudowy QFN, złącza, dławiki).
- [ ] **Stos warstw:** 4 warstwy (sygnał / masa / zasilanie / sygnał) — uzasadnij; policz szerokość ścieżki 50 Ω dla anteny lub złącza w.cz. (jeśli jest).
- [ ] **Rozmieszczenie i prowadzenie:** strefy (zasilanie impulsowe, cyfrowa, analogowa, złącza), krótkie pętle przetwornicy, odsprzęganie, ciągła masa.
- [ ] **Przegląd:** DRC, lista kontrolna EMC i DFM z tematów 06–08, przegląd przez drugą osobę (lub „na zimno” po kilku dniach).
- [ ] **Produkcja:** pliki Gerber, BOM, pick-and-place; zamówienie kilku płytek; montaż.
- [ ] **Uruchomienie** według procedury z tematu 08, z dziennikiem problemów; pomiar tętnień, poboru prądu, podstawowa ocena emisji sondą pola bliskiego.

## Sprawdzian końcowy modułu

- [ ] Przekładam wymagania na schemat z bilansem mocy i uzasadnionym doborem elementów.
- [ ] Projektuję stos warstw i rozmieszczenie elementów dla układu mieszanego.
- [ ] Dobieram szerokość ścieżek do prądu i projektuję sieć zasilania z odsprzęganiem.
- [ ] Projektuję ścieżki o kontrolowanej impedancji i pary różnicowe, dbam o ścieżki powrotne.
- [ ] Rozumiem mechanizmy emisji i odporności, znam podstawowe normy i robię badania wstępne.
- [ ] Projektuję filtry wejściowe, ekranowanie i ochronę ESD/przepięciową.
- [ ] Przygotowuję dokumentację produkcyjną, projektuję pod montaż i test, uruchamiam płytkę krok po kroku.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [KiCad — dokumentacja](https://docs.kicad.org/) | Program do projektowania: schemat, PCB, DRC, eksport produkcyjny |
| [LearnEMC (T. Hubing)](https://learnemc.com/) | EMC dla projektantów płytek: mechanizmy, zasady projektowe, kalkulatory |
| [Electromagnetics, Vol. 1 — Ellingson](https://doi.org/10.21061/electromagnetics-vol-1) | Linie transmisyjne jako podstawa integralności sygnałów |
| [Analog Devices MT-101 — Decoupling Techniques](https://www.analog.com/media/en/training-seminars/tutorials/MT-101.pdf) | Odsprzęganie zasilania |
| [Rick Hartley — wykłady o masie i ścieżkach powrotnych (YouTube)](https://www.youtube.com/results?search_query=Rick+Hartley+grounding+PCB) | Ścieżki powrotne, masa, stos warstw — intuicyjnie |
| [Phil's Lab — projektowanie PCB w KiCad (YouTube)](https://www.youtube.com/results?search_query=Phil%27s+Lab+KiCad+PCB+design) | Praktyczne projekty płytek z mikrokontrolerami i zasilaniem |
| H. Johnson, M. Graham — *High-Speed Digital Design*; H. Ott — *Electromagnetic Compatibility Engineering*; E. Bogatin — *Signal and Power Integrity — Simplified* (płatne) | Klasyka integralności sygnałów i EMC |
