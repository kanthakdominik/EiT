# 10 — Podstawy automatyki

> **Status:** ✅ pełny

## Cel modułu

Opisywać układy dynamiczne, oceniać stabilność układów ze sprzężeniem zwrotnym i projektować proste regulatory — analogowe i cyfrowe. Ta wiedza wraca w stabilności wzmacniaczy ([04.06](../04-uklady-analogowe/06-sprzezenie-zwrotne-i-stabilnosc.md)), regulacji przetwornic (moduł [15](../15-energoelektronika-zasilanie/)), pętlach PLL (moduł [12](../12-technika-wcz-rf/)) i w każdym urządzeniu, które coś stabilizuje: temperaturę, prędkość, położenie, napięcie.

## Wymagania wstępne

- [06 Sygnały i systemy](../06-sygnaly-i-systemy/) — Laplace, transmitancja, bieguny, charakterystyki Bodego ([06.05](../06-sygnaly-i-systemy/05-transmitancja-i-bieguny.md)), transformata Z ([06.07](../06-sygnaly-i-systemy/07-czas-dyskretny-i-transformata-z.md)).
- [00.03 Równania różniczkowe](../00-matematyka/03-rownania-rozniczkowe.md), [00.04 Algebra liniowa](../00-matematyka/04-algebra-liniowa.md) — dla przestrzeni stanów.
- [09 Mikrokontrolery](../09-mikrokontrolery-embedded/) — dla implementacji regulatora cyfrowego.

## Tematy

| # | Temat | Czas (od zera / odświeżenie) |
|---|---|---|
| 01 | [Modele obiektów i schematy blokowe](01-modele-obiektow.md) | 8 h / 2 h |
| 02 | [Odpowiedzi czasowe i uchyb ustalony](02-odpowiedzi-czasowe-i-uchyb.md) | 6 h / 2 h |
| 03 | [Stabilność: Routh, Nyquist, zapasy](03-stabilnosc.md) | 10 h / 3 h |
| 04 | [Linie pierwiastkowe](04-linie-pierwiastkowe.md) | 6 h / 2 h |
| 05 | [Regulatory PID i dobór nastaw](05-regulatory-pid.md) | 10 h / 3 h |
| 06 | [Przestrzeń stanów](06-przestrzen-stanow.md) | 10 h / 3 h |
| 07 | [Regulacja cyfrowa](07-regulacja-cyfrowa.md) | 8 h / 3 h |
| 08 | [Zastosowania w elektronice: zasilacze, PLL, silniki, temperatura](08-zastosowania-w-elektronice.md) | 6 h / 2 h |

