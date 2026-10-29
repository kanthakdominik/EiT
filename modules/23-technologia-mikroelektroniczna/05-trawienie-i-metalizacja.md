# 23.05 — Trawienie i metalizacja

## Po co to jest

Litografia rysuje wzór w rezyście, trawienie przenosi go do warstwy pod spodem — z pionowymi ścianami i bez naruszania warstw niżej. Metalizacja łączy miliardy tranzystorów kilkunastoma warstwami połączeń, które w nowoczesnych układach decydują o opóźnieniach i poborze mocy bardziej niż same tranzystory. Ten temat opisuje metody trawienia, proces damasceński z miedzią i liczy opór oraz opóźnienie ścieżek.

## Teoria w pigułce

### Trawienie

| Cecha | Trawienie mokre | Trawienie suche (plazmowe, RIE) |
|---|---|---|
| Zasada | Roztwór chemiczny (HF dla SiO₂, H₃PO₄ dla Si₃N₄, KOH dla Si) | Plazma: jony + rodniki (CF₄, Cl₂, SF₆, O₂) |
| Kierunkowość | **Izotropowe** (podtrawienie pod maskę) — wyjątek: anizotropowe trawienie krystalograficzne Si w KOH (MEMS) | **Anizotropowe** (pionowe ściany) dzięki bombardowaniu jonami |
| Selektywność | Bardzo duża | Mniejsza, regulowana chemią |
| Zastosowanie | Czyszczenie, usuwanie warstw, MEMS | Wzory o małych wymiarach |

- **Anizotropia** $A = 1 - r_{lat}/r_{pion}$ (1 — idealnie pionowe).
- **Selektywność** $S = r_{warstwa}/r_{maska\ lub\ podłoże}$ — decyduje, ile przetrawienia można dopuścić.
- **DRIE (proces Boscha)** — naprzemienne trawienie SF₆ i pasywacja C₄F₈: głębokie rowki o dużym współczynniku kształtu (MEMS, przelotki TSV).
- **Planaryzacja CMP** — polerowanie chemiczno-mechaniczne usuwa nadmiar materiału i wyrównuje powierzchnię (warunek głębi ostrości litografii).

### Metalizacja

- **Aluminium** (z Cu 0,5–1% przeciw elektromigracji) — do ok. 180 nm; osadzanie PVD i trawienie plazmowe.
- **Miedź** (od ok. 130 nm): mniejsza rezystywność (1,7 vs 2,7 µΩ·cm) i lepsza odporność na elektromigrację, ale nie da się jej łatwo trawić plazmowo i dyfunduje w krzemie → **proces damasceński (dual damascene):** trawienie rowków i otworów w dielektryku → bariera (Ta/TaN) i warstwa zarodkowa → galwaniczne wypełnienie miedzią → CMP.
- **Dielektryki low-k** (SiOCH, porowate, $\varepsilon_r$ = 2,5–3 zamiast 3,9) — mniejsza pojemność między ścieżkami.
- **Kontakty** do krzemu: krzemki (NiSi, TiSi₂) + wolfram lub kobalt; w najnowszych węzłach ruten i molibden w najwęższych ścieżkach.
- **Hierarchia warstw:** najniższe — najwęższe (lokalne połączenia), wyższe — coraz grubsze (globalne sygnały, zasilanie, zegar).

### Opóźnienie połączeń

- Opór: $R = \rho\dfrac{L}{wt}$; przy szerokościach rzędu kilkudziesięciu nm rezystywność miedzi rośnie 2–3× (rozpraszanie na granicach i powierzchni, bariera zajmuje część przekroju).
- Pojemność: ok. 0,1–0,2 fF/µm (słabo zależy od skalowania).
- Linia rozłożona RC: opóźnienie $\approx 0\text{,}38\,RC$ (Elmore: $0\text{,}5RC$); rośnie z **kwadratem długości** → długie połączenia dzieli się wzmacniaczami (repeatery).
- Skalowanie: przy zmniejszaniu wymiarów o $1/\kappa$ opór na jednostkę długości rośnie $\kappa^2$ razy, a pojemność zostaje — opóźnienie długich połączeń **rośnie**, gdy tranzystory przyspieszają.

## Przykład rozwiązany

**Ścieżka miedziana 1 mm**, szerokość 100 nm, grubość 200 nm, pojemność 0,2 fF/µm.

1. Rezystywność objętościowa 1,7 µΩ·cm: $R = 1\text{,}7\cdot 10^{-8}\cdot 10^{-3}/(10^{-7}\cdot 2\cdot 10^{-7}) = 850$ Ω.
2. Rezystywność efektywna przy tej szerokości ok. 4 µΩ·cm: $R = 2$ kΩ.
3. $C = 0\text{,}2\ \text{fF}/\mu\text{m}\cdot 1000\ \mu\text{m} = 200$ fF.
4. Opóźnienie linii: $0\text{,}38\cdot 2000\cdot 200\cdot 10^{-15} \approx 150$ ps — tyle co kilkanaście–kilkadziesiąt bramek logicznych. Podział na 4 odcinki ze wzmacniaczami: opóźnienie RC każdego odcinka 16 razy mniejsze, razem 4 razy mniejsze (plus opóźnienie wzmacniaczy).

