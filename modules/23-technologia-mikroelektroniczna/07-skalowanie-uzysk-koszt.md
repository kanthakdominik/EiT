# 23.07 — Skalowanie, uzysk i koszt

## Po co to jest

Przez pięćdziesiąt lat liczba tranzystorów w układzie rosła wykładniczo, a koszt jednego tranzystora spadał. Zrozumienie, dlaczego tak było i dlaczego dziś jest trudniej, wyjaśnia trendy w elektronice: wielordzeniowość zamiast wyższych częstotliwości, układy specjalizowane, chiplety i obudowy 3D. Uzysk produkcji (jaki procent struktur działa) decyduje o koszcie — i jest prostym zastosowaniem rozkładu Poissona ([21.08](../21-procesy-losowe-szum/08-szum-waskopasmowy-i-procesy-punktowe.md)).

## Teoria w pigułce

### Prawo Moore'a i skalowanie Dennarda

- **Moore (1965, 1975):** liczba tranzystorów w układzie podwaja się co ok. 2 lata — obserwacja ekonomiczna, nie prawo fizyki.
- **Skalowanie Dennarda (1974):** gdy wymiary i napięcia maleją $\kappa$ razy:

| Wielkość | Zmiana |
|---|---|
| Wymiary $L, W, t_{ox}$, napięcie $U$ | $1/\kappa$ |
| Gęstość upakowania | $\kappa^2$ |
| Opóźnienie bramki | $1/\kappa$ |
| Moc na bramkę ($CU^2f$) | $1/\kappa^2$ |
| **Gęstość mocy** | stała |

- **Koniec skalowania Dennarda (ok. 2005):** napięcia nie da się dalej obniżać (napięcie progowe ograniczone upływem podprogowym — nachylenie co najmniej ok. 60 mV/dekadę prądu w 300 K), więc gęstość mocy rosłaby z każdą generacją → koniec wzrostu częstotliwości zegara, „ciemny krzem” (nie wszystkie bloki mogą pracować jednocześnie), wielordzeniowość.
- Dziś postęp: nowe struktury (FinFET, GAA), litografia EUV, połączenia 3D, **chiplety** (kilka mniejszych struktur w jednej obudowie), specjalizacja (akceleratory).

### Uzysk

Defekty rozłożone losowo z gęstością $D_0$ [defektów/cm²]; struktura o powierzchni $A$ działa, jeśli nie trafi w nią żaden „zabójczy” defekt. Model Poissona:

$$Y = e^{-D_0A}$$

- Model Murphy'ego (defekty skupione — bardziej realistyczny dla dużych struktur): $Y = \left(\dfrac{1 - e^{-D_0A}}{D_0A}\right)^2$.
- Typowo $D_0$ dojrzałego procesu: 0,05–0,2 /cm²; nowego — wyższe.
- **Koszt dobrej struktury:** $K = \dfrac{K_{płytki}}{N_{struktur}\cdot Y}$ — rośnie z powierzchnią szybciej niż liniowo (mniej struktur na płytce × niższy uzysk).
- Redundancja (zapasowe wiersze pamięci, wyłączane rdzenie) i sortowanie egzemplarzy (binning) podnoszą efektywny uzysk.

## Przykład rozwiązany

**Koszt struktury:** płytka 300 mm za 10 000 USD, $D_0 = 0\text{,}1$ /cm².

| Struktura | Liczba na płytce | Uzysk $e^{-D_0A}$ | Dobrych | Koszt dobrej |
|---|---|---|---|---|
| 100 mm² (1 cm²) | 640 | 90,5% | 579 | 17,3 USD |
| 600 mm² (6 cm²) | 91 | 54,9% | 50 | 201 USD |

Struktura sześciokrotnie większa kosztuje **11,6 razy więcej**. Podział dużego układu na cztery chiplety po 150 mm² (każdy testowany przed montażem — *known good die*) daje uzysk pojedynczego chipletu 86% — koszt krzemu wyraźnie spada, kosztem złożoności obudowy i połączeń między chipletami.

## Typowe pułapki

