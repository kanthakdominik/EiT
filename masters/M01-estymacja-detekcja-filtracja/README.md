# M01 — Detekcja, estymacja i filtracja optymalna

> **Status:** ✅ pełny · ścieżka magisterska (II stopień)

## Cel modułu

Wyciągać informację z zaszumionych pomiarów w sposób optymalny i umieć to udowodnić: decydować o obecności sygnału z zadanym prawdopodobieństwem fałszywego alarmu, wyznaczać granicę dokładności każdego estymatora (Craméra–Rao), konstruować estymatory największej wiarygodności, najmniejszych kwadratów i bayesowskie, projektować filtry Wienera i adaptacyjne (LMS, RLS) oraz filtr Kalmana z jego nieliniowymi wersjami. To fundament radaru, łączności, nawigacji, fuzji czujników, przetwarzania mowy i systemów pomiarowych.

## Wymagania wstępne

- [21 Procesy losowe i szum](../../modules/21-procesy-losowe-szum/) — cały moduł, w szczególności autokorelacja, widmo mocy i przejście przez układy liniowe.
- [00.04 Algebra liniowa](../../modules/00-matematyka/04-algebra-liniowa.md) i [20.03 Układy równań liniowych](../../modules/20-metody-numeryczne/03-uklady-rownan-liniowych.md) — macierze, rozkłady, uwarunkowanie.
- [10.06 Przestrzeń stanów](../../modules/10-automatyka/06-przestrzen-stanow.md) — dla tematów 07–08.
- [13.05 Detekcja i BER](../../modules/13-telekomunikacja/05-detekcja-i-ber.md) — filtr dopasowany w łączności.

## Tematy

| # | Temat | Czas |
|---|---|---|
| 01 | [Teoria detekcji: Neyman–Pearson, ROC, filtr dopasowany](01-teoria-detekcji.md) | 10 h |
| 02 | [Podstawy estymacji i granica Craméra–Rao](02-estymacja-i-crlb.md) | 10 h |
| 03 | [Największa wiarygodność i najmniejsze kwadraty](03-ml-i-najmniejsze-kwadraty.md) | 10 h |
| 04 | [Estymacja bayesowska: MAP, MMSE, LMMSE](04-estymacja-bayesowska.md) | 8 h |
| 05 | [Filtr Wienera](05-filtr-wienera.md) | 8 h |
| 06 | [Filtry adaptacyjne: LMS, NLMS, RLS](06-filtry-adaptacyjne.md) | 10 h |
| 07 | [Filtr Kalmana](07-filtr-kalmana.md) | 12 h |
| 08 | [Nieliniowe filtry Kalmana i fuzja czujników](08-nieliniowe-filtry-i-fuzja.md) | 10 h |

## Test wejściowy (diagnoza)

Około 60 minut.

1. Zmienna $X \sim \mathcal N(\mu, \sigma^2)$. Podaj funkcję wiarygodności $N$ niezależnych próbek i jej logarytm.
2. Ile wynosi wariancja średniej z $N$ niezależnych próbek o wariancji $\sigma^2$?
3. Zapisz rozwiązanie zadania najmniejszych kwadratów $\min_\theta\lVert\mathbf y - \mathbf H\theta\rVert^2$.
4. Proces $x[n] = ax[n-1] + w[n]$, $\lvert a\rvert < 1$, $w$ biały o wariancji $\sigma_w^2$. Ile wynosi wariancja $x$?
5. Gęstość widmowa wyjścia filtru o transmitancji $H(e^{j\omega})$ przy wejściu o gęstości $S_x$?
6. Czym różni się prawdopodobieństwo a priori od wiarygodności?

<details>
<summary>Odpowiedzi</summary>

1. $L(\mu, \sigma^2) = (2\pi\sigma^2)^{-N/2}\exp\left(-\tfrac{1}{2\sigma^2}\sum(x_i - \mu)^2\right)$; $\ln L = -\tfrac N2\ln(2\pi\sigma^2) - \tfrac{1}{2\sigma^2}\sum(x_i - \mu)^2$
2. $\sigma^2/N$
3. $\hat\theta = (\mathbf H^T\mathbf H)^{-1}\mathbf H^T\mathbf y$ (przy pełnym rzędzie $\mathbf H$)
4. $\sigma_w^2/(1 - a^2)$
5. $S_y = \lvert H\rvert^2S_x$
6. A priori $p(\theta)$ — wiedza o parametrze przed pomiarem; wiarygodność $p(\mathbf x\mid\theta)$ — prawdopodobieństwo danych przy danym parametrze, traktowane jako funkcja $\theta$

