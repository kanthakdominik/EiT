# 23 — Technologia mikroelektroniczna

> **Status:** ✅ pełny

## Cel modułu

Rozumieć, jak powstaje układ scalony — od pręta krzemu po zamkniętą w obudowie strukturę — i liczyć podstawowe zależności procesowe: grubość tlenku, głębokość złącza po dyfuzji, rozdzielczość litografii, opóźnienie połączeń, uzysk produkcji i niezawodność. Ta wiedza tłumaczy parametry z kart katalogowych (dlaczego układy mają takie napięcia, prądy upływu i obudowy), ograniczenia skalowania i koszty, a dla chętnych jest wstępem do projektowania układów scalonych.

## Wymagania wstępne

- [02.05 Pasma i półprzewodniki](../02-fizyka-i-materialy/05-pasma-i-polprzewodniki.md), [02.06 Transport nośników](../02-fizyka-i-materialy/06-transport-nosnikow.md) (dyfuzja), [02.07 Materiały elektroniczne](../02-fizyka-i-materialy/07-materialy-elektroniczne.md).
- [03.01 Złącze p-n](../03-przyrzady-polprzewodnikowe/01-zlacze-pn.md) i [03.06 MOSFET](../03-przyrzady-polprzewodnikowe/06-mosfet.md).
- [21.01 Zmienne losowe](../21-procesy-losowe-szum/01-zmienne-i-wektory-losowe.md) i [21.08 Proces Poissona](../21-procesy-losowe-szum/08-szum-waskopasmowy-i-procesy-punktowe.md) — dla uzysku i niezawodności.

## Tematy

| # | Temat | Czas (od zera / odświeżenie) |
|---|---|---|
| 01 | [Krzem i płytka](01-krzem-i-plytka.md) | 4 h / 1 h |
| 02 | [Utlenianie i osadzanie cienkich warstw](02-utlenianie-i-cienkie-warstwy.md) | 6 h / 2 h |
| 03 | [Fotolitografia](03-fotolitografia.md) | 6 h / 2 h |
| 04 | [Domieszkowanie: dyfuzja i implantacja](04-dyfuzja-i-implantacja.md) | 7 h / 2 h |
| 05 | [Trawienie i metalizacja](05-trawienie-i-metalizacja.md) | 5 h / 2 h |
| 06 | [Proces CMOS krok po kroku](06-proces-cmos.md) | 6 h / 2 h |
| 07 | [Skalowanie, uzysk i koszt](07-skalowanie-uzysk-koszt.md) | 5 h / 2 h |
| 08 | [Montaż, obudowy i niezawodność](08-obudowy-i-niezawodnosc.md) | 6 h / 2 h |

## Test wejściowy (diagnoza)

Około 40 minut.

1. Dlaczego do produkcji układów scalonych używa się krzemu monokrystalicznego, a nie polikrystalicznego?
2. Jaki tlenek powstaje na krzemie i do czego służy w tranzystorze MOS?
3. Od czego zależy najmniejszy wymiar, jaki można wykonać fotolitografią?
4. Jak w przybliżeniu zależy głębokość dyfuzji od czasu procesu?
5. Dlaczego duże układy (np. procesory graficzne) są znacznie droższe od małych, choć powstają na tych samych płytkach?
6. Co to jest elektromigracja?
7. Ile atomów krzemu przypada na jeden atom domieszki przy koncentracji $10^{16}$ cm⁻³ (krzem: $5\cdot 10^{22}$ atomów/cm³)?

<details>
<summary>Odpowiedzi</summary>

1. Defekty sieci (granice ziaren) działają jak pułapki i centra rekombinacji, zmieniają ruchliwość i powodują rozrzut parametrów; monokryształ zapewnia jednorodność na całej płytce
2. SiO₂ (dwutlenek krzemu) — dielektryk bramkowy (dziś zastąpiony tlenkami o dużej przenikalności, high-k), izolacja między elementami i warstwami, maska przy domieszkowaniu
3. Od długości fali światła i apertury numerycznej obiektywu: $CD = k_1\lambda/\mathrm{NA}$
4. Jak $\sqrt{Dt}$ — czterokrotnie dłuższy proces daje dwukrotnie głębsze złącze
5. Uzysk maleje wykładniczo z powierzchnią struktury ($Y = e^{-D_0A}$), a na płytce mieści się mniej dużych struktur — koszt dobrej struktury rośnie szybciej niż proporcjonalnie do powierzchni
6. Przemieszczanie atomów metalu ścieżki przez strumień elektronów przy dużej gęstości prądu — prowadzi do przerw i zwarć połączeń
7. $5\cdot 10^{22}/10^{16} = 5\cdot 10^6$

