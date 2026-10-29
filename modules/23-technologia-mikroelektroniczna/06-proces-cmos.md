# 23.06 — Proces CMOS krok po kroku

## Po co to jest

Tematy 01–05 opisują pojedyncze operacje; ten temat składa je w kompletny proces wytwarzania inwertera CMOS. Znajomość kolejności kroków wyjaśnia strukturę tranzystora z [03.06](../03-przyrzady-polprzewodnikowe/06-mosfet.md), pochodzenie elementów pasożytniczych (tyrystor pasożytniczy i latch-up, pojemności złącz, diody do podłoża), reguły projektowe w layoucie i to, dlaczego wyprowadzenia układu mają diody zabezpieczające ESD.

## Teoria w pigułce

### Uproszczony proces (płaski CMOS, studnia podwójna, dwie warstwy metalu)

| # | Etap | Operacje | Maska |
|---|---|---|---|
| 1 | Podłoże | Płytka p (lub p na p+ z epitaksją) | — |
| 2 | **Izolacja STI** | Trawienie rowków, wypełnienie SiO₂ (CVD), CMP | 1 |
| 3 | **Studnie** | Implantacja studni n (dla PMOS) i p (dla NMOS), wygrzewanie | 2, 3 |
| 4 | Korekcja progu | Implantacje kanałów (dawki $10^{12}$–$10^{13}$ cm⁻²) | 4, 5 |
| 5 | **Bramka** | Tlenek bramkowy (termiczny lub high-k ALD), polikrzem lub metal, litografia i trawienie bramki | 6 |
| 6 | **LDD** | Płytkie, słabo domieszkowane przedłużenia źródła/drenu (mniejsze pole przy drenie) | 7, 8 |
| 7 | Dystanse (spacers) | Osadzenie Si₃N₄, anizotropowe trawienie — dystanse przy bokach bramki | — |
| 8 | **Źródło i dren** | Implantacja n+ (As/P) dla NMOS i p+ (B) dla PMOS, samowyrównana do bramki; RTA | 9, 10 |
| 9 | Krzemki | NiSi na bramce, źródle i drenie (mała rezystancja kontaktu) | — |
| 10 | **Kontakty** | Dielektryk, otwory, wolfram, CMP | 11 |
| 11 | **Metal 1, przelotki, metal 2** | Proces damasceński z miedzią | 12–14 |
| 12 | Pasywacja | Si₃N₄/SiO₂, otwarcie pól kontaktowych | 15 |

Proces produkcyjny nowoczesnego węzła ma ok. 1000 operacji, 60–80 masek i trwa 2–3 miesiące.

### Samowyrównanie

Bramka wykonana **przed** implantacją źródła i drenu sama działa jak maska — krawędzie obszarów n+/p+ trafiają dokładnie pod krawędź bramki bez potrzeby precyzyjnego nakładania masek. To kluczowa idea technologii MOS.

### Struktury nowoczesne

- **Strained silicon** — naprężony kanał (SiGe w źródle/drenie PMOS, warstwy naprężające) zwiększa ruchliwość.
- **High-k / metal gate (HKMG)** — HfO₂ zamiast SiO₂, bramka metalowa (bez zubożenia polikrzemu).
- **FinFET** (od ok. 22/16 nm) — kanał w pionowym „żeberku” otoczonym bramką z trzech stron: lepsza kontrola kanału, mniejszy upływ. Szerokość tranzystora jest skwantowana liczbą żeberek.
- **GAA / nanosheet** (od ok. 3/2 nm) — bramka otacza kanał ze wszystkich stron; kanały w postaci ułożonych w stos płatków.
- **Zasilanie od spodu płytki** (backside power delivery) — sieć zasilania przeniesiona pod tranzystory.

### Elementy pasożytnicze

- **Latch-up:** struktura p+ (PMOS) / studnia n / podłoże p / n+ (NMOS) tworzy tyrystor pasożytniczy; po wyzwoleniu (prąd wstrzyknięty przez wyprowadzenie, zakłócenie) zwiera zasilanie. Zapobiega się mu kontaktami do studni i podłoża gęsto rozmieszczonymi, pierścieniami ochronnymi, epitaksją, SOI.
- Diody złącz źródła/drenu do studni — podstawa struktur ESD na wyprowadzeniach.
- Pojemności złącz i nakładania bramki — ograniczają szybkość.

### Pojemność tlenku bramkowego

$$C_{ox} = \frac{\varepsilon_{ox}}{t_{ox}}$$

Dla SiO₂ ($\varepsilon_r = 3\text{,}9$) o grubości 2 nm: $C_{ox} = 3\text{,}9\cdot 8\text{,}854\cdot 10^{-12}/2\cdot 10^{-9} = 17\text{,}3$ fF/µm². Prąd tranzystora w nasyceniu jest proporcjonalny do $C_{ox}$ — dążenie do cieńszego tlenku przy ograniczeniu przez tunelowanie prowadzi do high-k: **EOT** (równoważna grubość tlenku) $= t_{hk}\cdot 3\text{,}9/\varepsilon_{hk}$.

## Przykład rozwiązany

