# 04 — Układy analogowe

> **Status:** ✅ pełny

## Cel modułu

Analizować i projektować podstawowe bloki analogowe: układy z diodami, wzmacniacze tranzystorowe, wzmacniacze operacyjne, filtry aktywne, generatory i stabilizatory. Po tym module potrafisz zaprojektować tor sygnałowy od czujnika do przetwornika A/C i sprawdzić go symulacją.

## Wymagania wstępne

- [01 Teoria obwodów](../01-teoria-obwodow/) — zwłaszcza Thévenin, AC, charakterystyki częstotliwościowe, Bode.
- [03 Przyrządy półprzewodnikowe](../03-przyrzady-polprzewodnikowe/) — modele diody, BJT i MOSFET-a.

## Tematy

| # | Temat | Czas (od zera / odświeżenie) |
|---|---|---|
| 01 | [Układy z diodami: prostowniki, ograniczniki, stabilizator Zenera](01-uklady-z-diodami.md) | 8 h / 2 h |
| 02 | [Polaryzacja tranzystorów i punkt pracy](02-polaryzacja-tranzystorow.md) | 8 h / 2 h |
| 03 | [Wzmacniacze jednotranzystorowe i ich pasmo](03-wzmacniacze-jednotranzystorowe.md) | 14 h / 4 h |
| 04 | [Wzmacniacz różnicowy i lustra prądowe](04-wzmacniacz-roznicowy-i-lustra.md) | 8 h / 3 h |
| 05 | [Stopnie wyjściowe](05-stopnie-wyjsciowe.md) | 6 h / 2 h |
| 06 | [Sprzężenie zwrotne i stabilność](06-sprzezenie-zwrotne-i-stabilnosc.md) | 10 h / 3 h |
| 07 | [Wzmacniacz operacyjny — układy podstawowe](07-wzmacniacz-operacyjny-idealny.md) | 10 h / 3 h |
| 08 | [Wzmacniacz operacyjny — parametry rzeczywiste](08-wzmacniacz-operacyjny-rzeczywisty.md) | 8 h / 3 h |
| 09 | [Filtry aktywne](09-filtry-aktywne.md) | 10 h / 3 h |
| 10 | [Komparatory i generatory](10-komparatory-i-generatory.md) | 8 h / 3 h |
| 11 | [Stabilizatory liniowe](11-stabilizatory.md) | 6 h / 2 h |

## Test wejściowy (diagnoza)

Około 90 minut, bez notatek. $U_T = 25{,}85$ mV, $U_{BE} = 0{,}7$ V.

1. Transformator 12 V (skuteczne), mostek Graetza, kondensator 2200 µF, obciążenie 0,5 A, sieć 50 Hz. Ile wynosi napięcie szczytowe i tętnienia?
2. Wzmacniacz WE: $V_{CC} = 12$ V, $R_1 = 47$ kΩ, $R_2 = 10$ kΩ, $R_C = 4{,}7$ kΩ, $R_E = 1$ kΩ (zablokowany kondensatorem), $\beta = 100$. Wyznacz punkt pracy i wzmocnienie napięciowe.
3. Wzmacniacz odwracający na wzmacniaczu operacyjnym: $R_1 = 10$ kΩ, $R_2 = 100$ kΩ. Wzmocnienie i rezystancja wejściowa?
4. Wzmacniacz operacyjny ma GBW = 1 MHz. Jakie pasmo ma wzmacniacz nieodwracający o wzmocnieniu 10?
5. Slew rate wynosi 0,5 V/µs. Do jakiej częstotliwości wzmacniacz odda sinusoidę o amplitudzie 10 V bez zniekształceń?
6. Zaprojektuj filtr dolnoprzepustowy Sallen–Key Butterwortha (wzmocnienie 1) o $f_0 = 1$ kHz z $R_1 = R_2 = 10$ kΩ.
7. Stabilizator liniowy 12 V → 5 V, 0,5 A. Ile mocy rozprasza i jaka jest sprawność?

<details>
<summary>Odpowiedzi</summary>