- **Traktowanie prawa Moore'a jak prawa fizyki.**
- **Liniowe skalowanie kosztu z powierzchnią** — ignoruje uzysk i straty brzegowe.
- **Zakładanie, że mniejszy węzeł jest zawsze tańszy** — koszt płytki w najnowszych węzłach rośnie szybciej niż gęstość; dla układów analogowych, mocy i w.cz. starsze węzły są optymalne.
- **Utożsamianie częstotliwości z wydajnością** po końcu skalowania Dennarda.
- **Model Poissona dla bardzo dużych struktur** — zaniża uzysk (defekty są skupione); używaj modeli z rozkładem ujemnym dwumianowym/Murphy'ego.

## Ćwiczenie komputerowe

Koszt dobrej struktury w funkcji powierzchni (Poisson i Murphy) i opłacalność podziału na chiplety:

```python
import numpy as np

d, wafer_cost = 300.0, 10_000.0
def gross(S_mm2): return np.pi*d**2/(4*S_mm2) - np.pi*d/np.sqrt(2*S_mm2)
def y_poisson(A_cm2, D0): return np.exp(-D0*A_cm2)
def y_murphy(A_cm2, D0): x = D0*A_cm2; return ((1 - np.exp(-x))/x)**2

for D0 in (0.1, 0.3):
    print(f"D0 = {D0} /cm²")
    for S in (25, 100, 300, 600):
        A = S/100
        g = gross(S)
        for name, Y in (("Poisson", y_poisson(A, D0)), ("Murphy", y_murphy(A, D0))):
            print(f"  {S:3d} mm², {name:7s}: struktur {g:6.0f}, uzysk {Y*100:5.1f}%, koszt dobrej {wafer_cost/(g*Y):7.1f} $")

# monolit 600 mm² kontra 4 chiplety po 150 mm² (bez kosztu obudowy), D0 = 0,1
D0 = 0.1
mono = wafer_cost/(gross(600)*y_poisson(6, D0))
chip = 4*wafer_cost/(gross(150)*y_poisson(1.5, D0))
print(f"koszt krzemu: monolit {mono:.0f} $, 4 chiplety {chip:.0f} $")
```

## Zadania

1. Struktura 2 cm², $D_0 = 0\text{,}2$ /cm². Uzysk według modelu Poissona?
2. Ile razy wzrośnie gęstość upakowania po trzech generacjach skalowania o $\kappa = \sqrt2$ każda?
3. Dlaczego koniec skalowania Dennarda zatrzymał wzrost częstotliwości zegara procesorów?
4. Dlaczego pamięci mają zapasowe wiersze i kolumny?
5. Kiedy podział układu na chiplety przestaje się opłacać?

<details>
<summary>Odpowiedzi</summary>

1. $e^{-0\text{,}4} = 67\%$
2. Każda generacja ×2 → $2^3 = 8$ razy
3. Napięcie przestało maleć (ograniczenie upływu podprogowego), więc przy zwiększaniu gęstości i częstotliwości moc na mm² rosłaby ponad możliwości odprowadzenia ciepła; zysk tranzystorów wykorzystuje się na więcej rdzeni i bloków specjalizowanych zamiast wyższej częstotliwości
4. Po teście uszkodzone wiersze/kolumny zastępuje się zapasowymi (przepalanie bezpieczników, programowanie) — struktura z kilkoma defektami staje się sprawna, co znacznie zwiększa uzysk dużych pamięci
5. Gdy koszt połączeń i obudowy (interposer, mostki krzemowe, montaż, testy) oraz straty wydajności i energii na komunikacji między chipletami przewyższą oszczędność z wyższego uzysku — zwykle dla małych struktur lub w dojrzałych procesach o małym $D_0$
</details>

## Źródła

- [MIT 6.012 Microelectronic Devices and Circuits](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-spring-2009/) — skalowanie MOSFET
- [Purdue — Semiconductor Fabrication 101](https://engineering.purdue.edu/online/semiconductors/semiconductor-fabrication-101) — uzysk i ekonomia produkcji
- [21.08 Procesy punktowe (Poisson)](../21-procesy-losowe-szum/08-szum-waskopasmowy-i-procesy-punktowe.md)
