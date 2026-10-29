# 16.01 — Proces projektowy: od wymagań do schematu

## Po co to jest

Większość błędów w urządzeniach nie jest wynikiem złej płytki, tylko złych założeń: nieprzemyślanego zasilania, elementu bez zapasu, złego footprintu, braku punktu pomiarowego. Uporządkowany proces — wymagania, architektura, obliczenia, schemat z uzasadnieniami, przegląd — kosztuje kilka dni, a oszczędza kolejne wersje płytki.

## Teoria w pigułce

### Etapy

1. **Wymagania** z liczbami: funkcje, zakres napięć zasilania, pobór prądu, warunki środowiskowe (temperatura, wilgotność, wibracje), interfejsy, normy (bezpieczeństwo, EMC), koszt, wielkość serii, rozmiar obudowy.
2. **Architektura:** schemat blokowy, wybór kluczowych układów (mikrokontroler, przetwornik, przetwornica, radio), alternatywy i ryzyka.
3. **Obliczenia i symulacje** kluczowych bloków (tor analogowy, zasilanie, filtry).
4. **Schemat** z dokumentacją doboru elementów.
5. **Przegląd schematu** (lista kontrolna, druga osoba).
6. **Płytka**, przegląd, produkcja, uruchomienie, weryfikacja (tematy 02–08, moduł [18](../18-projekt-dyplomowy/)).

### Bilans mocy i drzewo zasilania

Tabela: każdy odbiornik, napięcie, prąd typowy i maksymalny, tryby pracy → wymagania na każdą szynę zasilania, sprawność przetwornic, prąd z wejścia, ciepło. Sekwencja zasilania (kolejność włączania szyn) i zachowanie przy zaniku.

### Dobór elementów

| Zasada | Przykład |
|---|---|
| **Zapas (derating)** | Kondensatory ceramiczne na napięcie ≥ 1,5–2× pracy (DC bias!), elektrolity ≤ ok. 80% napięcia, rezystory ≤ 50–60% mocy, tranzystory i diody z zapasem napięcia 20–50% |
| Zakres temperatur | Komercyjny 0–70 °C, przemysłowy −40–85 °C, samochodowy (AEC-Q) do 125 °C |
| Dostępność | Kilku producentów, status produkcji (nie „NRND”/„EOL”), czas dostawy |
| Standaryzacja | Ograniczona liczba wartości i obudów w BOM (np. 0402 lub 0603, ten sam typ kondensatora 100 nF w całym projekcie) |
| Tolerancja i dryft | Analiza najgorszego przypadku lub Monte Carlo dla obwodów krytycznych |

### Biblioteki i footprinty

- **Symbol** (schemat) i **footprint** (płytka) — połączone przez numery pinów; błąd w mapowaniu = martwa płytka.
- Footprint z karty katalogowej (zalecany land pattern) lub generator według IPC-7351; sprawdź: wymiary padów, pad termiczny i przelotki w nim, oznaczenie pinu 1, strefę zabronioną (anteny, przełączniki).
- Obudowy: THT (przewlekane — złącza, duże elementy), SMD (0402/0603, SOT, SOIC, QFN — niewidoczne luty, BGA — wymaga RTG przy montażu).
- Model 3D — sprawdzenie kolizji z obudową.

### Dobre praktyki schematu

- Czytelny podział na arkusze funkcjonalne, przepływ sygnału od lewej do prawej, nazwane sieci.
- Przy każdym nietypowym elemencie — notatka z obliczeniem lub odwołaniem do noty aplikacyjnej.
- Elementy „opcjonalne” (DNP — nie montować) do strojenia: miejsca na rezystor 0 Ω, filtr π, zworki pomiarowe prądu.
- **Punkty testowe** na szynach zasilania, sygnałach zegarowych i magistralach.
- ERC (sprawdzenie reguł elektrycznych): niepodłączone piny, wyjścia zwarte ze sobą, brak zasilania pinów.

## Przykład rozwiązany

**Bilans mocy rejestratora** (zasilanie 12 V, przetwornica 3,3 V o sprawności 88%):

| Odbiornik | Prąd typowy / maks. przy 3,3 V |
|---|---|
| Mikrokontroler | 15 / 40 mA |
| Moduł radiowy | 5 / 120 mA (impulsy) |
| Tor analogowy (wzmacniacz, źródło odniesienia, przetwornik) | 3 / 5 mA |
| Diody LED | 0 / 10 mA |
| **Razem** | **23 / 175 mA** |