1. $U_{pk} \approx 12\sqrt2 - 1{,}4 \approx 15{,}6$ V; tętnienia $\Delta U \approx \dfrac{I}{2fC} \approx 2{,}3$ V
2. $I_C \approx 1{,}29$ mA, $U_{CE} \approx 4{,}66$ V; $K_u = -g_mR_C \approx -234$
3. −10, 10 kΩ
4. 100 kHz
5. $f = \dfrac{SR}{2\pi U_{pk}} \approx 8$ kHz
6. $C_2 \approx 11{,}3$ nF (do masy), $C_1 = 2C_2 \approx 22{,}5$ nF (do wyjścia)
7. 3,5 W, ok. 42%

**Ocena:** zadanie 1 — temat 01; 2 — tematy 02–03; 3 — temat 07; 4–5 — temat 08; 6 — temat 09; 7 — temat 11.
</details>

## Projekt modułowy: tor kondycjonowania sygnału z czujnika

Wymagania: czujnik daje sygnał różnicowy 0–10 mV na tle napięcia wspólnego 2,5 V, pasmo użyteczne do 100 Hz. Wyjście ma sterować wejściem przetwornika A/C 0–3,3 V próbkującego z częstotliwością 1 kHz.

- [ ] Dobierz wzmocnienie i zaprojektuj wzmacniacz pomiarowy (3 wzmacniacze operacyjne lub układ scalony).
- [ ] Zaprojektuj filtr antyaliasingowy (Sallen–Key, Butterworth 2. lub 4. rzędu). Uzasadnij rząd tłumieniem przy 500 Hz.
- [ ] Dodaj przesunięcie poziomu i bufor dla wejścia A/C, z zasilaniem pojedynczym 3,3 V.
- [ ] Oszacuj błąd offsetu i szumu na wyjściu (dla wybranego modelu wzmacniacza).
- [ ] Zasymuluj w LTspice: `.ac` (charakterystyka), `.tran` (odpowiedź na sygnał z zakłóceniem 50 Hz w trybie wspólnym), `.noise`.
- [ ] Jeśli masz sprzęt: zbuduj układ na płytce stykowej i zmierz charakterystykę i CMRR.

## Sprawdzian końcowy modułu

- [ ] Projektuję zasilacz z prostownikiem i filtrem pojemnościowym oraz dobieram diody.
- [ ] Ustalam punkt pracy wzmacniacza tranzystorowego niezależny od rozrzutu $\beta$.
- [ ] Wyznaczam wzmocnienie, rezystancje wejściową i wyjściową oraz pasmo wzmacniacza jednotranzystorowego.
- [ ] Oceniam stabilność układu ze sprzężeniem zwrotnym z wykresu Bodego pętli.
- [ ] Projektuję układy na wzmacniaczach operacyjnych z uwzględnieniem GBW, SR, offsetu i szumu.
- [ ] Projektuję filtr aktywny o zadanej charakterystyce.
- [ ] Projektuję generator i układ z komparatorem z histerezą.
- [ ] Dobieram stabilizator liniowy i radiator.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [Operational Amplifiers & Linear Integrated Circuits — J. M. Fiore](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html) | Tematy 06–11: wzmacniacze operacyjne, filtry, generatory, stabilizatory |
| [Semiconductor Devices — J. M. Fiore](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html) | Tematy 01–05: układy z diodami, wzmacniacze tranzystorowe |
| [Analog Devices — Electronics I and II](https://wiki.analog.com/university/courses/electronics/text/electronics-toc) | Cały moduł + ćwiczenia laboratoryjne |
| [MIT 6.002 Circuits and Electronics](https://ocw.mit.edu/courses/6-002-circuits-and-electronics-spring-2007/) | Wzmacniacze, model małosygnałowy, wzmacniacz operacyjny, sprzężenie dodatnie |
| [MIT 6.012 Microelectronic Devices and Circuits](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-spring-2009/) | Tematy 03–05: wzmacniacze wielostopniowe, lustra, odpowiedź częstotliwościowa |
| [Ultimate Electronics](https://ultimateelectronicsbook.com/) | Interaktywne symulacje układów |
| [Falstad — demonstracje](https://falstad.com/circuit/e-index.html) | Diody, wzmacniacze operacyjne, tranzystory, układ 555 |