**Ocena:** 1–3 — tematy 02–03; 4–5 — moduł 21 i temat 05; 6 — temat 04.
</details>

## Projekt modułowy: śledzenie obiektu z fuzją czujników

- [ ] **Model (tematy 07–08):** obiekt w ruchu płaskim (np. robot, dron, samochód) z modelem stałej prędkości lub stałego skrętu; czujniki: GNSS (położenie, 1 Hz, kilka m), odometria lub IMU (prędkość/przyspieszenie, 50–100 Hz), opcjonalnie radar/odległościomierz.
- [ ] **Filtr:** Kalman (liniowa część) i EKF/UKF (pomiary nieliniowe), z asynchronicznymi pomiarami o różnych częstotliwościach.
- [ ] **Weryfikacja:** symulacja Monte Carlo — błąd RMS względem prawdy, test spójności NEES/NIS (czy kowariancja filtru odpowiada rzeczywistym błędom), porównanie z granicą Craméra–Rao dla przypadku statycznego.
- [ ] **Dane rzeczywiste:** zapis z telefonu (GNSS + akcelerometr + żyroskop) lub zestawu z mikrokontrolerem; strojenie $\mathbf Q$ i $\mathbf R$; raport z wykresami i analizą błędów.

## Sprawdzian końcowy modułu

- [ ] Formułuję test Neymana–Pearsona, wyznaczam próg i ROC, stosuję filtr dopasowany i GLRT.
- [ ] Wyznaczam informację Fishera i granicę Craméra–Rao, oceniam efektywność estymatora.
- [ ] Konstruuję estymator ML i LS (także ważony i nieliniowy), podaję jego kowariancję.
- [ ] Stosuję estymację bayesowską (MAP, MMSE, LMMSE) i rozumiem rolę informacji a priori.
- [ ] Projektuję filtr Wienera FIR i nieprzyczynowy, liczę jego MSE.
- [ ] Implementuję LMS, NLMS i RLS, dobieram krok i współczynnik zapominania, oceniam szybkość zbieżności i błąd ustalony.
- [ ] Implementuję filtr Kalmana, dobieram $\mathbf Q$ i $\mathbf R$, sprawdzam spójność, wyznaczam stan ustalony z równania Riccatiego.
- [ ] Stosuję EKF i UKF, rozumiem ich ograniczenia, projektuję fuzję czujników o różnych częstotliwościach.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [MIT 6.432 Stochastic Processes, Detection, and Estimation (2004)](https://ocw.mit.edu/courses/6-432-stochastic-processes-detection-and-estimation-spring-2004/) | Główny kurs modułu (poziom magisterski): detekcja, estymacja, filtracja Wienera i Kalmana |
| [MIT 6.011 Signals, Systems and Inference (2018)](https://ocw.mit.edu/courses/6-011-signals-systems-and-inference-spring-2018/) | Łagodniejsze wprowadzenie: estymacja LMMSE, filtr Wienera, testy hipotez |
| [MIT 2.160 Identification, Estimation, and Learning (2006)](https://ocw.mit.edu/courses/2-160-identification-estimation-and-learning-spring-2006/) | Filtr Kalmana, identyfikacja systemów, RLS |
| [R. Labbe — Kalman and Bayesian Filters in Python](https://github.com/rlabbe/Kalman-and-Bayesian-Filters-in-Python) | Darmowa książka w notatnikach Jupyter: Kalman, EKF, UKF, filtr cząsteczkowy |
| [G. Welch, G. Bishop — An Introduction to the Kalman Filter](https://www.cs.unc.edu/~welch/kalman/kalmanIntro.html) | Zwięzłe wprowadzenie do filtru Kalmana i EKF |
| S. M. Kay — *Fundamentals of Statistical Signal Processing*, t. I (estymacja) i II (detekcja) (płatne) | Klasyczne podręczniki modułu |
| S. Haykin — *Adaptive Filter Theory* (płatna) | Filtry adaptacyjne |
| D. Simon — *Optimal State Estimation* (płatna) | Kalman, H∞, filtry nieliniowe |