Kod w tym module korzysta z `numpy`, `scipy.signal` i `matplotlib`. Biblioteka [python-control](https://python-control.readthedocs.io/en/latest/intro.html) ma wygodniejsze funkcje (`margin`, `root_locus`, `feedback`) i warto ją zainstalować, ale przykłady jej nie wymagają.

## Test wejściowy (diagnoza)

Około 60 minut, bez notatek.

1. Obiekt $G(s) = \dfrac{2}{100s + 1}$. Jakie są wzmocnienie statyczne i stała czasowa? Po jakim czasie odpowiedź skokowa osiąga 63% wartości ustalonej?
2. Układ drugiego rzędu ma $\zeta = 0\text{,}5$, $\omega_n = 10$ rad/s. Oszacuj przeregulowanie i czas ustalania (2%).
3. Pętla otwarta $L(s) = \dfrac{K}{(s+1)^3}$ w układzie z ujemnym sprzężeniem. Dla jakich $K$ układ zamknięty jest stabilny?
4. Ten sam układ przy $K = 4$: zapas fazy i zapas wzmocnienia?
5. Dlaczego regulator P nie usuwa uchybu ustalonego dla obiektu inercyjnego, a regulator PI usuwa?
6. Co to jest nasycenie całki (windup) i jak mu zapobiec?
7. Regulator cyfrowy pracuje z okresem 10 ms, pasmo pętli 10 rad/s. Ile fazy „zabiera” próbkowanie z ekstrapolatorem zerowego rzędu?

<details>
<summary>Odpowiedzi</summary>

1. $K = 2$, $\tau = 100$ s; po 100 s
2. $M_p = e^{-\pi\zeta/\sqrt{1-\zeta^2}} \approx 16\text{,}3\%$; $t_s \approx 4/(\zeta\omega_n) = 0\text{,}8$ s
3. Równanie charakterystyczne $s^3 + 3s^2 + 3s + 1 + K = 0$; Routh: $0 < K < 8$ (dla $K > -1$ zgodnie z warunkiem $1+K>0$)
4. $\omega_c \approx 1\text{,}23$ rad/s, PM ≈ 27°; $\omega_{180} = \sqrt 3$, GM = $8/4$ → 6 dB
5. Uchyb ustalony dla P: $e_{ss} = 1/(1 + K_pK)$ — do wytworzenia niezerowego sterowania potrzebny jest niezerowy uchyb. Całka narasta, dopóki uchyb jest różny od zera, więc w stanie ustalonym uchyb musi być zerowy
6. Przy nasyconym elemencie wykonawczym całka dalej rośnie, a po powrocie do zakresu liniowego trzeba ją długo „rozładowywać” — duże przeregulowanie. Zapobieganie: całkowanie warunkowe, ograniczenie całki, sprzężenie zwrotne od różnicy sterowania obliczonego i nasyconego (back-calculation)
7. Opóźnienie ok. $T/2$: $\omega T/2 = 0\text{,}05$ rad ≈ 2,9°

**Ocena:** 1–2 — tematy 01–02; 3–4 — 03; 5–6 — 05; 7 — 07.
</details>

## Projekt modułowy: regulacja temperatury

- [ ] Układ: rezystor mocy (grzałka, sterowana PWM przez MOSFET — [09.08](../09-mikrokontrolery-embedded/08-sprzet-wokol-mcu.md)) przyklejony do radiatora lub bloczka aluminium, czujnik temperatury (NTC lub cyfrowy) — [08.06](../08-miernictwo/06-czujniki-i-tor-pomiarowy.md).
- [ ] **Identyfikacja:** skok mocy w pętli otwartej, zapis przebiegu temperatury, dopasowanie modelu inercyjnego z opóźnieniem $K e^{-Ls}/(\tau s + 1)$ (temat 01).
- [ ] **Projekt:** dobór nastaw PI (temat 05), symulacja z nasyceniem mocy i anti-windup; porównanie z dwiema innymi metodami doboru.
- [ ] **Implementacja:** regulator cyfrowy w C na mikrokontrolerze (temat 07), okres próbkowania uzasadniony obliczeniem.
- [ ] **Weryfikacja:** skok wartości zadanej i zakłócenie (np. wentylator) — porównanie pomiaru z symulacją; raport z wykresami.

## Sprawdzian końcowy modułu

- [ ] Wyznaczam transmitancję zastępczą złożonego schematu blokowego.
- [ ] Wyznaczam model obiektu z odpowiedzi skokowej.
- [ ] Łączę położenie biegunów z przeregulowaniem, czasem ustalania i tłumieniem.
- [ ] Oceniam stabilność kryterium Routha i z charakterystyk Bodego/Nyquista pętli otwartej, odczytuję zapasy.
- [ ] Dobieram nastawy PID, rozumiem wpływ każdego członu, stosuję filtr różniczkowania i anti-windup.
- [ ] Projektuję sprzężenie od stanu metodą lokowania biegunów i rozumiem rolę obserwatora.
- [ ] Implementuję regulator cyfrowy i dobieram okres próbkowania.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [Feedback Systems — K. J. Åström, R. M. Murray (2nd ed., darmowy PDF)](https://www.cds.caltech.edu/~murray/amwiki/Second_Edition.html) | Główny podręcznik modułu: modele, stabilność, PID, przestrzeń stanów, odporność |
| [MIT 6.302 Feedback Systems (2007)](https://ocw.mit.edu/courses/6-302-feedback-systems-spring-2007/) | Kurs sprzężenia zwrotnego z perspektywy elektroniki (wzmacniacze, kompensacja) |
| [MIT 6.003 Signals and Systems (2011)](https://ocw.mit.edu/courses/6-003-signals-and-systems-fall-2011/) | Sprzężenie zwrotne i bieguny w ujęciu sygnałów i systemów |
| [MIT RES.6-007 Signals and Systems (Oppenheim)](https://ocw.mit.edu/courses/res-6-007-signals-and-systems-spring-2011/) | Wykłady o sprzężeniu zwrotnym i linii pierwiastkowej |
| [python-control — dokumentacja](https://python-control.readthedocs.io/en/latest/intro.html) | Narzędzie do analizy i projektowania w Pythonie |
| [Steve Brunton — Control Bootcamp (YouTube)](https://www.youtube.com/results?search_query=Steve+Brunton+Control+Bootcamp) | Przestrzeń stanów, sterowalność, LQR, obserwatory — krótkie wykłady |
| [Brian Douglas — Control Systems Lectures (YouTube)](https://www.youtube.com/results?search_query=Brian+Douglas+Control+System+Lectures) | Intuicyjne wyjaśnienia: Bode, Nyquist, linie pierwiastkowe, PID |
