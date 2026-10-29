# 03.09 — Czytanie dokumentacji i obliczenia cieplne

## Po co to jest

Inżynier elektronik spędza nad dokumentacją producentów więcej czasu niż nad podręcznikami. Większość awarii prototypów wynika z przeoczonego warunku pomiaru, wartości „typowej” użytej zamiast gwarantowanej albo z przegrzania.

## Teoria w pigułce

### Struktura dokumentacji (datasheet)

| Sekcja | Co zawiera | Jak używać |
|---|---|---|
| **Absolute Maximum Ratings** | Wartości, których przekroczenie może zniszczyć element | **Nie projektuj blisko nich** — to nie są warunki pracy |
| **Recommended Operating Conditions** | Zakres, w którym producent gwarantuje działanie | Tu projektuj |
| **Electrical Characteristics** | Parametry min/typ/max **wraz z warunkami pomiaru** | Do obliczeń bierz min lub max (najgorszy przypadek), nie typ |
| **Typical Performance Curves** | Wykresy zależności parametrów | Orientacyjne — zwykle wartości typowe |
| **Thermal Information** | $R_{\theta JA}$, $R_{\theta JC}$ | Obliczenia temperatury złącza |
| **Package / Footprint** | Wymiary, rozmieszczenie wyprowadzeń | Projekt PCB |
| **Application Information** | Zalecane układy pracy i rozmieszczenie na płytce | Często najcenniejsza część |

**Warunki pomiaru zmieniają wszystko.** Np. $R_{DS(on)} = 20$ mΩ „przy $U_{GS} = 10$ V, $T_j = 25$ °C” nic nie mówi o pracy przy 4,5 V i 100 °C. $\beta$ tranzystora podane przy 10 mA może być dwa razy mniejsze przy 500 mA.

**Obszar bezpiecznej pracy (SOA)** — wykres dopuszczalnych kombinacji $U$ i $I$ dla różnych czasów impulsu. Ważny przy pracy liniowej tranzystorów mocy (np. stabilizatory, ograniczniki prądu rozruchowego).

### Obliczenia cieplne

Model cieplny to „obwód” z rezystancjami cieplnymi (K/W), mocą zamiast prądu i temperaturą zamiast napięcia:

$$T_j = T_a + P\left(R_{\theta JC} + R_{\theta CS} + R_{\theta SA}\right)$$

- $R_{\theta JC}$ — złącze–obudowa (z dokumentacji),
- $R_{\theta CS}$ — obudowa–radiator (pasta, podkładka izolacyjna: 0,2–1 K/W),
- $R_{\theta SA}$ — radiator–otoczenie (z dokumentacji radiatora),
- bez radiatora: $T_j = T_a + P\cdot R_{\theta JA}$.

Dla elementów SMD $R_{\theta JA}$ silnie zależy od powierzchni miedzi na płytce — wartość z dokumentacji dotyczy konkretnej płytki testowej.

**Derating** — zmniejszanie dopuszczalnej mocy ze wzrostem temperatury. Dla niezawodności projektuje się z zapasem: typowo $T_j \leq 100$–125 °C mimo dopuszczalnych 150 °C.

## Przykład rozwiązany

Tranzystor rozprasza 10 W. $T_{j,max} = 150$ °C, $R_{\theta JC} = 1\text{,}5$ K/W, podkładka $R_{\theta CS} = 0\text{,}5$ K/W, temperatura w obudowie urządzenia 40 °C.

1. Dopuszczalna łączna rezystancja: $\dfrac{150 - 40}{10} = 11$ K/W.
2. Radiator: $R_{\theta SA} \leq 11 - 1\text{,}5 - 0\text{,}5 = 9$ K/W.
3. Z zapasem (projekt na $T_j = 120$ °C): $R_{\theta SA} \leq 8 - 2 = 6$ K/W.

Bez radiatora (obudowa TO-220, $R_{\theta JA} \approx 62$ K/W) element rozproszy w tych warunkach tylko ok. $110/62 \approx 1\text{,}8$ W.