Moc wyjściowa maksymalna $3\text{,}3\cdot 0\text{,}175 \approx 0\text{,}58$ W → z wejścia 12 V: $0\text{,}58/0\text{,}88/12 \approx 55$ mA. Przetwornica dobrana na 0,5 A (zapas ×3 na rozruch i rozbudowę); tor analogowy zasilany przez filtr LC lub osobne LDO z szyny 3,3 V (lepsze PSRR — [15.01](../15-energoelektronika-zasilanie/01-zasilacze-liniowe-i-ldo.md)).

## Typowe pułapki

- **Footprint „z biblioteki” bez porównania z kartą katalogową** — zła numeracja pinów (np. tranzystor SOT-23 o innym rozkładzie), lustrzane odbicie złącza.
- **Brak zapasu napięciowego kondensatorów ceramicznych.**
- **Element jednego producenta, wycofywany z produkcji.**
- **Brak złącza programowania, punktów testowych, miejsc na poprawki.**
- **Zasilanie projektowane „na oko”** — przetwornica bez zapasu przy impulsach radia.

## Ćwiczenie komputerowe

Bilans mocy i sprawdzenie zapasów elementów w prostym skrypcie (tabela jak w arkuszu BOM):

```python
loads = {'MCU': (15, 40), 'radio': (5, 120), 'analog': (3, 5), 'LED': (0, 10)}   # mA typ, maks przy 3,3 V
V, eta, Vin = 3.3, 0.88, 12.0
I_typ = sum(t for t, _ in loads.values()); I_max = sum(m for _, m in loads.values())
for name, I in [('typowy', I_typ), ('maksymalny', I_max)]:
    P = V*I/1e3
    print(f"{name:10s}: {I:4d} mA przy 3,3 V, {P:.3f} W, z wejścia {P/eta/Vin*1e3:5.1f} mA")

parts = [  # (nazwa, napięcie pracy, napięcie znamionowe, min. współczynnik zapasu)
    ('C ceramiczny 10 uF', 5.0, 6.3, 1.5), ('C ceramiczny 10 uF', 5.0, 16, 1.5),
    ('C elektrolit. 100 uF', 12.0, 16, 1.25), ('MOSFET', 24.0, 30, 1.25), ('dioda TVS', 13.0, 15, 1.1)]
for n, Vop, Vr, k in parts:
    ok = Vr/Vop >= k
    print(f"{n:22s} {Vop:5.1f} V / {Vr:4.1f} V: zapas {Vr/Vop:4.2f} -> {'OK' if ok else 'ZA MAŁY'}")
```

## Zadania

1. Przygotuj bilans mocy dla urządzenia: mikrokontroler 30 mA, wyświetlacz 80 mA, Wi-Fi 300 mA impulsowo, zasilanie z USB 5 V przez przetwornicę 3,3 V (90%). Jaki prąd z USB?
2. Kondensator 22 µF/6,3 V X5R na szynie 5 V — co jest nie tak?
3. Dlaczego warto ograniczyć liczbę różnych wartości i obudów w BOM?
4. Wymień pięć rzeczy, które sprawdzisz w footprincie układu w obudowie QFN.
5. Co to jest element DNP i do czego służy na prototypie?

<details>
<summary>Odpowiedzi</summary>

1. $3\text{,}3\cdot 0\text{,}41/0\text{,}9/5 \approx 0\text{,}30$ A szczytowo (typowo mniej); przetwornica i USB muszą dostarczyć impulsy Wi-Fi — kondensator magazynujący
2. Za mały zapas napięciowy (praktycznie pojemność spadnie do ok. 20–40% przy 5 V) i ryzyko niezawodności — kondensator 10–16 V
3. Mniejsze koszty zakupu i montażu (mniej podajników w automacie), mniej błędów, łatwiejsze zaopatrzenie i zamienniki
4. Wymiary i rozstaw padów, pad termiczny (wymiar, przelotki, podział pasty), oznaczenie pinu 1, warstwa pasty i maski, zgodność numeracji pinów z symbolem
5. Element zaprojektowany na płytce, ale nie montowany — miejsce na strojenie (filtr, dopasowanie), alternatywne warianty, pomiary prądu; pozwala poprawić prototyp bez nowej płytki
</details>

## Źródła

- [KiCad — dokumentacja](https://docs.kicad.org/) — edytor schematów, biblioteki, ERC
- [Phil's Lab — projektowanie PCB w KiCad](https://www.youtube.com/results?search_query=Phil%27s+Lab+KiCad+PCB+design) — przykładowe projekty od schematu do płytki
- [Embedded Systems — Shape the World (J. Valvano)](https://users.ece.utexas.edu/~valvano/Volume1/E-Book/) — projektowanie systemów od wymagań
- H. Scott — *Designing Electronics That Work* (No Starch Press, płatna) — praktyka projektowania sprzętu od wymagań po produkcję
