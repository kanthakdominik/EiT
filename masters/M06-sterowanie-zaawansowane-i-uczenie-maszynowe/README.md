# M06 — Sterowanie zaawansowane i uczenie maszynowe

> **Status:** ✅ pełny · ścieżka magisterska (II stopień)

## Cel modułu

Rozszerzyć automatykę inżynierską ([10](../../modules/10-automatyka/)) o metody stosowane w nowoczesnych układach sterowania i przetwarzania sygnałów: sterowanie optymalne od stanu (LQR) i od pomiarów (LQG), sterowanie predykcyjne z ograniczeniami (MPC), analizę i projekt odporny (funkcje wrażliwości, norma H∞), sterowanie nieliniowe (Lapunow, linearyzacja przez sprzężenie, tryb ślizgowy), identyfikację modeli z danych — oraz podstawy uczenia maszynowego zrozumiane od środka: regularyzacja i walidacja, sieci neuronowe z propagacją wsteczną, uczenie ze wzmocnieniem i uruchamianie modeli na mikrokontrolerach w arytmetyce int8. Wszystkie algorytmy są implementowane w numpy/scipy i porównywane z rozwiązaniami optymalnymi lub teorią.

## Wymagania wstępne

- [10 Automatyka](../../modules/10-automatyka/) — transmitancje, stabilność, PID, przestrzeń stanów ([10.06](../../modules/10-automatyka/06-przestrzen-stanow.md)), regulacja cyfrowa.
- [M01 Detekcja, estymacja i filtracja](../M01-estymacja-detekcja-filtracja/) — najmniejsze kwadraty, estymacja bayesowska, filtr Kalmana.
- [20 Metody numeryczne](../../modules/20-metody-numeryczne/) — optymalizacja ([20.08](../../modules/20-metody-numeryczne/08-optymalizacja-i-dopasowanie.md)), równania różniczkowe.
- [00.04 Algebra liniowa](../../modules/00-matematyka/04-algebra-liniowa.md), [21 Procesy losowe](../../modules/21-procesy-losowe-szum/).

## Tematy

| # | Temat | Czas |
|---|---|---|
| 01 | [Sterowanie optymalne: LQR i LQG](01-lqr-i-lqg.md) | 10 h |
| 02 | [Sterowanie predykcyjne (MPC)](02-sterowanie-predykcyjne-mpc.md) | 10 h |
| 03 | [Sterowanie odporne: funkcje wrażliwości i norma H∞](03-sterowanie-odporne.md) | 10 h |
| 04 | [Sterowanie nieliniowe: Lapunow, linearyzacja przez sprzężenie, tryb ślizgowy](04-sterowanie-nieliniowe.md) | 10 h |
| 05 | [Identyfikacja systemów](05-identyfikacja-systemow.md) | 8 h |
| 06 | [Uczenie maszynowe: podstawy dla inżyniera sygnałów](06-uczenie-maszynowe-podstawy.md) | 8 h |
| 07 | [Sieci neuronowe od zera: propagacja wsteczna i klasyfikacja sygnałów](07-sieci-neuronowe.md) | 10 h |
| 08 | [Uczenie ze wzmocnieniem i uczenie maszynowe na mikrokontrolerach](08-uczenie-ze-wzmocnieniem-i-ml-wbudowane.md) | 10 h |

## Test wejściowy (diagnoza)

Około 60 minut.

1. Zapisz model w przestrzeni stanów silnika DC (napięcie → prędkość) i sprawdź sterowalność.
2. Jak przejść od modelu ciągłego do dyskretnego z ekstrapolatorem zerowego rzędu?
3. Co mówi zapas fazy i jak wiąże się z przeregulowaniem?
4. Podaj estymator najmniejszych kwadratów dla $y = X\theta + e$.
5. Jaki jest gradient funkcji $f(\theta) = \lVert y - X\theta\rVert^2$?
6. Na czym polega metoda spadku gradientu i od czego zależy jej zbieżność?

<details>
<summary>Odpowiedzi</summary>

1. Np. $x = [\omega, i]$: $J\dot\omega = k_ti - b\omega$, $L\dot i = u - Ri - k_e\omega$; macierz sterowalności $[B, AB]$ ma rząd 2 (przy $k_t \neq 0$)
2. $A_d = e^{AT_s}$, $B_d = \int_0^{T_s}e^{A\tau}d\tau\,B$ (np. `scipy.signal.cont2discrete`)
3. Odległość fazy pętli od −180° przy wzmocnieniu 1 — miara odporności; mały zapas fazy (< 45°) to silne przeregulowanie i oscylacje
4. $\hat\theta = (X^TX)^{-1}X^Ty$
5. $\nabla f = -2X^T(y - X\theta)$
6. $\theta \leftarrow \theta - \eta\nabla f$; zbieżność zależy od kroku $\eta$ i uwarunkowania (stosunku skrajnych wartości własnych hesjanu) — dla funkcji kwadratowej wymagane $\eta < 2/\lambda_{\max}$

