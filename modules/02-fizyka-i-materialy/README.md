# 02 — Fizyka i materiałoznawstwo elektroniczne

> **Status:** ✅ pełny

## Cel modułu

Zrozumieć zjawiska fizyczne, na których opiera się elektronika: pole elektryczne i magnetyczne, przewodnictwo, fale oraz pasma energetyczne w półprzewodnikach. Bez tego przyrządy półprzewodnikowe (moduł 03) i pole EM (moduł 11) są tylko zbiorem wzorów do zapamiętania.

## Wymagania wstępne

- [00 Matematyka](../00-matematyka/): pochodne, całki, równania różniczkowe, [rachunek wektorowy](../00-matematyka/08-rachunek-wektorowy.md).

## Tematy

| # | Temat | Gdzie wraca | Czas (od zera / odświeżenie) |
|---|---|---|---|
| 01 | [Elektrostatyka i pojemność](01-elektrostatyka.md) | Kondensatory, złącze p-n, pole EM | 10 h / 3 h |
| 02 | [Prąd i przewodnictwo](02-prad-i-przewodnictwo.md) | Rezystory, ścieżki PCB, półprzewodniki | 6 h / 2 h |
| 03 | [Magnetyzm i indukcja](03-magnetyzm-i-indukcja.md) | Cewki, transformatory, EMC | 10 h / 3 h |
| 04 | [Drgania i fale](04-drgania-i-fale.md) | Obwody rezonansowe, linie, anteny | 6 h / 2 h |
| 05 | [Pasma energetyczne i półprzewodniki](05-pasma-i-polprzewodniki.md) | Wszystkie przyrządy półprzewodnikowe | 10 h / 3 h |
| 06 | [Transport nośników ładunku](06-transport-nosnikow.md) | Złącze p-n, tranzystory | 8 h / 2 h |
| 07 | [Materiały elektroniczne w praktyce](07-materialy-elektroniczne.md) | Dobór elementów biernych | 6 h / 2 h |

## Test wejściowy (diagnoza)

Rozwiąż bez notatek, około 60 minut.

1. Kondensator płaski: okładki 1 cm², odległość 0,1 mm, dielektryk $\varepsilon_r = 4$. Ile wynosi pojemność?
2. Jaka jest rezystancja 10 m przewodu miedzianego o przekroju 1 mm²?
3. Jakie jest natężenie pola magnetycznego (indukcja $B$) w odległości 1 cm od przewodu z prądem 10 A?
4. Jaka jest długość fali sygnału 2,4 GHz w próżni?
5. W krzemie domieszkowanym donorami $N_D = 10^{16}$ cm⁻³ (temperatura pokojowa, $n_i = 10^{10}$ cm⁻³) jaka jest koncentracja dziur?
6. Dlaczego rezystancja metalu rośnie z temperaturą, a półprzewodnika samoistnego maleje?

<details>
<summary>Odpowiedzi</summary>

1. $C = \varepsilon_0\varepsilon_r A/d \approx 35{,}4$ pF
2. $R = \rho l/A \approx 0{,}17\ \Omega$
3. $B = \mu_0 I/(2\pi r) = 200\ \mu$T
4. $\lambda = c/f = 12{,}5$ cm
5. $p = n_i^2/N_D = 10^4$ cm⁻³
6. W metalu liczba nośników jest stała, a z temperaturą rośnie rozpraszanie na drganiach sieci (maleje ruchliwość). W półprzewodniku samoistnym gwałtownie rośnie liczba nośników generowanych termicznie — ten efekt dominuje.
</details>

## Projekt modułowy: symulacja pola w kondensatorze

- [ ] Napisz w Pythonie rozwiązywanie równania Laplace'a $\nabla^2 V = 0$ metodą różnic skończonych (iteracja Jacobiego) w prostokącie z dwiema elektrodami.
- [ ] Policz pole $\mathbf{E} = -\nabla V$ i narysuj linie pola (`plt.streamplot`).
- [ ] Wyznacz pojemność z energii pola $W = \tfrac12\int\varepsilon E^2 dV$ i porównaj ze wzorem na kondensator płaski. Pokaż efekt brzegowy.
- [ ] Dodaj warstwę dielektryka o innym $\varepsilon_r$ i sprawdź warunki brzegowe na granicy ośrodków.

## Sprawdzian końcowy modułu

- [ ] Liczę pojemność, pole i energię prostych układów elektrod.
- [ ] Wyjaśniam, skąd bierze się indukcyjność i dlaczego cewka przeciwdziała zmianom prądu.
- [ ] Liczę koncentracje nośników w półprzewodniku domieszkowanym i jego rezystywność.
- [ ] Opisuję różnicę między dryftem a dyfuzją i wiem, gdzie każde zjawisko dominuje.
- [ ] Dobieram typ kondensatora i rdzenia do zastosowania na podstawie właściwości materiału.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [MIT 8.02 Physics II: Electricity and Magnetism](https://ocw.mit.edu/courses/8-02-physics-ii-electricity-and-magnetism-spring-2007/) | Tematy 01–04: podręcznik kursu, notatki, zadania, wizualizacje |
| [Electromagnetics, Vol. 1 — Ellingson](https://doi.org/10.21061/electromagnetics-vol-1) | Tematy 01–03 od strony inżynierskiej, z zadaniami i rozwiązaniami |
| [MIT 6.012 Microelectronic Devices and Circuits](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-spring-2009/) | Tematy 05–06: fizyka półprzewodników pod kątem przyrządów |
| [Semiconductor Devices — J. M. Fiore, rozdział 1](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html) | Temat 05 — przystępne wprowadzenie |
| [Khan Academy — Electrical Engineering](https://www.khanacademy.org/science/electrical-engineering) | Elektrostatyka i półprzewodniki na wideo |
| [All About Circuits Textbook](https://www.allaboutcircuits.com/textbook/) | Temat 07: przewodniki, izolatory, kondensatory, magnetyzm |
