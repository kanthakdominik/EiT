# 16.02 — Stos warstw i rozmieszczenie elementów

## Po co to jest

Decyzje podjęte przed poprowadzeniem pierwszej ścieżki — ile warstw, co na każdej z nich i gdzie stoi każdy blok — przesądzają o integralności sygnałów, EMC i termice bardziej niż samo prowadzenie. Dobrze rozmieszczona płytka „prowadzi się sama”, źle rozmieszczonej nie uratują najstaranniejsze ścieżki.

## Teoria w pigułce

### Stos warstw (stackup)

| Warstwy | Typowy układ | Kiedy |
|---|---|---|
| 2 | Sygnały + rozlana masa na spodzie | Proste układy, wolne sygnały, mała seria; trudniej o dobrą EMC |
| **4** | **Sygnał / masa / zasilanie / sygnał** (lub sygnał / masa / masa / sygnał z zasilaniem jako polygon) | Mikrokontrolery, przetwornice, radio — „rozsądne minimum” dla nowoczesnych układów |
| 6 | S / G / S / P / G / S lub S / G / S / S / G / S | Szybkie interfejsy, gęste płytki |
| 8+ | Wiele par sygnał–płaszczyzna | Procesory, FPGA, pamięci DDR |

Zasady:
- **Każda warstwa sygnałowa sąsiaduje z płaszczyzną odniesienia** (najlepiej masy) — kontrolowana impedancja i krótkie ścieżki powrotne ([16.04](04-integralnosc-sygnalow.md)).
- Cienki dielektryk między masą a zasilaniem — pojemność międzypłaszczyznowa ($C = \varepsilon A/d$; przy 0,1 mm i 100 cm² ok. 3,9 nF) pomaga w odsprzęganiu przy wysokich częstotliwościach.
- Symetria stosu (miedź i dielektryki) — zapobiega wyginaniu płytki przy lutowaniu.
- Stos dogadany z producentem (dostępne dielektryki, grubości, kontrola impedancji) — producent poda rzeczywiste szerokości ścieżek.

### Rozmieszczenie (placement)

Kolejność:
1. **Elementy o narzuconym położeniu:** złącza, przyciski, wyświetlacze, otwory montażowe, antena (krawędź płytki, strefa wolna od miedzi), radiatory.
2. **Podział na strefy:** wejście zasilania i filtr → przetwornica → część cyfrowa → część analogowa → złącza we/wy. Prądy płyną krótko i nie przecinają cudzych stref.
3. **Bloki krytyczne:** pętle przetwornic ([15.07](../15-energoelektronika-zasilanie/07-termika-plytka-emi.md)), kwarc przy mikrokontrolerze, kondensatory odsprzęgające przy pinach, przetwornik A/C przy wejściu analogowym, ochrona ESD przy złączu.
4. **Elementy pomocnicze** (rezystory podciągające, diody LED).

Dodatkowo: orientacja elementów dla montażu (te same kierunki, polaryzacja), odległość od krawędzi (V-cut, frezowanie), dostęp do punktów testowych i złącza programowania, elementy ciepłe z dala od czułych (źródło odniesienia, czujnik temperatury) i elektrolitów.

### Siatka i reguły

Reguły projektowe (DRC) z możliwości producenta: minimalna szerokość i odstęp ścieżek (np. 0,1–0,15 mm), średnica otworu i pierścień przelotki, odstęp od krawędzi, maska między padami. Klasy sieci: zasilanie (szersze), sygnały 50 Ω/90 Ω/100 Ω (kontrolowana impedancja), wysokie napięcie (odstępy izolacyjne).

## Przykład rozwiązany

**Płytka 4-warstwowa rejestratora** (FR-4, 1,6 mm):

| Warstwa | Funkcja | Dielektryk do następnej |
|---|---|---|
| L1 (top) | Elementy, sygnały, krótkie ścieżki zasilania | prepreg 0,2 mm |
| L2 | **Ciągła masa** | rdzeń ok. 1,1 mm |
| L3 | Zasilanie 3,3 V i 5 V (polygony), nieliczne wolne sygnały | prepreg 0,2 mm |
| L4 (bottom) | Sygnały, pojedyncze elementy | — |

Ścieżka 50 Ω na L1 nad L2 (0,2 mm, $\varepsilon_r$ ≈ 4,4): szerokość ok. 0,38–0,39 mm ([11.06](../11-pole-em-linie-anteny/06-linie-praktyczne-i-falowody.md)) — dobrze pasuje do padów elementów 0402/0603. Na płytce 2-warstwowej 1,6 mm 50 Ω wymagałoby ok. 3 mm — stąd jedna z zalet stosu 4-warstwowego.