**Ocena:** 1–3 — moduł 10, tematy 01–04; 4–6 — tematy 05–07.
</details>

## Projekt modułowy: od identyfikacji do sterowania i diagnostyki

- [ ] **Obiekt:** silnik DC z enkoderem, układ „kulka na belce”, wahadło na wózku lub obiekt cieplny sterowany z mikrokontrolera ([09](../../modules/09-mikrokontrolery-embedded/)).
- [ ] **Identyfikacja (temat 05):** pobudzenie PRBS, model ARX/IV lub w przestrzeni stanów, walidacja na osobnym zapisie.
- [ ] **Sterowanie (tematy 01–03):** LQR z całkowaniem i obserwatorem (LQG), MPC z ograniczeniem napięcia/prądu; analiza $M_s$ i test odporności na zmianę obciążenia.
- [ ] **Nieliniowości (temat 04):** sterowanie ślizgowe lub kompensacja tarcia; porównanie uchybu z regulatorem liniowym.
- [ ] **Diagnostyka (tematy 06–08):** klasyfikator stanu (np. zablokowanie, zwiększone tarcie, poluzowanie) z cech prądu i prędkości; kwantyzacja int8 i uruchomienie na mikrokontrolerze; czas wnioskowania i zużycie pamięci.

## Sprawdzian końcowy modułu

- [ ] Projektuję LQR i LQG dla obiektu wielowymiarowego, dobieram wagi, rozumiem zasadę separacji i jej ograniczenia.
- [ ] Formułuję MPC jako zadanie QP z ograniczeniami, dobieram horyzont i koszt końcowy.
- [ ] Wyznaczam $S$, $T$, $M_s$, oceniam odporną stabilność, liczę normę H∞.
- [ ] Dowodzę stabilności funkcją Lapunowa, stosuję linearyzację przez sprzężenie i sterowanie ślizgowe.
- [ ] Identyfikuję modele ARX i IV, dobieram rząd i waliduję model.
- [ ] Stosuję regularyzację i walidację krzyżową, porównuję klasyfikator z optimum Bayesa.
- [ ] Implementuję MLP z propagacją wsteczną i Adamem, sprawdzam gradient.
- [ ] Stosuję Q-learning, rozumiem związek RL z programowaniem dynamicznym; kwantyzuję sieć do int8.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [K. J. Åström, R. M. Murray — Feedback Systems (wyd. 2, darmowe)](https://www.cds.caltech.edu/~murray/amwiki/Second_Edition.html) | Sprzężenie od stanu, estymatory, odporność, ograniczenia fundamentalne |
| [MIT 16.323 Principles of Optimal Control (2008)](https://ocw.mit.edu/courses/16-323-principles-of-optimal-control-spring-2008/) | LQR, LQG, programowanie dynamiczne |
| [J. B. Rawlings, D. Q. Mayne, M. M. Diehl — Model Predictive Control (darmowy PDF)](https://engineering.ucsb.edu/~jbraw/mpc/MPC-book-2nd-edition-1st-printing.pdf) | Główny podręcznik MPC |
| [MIT 6.241J Dynamic Systems and Control (2011)](https://ocw.mit.edu/courses/6-241j-dynamic-systems-and-control-spring-2011/) | Normy, odporność, stabilność w sensie Lapunowa |
| [R. Tedrake — Underactuated Robotics](https://underactuated.mit.edu/) | Sterowanie nieliniowe, LQR, optymalizacja trajektorii, Lapunow |
| [MIT 2.160 Identification, Estimation, and Learning (2006)](https://ocw.mit.edu/courses/2-160-identification-estimation-and-learning-spring-2006/) | Identyfikacja systemów |
| [MIT 6.036 Introduction to Machine Learning (2020)](https://ocw.mit.edu/courses/6-036-introduction-to-machine-learning-fall-2020/) | Podstawy uczenia maszynowego |
| [I. Goodfellow, Y. Bengio, A. Courville — Deep Learning](https://www.deeplearningbook.org) i [Dive into Deep Learning](https://d2l.ai) | Sieci neuronowe (darmowe) |
| [R. S. Sutton, A. G. Barto — Reinforcement Learning: An Introduction](http://incompleteideas.net/book/the-book.html) | Uczenie ze wzmocnieniem (darmowe) |
| [python-control](https://python-control.readthedocs.io) i [CMSIS-NN](https://github.com/ARM-software/CMSIS-NN) | Narzędzia: projekt regulatorów w Pythonie, sieci int8 na Cortex-M |
| S. Skogestad, I. Postlethwaite — *Multivariable Feedback Control* (płatna) | Sterowanie odporne wielowymiarowe |
| H. K. Khalil — *Nonlinear Systems* (płatna); L. Ljung — *System Identification* (płatna) | Sterowanie nieliniowe; identyfikacja |