**Ocena:** 1, 7 — temat 01; 2 — 02; 3 — 03; 4 — 04; 5 — 07; 6 — 08.
</details>

## Projekt modułowy: od karty procesu do kosztu układu

- [ ] **Karta procesu (tematy 01–06):** rozpisz uproszczony proces CMOS (studnie, izolacja, bramka, źródło/dren, kontakty, dwie warstwy metalu) jako tabelę kroków: operacja, maska, parametry (temperatura, czas, dawka), wynik.
- [ ] **Obliczenia procesowe (tematy 02–04):** czas utleniania dla tlenku polowego i bramkowego, głębokość złącza źródła/drenu po wygrzewaniu, rozdzielczość litografii dla wybranego węzła — skrypt w Pythonie z wykresami.
- [ ] **Połączenia (temat 05):** opóźnienie RC ścieżki 1 mm w kilku warstwach metalu; porównanie miedzi i aluminium, wpływ zwężania.
- [ ] **Ekonomia (temat 07):** koszt dobrej struktury w funkcji jej powierzchni dla dwóch gęstości defektów i dwóch kosztów płytki; wnioski o opłacalności podziału dużego układu na chiplety.
- [ ] **Niezawodność (temat 08):** plan testu przyspieszonego (HTOL) dla wymaganego wskaźnika FIT; liczba próbek i czas.

## Sprawdzian końcowy modułu

- [ ] Opisuję wytwarzanie monokryształu i płytki, liczę liczbę struktur na płytce.
- [ ] Liczę grubość tlenku z modelu Deala–Grove'a, rozróżniam metody osadzania (CVD, PVD, ALD).
- [ ] Liczę rozdzielczość i głębię ostrości litografii, rozumiem rolę immersji, EUV i wielokrotnego naświetlania.
- [ ] Liczę profil domieszki po dyfuzji i implantacji, głębokość złącza i dawkę.
- [ ] Rozróżniam trawienie mokre i suche, liczę opór i opóźnienie połączeń.
- [ ] Opisuję kolejne etapy procesu CMOS i strukturę FinFET/GAA.
- [ ] Liczę uzysk i koszt struktury, opisuję prawa skalowania i ich granice.
- [ ] Opisuję obudowy i mechanizmy uszkodzeń, liczę współczynnik przyspieszenia i FIT.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [MIT 6.152J Micro/Nano Processing Technology (2005)](https://ocw.mit.edu/courses/6-152j-micro-nano-processing-technology-fall-2005/) | Główny kurs modułu: utlenianie, dyfuzja, implantacja, litografia, trawienie, osadzanie; laboratorium |
| [MIT 6.774 Physics of Microfabrication: Front End Processing (2004)](https://ocw.mit.edu/courses/6-774-physics-of-microfabrication-front-end-processing-fall-2004/) | Fizyka procesów: dyfuzja, implantacja, utlenianie — poziom zaawansowany |
| [Purdue — Semiconductor Fabrication 101 (bezpłatny kurs online)](https://engineering.purdue.edu/online/semiconductors/semiconductor-fabrication-101) | Przegląd całego procesu produkcji |
| [ASML — Lithography principles: Rayleigh criterion](https://www.asml.com/technology/lithography-principles/rayleigh-criterion) | Rozdzielczość litografii, DUV i EUV — temat 03 |
| J. D. Plummer, M. D. Deal, P. B. Griffin — *Silicon VLSI Technology* (płatna) | Podstawowy podręcznik technologii |
| R. C. Jaeger — *Introduction to Microelectronic Fabrication* (płatna) | Przystępny podręcznik z zadaniami |
| JEDEC JESD47 — *Stress-Test-Driven Qualification of Integrated Circuits* (norma) | Kwalifikacja i testy niezawodności — temat 08 |