## Typowe pułapki

- **Warstwa sygnałowa sąsiadująca z drugą warstwą sygnałową** zamiast płaszczyzny — niekontrolowana impedancja, przesłuchy.
- **Płaszczyzna masy pocięta ścieżkami** na płytce 2-warstwowej.
- **Antena PCB otoczona miedzią lub elementami** w strefie zabronionej.
- **Przetwornica obok wejścia analogowego** lub kwarcu.
- **Stos zaprojektowany bez kontaktu z producentem** — impedancja odbiega o 20%.

## Ćwiczenie komputerowe

Porównanie szerokości ścieżki 50 Ω i pojemności międzypłaszczyznowej dla różnych stosów (wzory z [11.06](../11-pole-em-linie-anteny/06-linie-praktyczne-i-falowody.md)):

```python
import numpy as np
from scipy.optimize import brentq

def microstrip(W, h, er):
    u = W/h; ee = (er + 1)/2 + (er - 1)/2*(1 + 12/u)**-0.5
    Z = 60/np.sqrt(ee)*np.log(8/u + u/4) if u <= 1 else 120*np.pi/(np.sqrt(ee)*(u + 1.393 + 0.667*np.log(u + 1.444)))
    return Z
for name, h in [('2 warstwy, 1,6 mm', 1.6e-3), ('4 warstwy, prepreg 0,2 mm', 0.2e-3), ('4 warstwy, prepreg 0,1 mm', 0.1e-3)]:
    W = brentq(lambda W: microstrip(W, h, 4.4) - 50, h/20, 20*h)
    print(f"{name:28s}: W(50 Ohm) = {W*1e3:.2f} mm")
eps0 = 8.854e-12
for d in [0.1e-3, 0.2e-3, 1.1e-3]:
    print(f"płaszczyzny 100 cm² w odstępie {d*1e3:.1f} mm: C = {eps0*4.4*0.01/d*1e9:.2f} nF")
```

## Zadania

1. Zaproponuj stos 4-warstwowy dla płytki z mikrokontrolerem, modułem BLE i przetwornicą. Uzasadnij.
2. Dlaczego symetria stosu jest ważna dla produkcji?
3. Policz pojemność między płaszczyznami 50 cm² odległymi o 0,1 mm (εr = 4,2).
4. W jakiej kolejności rozmieścisz elementy płytki z gniazdem USB-C, przetwornicą, mikrokontrolerem i czujnikiem analogowym?
5. Dlaczego antenę PCB umieszcza się na krawędzi płytki?

<details>
<summary>Odpowiedzi</summary>

1. L1 sygnały i elementy, L2 ciągła masa, L3 zasilanie (polygony) + nieliczne sygnały, L4 sygnały; każda warstwa sygnałowa nad masą lub zasilaniem; antena BLE na krawędzi ze strefą bez miedzi na wszystkich warstwach
2. Różna rozszerzalność cieplna warstw miedzi i dielektryka przy niesymetrycznym stosie powoduje wyginanie (warpage) przy laminowaniu i lutowaniu rozpływowym — problemy z montażem BGA/QFN
3. $8\text{,}854\cdot 10^{-12}\cdot 4\text{,}2\cdot 0\text{,}005/10^{-4} \approx 1\text{,}86$ nF
4. Złącze USB-C (krawędź) z ochroną ESD → filtr i przetwornica przy złączu → mikrokontroler w centrum z kwarcem i odsprzęganiem → czujnik analogowy po przeciwnej stronie od przetwornicy, z torem analogowym przy przetworniku A/C
5. Antena potrzebuje otoczenia bez miedzi (płaszczyzna masy pod anteną zmienia jej impedancję i charakterystykę, ekranuje promieniowanie); krawędź daje swobodne promieniowanie w półprzestrzeń
</details>

## Źródła

- [KiCad — dokumentacja](https://docs.kicad.org/) — konfiguracja stosu warstw, reguły projektowe, klasy sieci
- [Rick Hartley — wykłady o masie i ścieżkach powrotnych](https://www.youtube.com/results?search_query=Rick+Hartley+grounding+PCB) — stos warstw i płaszczyzny
- [LearnEMC](https://learnemc.com/) — zasady projektowania płytek pod kątem EMC
