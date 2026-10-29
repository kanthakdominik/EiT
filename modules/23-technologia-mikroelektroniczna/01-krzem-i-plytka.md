# 23.01 — Krzem i płytka

## Po co to jest

Każdy układ scalony zaczyna się od płytki (wafla) monokrystalicznego krzemu o czystości „dziewięciu dziewiątek” i powierzchni gładszej niż lustro. Właściwości płytki — orientacja kryształu, domieszkowanie, defekty, średnica — wpływają na parametry tranzystorów, a jej rozmiar na koszt każdej struktury. Ten temat opisuje drogę od piasku do płytki i liczy, ile struktur się na niej mieści.

## Teoria w pigułce

### Od piasku do monokryształu

1. **Krzem metalurgiczny** (98–99%) — redukcja kwarcu węglem w piecu łukowym.
2. **Krzem półprzewodnikowy** (99,9999999%, „9N”) — przez trichlorosilan (SiHCl₃), destylację i osadzanie (proces Siemensa) → polikrzem.
3. **Monokryształ metodą Czochralskiego (CZ):** zarodek o zadanej orientacji zanurzony w stopionym krzemie (1414 °C) i wyciągany z obrotem; domieszka (B, P, As, Sb) dodana do stopu. Kryształ zawiera tlen z tygla kwarcowego (ok. $10^{18}$ cm⁻³) — przydatny do wychwytywania zanieczyszczeń (gettering), ale ogranicza rezystywność.
4. **Metoda strefowa (FZ)** — bez tygla: bardzo czysty krzem o dużej rezystywności (detektory, elementy mocy wysokonapięciowe).

### Płytka

- Cięcie piłą drutową, szlifowanie, trawienie, **polerowanie chemiczno-mechaniczne (CMP)** do chropowatości rzędu 0,1 nm.
- Średnice: 150 mm (elementy mocy, MEMS), 200 mm (analogowe, czujniki, starsze węzły), **300 mm** (logika i pamięci); grubość 300 mm płytki ok. 775 µm.
- **Orientacja:** (100) dla CMOS (najmniej stanów powierzchniowych na granicy Si/SiO₂), (111) dla niektórych bipolarnych; oznaczana ścięciem (flat) lub wcięciem (notch).
- **Płytki epitaksjalne** — cienka warstwa monokryształu o innym domieszkowaniu wyhodowana na podłożu (np. lekko domieszkowana warstwa na silnie domieszkowanym podłożu — odporność na latch-up).
- **SOI** (krzem na izolatorze) — cienka warstwa krzemu na zakopanym tlenku: mniejsze pojemności, brak latch-up, RF i układy niskiej mocy.
- Inne materiały: SiC i GaN (elementy mocy, w.cz. — [15.04](../15-energoelektronika-zasilanie/04-elementy-straty-sprawnosc.md)), GaAs i InP (w.cz., optoelektronika — [22](../22-optoelektronika-fotonika/)).

### Czyste pomieszczenie

Cząstka wielkości wymiaru krytycznego niszczy strukturę. Klasy czystości ISO 14644-1: ISO 5 (ok. 3500 cząstek ≥ 0,5 µm na m³) do ISO 3 i lepszych w strefach litografii; płytki przenoszone w zamkniętych pojemnikach (FOUP) z czystą atmosferą.

## Przykład rozwiązany

**Ile struktur mieści się na płytce 300 mm?** Przybliżenie z uwzględnieniem strat na brzegu:

$$N \approx \frac{\pi d^2}{4S} - \frac{\pi d}{\sqrt{2S}}$$

- Struktura 100 mm² (10 × 10 mm): $\dfrac{\pi\cdot 300^2}{400} - \dfrac{\pi\cdot 300}{\sqrt{200}} = 706\text{,}9 - 66\text{,}6 \approx 640$.
- Struktura 600 mm² (duży procesor graficzny): $117\text{,}8 - 27\text{,}2 \approx 91$.