## Typowe pułapki

- **Trawienie mokre małych wzorów** — podtrawienie zjada wymiar.
- **Za mała selektywność** — przetrawienie przez warstwę zatrzymującą i uszkodzenie podłoża.
- **Ładowanie plazmą** (antenna effect) — długie ścieżki podłączone do bramki zbierają ładunek w czasie trawienia i przebijają tlenek bramkowy; reguły projektowe ograniczają stosunek powierzchni anteny do bramki.
- **Liczenie oporu z rezystywnością objętościową** dla wąskich ścieżek — zaniżenie 2–3×.
- **Długie połączenia globalne w dolnych warstwach** — prowadzi się je w grubych, górnych warstwach metalu.

## Ćwiczenie komputerowe

Opóźnienie ścieżki w funkcji długości i liczby wzmacniaczy (model linii rozłożonej + bufor):

```python
import numpy as np

rho_eff, w, t, c_per_um = 4e-8, 100e-9, 200e-9, 0.2e-15
r_per_um = rho_eff*1e-6/(w*t)                        # Ω/µm
R_drv, C_in, t_buf = 1e3, 2e-15, 15e-12              # wzmacniacz: rezystancja wyjściowa, pojemność wejściowa, opóźnienie własne

def delay(L_um, n_seg):
    """Opóźnienie linii długości L podzielonej na n_seg odcinków z wzmacniaczami."""
    l = L_um/n_seg
    R, C = r_per_um*l, c_per_um*l
    seg = 0.69*R_drv*(C + C_in) + 0.38*R*C + 0.69*R*C_in + t_buf
    return n_seg*seg

for L in (100, 1000, 5000):
    best = min(range(1, 41), key=lambda n: delay(L, n))
    print(f"L = {L:5d} µm: bez podziału {delay(L, 1)*1e12:8.1f} ps, optymalnie {best:2d} odcinków → {delay(L, best)*1e12:7.1f} ps")
print(f"R(1 mm) = {r_per_um*1000:.0f} Ω, C(1 mm) = {c_per_um*1000*1e15:.0f} fF")
```

Model jest uproszczony (stała rezystancja wyjściowa i pojemność wzmacniacza), ale pokazuje główną zależność: bez wzmacniaczy opóźnienie rośnie z kwadratem długości, z optymalnym podziałem — liniowo.

## Zadania

1. Rezystancja ścieżki aluminiowej ($\rho = 2\text{,}7$ µΩ·cm) 500 µm × 0,5 µm × 0,5 µm?
2. Trawienie: szybkość pionowa 100 nm/min, boczna 5 nm/min. Ile wynosi anizotropia?
3. Dlaczego miedź wymaga bariery (Ta/TaN), a aluminium jej nie potrzebowało w tym samym stopniu?
4. Ile razy wzrośnie opóźnienie RC ścieżki, gdy jej długość się podwoi (bez wzmacniaczy)?
5. Dlaczego dielektryki low-k są mechanicznie problematyczne w CMP i montażu?

<details>
<summary>Odpowiedzi</summary>

1. $R = 2\text{,}7\cdot 10^{-8}\cdot 5\cdot 10^{-4}/(0\text{,}5\cdot 10^{-6})^2 = 54$ Ω
2. $A = 1 - 5/100 = 0\text{,}95$
3. Miedź szybko dyfunduje w krzemie i SiO₂, tworząc w krzemie głębokie poziomy (centra rekombinacji, upływy) — bariera ją zatrzymuje i poprawia przyczepność. Aluminium dyfunduje znacznie słabiej (choć z krzemem tworzy „kolce”, stąd domieszka Si w Al i bariery TiN pod kontaktami)
4. 4 razy (R i C rosną liniowo z długością)
5. Mają mały moduł Younga i słabą przyczepność (szczególnie porowate) — pękają i rozwarstwiają się pod naciskiem polerowania, przy cięciu płytki i przy naprężeniach termicznych w obudowie
</details>

## Źródła

- [MIT 6.152J Micro/Nano Processing Technology](https://ocw.mit.edu/courses/6-152j-micro-nano-processing-technology-fall-2005/) — trawienie i metalizacja
- [Purdue — Semiconductor Fabrication 101](https://engineering.purdue.edu/online/semiconductors/semiconductor-fabrication-101)
- J. D. Plummer, M. D. Deal, P. B. Griffin — *Silicon VLSI Technology* (płatna) — rozdziały o trawieniu i połączeniach
