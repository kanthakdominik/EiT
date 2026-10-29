# Plan testów i macierz zgodności — [nazwa projektu]

**Wersja sprzętu:** … · **Wersja oprogramowania:** … · **Data:** …

## 1. Stanowisko pomiarowe

| Przyrząd | Model / numer | Zakres | Niepewność (z dokumentacji / świadectwa) |
|---|---|---|---|
| Multimetr | … | … | … |
| Oscyloskop + sondy | … | … | … |
| Zasilacz | … | … | … |
| … | … | … | … |

Schemat połączeń: (rysunek lub opis). Warunki otoczenia: temperatura, wilgotność.

## 2. Testy

### T1 — [nazwa] → wymaganie W…

- **Cel:** …
- **Konfiguracja:** …
- **Procedura:** 1. … 2. … 3. … (liczba powtórzeń: …)
- **Kryterium zaliczenia:** … (z uwzględnieniem niepewności: $y + U \leq L$ lub $y - U \geq L$)
- **Wynik:** $y$ = … ± … (k = 2) · **Status:** spełnione / niespełnione / niejednoznaczne
- **Dane i skrypt:** `measurements/T1/…`
- **Uwagi, porównanie z obliczeniami:** …

### T2 — …

## 3. Macierz zgodności

| Wymaganie | Test | Granica | Wynik ± U | Status | Uwagi |
|---|---|---|---|---|---|
| W1 | T1 | … | … | … | … |
| W2 | T2 | … | … | … | … |
| W3 | T3 + analiza | … | … | … | … |

## 4. Odstępstwa i wnioski

Wymagania niespełnione lub niejednoznaczne: przyczyna, wpływ, proponowana zmiana w kolejnej wersji.