Sześciokrotnie większa struktura — siedmiokrotnie mniej sztuk na płytce, bo większa część brzegu się marnuje. Uwzględnienie uzysku pogarsza ten stosunek jeszcze bardziej ([23.07](07-skalowanie-uzysk-koszt.md)).

## Typowe pułapki

- **Myślenie o krzemie jako „zwykłym” materiale** — zanieczyszczenie metalami na poziomie $10^{10}$ atomów/cm² (miliardowe części) psuje czasy życia nośników i upływy.
- **Mylenie rezystywności płytki z parametrami przyrządu** — w CMOS o progach decydują implantacje w studniach, nie podłoże.
- **Pomijanie straty brzegowej** w szacowaniu liczby struktur.
- **Utożsamianie średnicy płytki z węzłem technologicznym** — to dwie niezależne cechy.

## Ćwiczenie komputerowe

Liczba struktur na płytce w funkcji rozmiaru struktury i średnicy płytki — wzór przybliżony i zliczenie siatki:

```python
import numpy as np

def dies_formula(d, S):
    return np.pi*d**2/(4*S) - np.pi*d/np.sqrt(2*S)

def dies_grid(d, a, b, edge=3.0):
    """Zliczanie prostokątów a×b mm całkowicie w kole o średnicy d − 2·edge (najlepsze przesunięcie siatki)."""
    R = d/2 - edge; best = 0
    for ox in np.linspace(0, a, 11):
        for oy in np.linspace(0, b, 11):
            xs = np.arange(-R - a + ox, R + a, a); ys = np.arange(-R - b + oy, R + b, b)
            X, Y = np.meshgrid(xs, ys)
            corners = [(X, Y), (X + a, Y), (X, Y + b), (X + a, Y + b)]
            inside = np.all([cx**2 + cy**2 <= R**2 for cx, cy in corners], axis=0)
            best = max(best, int(inside.sum()))
    return best

for d in (200, 300):
    for side in (5, 10, 24.5):
        S = side**2
        print(f"płytka {d} mm, struktura {side} × {side} mm: wzór {dies_formula(d, S):6.0f}, siatka (brzeg 3 mm) {dies_grid(d, side, side):6d}")
```

## Zadania

1. Ile struktur 5 × 5 mm mieści się na płytce 200 mm (ze wzoru)?
2. Dlaczego do CMOS stosuje się płytki o orientacji (100)?
3. Ile wynosi koncentracja domieszki odpowiadająca jednemu atomowi na milion atomów krzemu?
4. Do czego służą płytki epitaksjalne i SOI?
5. Dlaczego przejście z płytek 200 mm na 300 mm obniża koszt struktury?

<details>
<summary>Odpowiedzi</summary>

1. $\pi\cdot 200^2/100 - \pi\cdot 200/\sqrt{50} = 1257 - 89 \approx 1168$
2. Na powierzchni (100) gęstość stanów powierzchniowych na granicy z SiO₂ jest najmniejsza — stabilne i powtarzalne napięcie progowe, większa ruchliwość elektronów w kanale
3. $5\cdot 10^{22}/10^6 = 5\cdot 10^{16}$ cm⁻³
4. Epitaksja: warstwa o kontrolowanym, innym niż podłoże domieszkowaniu i niższej gęstości defektów (np. struktury bipolarne, odporność na latch-up, elementy mocy). SOI: izolacja tranzystorów od podłoża — mniejsze pojemności pasożytnicze i upływy, brak latch-up, lepsze własności w.cz. i radiacyjne
5. Powierzchnia rośnie 2,25 razy, a koszt przetworzenia płytki znacznie mniej (wiele etapów przetwarza płytkę jako całość); mniejsza też względna strata na brzegu
</details>

## Źródła

- [MIT 6.152J Micro/Nano Processing Technology](https://ocw.mit.edu/courses/6-152j-micro-nano-processing-technology-fall-2005/) — wykład o krzemie i czystości
- [Purdue — Semiconductor Fabrication 101](https://engineering.purdue.edu/online/semiconductors/semiconductor-fabrication-101)
- [02.07 Materiały elektroniczne](../02-fizyka-i-materialy/07-materialy-elektroniczne.md)