## Typowe pułapki

- **Projekt na wartościach typowych.** Seria 1000 sztuk zawsze zawiera egzemplarze z krańców rozkładu.
- **Absolute maximum traktowane jako warunki pracy.**
- **Pominięcie warunków pomiaru** (napięcie bramki, temperatura, częstotliwość, obciążenie).
- **Temperatura otoczenia 25 °C**, podczas gdy we wnętrzu obudowy urządzenia jest 40–60 °C.
- **Moc stała w czasie** przyjmowana dla impulsów — dla krótkich impulsów obowiązuje przejściowa impedancja cieplna $Z_{\theta JC}(t)$, mniejsza niż $R_{\theta JC}$.

## Ćwiczenie praktyczne

Pobierz dokumentację trzech elementów: diody 1N4148, tranzystora 2N3904 i MOSFET-a mocy z serii logic level (dowolny producent). Dla każdego wypisz:

- [ ] trzy parametry graniczne, które najczęściej ograniczają zastosowanie,
- [ ] wartości min/typ/max i warunki pomiaru dla parametru kluczowego (napięcie przewodzenia, $\beta$, $R_{DS(on)}$),
- [ ] rezystancje cieplne i maksymalną moc bez radiatora w 50 °C,
- [ ] jedną informację, której szukałeś, a której dokumentacja nie zawiera.

## Zadania

1. Tranzystor bez radiatora: $P = 0\text{,}5$ W, $R_{\theta JA} = 62$ K/W, $T_a = 25$ °C. Jaka jest temperatura złącza?
2. $P = 10$ W, $T_{j,max} = 150$ °C, $T_a = 40$ °C, $R_{\theta JC} = 1\text{,}5$ K/W, $R_{\theta CS} = 0\text{,}5$ K/W. Jaki radiator?
3. Stabilizator liniowy w obudowie TO-220 ($R_{\theta JA} = 50$ K/W) rozprasza 3,5 W. Czy wystarczy bez radiatora przy $T_a = 40$ °C?
4. Dokumentacja podaje $\beta$ = 100–300 przy $I_C = 10$ mA. Jaką wartość przyjmiesz do projektu klucza, a jaką do oszacowania maksymalnego prądu bazy pobieranego ze źródła?
5. MOSFET ma podane: $R_{DS(on)} = 25$ mΩ (max) przy $U_{GS} = 10$ V i 40 mΩ (max) przy 4,5 V, oba w 25 °C, oraz wykres: w 100 °C $R_{DS(on)}$ rośnie 1,6 razy. Ile przyjmiesz do obliczeń strat przy sterowaniu 5 V i pracy w 100 °C?

<details>
<summary>Odpowiedzi</summary>

1. $25 + 0\text{,}5\cdot 62 = 56$ °C
2. $R_{\theta SA} \leq 9$ K/W
3. Nie: $T_j = 40 + 3\text{,}5\cdot 50 = 215$ °C. Potrzebny radiator — patrz [04.11](../04-uklady-analogowe/11-stabilizatory.md)
4. Do klucza — minimum (100), żeby zapewnić nasycenie; do oszacowania prądu bazy przy zadanym prądzie kolektora też minimum (największy prąd bazy). Maksimum przydaje się np. do oszacowania prądu kolektora przy zadanym prądzie bazy w układzie bez ujemnego sprzężenia
5. $40\cdot 1\text{,}6 = 64$ mΩ (wartość przy 4,5 V jest najbliższa sterowaniu 5 V; nie interpoluj w stronę lepszej wartości)
</details>

## Źródła

- [Semiconductor Devices — J. M. Fiore](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html) — przykłady pracy z dokumentacją elementów dyskretnych
- [Analog Devices — Electronics I and II](https://wiki.analog.com/university/courses/electronics/text/electronics-toc)
- Dokumentacja producentów elementów (diody, tranzystory, radiatory) — zawsze aktualna wersja ze strony producenta