**EOT tlenku HfO₂:** warstwa 3 nm HfO₂ ($\varepsilon_r = 22$) na 0,5 nm warstwie przejściowej SiO₂.

$$\mathrm{EOT} = 0\text{,}5 + 3\cdot\frac{3\text{,}9}{22} = 0\text{,}5 + 0\text{,}53 = 1\text{,}03\ \text{nm}$$

Pojemność jak dla ok. 1 nm SiO₂ ($C_{ox} \approx 33$ fF/µm²), przy grubości fizycznej 3,5 nm — prąd tunelowy mniejszy o rzędy wielkości.

## Typowe pułapki

- **Wyobrażanie sobie tranzystora jako osobnego elementu** — w układzie scalonym wszystkie tranzystory dzielą podłoże i studnie; to źródło sprzężeń i latch-up.
- **Wymuszanie prądu w wyprowadzenie poza zasilanie** (np. sygnał przy wyłączonym zasilaniu układu) — diody ESD przewodzą, zasilają układ „od tyłu” lub wyzwalają latch-up ([09.08](../09-mikrokontrolery-embedded/08-sprzet-wokol-mcu.md)).
- **Pomijanie pojemności nakładania** bramki na źródło/dren w modelu.
- **Myślenie, że FinFET ma dowolną szerokość** — szerokość jest wielokrotnością żeberka.

## Ćwiczenie komputerowe

Pojemność bramki i EOT dla różnych dielektryków, prąd nasycenia prostego modelu MOSFET-a (model kwadratowy) przy zmianie EOT:

```python
import numpy as np

eps0 = 8.854e-12
def cox(t_nm, er=3.9):
    return er*eps0/(t_nm*1e-9)                       # F/m²

for name, layers in [("SiO2 2 nm", [(2.0, 3.9)]), ("SiO2 1,2 nm", [(1.2, 3.9)]),
                     ("HfO2 3 nm + SiO2 0,5 nm", [(0.5, 3.9), (3.0, 22)])]:
    eot = sum(t*3.9/er for t, er in layers)
    print(f"{name:25s}: EOT = {eot:.2f} nm, C_ox = {cox(eot)*1e15/1e12:.1f} fF/µm², grubość fizyczna {sum(t for t, _ in layers):.1f} nm")

# model kwadratowy: I_D = 0,5·µ·C_ox·(W/L)·(U_GS − U_T)²
mu, W_L, Vgs, Vt = 0.02, 10, 1.0, 0.35            # µ = 200 cm²/(V·s) (z degradacją), W/L = 10
for eot in (2.0, 1.0):
    Id = 0.5*mu*cox(eot)*W_L*(Vgs - Vt)**2
    print(f"EOT = {eot} nm: I_D(nasycenie) ≈ {Id*1e3:.2f} mA (model kwadratowy, bez efektów krótkiego kanału)")
```

## Zadania

1. Dlaczego izolacja rowkowa STI zastąpiła izolację przez lokalne utlenianie (LOCOS)?
2. Co oznacza „samowyrównanie” źródła i drenu względem bramki?
3. Policz EOT dla 2 nm HfO₂ ($\varepsilon_r = 25$) bez warstwy przejściowej.
4. Jakie elementy struktury CMOS tworzą tyrystor pasożytniczy i jak projektant layoutu mu przeciwdziała?
5. Dlaczego przejście z tranzystorów płaskich na FinFET zmniejszyło upływy?

<details>
<summary>Odpowiedzi</summary>

1. LOCOS tworzy „ptasi dziób” — tlenek wnika pod maskę azotkową i zjada obszar aktywny, a topografia utrudnia litografię; STI daje pionowe ściany i płaską powierzchnię (CMP), co pozwala gęściej upakować tranzystory
2. Bramkę wykonuje się przed implantacją źródła i drenu; bramka (z dystansami) zasłania kanał, więc obszary źródła i drenu automatycznie zaczynają się przy jej krawędziach, bez błędu nałożenia masek
3. $2\cdot 3\text{,}9/25 = 0\text{,}31$ nm
4. p+ źródła PMOS – studnia n – podłoże p – n+ źródła NMOS (struktura pnpn, z rezystancjami studni i podłoża); przeciwdziałanie: gęste kontakty do studni i podłoża (zmniejszają spadki napięcia), pierścienie ochronne wokół tranzystorów przy wyprowadzeniach, odległość między NMOS i PMOS w strukturach wejścia/wyjścia
5. Bramka otacza kanał z trzech stron, więc lepiej kontroluje potencjał w całym kanale; w tranzystorze płaskim dren przy krótkim kanale „sięga” do źródła przez obszar pod powierzchnią (DIBL, upływ podprogowy). Lepsza kontrola elektrostatyczna = mniejsze nachylenie podprogowe i upływ
</details>

## Źródła

- [MIT 6.152J Micro/Nano Processing Technology](https://ocw.mit.edu/courses/6-152j-micro-nano-processing-technology-fall-2005/) — integracja procesu CMOS
- [MIT 6.012 Microelectronic Devices and Circuits](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-spring-2009/) — MOSFET i jego struktura
- [Purdue — Semiconductor Fabrication 101](https://engineering.purdue.edu/online/semiconductors/semiconductor-fabrication-101)
