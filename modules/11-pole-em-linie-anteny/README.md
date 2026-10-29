# 11 — Pole elektromagnetyczne, linie transmisyjne i anteny

> **Status:** ✅ pełny

## Cel modułu

Rozumieć propagację fal elektromagnetycznych, zachowanie linii transmisyjnych i podstawy anten oraz liczyć budżet łącza radiowego. To fundament techniki w.cz. ([12](../12-technika-wcz-rf/)), integralności sygnałów i kompatybilności EM ([16](../16-pcb-emc-konstrukcja/)), a także telekomunikacji ([13](../13-telekomunikacja/)).

## Wymagania wstępne

- [00.08 Rachunek wektorowy](../00-matematyka/08-rachunek-wektorowy.md), [00.01 Liczby zespolone](../00-matematyka/01-liczby-zespolone.md).
- [02 Fizyka i materiały](../02-fizyka-i-materialy/) — elektrostatyka, magnetyzm, indukcja, fale.
- [01.06 Analiza AC i fazory](../01-teoria-obwodow/06-analiza-ac-fazory.md).

## Tematy

| # | Temat | Czas (od zera / odświeżenie) |
|---|---|---|
| 01 | [Równania Maxwella](01-rownania-maxwella.md) | 10 h / 3 h |
| 02 | [Fale płaskie](02-fale-plaskie.md) | 8 h / 2 h |
| 03 | [Linie transmisyjne w stanie ustalonym](03-linie-transmisyjne.md) | 10 h / 3 h |
| 04 | [Wykres Smitha i dopasowanie impedancji](04-wykres-smitha-i-dopasowanie.md) | 8 h / 3 h |
| 05 | [Stany nieustalone na liniach i integralność sygnałów](05-stany-nieustalone-na-liniach.md) | 6 h / 2 h |
| 06 | [Linie praktyczne i falowody](06-linie-praktyczne-i-falowody.md) | 6 h / 2 h |
| 07 | [Anteny](07-anteny.md) | 8 h / 3 h |
| 08 | [Propagacja fal radiowych i budżet łącza](08-propagacja-i-budzet-lacza.md) | 6 h / 2 h |

## Test wejściowy (diagnoza)

Około 60 minut, bez notatek.

1. Zapisz równania Maxwella w postaci różniczkowej i powiedz, co oznacza każde z nich.
2. Ile wynosi impedancja falowa wolnej przestrzeni? Jaka jest prędkość fali w ośrodku o $\varepsilon_r = 4$?
3. Głębokość wnikania w miedzi przy 1 MHz wynosi ok. 65 µm. Ile przy 100 MHz?
4. Linia 50 Ω obciążona rezystancją 100 Ω. Współczynnik odbicia, WFS, tłumienie odbiciowe?
5. Jaką impedancję wejściową ma linia ćwierćfalowa 50 Ω obciążona zwarciem? A rozwarciem?
6. Dipol półfalowy na 868 MHz — jaka w przybliżeniu długość?
7. Ile wynosi tłumienie wolnej przestrzeni dla 2,4 GHz na 100 m?

<details>
<summary>Odpowiedzi</summary>

1. $\nabla\cdot\mathbf D = \rho$ (ładunek źródłem pola E), $\nabla\cdot\mathbf B = 0$ (brak ładunków magnetycznych), $\nabla\times\mathbf E = -\partial\mathbf B/\partial t$ (indukcja Faradaya), $\nabla\times\mathbf H = \mathbf J + \partial\mathbf D/\partial t$ (prawo Ampère'a z prądem przesunięcia)
2. ≈ 377 Ω (120π); $c/2 = 1\text{,}5\cdot 10^8$ m/s
3. $\delta \propto 1/\sqrt f$ → 6,5 µm
4. $\Gamma = 1/3$, WFS = 2, RL ≈ 9,5 dB
5. Zwarcie → rozwarcie (∞), rozwarcie → zwarcie (0)
6. $\lambda/2 \approx 17\text{,}3$ cm, w praktyce ok. 16–16,5 cm (skrócenie ok. 5%)
7. ≈ 80 dB

**Ocena:** 1 — temat 01; 2–3 — 02; 4–5 — 03; 6 — 07; 7 — 08.
</details>

## Projekt modułowy: linia, dopasowanie i łącze

- [ ] **Symulacja odbić:** w LTspice linia bezstratna (element `T`) z różnymi rezystancjami źródła i obciążenia; porównaj przebiegi z wykresem odbić liczonym ręcznie (temat 05).
- [ ] **Pomiar TDR „dla ubogich”:** generator z szybkim zboczem + oscyloskop + kilka metrów kabla koncentrycznego; zmierz opóźnienie, wyznacz współczynnik skrócenia i zobacz odbicia przy rozwarciu, zwarciu i dopasowaniu.
- [ ] **Dopasowanie:** zaprojektuj na wykresie Smitha dopasowanie obciążenia zespolonego do 50 Ω (transformator λ/4 i stub równoległy); sprawdź analizą AC w LTspice pasmo dopasowania.
- [ ] **Antena:** zbuduj dipol lub monopol ćwierćfalowy na wybrane pasmo (np. 433 lub 868 MHz); jeśli masz dostęp do analizatora (choćby taniego NanoVNA), zmierz S11 i skróć antenę do rezonansu.
- [ ] **Budżet łącza:** policz zasięg dla wybranego modułu radiowego (moc, czułość, anteny, margines zaników) i porównaj z próbą w terenie.

## Sprawdzian końcowy modułu

- [ ] Rozumiem fizyczny sens każdego równania Maxwella i warunki brzegowe.
- [ ] Liczę parametry fali płaskiej, głębokość wnikania i odbicie na granicy ośrodków.
- [ ] Liczę impedancję wejściową linii obciążonej, Γ, WFS i straty niedopasowania.
- [ ] Posługuję się wykresem Smitha i projektuję dopasowanie transformatorem λ/4 i stubem.
- [ ] Rysuję wykres odbić i dobieram terminację linii cyfrowej.
- [ ] Dobieram linię (koncentryczna, mikropaskowa, falowód) i liczę jej impedancję.
- [ ] Znam parametry anten i liczę budżet łącza z równania Friisa.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [Electromagnetics, Vol. 1 — S. W. Ellingson](https://doi.org/10.21061/electromagnetics-vol-1) | Główny podręcznik: linie transmisyjne, elektrostatyka, magnetostatyka, fale płaskie (z zadaniami i rozwiązaniami) |
| [Electromagnetics, Vol. 2 — S. W. Ellingson](https://doi.org/10.21061/electromagnetics-vol-2) | Odbicia, falowody, anteny, propagacja |
| [MIT 6.013 Electromagnetics and Applications (2005)](https://ocw.mit.edu/courses/6-013-electromagnetics-and-applications-fall-2005/) | Kurs inżynierski: Maxwell, fale, linie, promieniowanie |
| [MIT 8.02 Physics II: Electricity and Magnetism](https://ocw.mit.edu/courses/8-02-physics-ii-electricity-and-magnetism-spring-2007/) | Równania Maxwella na poziomie fizyki, wizualizacje |
| [Fundamentals of Microwave and RF Design — M. Steer (open textbook)](https://open.umn.edu/opentextbooks/textbooks/fundamentals-of-microwave-and-rf-design) | Linie transmisyjne, mikropaski, dopasowanie — most do modułu 12 |
| [antenna-theory.com](https://antenna-theory.com/) | Przystępny przewodnik po parametrach i typach anten |
| [Falstad — symulator obwodów (przykłady linii)](https://falstad.com/circuit/e-index.html) | Animowane odbicia na liniach |
