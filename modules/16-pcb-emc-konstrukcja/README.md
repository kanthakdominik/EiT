# 16 — Projektowanie PCB, EMC i konstrukcja urządzeń

> **Status:** 🟡 szkielet — zakres, cele i główne źródła. Pełne notatki i zadania w kolejnym etapie.

## Cel modułu

Przekuć schemat w działające, powtarzalne urządzenie: płytka drukowana, integralność sygnałów, kompatybilność elektromagnetyczna, montaż i testy.

## Wymagania wstępne

- [04 Układy analogowe](../04-uklady-analogowe/), [09 Mikrokontrolery](../09-mikrokontrolery-embedded/), [11 Pole EM i linie](../11-pole-em-linie-anteny/), [15 Zasilanie](../15-energoelektronika-zasilanie/).

## Tematy

### Proces projektowy
- [ ] Od wymagań do schematu: bilans mocy, dobór elementów, rezerwy
- [ ] Biblioteki elementów, footprinty, obudowy SMD i THT
- [ ] Reguły projektowe (DRC), możliwości technologiczne producenta

### Projekt płytki
- [ ] Liczba warstw, stos (stackup), płaszczyzny masy i zasilania
- [ ] Rozmieszczenie elementów, ścieżki zasilania, szerokość ścieżek a prąd
- [ ] Odsprzęganie: rozmieszczenie kondensatorów, pętle prądowe
- [ ] Rozdzielenie części analogowej i cyfrowej, prowadzenie masy

### Integralność sygnałów
- [ ] Ścieżka jako linia transmisyjna, impedancja kontrolowana, terminacje
- [ ] Przesłuchy (crosstalk), ścieżki powrotne prądu
- [ ] Pary różnicowe

### Kompatybilność elektromagnetyczna (EMC)
- [ ] Emisja i odporność, mechanizmy sprzężeń (przewodzone, promieniowane)
- [ ] Filtracja, ekranowanie, ochrona ESD i przepięciowa
- [ ] Wymagania norm — przegląd, badania wstępne we własnym zakresie

### Produkcja i uruchamianie
- [ ] Dokumentacja produkcyjna: Gerber, BOM, pliki pick-and-place
- [ ] Lutowanie SMD, inspekcja, uruchamianie płytki krok po kroku
- [ ] Projektowanie pod test (punkty pomiarowe)

## Główne źródła

- [KiCad](https://www.kicad.org/) — dokumentacja programu i symulacja przez ngspice
- [Electromagnetics, Vol. 1 — Ellingson](https://doi.org/10.21061/electromagnetics-vol-1) — linie transmisyjne jako podstawa integralności sygnałów
- Książka płatna: H. Johnson, M. Graham — *High-Speed Digital Design*

## Ćwiczenie modułowe

Zaprojektuj w KiCad dwuwarstwową płytkę rejestratora z modułu 09 (z przetwornicą z modułu 15): schemat, PCB, DRC, pliki produkcyjne. Przejrzyj projekt według listy kontrolnej EMC.

## Sprawdzian umiejętności

- Dobieram szerokość ścieżki do prądu i dopuszczalnego przyrostu temperatury.
- Projektuję stos warstw i rozmieszczenie odsprzęgania dla mikrokontrolera.
- Wskazuję na gotowym projekcie potencjalne źródła problemów EMC.
